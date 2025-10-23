# ai/src/train.py
import argparse
import os
import time
from pathlib import Path
from typing import Dict, Any, Tuple, Optional, List

import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, random_split, WeightedRandomSampler
from sklearn.metrics import f1_score
from tqdm import tqdm

import timm
import yaml
import h5py

# ---- Albumentations (keep version-friendly)
from albumentations import (
    Compose, Resize, CenterCrop, HorizontalFlip, Normalize,
    RandomResizedCrop, ShiftScaleRotate, RGBShift, HueSaturationValue
)
from albumentations.pytorch import ToTensorV2

from ai.src.cuda_prefetcher import CUDAPrefetcher

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

# ====================== Transforms ======================
def train_transforms(img_size: int):
    return Compose([
        RandomResizedCrop(size=(img_size, img_size), scale=(0.6, 1.0), ratio=(0.75, 1.33)),
        HorizontalFlip(p=0.5),
        ShiftScaleRotate(shift_limit=0.02, scale_limit=0.15, rotate_limit=20, p=0.5, border_mode=0),
        HueSaturationValue(p=0.2),
        RGBShift(p=0.2),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])

def val_transforms(img_size: int):
    return Compose([
        Resize(height=img_size, width=img_size),
        CenterCrop(height=img_size, width=img_size),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])

# ====================== Utils ======================
def load_cfg(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def ensure_parent(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)

def set_seed(seed: int = 42):
    import random
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.backends.cudnn.deterministic = False
    torch.backends.cudnn.benchmark = True

def device_from_cfg(cfg: Dict[str, Any]) -> torch.device:
    want = cfg["train"].get("device", "cuda")
    if want == "cuda" and torch.cuda.is_available():
        return torch.device("cuda")
    return torch.device("cpu")

def build_model(model_name: str, num_classes: int) -> nn.Module:
    return timm.create_model(model_name, pretrained=True, num_classes=num_classes)

def save_best(ckpt_path: Path, model: nn.Module, classes):
    ensure_parent(ckpt_path)
    torch.save({"model": model.state_dict(), "classes": classes}, ckpt_path)

class CSVLogger:
    def __init__(self, out_dir: Path):
        self.out_dir = out_dir
        self.out_dir.mkdir(parents=True, exist_ok=True)
        self.fp = open(self.out_dir / "metrics.csv", "w", encoding="utf-8")
        self.fp.write("epoch,train_loss,val_loss,macro_f1,lr,seconds\n")
        self.fp.flush()
    def log(self, epoch, train_loss, val_loss, macro_f1, lr, seconds):
        self.fp.write(f"{epoch},{train_loss:.6f},{val_loss:.6f},{macro_f1:.6f},{lr:.8f},{seconds:.2f}\n")
        self.fp.flush()
    def close(self):
        try:
            self.fp.close()
        except Exception:
            pass

# ====================== Schedulers ======================
class WarmupCosine(torch.optim.lr_scheduler._LRScheduler):
    def __init__(self, optimizer, warmup_epochs, total_epochs, min_lr=1e-6, last_epoch=-1):
        self.warmup_epochs = int(warmup_epochs)
        self.total_epochs = int(total_epochs)
        self.min_lr = float(min_lr)
        super().__init__(optimizer, last_epoch)

    def get_lr(self):
        e = max(0, self.last_epoch)
        lrs = []
        for base_lr in self.base_lrs:
            if e < self.warmup_epochs:
                lrs.append(base_lr * (e + 1) / max(1, self.warmup_epochs))
            else:
                t = (e - self.warmup_epochs) / max(1, self.total_epochs - self.warmup_epochs)
                lr = self.min_lr + 0.5 * (base_lr - self.min_lr) * (1 + np.cos(np.pi * t))
                lrs.append(lr)
        return lrs

# ====================== HDF5 helpers ======================
def _h5_labels(h5_path: str, split: str = "train", indices=None):
    with h5py.File(h5_path, "r") as h5:
        key = f"{split}/labels"
        if key not in h5:
            raise RuntimeError(f"'{key}' not found in {h5_path}")
        arr = h5[key][:]
    if indices is not None:
        arr = arr[indices]
    return arr.astype(np.int64)

def make_weighted_sampler_from_h5(h5_path: str, ds) -> WeightedRandomSampler:
    split = getattr(ds, "split", "train")
    indices = None
    if hasattr(ds, "indices") and hasattr(ds, "dataset"):
        split = getattr(ds.dataset, "split", split)
        indices = ds.indices
    labels = _h5_labels(h5_path, split=split, indices=indices)
    # compact labels for counting
    _, inv = np.unique(labels, return_inverse=True)
    counts = np.bincount(inv).astype(np.float64)
    counts[counts == 0] = 1.0
    cls_w = 1.0 / counts
    sample_w = cls_w[inv]
    return WeightedRandomSampler(
        weights=torch.from_numpy(sample_w).double(),
        num_samples=len(sample_w),
        replacement=True
    )

def class_weights_from_h5(
    h5_path: str,
    split: str = "train",
    indices=None,
    expected_num_classes: Optional[int] = None,
    normalize: bool = True,
    device: str = "cpu",
):
    """
    Build class weights robustly even if labels are sparse/non-contiguous.
    Returns a tensor of shape [expected_num_classes] if possible; otherwise None (fallback to unweighted CE).
    """
    with h5py.File(h5_path, "r") as h5:
        key = f"{split}/labels"
        if key not in h5:
            raise RuntimeError(f"'{key}' not found in {h5_path}")
        y = h5[key][:]
    if indices is not None:
        y = y[indices]
    y = y.astype(np.int64)
    if y.size == 0:
        return None

    uniq, inv = np.unique(y, return_inverse=True)
    counts = np.bincount(inv).astype(np.float64)  # length K (unique labels in this split)
    if expected_num_classes is not None and counts.shape[0] != int(expected_num_classes):
        print(
            f"[class_weights_from_h5] Mismatch: got {counts.shape[0]} unique labels, "
            f"expected {expected_num_classes}. Falling back to unweighted CE."
        )
        return None

    counts[counts == 0] = 1.0
    w = 1.0 / counts
    if normalize:
        w = w / w.mean()
    return torch.tensor(w, dtype=torch.float32, device=device)

# ====================== MixUp ======================
def do_mixup(x, y, num_classes: int, alpha: float = 0.2):
    if alpha <= 0:
        return x, y, None
    lam = np.random.beta(alpha, alpha)
    idx = torch.randperm(x.size(0), device=x.device)
    mixed_x = lam * x + (1 - lam) * x[idx]
    y1 = torch.nn.functional.one_hot(y, num_classes=num_classes).float()
    y2 = y1[idx]
    target = (y1, y2, lam)
    return mixed_x, y, target

def mixup_loss(logits, target):
    y1, y2, lam = target
    return lam * torch.nn.functional.cross_entropy(logits, y1.argmax(1)) + \
           (1 - lam) * torch.nn.functional.cross_entropy(logits, y2.argmax(1))

# ====================== Dataset factory ======================
def make_datasets(h5_path: str, img_size: int, seed: int = 42):
    """
    If HDF5 has train/ and val/, use them.
    If only train/ exists, split 90/10 into (train, val).
    Auto-detect pixels vs encoded_bytes loaders.
    """
    with h5py.File(h5_path, "r") as h5:
        groups = set(h5.keys())
        storage = h5.attrs.get("storage", "pixels")

    if storage == "encoded_bytes":
        from ai.src.hdf5_dataset_bytes import H5BytesClassificationDataset as DS
    else:
        from ai.src.hdf5_dataset import H5ClassificationDataset as DS

    if "train" not in groups:
        raise RuntimeError(f"No 'train' split in {h5_path}. Found groups: {groups}")

    if "val" in groups:
        tr = DS(h5_path, "train", atransforms=train_transforms(img_size))
        va = DS(h5_path, "val",   atransforms=val_transforms(img_size))
        classes = getattr(tr, "class_names", None)
        return tr, va, classes

    # only train -> random split
    full = DS(h5_path, "train", atransforms=train_transforms(img_size))
    n = len(full)
    n_val = max(1, int(0.10 * n))
    n_tr  = n - n_val
    g = torch.Generator().manual_seed(seed)
    tr_subset, va_subset = random_split(full, [n_tr, n_val], generator=g)
    classes = getattr(full, "class_names", None)
    tr_subset.class_names = classes
    va_subset.class_names = classes
    return tr_subset, va_subset, classes

# ====================== Eval (fast & capped) ======================
@torch.inference_mode()
def validate(
    model: nn.Module,
    loader,
    device: torch.device,
    criterion: nn.Module,
    max_batches: Optional[int] = None
) -> Tuple[float, float]:
    model.eval()
    total_loss = 0.0
    preds, gts = [], []

    seen = 0
    for bi, batch in enumerate(loader, 1):
        if isinstance(batch, (tuple, list)) and len(batch) == 2:
            x, y = batch
        else:
            x, y = batch

        x = x.to(device, non_blocking=True)
        y = y.to(device, non_blocking=True)
        if device.type == "cuda" and x.ndim == 4:
            x = x.to(memory_format=torch.channels_last)

        logits = model(x)
        loss = criterion(logits, y)
        total_loss += loss.item() * x.size(0)
        preds.extend(logits.argmax(1).detach().cpu().tolist())
        gts.extend(y.detach().cpu().tolist())

        seen += x.size(0)
        if max_batches is not None and bi >= max_batches:
            break

    denom = seen if seen > 0 else len(loader.dataset)
    avg_loss = total_loss / max(1, denom)
    macro_f1 = f1_score(gts, preds, average="macro") if len(set(gts)) > 1 else 0.0
    return avg_loss, macro_f1

def maybe_wrap_prefetch(loader, device, enable: bool):
    if device.type == "cuda" and enable:
        return CUDAPrefetcher(loader, device)
    return loader

# ====================== Train ======================
def train_one_epoch(
    model, loader, device, optimizer, criterion,
    scaler: Optional[torch.amp.GradScaler],
    use_amp: bool, max_grad_norm: Optional[float],
    use_prefetch: bool, num_classes: int,
    mixup_alpha: float = 0.2,
    max_steps: Optional[int] = None,
    accumulate_steps: int = 1
):
    model.train()
    running = 0.0
    wrapped = maybe_wrap_prefetch(loader, device, use_prefetch)
    pbar = tqdm(wrapped, desc="train", leave=False)
    optimizer.zero_grad(set_to_none=True)

    steps = 0
    for batch in pbar:
        if isinstance(wrapped, CUDAPrefetcher):
            x, y = batch  # already on GPU, channels_last
        else:
            x, y = batch
            x = x.to(device, non_blocking=True)
            y = y.to(device, non_blocking=True)
            if device.type == "cuda" and x.ndim == 4:
                x = x.to(memory_format=torch.channels_last)

        # MixUp
        xm, y_raw, mix = do_mixup(x, y, num_classes, alpha=mixup_alpha)

        if use_amp:
            with torch.amp.autocast("cuda"):
                logits = model(xm)
                loss = mixup_loss(logits, mix) if mix is not None else criterion(logits, y_raw)
            loss = loss / max(1, accumulate_steps)
            scaler.scale(loss).backward()
            if (steps + 1) % accumulate_steps == 0:
                if max_grad_norm is not None:
                    scaler.unscale_(optimizer)
                    nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm)
                scaler.step(optimizer)
                scaler.update()
                optimizer.zero_grad(set_to_none=True)
        else:
            logits = model(xm)
            loss = mixup_loss(logits, mix) if mix is not None else criterion(logits, y_raw)
            loss = loss / max(1, accumulate_steps)
            loss.backward()
            if (steps + 1) % accumulate_steps == 0:
                if max_grad_norm is not None:
                    nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm)
                optimizer.step()
                optimizer.zero_grad(set_to_none=True)

        running += (loss.item() * max(1, accumulate_steps)) * x.size(0)
        pbar.set_postfix(loss=f"{(loss.item() * max(1, accumulate_steps)):.4f}")
        steps += 1
        if max_steps is not None and steps >= max_steps:
            break

    denom = min(len(loader.dataset), steps * loader.batch_size) or 1
    return running / denom

# ====================== Main ======================
def main(cfg_path: str):
    cfg = load_cfg(cfg_path)
    seed_val = int(cfg.get("seed", 42))
    set_seed(seed_val)

    # data cfg
    if not bool(cfg.get("data", {}).get("use_hdf5", True)):
        raise RuntimeError("Set data.use_hdf5: true and provide data.hdf5_path.")
    img_size      = int(cfg["data"]["img_size"])
    num_workers   = int(cfg["data"].get("num_workers", 0))   # HDF5 safest on WSL: 0
    prefetch      = int(cfg["data"].get("prefetch_factor", 2))
    h5_path       = cfg["data"]["hdf5_path"]
    use_prefetch  = bool(cfg["data"].get("cuda_prefetch", True))

    # training cfg
    train_cfg       = cfg["train"]
    batch_size      = int(train_cfg["batch_size"])
    epochs          = int(train_cfg["epochs"])
    lr              = float(train_cfg["lr"])
    weight_decay    = float(train_cfg["weight_decay"])
    label_smooth    = float(train_cfg.get("label_smoothing", 0.0))
    max_grad_norm   = float(train_cfg.get("max_grad_norm", 1.0))
    warmup_epochs   = int(train_cfg.get("warmup_epochs", 3))
    mixup_alpha     = float(train_cfg.get("mixup_alpha", 0.2))
    use_weighted_sampler = bool(train_cfg.get("use_weighted_sampler", False))
    grad_checkpoint = bool(train_cfg.get("grad_checkpoint", False))
    accumulate_steps = int(train_cfg.get("accumulate_steps", 1))
    max_steps_per_epoch = train_cfg.get("max_steps_per_epoch", None)
    if max_steps_per_epoch is not None:
        max_steps_per_epoch = int(max_steps_per_epoch)
    # NEW: separate val loader knobs
    val_batch_size  = int(train_cfg.get("val_batch_size", batch_size))
    val_max_batches = train_cfg.get("val_max_batches", None)
    if val_max_batches is not None:
        val_max_batches = int(val_max_batches)

    # datasets & loaders
    train_ds, val_ds, classes = make_datasets(h5_path, img_size, seed=seed_val)
    num_classes = len(classes) if classes is not None else None

    # device
    device = device_from_cfg(cfg)
    print(f"CUDA available: {torch.cuda.is_available()} | Selected device: {device}")
    if device.type == "cuda":
        print(f"GPU: {torch.cuda.get_device_name(0)} | CUDA: {torch.version.cuda}")
        frac = float(os.getenv("CUDA_VRAM_FRAC", "0.90"))
        try:
            torch.cuda.set_per_process_memory_fraction(frac)
            print(f"VRAM cap set to {int(frac*100)}%")
        except Exception as e:
            print(f"VRAM cap not set: {e}")

    pin = (device.type == "cuda")

    # sampler
    sampler = None
    shuffle = True
    if use_weighted_sampler:
        try:
            sampler = make_weighted_sampler_from_h5(h5_path, train_ds)
            shuffle = False
            print("Using WeightedRandomSampler (HDF5 labels).")
        except Exception as e:
            print(f"Weighted sampler unavailable ({e}); falling back to shuffle=True.")

    train_loader = DataLoader(
        train_ds,
        batch_size=batch_size,
        shuffle=shuffle if sampler is None else False,
        sampler=sampler,
        num_workers=num_workers,
        pin_memory=pin,
        drop_last=False,
        persistent_workers=False,
        prefetch_factor=prefetch if num_workers > 0 else None
    )
    val_loader = DataLoader(
        val_ds,
        batch_size=val_batch_size,   # separate val batch
        shuffle=False,
        num_workers=num_workers,
        pin_memory=pin,
        drop_last=False,
        persistent_workers=False,
        prefetch_factor=prefetch if num_workers > 0 else None
    )

    # model/optim
    model = build_model(train_cfg["model_name"], num_classes).to(device)
    if device.type == "cuda":
        model = model.to(memory_format=torch.channels_last)
    if grad_checkpoint:
        try:
            model.set_grad_checkpointing(True)
            print("Gradient checkpointing: ON")
        except Exception as e:
            print(f"Checkpointing not supported by this model: {e}")

    use_amp = (device.type == "cuda")
    scaler = torch.amp.GradScaler("cuda") if use_amp else None

    # class weights (use same subset as sampler)
    split = getattr(train_ds, "split", "train")
    indices = getattr(train_ds, "indices", None)
    cw = class_weights_from_h5(
        h5_path, split=split, indices=indices,
        expected_num_classes=num_classes, device=device
    )

    # IMPORTANT: when mixup>0, keep smoothing small (<=0.05) or 0.0
    if cw is not None and cw.numel() == num_classes:
        criterion = nn.CrossEntropyLoss(weight=cw, label_smoothing=label_smooth)
        print(f"Using class-weighted CE (K={cw.numel()}).")
    else:
        criterion = nn.CrossEntropyLoss(label_smoothing=label_smooth)
        print("Using unweighted CE (class weights unavailable or mismatched).")

    optimizer = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
    scheduler = WarmupCosine(optimizer, warmup_epochs=warmup_epochs, total_epochs=epochs, min_lr=1e-6)

    out_best  = Path(cfg.get("paths", {}).get("best_ckpt", "ai/models/best.pt"))
    out_last  = Path(cfg.get("paths", {}).get("last_ckpt", "ai/models/last.pt"))
    patience  = int(train_cfg.get("early_stop_patience", 5))
    best_f1   = -1.0
    no_improv = 0

    # CSV logger
    run_dir = Path("ai/experiments") / time.strftime("run_%Y%m%d_%H%M%S")
    logger = CSVLogger(run_dir)

    print(f"Classes: {num_classes} | batch={batch_size} | img={img_size} | workers={num_workers} | "
          f"prefetcher={use_prefetch} | mixup_alpha={mixup_alpha} | weighted_sampler={use_weighted_sampler} | "
          f"accumulate_steps={accumulate_steps} | grad_checkpoint={grad_checkpoint}")

    # train loop
    try:
        for epoch in range(1, epochs + 1):
            t0 = time.time()
            tr_loss = train_one_epoch(
                model, train_loader, device, optimizer, criterion,
                scaler, use_amp, max_grad_norm, use_prefetch,
                num_classes=num_classes, mixup_alpha=mixup_alpha,
                max_steps=max_steps_per_epoch, accumulate_steps=accumulate_steps
            )
            va_loss, va_f1 = validate(
                model,
                maybe_wrap_prefetch(val_loader, device, enable=False),
                device, criterion,
                max_batches=val_max_batches  # cap val work per epoch
            )
            scheduler.step()
            dt = time.time() - t0
            print(f"Epoch {epoch:03d}/{epochs} | {dt:.1f}s  train_loss={tr_loss:.4f}  val_loss={va_loss:.4f}  macroF1={va_f1:.4f}")

            # save last
            ensure_parent(out_last)
            torch.save(model.state_dict(), out_last)

            # save best
            if va_f1 > best_f1:
                best_f1 = va_f1
                save_best(out_best, model, classes)
                print(f"  ✔ New best F1={best_f1:.4f} → {out_best}")
                no_improv = 0
            else:
                no_improv += 1

            # log CSV
            current_lr = next(iter(optimizer.param_groups))["lr"]
            logger.log(epoch, tr_loss, va_loss, va_f1, current_lr, dt)

            if no_improv >= patience:
                print(f"Early stopping after {patience} epochs without improvement.")
                break
    finally:
        logger.close()
        print("Metrics CSV →", run_dir / "metrics.csv")

    # save classes list
    cls_txt = Path("ai/models/classes.txt")
    ensure_parent(cls_txt)
    if classes is None:
        classes = []
    cls_txt.write_text("\n".join(classes), encoding="utf-8")
    print("Saved classes list →", cls_txt)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    args = ap.parse_args()
    main(args.config)
