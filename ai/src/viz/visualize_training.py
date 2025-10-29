# ai/src/viz/visualize_training.py
from __future__ import annotations
import argparse, csv, os, glob
from pathlib import Path
from typing import Dict, List, Tuple, Optional

import numpy as np
import matplotlib.pyplot as plt


def find_run_dir(exp_root: str | Path) -> Path:
    exp_root = Path(exp_root)
    candidates = sorted(exp_root.glob("run_*"))
    if not candidates:
        raise SystemExit(f"No runs found under {exp_root}")
    return candidates[-1]


def load_metrics(run_dir: Path) -> Dict[str, List[float]]:
    csv_path = run_dir / "metrics.csv"
    if not csv_path.exists():
        raise SystemExit(f"metrics.csv not found in {run_dir}")
    cols = {"epoch": [], "train_loss": [], "val_loss": [], "macro_f1": [], "lr": [], "seconds": []}
    with csv_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cols["epoch"].append(int(row["epoch"]))
            cols["train_loss"].append(float(row["train_loss"]))
            cols["val_loss"].append(float(row["val_loss"]))
            cols["macro_f1"].append(float(row["macro_f1"]))
            cols["lr"].append(float(row["lr"]))
            cols["seconds"].append(float(row["seconds"]))
    return cols


def best_epoch(metrics: Dict[str, List[float]]) -> Tuple[int, float]:
    f1s = np.array(metrics["macro_f1"])
    idx = int(np.argmax(f1s))
    return metrics["epoch"][idx], float(f1s[idx])


def plot_series(x, y, title: str, ylabel: str, out_path: Path, xbest: Optional[int] = None, ybest: Optional[float] = None):
    fig = plt.figure()
    plt.plot(x, y, linewidth=2)
    plt.title(title)
    plt.xlabel("epoch")
    plt.ylabel(ylabel)
    if xbest is not None and ybest is not None:
        plt.scatter([xbest], [ybest], s=50)
        plt.text(xbest, ybest, f"  best@{xbest}: {ybest:.4f}", va="bottom", fontsize=9)
    plt.grid(True, linestyle=":", linewidth=0.5)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def plot_two_series(x, y1, y2, labels: Tuple[str,str], title: str, ylabel: str, out_path: Path, xbest: Optional[int] = None):
    fig = plt.figure()
    plt.plot(x, y1, linewidth=2, label=labels[0])
    plt.plot(x, y2, linewidth=2, label=labels[1])
    plt.title(title)
    plt.xlabel("epoch")
    plt.ylabel(ylabel)
    if xbest is not None:
        plt.axvline(xbest, linestyle="--")
        plt.text(xbest, max(max(y1), max(y2)), f" best@{xbest}", va="bottom", fontsize=9, rotation=90)
    plt.grid(True, linestyle=":", linewidth=0.5)
    plt.legend()
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)


def try_load_classes(project_root: Path) -> List[str]:
    cls_txt = project_root / "ai" / "models" / "classes.txt"
    if cls_txt.exists():
        try:
            return [ln.strip() for ln in cls_txt.read_text(encoding="utf-8").splitlines() if ln.strip()]
        except Exception:
            return []
    return []


def maybe_plot_confmat(confmat_csv: Optional[str], run_dir: Path, classes: List[str], show: bool):
    if not confmat_csv:
        return
    p = Path(confmat_csv)
    if not p.exists():
        print(f"[viz] Confusion matrix CSV not found: {p}")
        return
    # load as int matrix
    rows = []
    with p.open("r", encoding="utf-8") as f:
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            rows.append([int(x) for x in ln.split(",") if x != ""])
    cm = np.array(rows, dtype=np.int64)
    fig = plt.figure(figsize=(6, 5))
    plt.imshow(cm, interpolation="nearest")
    plt.title("Confusion Matrix")
    plt.xlabel("Predicted")
    plt.ylabel("True")
    plt.colorbar()
    # optional tick labels (only if not ridiculous)
    n = cm.shape[0]
    if classes and n == len(classes) and n <= 50:
        plt.xticks(np.arange(n), classes, rotation=90, fontsize=7)
        plt.yticks(np.arange(n), classes, fontsize=7)
    fig.tight_layout()
    out = run_dir / "confusion_matrix.png"
    fig.savefig(out, dpi=150)
    if show:
        plt.show()
    plt.close(fig)
    print(f"[viz] Saved confusion_matrix.png → {out}")


def visualize(run_dir: Path, out_dir: Optional[Path], confmat_csv: Optional[str], show: bool):
    metrics = load_metrics(run_dir)
    be, bf1 = best_epoch(metrics)
    print(f"[viz] Run: {run_dir.name} | best epoch={be} macro_f1={bf1:.4f}")

    out = out_dir or run_dir
    out.mkdir(parents=True, exist_ok=True)

    # Loss curves
    plot_two_series(
        metrics["epoch"], metrics["train_loss"], metrics["val_loss"],
        labels=("train_loss", "val_loss"),
        title="Loss vs Epoch",
        ylabel="loss",
        out_path=out / "loss.png",
        xbest=be
    )
    # F1 curve
    plot_series(
        metrics["epoch"], metrics["macro_f1"],
        title="Macro-F1 vs Epoch",
        ylabel="macro_f1",
        out_path=out / "macro_f1.png",
        xbest=be, ybest=bf1
    )
    # LR curve
    plot_series(
        metrics["epoch"], metrics["lr"],
        title="Learning Rate vs Epoch",
        ylabel="lr",
        out_path=out / "lr.png"
    )

    # Optional confusion matrix
    classes = try_load_classes(Path.cwd())
    maybe_plot_confmat(confmat_csv, out, classes, show)

    if show:
        # If user asked to show, open the three key figures quickly
        # We avoided keeping figures open above to save memory; re-display images here if needed.
        for name in ("loss.png", "macro_f1.png", "lr.png"):
            img_path = out / name
            if img_path.exists():
                img = plt.imread(img_path)
                fig = plt.figure()
                plt.imshow(img)
                plt.axis("off")
                plt.title(name)
                plt.show()
                plt.close(fig)


def parse_args():
    ap = argparse.ArgumentParser(description="Visualize training results from metrics.csv and optional confusion matrix.")
    ap.add_argument("--runs-root", default="ai/experiments", help="Root folder containing run_* dirs")
    ap.add_argument("--run", default=None, help="Specific run dir path; defaults to latest under runs-root")
    ap.add_argument("--outdir", default=None, help="Where to save PNGs; default: the run dir")
    ap.add_argument("--confmat", default=None, help="Path to confusion matrix CSV to plot (optional)")
    ap.add_argument("--show", action="store_true", help="Display figures interactively")
    return ap.parse_args()


def main():
    args = parse_args()
    run_dir = Path(args.run) if args.run else find_run_dir(args.runs_root)
    out_dir = Path(args.outdir) if args.outdir else None
    visualize(run_dir, out_dir, args.confmat, args.show)


if __name__ == "__main__":
    main()
