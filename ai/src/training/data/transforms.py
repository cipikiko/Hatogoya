from albumentations import (
    Compose, Resize, CenterCrop, HorizontalFlip, Normalize,
    RandomResizedCrop, ShiftScaleRotate, RGBShift, HueSaturationValue
)
from albumentations.pytorch import ToTensorV2

IMAGENET_MEAN = (0.485, 0.456, 0.406)
IMAGENET_STD  = (0.229, 0.224, 0.225)

def train_transforms(img_size: int):
    return Compose([
        RandomResizedCrop(size=(img_size, img_size), scale=(0.6, 1.0), ratio=(0.75, 1.33)),
        HorizontalFlip(p=0.5),
        ShiftScaleRotate(shift_limit=0.02, scale_limit=0.15, rotate_limit=20, p=0.5, border_mode=0),
        HueSaturationValue(p=0.2),
        RGBShift(p=0.2),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])

def val_transforms(img_size: int):
    return Compose([
        Resize(height=img_size, width=img_size),
        CenterCrop(height=img_size, width=img_size),
        Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ToTensorV2(),
    ])
