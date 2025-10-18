import argparse
import json
from pathlib import Path
from typing import Dict, Any, Tuple

import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from sklearn.metrics import f1_score
from torch.optim.lr_scheduler import CosineAnnealingLR

import timm
from albumentations import (
    Compose, RandomResizedCrop, Resize, CenterCrop, HorizontalFlip,
    ShiftScaleRotate, RandomBrightnessContrast, Normalize
)
from albumentations.pytorch import ToTensorV2
import yaml

from ai.src.hdf5_dataset import H5ClassificationDataset


IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

def train_transforms(img_size: int):
    return Compose([
        RandomResizedCrop(img_size, img_size, scale=(0.7, 1.0), ratio=(0.75, 1.33)),
        HorizontalFlip(p=0.5),
        ShiftScaleRotate(shift_limit=0.02, scale_limit=0.1, rotate_limit=10, p=0.5),
        RandomBrightnessContrast(p=0.2),
        Normalize(IMAGENET_MEAN, IMAGENET_STD),
        ToTensorV2(),
    ])

def val_transforms(img_size: int):
    return Compose([
        Resize(img_size, img_size),
        CenterCrop(img_size, img_size),
        Normalize(IMAGENET_MEAN, IMAGENET_STD),
        ToTensorV2(),
    ])


def load_cfg(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def ensure_parent(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)

def set_seed(seed: int = 42):
    import random, os
    random.seed(seed); np.random.seed(seed); torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = False
    torch.backends.cudnn.benchmark = True

def device_from_cfg(cfg: Dict[str, Any]) -> torch.device:
    want = cfg["train"].get("device", "cuda")
    return torch.device("cuda") if (want == "cuda" and torch.cuda.is_available()) else torch.device("cpu")

def build_model(model_name: str, num_classes: int) -> nn.Module:
    model = timm.create_model(model_name, pretrained=True, num_classes=num_classes)
    return model

def save_best(ckpt_path: Path, model: nn.Module, classes):
    ensure_parent(ckpt_path)
    torch.save({"model": model.state_dict(), "classes": classes}, ckpt_path)

@torch.no_grad()
def validate(model: nn.Module, loader: DataLoader, device: torch.device, criterion: nn.Module) -> Tuple[float, float]:
    model.eval()
    total_loss = 0.0
    preds, gts = [], []
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        logits = model(x)
        loss = criterion(logits, y)
        total_loss += loss.item() * x.size(0)
        preds.extend(logits.argmax(1).detach().cpu().tolist())
        gts.extend(y.detach().cpu().tolist())
    avg_loss = total_loss / len(loader.dataset)
    macro_f1 = f1_score(gts, preds, average="macro") if len(set(gts)) > 1 else 0.0
    return avg_loss, macro_f1

def train_one_epoch(model: nn.Module, loader: DataLoader, device: torch.device,
                    optimizer: torch.optim.Optimizer, scaler: torch.cuda.amp.GradScaler,
                    criterion: nn.Module, max_grad_norm: float | None) -> float:
    model.train()
    running = 0.0
    for x, y in loader:
        x, y = x.to(device), y.to(device)
        optimizer.zero_grad(set_to_none=True)
        with torch.cuda.amp.autocast(enabled=device.type == "cuda"):
            logits = model(x)
            loss = criterion(logits, y)
        scaler.scale(loss).backward()
        if max_grad_norm is not None:
            scaler.unscale_(optimizer)
            nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm)
        scaler.step(optimizer)
        scaler.update()
        running += loss.item() * x.size(0)
    return running / len(loader.dataset)


def main(cfg_path: str):
    cfg = load_cfg(cfg_path)
    set_seed(cfg.get("seed", 42))

    img_size    = int(cfg["data"]["img_size"])
    num_workers = int(cfg["data"].get("num_workers", 2))
    use_h5      = bool(cfg["data"].get("use_hdf5", True))
    h5_path     = cfg["data"].get("hdf5_path", "ai/data/dataset.h5")

    if not use_h5:
        raise RuntimeError("This trainer is set for HDF5. Set data.use_hdf5: true and provide data.hdf5_path.")

    train_ds = H5ClassificationDataset(h5_path, "train", atransforms=train_transforms(img_size))
    val_ds   = H5ClassificationDataset(h5_path, "val",   atransforms=val_transforms(img_size))
    classes  = train_ds.class_names
    num_classes = len(classes)

    train_loader = DataLoader(
        train_ds, batch_size=int(cfg["train"]["batch_size"]),
        shuffle=True, num_workers=num_workers, pin_memory=True, drop_last=False, persistent_workers=num_workers>0
    )
    val_loader = DataLoader(
        val_ds, batch_size=int(cfg["train"]["batch_size"]),
        shuffle=False, num_workers=num_workers, pin_memory=True, drop_last=False, persistent_workers=num_workers>0
    )

    device = device_from_cfg(cfg)
    model = build_model(cfg["train"]["model_name"], num_classes).to(device)

    label_smoothing = float(cfg["train"].get("label_smoothing", 0.0))
    criterion = nn.CrossEntropyLoss(label_smoothing=label_smoothing)

    optimizer = torch.optim.AdamW(
        model.parameters(),
        lr=float(cfg["train"]["lr"]),
        weight_decay=float(cfg["train"]["weight_decay"])
    )
    epochs = int(cfg["train"]["epochs"])
    scheduler = CosineAnnealingLR(optimizer, T_max=max(1, epochs))

    scaler = torch.cuda.amp.GradScaler(enabled=(device.type == "cuda"))
    max_grad_norm = float(cfg["train"].get("max_grad_norm", 1.0))

    out_best = Path(cfg.get("paths", {}).get("best_ckpt", "ai/models/best.pt"))
    out_last = Path(cfg.get("paths", {}).get("last_ckpt", "ai/models/last.pt"))

    patience = int(cfg["train"].get("early_stop_patience", 5))
    best_f1 = -1.0
    epochs_no_improve = 0

    print(f"Device: {device}  |  Classes: {classes}")
    for epoch in range(1, epochs + 1):
        tr_loss = train_one_epoch(model, train_loader, device, optimizer, scaler, criterion, max_grad_norm)
        va_loss, va_f1 = validate(model, val_loader, device, criterion)
        scheduler.step()

        print(f"Epoch {epoch:03d}/{epochs} | train_loss={tr_loss:.4f}  val_loss={va_loss:.4f}  macroF1={va_f1:.4f}")

        ensure_parent(out_last); torch.save(model.state_dict(), out_last)

        if va_f1 > best_f1:
            best_f1 = va_f1
            save_best(out_best, model, classes)
            print(f"  ✔ New best: {best_f1:.4f} → {out_best}")
            epochs_no_improve = 0
        else:
            epochs_no_improve += 1

        if epochs_no_improve >= patience:
            print(f"Early stopping after {patience} epochs without F1 improvement.")
            break

    cls_txt = Path("ai/models/classes.txt")
    ensure_parent(cls_txt)
    cls_txt.write_text("\n".join(classes), encoding="utf-8")
    print("Saved classes list →", cls_txt)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    args = ap.parse_args()
    main(args.config)
