import numpy as np
import h5py
import torch
from torch.utils.data import WeightedRandomSampler

def _h5_labels(h5_path: str, split: str = "train", indices=None):
    with h5py.File(h5_path, "r") as h5:
        key = f"{split}/labels"
        if key not in h5:
            raise RuntimeError(f"'{key}' not found in {h5_path}")
        arr = h5[key][:]
    if indices is not None:
        arr = arr[indices]
    return arr.astype(np.int64)

def make_weighted_sampler_from_h5(h5_path: str, ds) -> WeightedRandomSampler:
    split = getattr(ds, "split", "train")
    indices = None
    if hasattr(ds, "indices") and hasattr(ds, "dataset"):
        split = getattr(ds.dataset, "split", split)
        indices = ds.indices
    labels = _h5_labels(h5_path, split=split, indices=indices)
    _, inv = np.unique(labels, return_inverse=True)
    counts = np.bincount(inv).astype(np.float64)
    counts[counts == 0] = 1.0
    cls_w = 1.0 / counts
    sample_w = cls_w[inv]
    return WeightedRandomSampler(
        weights=torch.from_numpy(sample_w).double(),
        num_samples=len(sample_w),
        replacement=True
    )

def class_weights_from_h5(h5_path: str, split="train", indices=None,
                          expected_num_classes=None, normalize=True, device="cpu"):
    with h5py.File(h5_path, "r") as h5:
        key = f"{split}/labels"
        if key not in h5:
            raise RuntimeError(f"'{key}' not found in {h5_path}")
        y = h5[key][:]
    if indices is not None:
        y = y[indices]
    y = y.astype(np.int64)
    if y.size == 0:
        return None
    uniq, inv = np.unique(y, return_inverse=True)
    counts = np.bincount(inv).astype(np.float64)
    if expected_num_classes is not None and counts.shape[0] != int(expected_num_classes):
        print(f"[class_weights_from_h5] Mismatch: got {counts.shape[0]} unique, expected {expected_num_classes}.")
        return None
    counts[counts == 0] = 1.0
    w = 1.0 / counts
    if normalize:
        w = w / w.mean()
    return torch.tensor(w, dtype=torch.float32, device=device)
