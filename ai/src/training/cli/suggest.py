import argparse
from pathlib import Path
from ai.src.training.auto.hparams import suggest_from_dataset, to_yaml

def main():
    ap = argparse.ArgumentParser(description="Suggest training hyperparameters from an HDF5 dataset.")
    ap.add_argument("--h5", required=True, help="Path to dataset .h5")
    ap.add_argument("--model", default="resnet50", help="timm model name (e.g., resnet50, convnext_tiny, vit_base_patch16_224)")
    ap.add_argument("--device", default="cuda", choices=["cuda", "cpu"], help="Preferred device to probe")
    ap.add_argument("--img-size", type=int, default=None, help="Override image size; defaults to dataset size or 224")
    ap.add_argument("--updates", type=int, default=20000, help="Target total optimizer updates")
    ap.add_argument("--out", default=None, help="Write YAML to this path; default prints to stdout")
    args = ap.parse_args()

    cfg = suggest_from_dataset(
        h5_path=args.h5,
        model_name=args.model,
        device_want=args.device,
        img_size=args.img_size,
        target_updates=args.updates,
        prefer_amp=True,
    )
    yml = to_yaml(cfg)

    if args.out:
        out = Path(args.out)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(yml, encoding="utf-8")
        print(f"[suggest] Wrote config → {out}")
    else:
        print(yml)

if __name__ == "__main__":
    main()
