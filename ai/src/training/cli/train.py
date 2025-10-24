import argparse, time
from pathlib import Path

import torch
import torch.nn as nn
from torch.utils.data import DataLoader

from ai.src.training.config import load_cfg
from ai.src.training.utils.seed import set_seed
from ai.src.training.utils.device import device_from_cfg
from ai.src.training.utils.io import ensure_parent, save_best
from ai.src.training.utils.logging import CSVLogger

from ai.src.training.data.datasets import make_datasets
from ai.src.training.data.sampler import make_weighted_sampler_from_h5, class_weights_from_h5
from ai.src.training.data.prefetch import maybe_wrap_prefetch

from ai.src.training.modeling.factory import build_model
from ai.src.training.engine.schedulers import WarmupCosine
from ai.src.training.engine.validate import validate
from ai.src.training.engine.train_epoch import train_one_epoch


def main(cfg_path: str):
    cfg = load_cfg(cfg_path)

    seed_val = int(cfg.get("seed", 42))
    set_seed(seed_val)

    # ---------- Data ----------
    h5_path = cfg["data"]["hdf5_path"]
    img_size = int(cfg["data"]["img_size"])
    num_workers = int(cfg["data"].get("num_workers", 0))
    prefetch_factor = int(cfg["data"].get("prefetch_factor", 2))
    use_cuda_prefetch = bool(cfg["data"].get("cuda_prefetch", True))

    train_ds, val_ds, classes = make_datasets(h5_path, img_size, seed=seed_val)
    num_classes = len(classes) if classes is not None else None

    device = device_from_cfg(cfg)
    pin = device.type == "cuda"

    # optional weighted sampler
    tr_cfg = cfg["train"]
    use_weighted = bool(tr_cfg.get("use_weighted_sampler", False))
    sampler = None
    shuffle = True
    if use_weighted:
        try:
            sampler = make_weighted_sampler_from_h5(h5_path, train_ds)
            shuffle = False
            print("[train] Using class-balanced WeightedRandomSampler")
        except Exception as e:
            print(f"[train] Weighted sampler unavailable: {e}; falling back to shuffle=True")

    train_loader = DataLoader(
        train_ds,
        batch_size=int(tr_cfg["batch_size"]),
        shuffle=shuffle if sampler is None else False,
        sampler=sampler,
        num_workers=num_workers,
        pin_memory=pin,
        drop_last=False,
        persistent_workers=False,
        prefetch_factor=prefetch_factor if num_workers > 0 else None,
    )
    val_loader = DataLoader(
        val_ds,
        batch_size=int(tr_cfg.get("val_batch_size", tr_cfg["batch_size"])),
        shuffle=False,
        num_workers=num_workers,
        pin_memory=pin,
        drop_last=False,
        persistent_workers=False,
        prefetch_factor=prefetch_factor if num_workers > 0 else None,
    )

    # ---------- Model ----------
    model = build_model(tr_cfg["model_name"], num_classes).to(device)
    if device.type == "cuda":
        model = model.to(memory_format=torch.channels_last)

    if bool(tr_cfg.get("grad_checkpoint", False)):
        try:
            model.set_grad_checkpointing(True)
            print("[train] Gradient checkpointing enabled")
        except Exception as e:
            print(f"[train] Model does not support checkpointing: {e}")

    # ---------- Optim, loss, sched ----------
    lr = float(tr_cfg["lr"])
    weight_decay = float(tr_cfg["weight_decay"])
    label_smoothing = float(tr_cfg.get("label_smoothing", 0.0))
    criterion: nn.Module

    split = getattr(train_ds, "split", "train")
    indices = getattr(train_ds, "indices", None)
    cw = class_weights_from_h5(
        h5_path,
        split=split,
        indices=indices,
        expected_num_classes=num_classes,
        device=device,
    )
    if cw is not None and cw.numel() == num_classes:
        criterion = nn.CrossEntropyLoss(weight=cw, label_smoothing=label_smoothing)
        print("[train] Using class-weighted CrossEntropyLoss")
    else:
        criterion = nn.CrossEntropyLoss(label_smoothing=label_smoothing)

    optim = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
    epochs = int(tr_cfg["epochs"])
    warmup_epochs = int(tr_cfg.get("warmup_epochs", 3))
    sched = WarmupCosine(optim, warmup_epochs=warmup_epochs, total_epochs=epochs, min_lr=1e-6)

    # ---------- AMP ----------
    use_amp = device.type == "cuda"
    scaler = torch.amp.GradScaler("cuda") if use_amp else None

    # ---------- Paths ----------
    out_best = Path(cfg.get("paths", {}).get("best_ckpt", "ai/models/best.pt"))
    out_last = Path(cfg.get("paths", {}).get("last_ckpt", "ai/models/last.pt"))
    ensure_parent(out_last)

    # ---------- Train loop ----------
    patience = int(tr_cfg.get("early_stop_patience", 5))
    accumulate = int(tr_cfg.get("accumulate_steps", 1))
    max_steps = tr_cfg.get("max_steps_per_epoch", None)
    max_steps = int(max_steps) if max_steps is not None else None
    val_max_batches = tr_cfg.get("val_max_batches", None)
    val_max_batches = int(val_max_batches) if val_max_batches is not None else None
    mixup_alpha = float(tr_cfg.get("mixup_alpha", 0.2))
    max_grad_norm = float(tr_cfg.get("max_grad_norm", 1.0))

    run_dir = Path("ai/experiments") / time.strftime("run_%Y%m%d_%H%M%S")
    logger = CSVLogger(run_dir)

    best_f1, no_improv = -1.0, 0
    try:
        for epoch in range(1, epochs + 1):
            t0 = time.time()
            tr_loss = train_one_epoch(
                model, train_loader, device, optim, criterion,
                scaler, use_amp, max_grad_norm, use_cuda_prefetch,
                num_classes=num_classes, mixup_alpha=mixup_alpha,
                max_steps=max_steps, accumulate_steps=accumulate
            )
            va_loss, va_f1 = validate(
                model,
                maybe_wrap_prefetch(val_loader, device, enable=False),
                device,
                criterion,
                max_batches=val_max_batches,
            )
            sched.step()
            dt = time.time() - t0
            print(f"Epoch {epoch:03d}/{epochs} | {dt:.1f}s  train_loss={tr_loss:.4f}  val_loss={va_loss:.4f}  macroF1={va_f1:.4f}")

            torch.save(model.state_dict(), out_last)
            if va_f1 > best_f1:
                best_f1 = va_f1
                save_best(out_best, model, classes)
                print(f"  ✔ New best F1={best_f1:.4f} → {out_best}")
                no_improv = 0
            else:
                no_improv += 1

            current_lr = next(iter(optim.param_groups))["lr"]
            logger.log(epoch, tr_loss, va_loss, va_f1, current_lr, dt)

            if no_improv >= patience:
                print(f"Early stopping after {patience} epochs without improvement.")
                break
    finally:
        logger.close()
        print("Metrics CSV →", run_dir / "metrics.csv")

    # Save class names for inference pipelines
    classes = classes or []
    cls_txt = Path("ai/models/classes.txt")
    ensure_parent(cls_txt)
    cls_txt.write_text("\n".join(classes), encoding="utf-8")
    print("Saved classes list →", cls_txt)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    args = ap.parse_args()
    main(args.config)
