# ai/src/training/data/datasets.py
from typing import Tuple, Optional
from torch.utils.data import random_split
import torch
import h5py

# Prefer new package paths, fall back to legacy if someone didn't move files
try:
    from ai.src.datasets.hdf5_dataset_bytes import H5BytesClassificationDataset as BytesDS
    from ai.src.datasets.hdf5_dataset import H5ClassificationDataset as PixelsDS
except ModuleNotFoundError:
    from ai.src.hdf5_dataset_bytes import H5BytesClassificationDataset as BytesDS
    from ai.src.hdf5_dataset import H5ClassificationDataset as PixelsDS

from ai.src.training.data.transforms import train_transforms, val_transforms


def _h5_groups_and_storage(h5_path: str):
    with h5py.File(h5_path, "r") as h5:
        groups = set(h5.keys())
        storage = h5.attrs.get("storage", "pixels")
        classes = list(h5.attrs.get("classes", []))
    return groups, storage, classes


def make_datasets(h5_path: str, img_size: int, seed: int = 42):
    """
    Returns: train_ds, val_ds, classes
    - If the HDF5 has explicit 'train' and 'val' groups, use them.
    - Otherwise split the 'train' group 90/10 deterministically.
    - Selects correct dataset class based on h5.attrs['storage'] ('pixels' | 'encoded_bytes').
    """
    groups, storage, classes = _h5_groups_and_storage(h5_path)
    DS = BytesDS if storage == "encoded_bytes" else PixelsDS

    # sanity: need at least a 'train' group
    if "train" not in groups:
        raise RuntimeError(f"No 'train' group in {h5_path}. Found groups: {sorted(groups)}")

    # explicit train/val
    if "val" in groups:
        train_ds = DS(h5_path, split="train", atransforms=train_transforms(img_size))
        val_ds   = DS(h5_path, split="val",   atransforms=val_transforms(img_size))
        # propagate class names if dataset exposes them
        cls = getattr(train_ds, "class_names", None) or classes or None
        return train_ds, val_ds, cls

    # split the train group into train/val
    full = DS(h5_path, split="train", atransforms=train_transforms(img_size))
    n = len(full)
    n_val = max(1, int(0.10 * n))
    n_tr  = n - n_val
    g = torch.Generator().manual_seed(int(seed))
    tr_subset, va_subset = random_split(full, [n_tr, n_val], generator=g)

    # attach val transforms to the val subset
    # random_split returns Subset; swap its underlying dataset's transforms for val
    try:
        # only if the dataset supports 'atransforms' attribute
        va_subset.dataset.atransforms = val_transforms(img_size)
    except Exception:
        pass

    cls = getattr(full, "class_names", None) or classes or None
    # stash classes for convenience
    setattr(tr_subset, "class_names", cls)
    setattr(va_subset, "class_names", cls)
    return tr_subset, va_subset, cls
