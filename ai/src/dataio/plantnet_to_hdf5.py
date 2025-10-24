import argparse
import json
from pathlib import Path
from typing import List, Tuple, Dict

import h5py
import numpy as np
from PIL import Image, UnidentifiedImageError
from tqdm import tqdm


VALID_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}  # extend if needed


def find_classes(split_dir: Path) -> List[str]:
    
    classes = sorted([p.name for p in split_dir.iterdir() if p.is_dir()])
    if not classes:
        raise RuntimeError(f"No class folders found under {split_dir}")
    return classes


def list_images_for_split(root_images: Path, split: str, classes: List[str]) -> List[Tuple[Path, int]]:
    
    split_dir = root_images / split
    if not split_dir.exists():
        raise RuntimeError(f"Split '{split}' not found at {split_dir}")

    class_to_idx = {c: i for i, c in enumerate(classes)}
    items: List[Tuple[Path, int]] = []

    for cls in classes:
        cls_dir = split_dir / cls
        if not cls_dir.exists():
            # Some classes can be missing in val/test; just skip
            continue
        for p in cls_dir.rglob("*"):
            if p.is_file() and p.suffix.lower() in VALID_EXTS:
                items.append((p, class_to_idx[cls]))
    return items


def load_and_resize(path: Path, img_size: int) -> np.ndarray | None:
    
    try:
        with Image.open(path) as im:
            im = im.convert("RGB").resize((img_size, img_size), Image.BILINEAR)
            return np.array(im, dtype=np.uint8)
    except (UnidentifiedImageError, OSError):
        return None


def write_split(h5: h5py.File, split: str, items: List[Tuple[Path, int]], img_size: int,
                compression: str = "lzf") -> Dict[str, int]:
    
    n = len(items)
    grp = h5.create_group(split)
    
    d_imgs = grp.create_dataset(
        "images",
        shape=(n, img_size, img_size, 3),
        dtype=np.uint8,
        chunks=(min(n, 256), img_size, img_size, 3),
        compression=None if compression == "none" else compression,
        shuffle=True,
    )
    d_lbls = grp.create_dataset("labels", shape=(n,), dtype=np.int32)

    written, skipped = 0, 0
    for i, (path, y) in enumerate(tqdm(items, desc=f"{split:5s}", unit="img")):
        arr = load_and_resize(path, img_size)
        if arr is None:
            skipped += 1
            
            d_imgs[i] = np.zeros((img_size, img_size, 3), dtype=np.uint8)
            d_lbls[i] = y
            continue
        d_imgs[i] = arr
        d_lbls[i] = y
        written += 1

    return {"total": n, "written": written, "skipped": skipped}


def main():
    ap = argparse.ArgumentParser(description="Convert PlantNet-300K (images/train|val|test/<class>/) to HDF5.")
    ap.add_argument("--root", required=True, help="Path to PlantNet 'images' directory, e.g., ~/dataset/plantnet_300K/images")
    ap.add_argument("--out", default="ai/data/plantnet_300K.h5", help="Output HDF5 path")
    ap.add_argument("--img_size", type=int, default=224, help="Resize images to this square size")
    ap.add_argument("--compression", default="lzf", choices=["lzf", "gzip", "none"], help="HDF5 compression")
    args = ap.parse_args()

    root_images = Path(args.root).expanduser().resolve()
    if not root_images.exists():
        raise FileNotFoundError(f"Images root not found: {root_images}")

    
    classes = find_classes(root_images / "train")
    class_to_idx = {c: i for i, c in enumerate(classes)}
    print(f"Found {len(classes)} classes.")

    
    items = {
        "train": list_images_for_split(root_images, "train", classes),
        "val":   list_images_for_split(root_images, "val", classes),
        "test":  list_images_for_split(root_images, "test", classes),
    }
    for k, v in items.items():
        print(f"{k:5s}: {len(v):,} images")

    out_path = Path(args.out).expanduser().resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    print(f"\nCreating HDF5 → {out_path}")

    with h5py.File(out_path, "w") as h5:
        
        h5.attrs["img_size"] = int(args.img_size)
        h5.attrs["class_names"] = json.dumps(classes, ensure_ascii=False)

        
        stats = {}
        for split in ("train", "val", "test"):
            stats[split] = write_split(h5, split, items[split], args.img_size, args.compression)

    print("\nSummary:")
    for s, st in stats.items():
        print(f"  {s:5s}  total={st['total']:,}  written={st['written']:,}  skipped={st['skipped']:,}")
    print(f"\nDone. Saved to {out_path}")


if __name__ == "__main__":
    main()
