import h5py
import json
import numpy as np
import torch
from torch.utils.data import Dataset

class H5ClassificationDataset(Dataset):
    def __init__(self, h5_path, split, atransforms=None):
        super().__init__()
        self.h5_path = h5_path
        self.split = split
        self.atransforms = atransforms

        with h5py.File(h5_path, "r") as h5:
            if split not in h5:
                raise ValueError(f"Split '{split}' not found in {h5_path}.")
            self.length = len(h5[f"{split}/labels"])
            self.img_size = int(h5.attrs["img_size"])
            self.class_names = json.loads(h5.attrs["class_names"])

    def __len__(self):
        return self.length

    def __getitem__(self, idx):
        with h5py.File(self.h5_path, "r") as h5:
            img = h5[f"{self.split}/images"][idx]
            label = h5[f"{self.split}/labels"][idx]

        img = np.array(img, dtype=np.uint8)

     
        if self.atransforms:
            transformed = self.atransforms(image=img)
            img = transformed["image"]

        img = torch.tensor(img).permute(2, 0, 1).float() / 255.0
        label = torch.tensor(label).long()

        return img, label
