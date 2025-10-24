# ai/src/hdf5_dataset.py
import json
import h5py
import numpy as np
import torch
from torch.utils.data import Dataset
from albumentations import Compose, Resize, CenterCrop, Normalize
from albumentations.pytorch import ToTensorV2


IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

def default_val_transforms(img_size: int):
    return Compose([
        Resize(height=img_size, width=img_size),
        CenterCrop(height=img_size, width=img_size),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])

class H5ClassificationDataset(Dataset):
    """
    Expected HDF5 layout:
      <split>/images : uint8 [N, H, W, 3]
      <split>/labels : int   [N]
    attrs:
      class_names (JSON list), img_size (optional)
    """
    def __init__(self, h5_path: str, split: str, atransforms=None):
        self.h5_path = h5_path
        self.split = split
        self.atransforms = atransforms

        with h5py.File(self.h5_path, "r") as h5:
            if split not in h5:
                raise ValueError(f"Split '{split}' not found in {self.h5_path}")
            self.length = int(h5[f"{split}/labels"].shape[0])
            self.class_names = json.loads(h5.attrs["class_names"])

        if self.atransforms is None:
            with h5py.File(self.h5_path, "r") as h5:
                img_size = int(h5.attrs.get("img_size", 224))
            self.atransforms = default_val_transforms(img_size)

    def __len__(self): return self.length

    def __getitem__(self, idx):
        with h5py.File(self.h5_path, "r") as h5:
            img = h5[f"{self.split}/images"][idx]  # uint8 HWC
            label = int(h5[f"{self.split}/labels"][idx])
        img = img.astype(np.float32) / 255.0
        if self.atransforms:
            img = self.atransforms(image=img)["image"]  # torch tensor CHW
        return img, torch.tensor(label, dtype=torch.long)
