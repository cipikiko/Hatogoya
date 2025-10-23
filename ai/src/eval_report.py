# ai/src/eval_report.py
import argparse, json, time
from pathlib import Path

import numpy as np
import torch
import torch.nn.functional as F
from sklearn.metrics import (
    classification_report, confusion_matrix, f1_score,
    accuracy_score, top_k_accuracy_score
)
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
import yaml

from ai.src.train import load_cfg, device_from_cfg, make_datasets, build_model

def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)

def plot_confusion_topk(cm, labels, out_path: Path, k: int = 50, title: str = "Confusion (Top-50 classes)"):
    # choose top-k classes by support (row sums)
    support = cm.sum(axis=1)
    idx = np.argsort(-support)[:k]
    cm_k = cm[np.ix_(idx, idx)]
    labels_k = [labels[i] for i in idx]

    fig = plt.figure(figsize=(10, 10))
    ax = plt.gca()
    im = ax.imshow(cm_k, interpolation="nearest")
    ax.set_title(title)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_xticks(range(len(labels_k)))
    ax.set_yticks(range(len(labels_k)))
    ax.set_xticklabels(labels_k, rotation=90, fontsize=6)
    ax.set_yticklabels(labels_k, fontsize=6)
    fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    plt.tight_layout()
    fig.savefig(out_path, dpi=200, bbox_inches="tight")
    plt.close(fig)

def main(cfg_path: str, ckpt_path: str, batch_size: int | None):
    cfg = load_cfg(cfg_path)
    device = device_from_cfg(cfg)
    img_size = int(cfg["data"]["img_size"])
    h5_path  = cfg["data"]["hdf5_path"]
    bs = int(cfg["train"]["batch_size"]) if batch_size is None else int(batch_size)

    # dataset (same split logic as train.py)
    _, val_ds, classes = make_datasets(h5_path, img_size, seed=int(cfg.get("seed", 42)))
    if classes is None:
        # derive class names if missing
        if hasattr(val_ds, "class_names") and val_ds.class_names:
            classes = list(val_ds.class_names)
        elif hasattr(getattr(val_ds, "dataset", None), "class_names") and val_ds.dataset.class_names:
            classes = list(val_ds.dataset.class_names)
        else:
            # fallback to 0..C-1 if unknown
            # (we'll infer C from predictions below)
            classes = None

    # load model + figure out num_classes
    ckpt = torch.load(ckpt_path, map_location="cpu")
    ckpt_classes = ckpt.get("classes", None)
    if ckpt_classes is not None and isinstance(ckpt_classes, (list, tuple)):
        classes = list(ckpt_classes)

    # If classes is still None, we will infer num_classes from logits' width later
    known_num_classes = len(classes) if classes is not None else None

    val_loader = DataLoader(
        val_ds, batch_size=bs, shuffle=False, num_workers=0,
        pin_memory=(device.type=="cuda")
    )

    # Build model
    # If we don't know num_classes yet, temporarily set a large number; we'll adjust from first batch logits.
    num_classes = known_num_classes if known_num_classes is not None else 2048
    model = build_model(cfg["train"]["model_name"], num_classes).to(device).eval()
    state = ckpt["model"] if "model" in ckpt else ckpt
    model.load_state_dict(state, strict=False)  # strict=False to allow num_classes adjust

    y_true, y_pred, y_scores = [], [], []
    inferred_num_classes = None

    t0 = time.time()
    with torch.no_grad():
        for x, y in val_loader:
            x = x.to(device, non_blocking=True)
            logits = model(x)
            if inferred_num_classes is None:
                inferred_num_classes = logits.shape[1]
                # if classes was unknown, create placeholder names
                if known_num_classes is None:
                    classes = [str(i) for i in range(inferred_num_classes)]
            probs = F.softmax(logits, dim=1).cpu().numpy()
            y_scores.append(probs)
            y_pred.extend(np.argmax(probs, axis=1).tolist())
            y_true.extend(y.numpy().tolist())
    dt = time.time() - t0

    y_true = np.array(y_true)
    y_pred = np.array(y_pred)
    y_scores = np.concatenate(y_scores, axis=0)

    num_classes = inferred_num_classes if inferred_num_classes is not None else (known_num_classes or len(set(y_true)))
    if classes is None or len(classes) != num_classes:
        # ensure classes list matches the number of classes used by logits
        classes = [str(i) for i in range(num_classes)]

    # IMPORTANT: provide explicit labels to match target_names length
    labels_full = list(range(num_classes))

    acc = accuracy_score(y_true, y_pred)
    f1m = f1_score(y_true, y_pred, average="macro")
    try:
        top5 = top_k_accuracy_score(y_true, y_scores, k=min(5, num_classes), labels=labels_full)
    except Exception:
        top5 = float("nan")

    rpt = classification_report(
        y_true, y_pred,
        labels=labels_full,
        target_names=classes,
        output_dict=True,
        zero_division=0
    )
    cm = confusion_matrix(y_true, y_pred, labels=labels_full)

    # write report dir
    out_dir = Path("ai/experiments") / f"report_{time.strftime('%Y%m%d_%H%M%S')}"
    ensure_dir(out_dir)

    # summary
    (out_dir / "summary.txt").write_text(
        f"Samples: {len(y_true)}\n"
        f"Val accuracy: {acc:.4f}\n"
        f"Val macro-F1: {f1m:.4f}\n"
        f"Top-5 accuracy: {top5:.4f}\n"
        f"Classes (logits): {num_classes}\n"
        f"Present in val (unique y_true): {len(np.unique(y_true))}\n"
        f"Eval time: {dt:.1f}s\n",
        encoding="utf-8"
    )

    # per-class CSV
    import csv
    with open(out_dir / "per_class_metrics.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["class", "precision", "recall", "f1", "support"])
        for i, name in enumerate(classes):
            row = rpt.get(name) or {}
            w.writerow([
                name,
                f"{row.get('precision', 0.0):.6f}",
                f"{row.get('recall', 0.0):.6f}",
                f"{row.get('f1-score', 0.0):.6f}",
                int(row.get("support", 0))
            ])

    # confusion (top-50 by support)
    plot_confusion_topk(cm, classes, out_dir / "confusion_matrix_top50.png", k=min(50, num_classes))

    print("Saved:")
    print(" ", out_dir / "summary.txt")
    print(" ", out_dir / "per_class_metrics.csv")
    print(" ", out_dir / "confusion_matrix_top50.png")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    ap.add_argument("--ckpt", "-k", default="ai/models/best.pt")
    ap.add_argument("--batch-size", "-b", type=int, default=None)
    args = ap.parse_args()
    main(args.config, args.ckpt, args.batch_size)
