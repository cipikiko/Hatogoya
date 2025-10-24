# ai/src/hdf5_dataset_bytes.py
import json
from io import BytesIO
from pathlib import Path
from typing import List

import h5py
import numpy as np
import torch
from PIL import Image
from torch.utils.data import Dataset
from albumentations import Compose, Resize, CenterCrop, Normalize
from albumentations.pytorch import ToTensorV2

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

def default_val_transforms(sz: int):
    return Compose([
        Resize(height=sz, width=sz),
        CenterCrop(height=sz, width=sz),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])

class H5BytesClassificationDataset(Dataset):
    """
    Expected HDF5 layout (bytes-backed):
      <split>/images_bytes : vlen uint8
      <split>/labels       : class names (bytes or ASCII/UTF-8 strings)

    File attrs (optional):
      - storage="encoded_bytes"
      - class_names: JSON list of class names for stable indexing

    If class_names attr is missing, we derive classes from labels in the split.
    """
    def __init__(self, h5_path: str, split: str, img_size: int = 224, atransforms=None):
        self.h5_path = str(h5_path)
        self.split   = split
        self.sz      = int(img_size)
        self.atransforms = atransforms or default_val_transforms(self.sz)

        with h5py.File(self.h5_path, "r") as h5:
            if f"{split}/images_bytes" not in h5 or f"{split}/labels" not in h5:
                raise ValueError(
                    f"Split '{split}' not found (needs '{split}/images_bytes' & '{split}/labels') in {self.h5_path}"
                )
            self.n = int(h5[f"{split}/labels"].shape[0])

            # resolve class names (stable order if provided)
            if "class_names" in h5.attrs:
                try:
                    self.class_names: List[str] = json.loads(h5.attrs["class_names"])
                except Exception:
                    self.class_names = None
            else:
                self.class_names = None

            if self.class_names is None:
                # derive from labels in this split
                labs = h5[f"{split}/labels"][:]
                # handle bytes/str
                labs = [lb.decode("utf-8") if isinstance(lb, (bytes, bytearray, np.bytes_)) else str(lb) for lb in labs]
                # use sorted unique for stable indexing
                self.class_names = sorted(set(labs))

        # map: class name -> index
        self.class_to_idx = {c: i for i, c in enumerate(self.class_names)}

    def __len__(self):
        return self.n

    def __getitem__(self, idx: int):
        with h5py.File(self.h5_path, "r") as h5:
            b = bytes(h5[f"{self.split}/images_bytes"][idx])
            lb = h5[f"{self.split}/labels"][idx]
        # label to int
        if isinstance(lb, (bytes, bytearray, np.bytes_)):
            cls = lb.decode("utf-8")
        else:
            cls = str(lb)
        y = self.class_to_idx.get(cls, -1)
        if y < 0:
            # fallback: unseen class name (shouldn't happen), add at end
            y = len(self.class_to_idx)
            self.class_to_idx[cls] = y
            self.class_names.append(cls)

        # decode image
        with Image.open(BytesIO(b)) as im:
            im = im.convert("RGB")
        img = np.asarray(im)  # HWC uint8
        img = self.atransforms(image=img)["image"]  # torch tensor CHW
        return img, torch.tensor(y, dtype=torch.long)
