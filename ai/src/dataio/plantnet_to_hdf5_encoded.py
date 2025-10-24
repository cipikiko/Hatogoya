import os
import io
import h5py
import argparse
from pathlib import Path
from tqdm import tqdm
from PIL import Image
import numpy as np

def collect_images(root):
    root = Path(root)
    exts = {'.jpg', '.jpeg', '.png', '.webp'}
    return [p for p in root.rglob('*') if p.suffix.lower() in exts]

def main(args):
    files = collect_images(args.root)
    if not files:
        raise RuntimeError(f"No images found in {args.root}")

    print(f"Found {len(files)} images, writing to {args.out}")

    with h5py.File(args.out, "w") as h5:
        h5.attrs["storage"] = "encoded_bytes"
        h5.attrs["reencode"] = args.reencode
        h5.attrs["root"] = str(args.root)

        dt = h5py.vlen_dtype(np.dtype("uint8"))
        img_ds = h5.create_dataset("train/images_bytes", shape=(len(files),), dtype=dt)
        label_ds = h5.create_dataset("train/labels", shape=(len(files),), dtype="S128")

        for i, path in enumerate(tqdm(files, total=len(files))):
            label = path.parent.name.encode("utf-8")

            # read image bytes (optionally re-encode)
            if args.reencode == "none":
                data = path.read_bytes()
            else:
                img = Image.open(path).convert("RGB")
                buf = io.BytesIO()
                fmt = "WEBP" if args.reencode == "webp" else "JPEG"
                quality = args.quality
                img.save(buf, fmt, quality=quality)
                data = buf.getvalue()

            img_ds[i] = np.frombuffer(data, dtype=np.uint8)
            label_ds[i] = label

    print(f"Done: {args.out}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True, help="Root folder of the image dataset")
    ap.add_argument("--out", required=True, help="Output HDF5 file path")
    ap.add_argument("--reencode", choices=["none", "jpeg", "webp"], default="none")
    ap.add_argument("--quality", type=int, default=85, help="Reencode quality (if used)")
    args = ap.parse_args()
    main(args)
