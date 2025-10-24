import argparse
from pathlib import Path
import json
import numpy as np

import torch
import torch.nn as nn
from torch.utils.data import DataLoader

from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
import timm
import yaml
from albumentations import Compose, Resize, CenterCrop, Normalize
from albumentations.pytorch import ToTensorV2

from ai.src.datasets.hdf5_dataset import H5ClassificationDataset

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

def load_cfg(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def device_from_cfg(cfg):
    want = cfg["train"].get("device", "cuda")
    return torch.device("cuda") if (want == "cuda" and torch.cuda.is_available()) else torch.device("cpu")

def val_transforms(img_size: int):
    return Compose([
        Resize(height=img_size, width=img_size),
        CenterCrop(height=img_size, width=img_size),
        Normalize((0.485,0.456,0.406), (0.229,0.224,0.225)),
        ToTensorV2(),
    ])

@torch.no_grad()
def evaluate(model, loader, device, class_names):
    model.eval()
    y_true, y_pred = [], []
    for x, y in loader:
        x = x.to(device)
        logits = model(x)
        pred = logits.argmax(1).cpu().numpy().tolist()
        y_pred.extend(pred)
        y_true.extend(y.numpy().tolist())

    acc = accuracy_score(y_true, y_pred)
    f1  = f1_score(y_true, y_pred, average="macro") if len(set(y_true)) > 1 else 0.0
    print(f"\nOverall:  accuracy={acc:.4f}  macroF1={f1:.4f}\n")

    print("Per-class report:\n")
    print(classification_report(y_true, y_pred, target_names=class_names, digits=4))

    cm = confusion_matrix(y_true, y_pred)
    print("Confusion matrix (rows=true, cols=pred):\n", cm)

def main(cfg_path: str):
    cfg = load_cfg(cfg_path)

    if not bool(cfg["data"].get("use_hdf5", True)):
        raise RuntimeError("This evaluator expects HDF5. Set data.use_hdf5: true and data.hdf5_path.")

    h5_path = cfg["data"]["hdf5_path"]
    img_size = int(cfg["data"]["img_size"])
    num_workers = int(cfg["data"].get("num_workers", 2))

   
    test_ds = H5ClassificationDataset(h5_path, "test", atransforms=val_transforms(img_size))
    class_names = test_ds.class_names
    test_loader = DataLoader(
        test_ds, batch_size=int(cfg["train"]["batch_size"]),
        shuffle=False, num_workers=num_workers, pin_memory=True, drop_last=False,
        persistent_workers=num_workers>0
    )

    device = device_from_cfg(cfg)
    model_name = cfg["train"]["model_name"]
    num_classes = len(class_names)

    
    ckpt_path = Path(cfg.get("paths", {}).get("best_ckpt", "ai/models/best.pt"))
    if not ckpt_path.exists():
        raise FileNotFoundError(f"Best checkpoint not found at {ckpt_path}. Run training first.")

    ckpt = torch.load(ckpt_path, map_location="cpu")
    if "classes" in ckpt and isinstance(ckpt["classes"], (list, tuple)):
        class_names = list(ckpt["classes"])
        num_classes = len(class_names)

    model = timm.create_model(model_name, pretrained=False, num_classes=num_classes)
    state = ckpt["model"] if "model" in ckpt else ckpt
    model.load_state_dict(state, strict=True)
    model.to(device)

    evaluate(model, test_loader, device, class_names)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    args = ap.parse_args()
    main(args.config)
