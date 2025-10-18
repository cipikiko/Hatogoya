import argparse, json, csv
from pathlib import Path
from collections import defaultdict
import numpy as np, h5py, cv2
from tqdm import tqdm
import random

def load_manifest(csv_path, autosplit=False, split_ratios=(0.8,0.1,0.1), seed=42):
    items_by_split = defaultdict(list)
    labels_set = set()
    rows = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            p = Path(r["path"])
            split = r["split"].strip().lower()
            label = r["label"].strip()
            rows.append((p, split, label))
            labels_set.add(label)

    labels = sorted(labels_set)
    cls2idx = {c:i for i,c in enumerate(labels)}

    if autosplit:
        random.seed(seed)
        by_label = defaultdict(list)
        for p, _, label in rows:
            by_label[label].append(p)
        for label, paths in by_label.items():
            random.shuffle(paths)
            n = len(paths)
            t = int(n*split_ratios[0]); v = int(n*split_ratios[1])
            splits = {"train": paths[:t], "val": paths[t:t+v], "test": paths[t+v:]}
            for s, plist in splits.items():
                for p in plist:
                    items_by_split[s].append((p, cls2idx[label]))
    else:
        for p, split, label in rows:
            if split not in {"train","val","test"}:
                raise ValueError(f"Bad split '{split}' for {p}")
            items_by_split[split].append((p, cls2idx[label]))

    return items_by_split, labels

def write_split(h5, split, items, img_size, compression="lzf"):
    n = len(items)
    grp = h5.create_group(split)
    d_imgs = grp.create_dataset(
        "images",
        shape=(n, img_size, img_size, 3),
        dtype=np.uint8,
        chunks=(min(n,256), img_size, img_size, 3),
        compression=(compression if compression!="none" else None),
        shuffle=True
    )
    d_labels = grp.create_dataset("labels", shape=(n,), dtype=np.int64)

    for i, (path, y) in enumerate(tqdm(items, desc=f"{split:5s}", unit="img")):
        img = cv2.imread(str(path))
        if img is None:
            raise RuntimeError(f"Failed to read image: {path}")
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (img_size, img_size), interpolation=cv2.INTER_AREA)
        d_imgs[i] = img
        d_labels[i] = y

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", default="ai/data/manifest.csv")
    ap.add_argument("--out", default="ai/data/dataset.h5")
    ap.add_argument("--img_size", type=int, default=224)
    ap.add_argument("--compression", default="lzf", choices=["lzf","gzip","none"])
    ap.add_argument("--autosplit", action="store_true", help="use if CSV has no split (put 'unsplit')")
    args = ap.parse_args()

    items_by_split, labels = load_manifest(args.manifest, autosplit=args.autosplit)
    out = Path(args.out); out.parent.mkdir(parents=True, exist_ok=True)
    with h5py.File(out, "w") as h5:
        h5.attrs["img_size"] = int(args.img_size)
        h5.attrs["class_names"] = json.dumps(labels)
        for split in ("train","val","test"):
            write_split(h5, split, items_by_split.get(split, []), args.img_size, args.compression)

    print(f"Wrote {out} with classes: {labels}")

if __name__ == "__main__":
    main()
