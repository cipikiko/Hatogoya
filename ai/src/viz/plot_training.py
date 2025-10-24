# ai/src/plot_training.py
import argparse
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

def main(csv_path: str):
    p = Path(csv_path)
    df = pd.read_csv(p)
    out_dir = p.parent

    # loss curve
    fig1 = plt.figure()
    plt.plot(df["epoch"], df["train_loss"], label="train_loss")
    plt.plot(df["epoch"], df["val_loss"], label="val_loss")
    plt.xlabel("epoch"); plt.ylabel("loss"); plt.title("Loss vs epoch"); plt.legend()
    fig1.savefig(out_dir / "loss_curves.png", dpi=200, bbox_inches="tight"); plt.close(fig1)

    # macro-F1 curve
    fig2 = plt.figure()
    plt.plot(df["epoch"], df["macro_f1"])
    plt.xlabel("epoch"); plt.ylabel("macro-F1"); plt.title("Macro-F1 vs epoch")
    fig2.savefig(out_dir / "f1_curve.png", dpi=200, bbox_inches="tight"); plt.close(fig2)

    # LR curve (optional)
    fig3 = plt.figure()
    plt.plot(df["epoch"], df["lr"])
    plt.xlabel("epoch"); plt.ylabel("lr"); plt.title("Learning rate vs epoch")
    fig3.savefig(out_dir / "lr_curve.png", dpi=200, bbox_inches="tight"); plt.close(fig3)

    print("Saved plots to:", out_dir)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", help="Path to metrics.csv")
    args = ap.parse_args()
    main(args.csv)
