from __future__ import annotations
import math, time, os
from dataclasses import dataclass, asdict
from typing import Optional, Dict, Any, Tuple, List

import h5py
import numpy as np
import torch

# Prefer new package layout; fall back if needed
try:
    from ai.src.datasets.hdf5_dataset import H5ClassificationDataset as PixelsDS
    from ai.src.datasets.hdf5_dataset_bytes import H5BytesClassificationDataset as BytesDS
except ModuleNotFoundError:  # legacy layout
    from ai.src.hdf5_dataset import H5ClassificationDataset as PixelsDS
    from ai.src.hdf5_dataset_bytes import H5BytesClassificationDataset as BytesDS

# a minimal transform pipeline to get tensors in [0,1], no normalization/resize
try:
    from albumentations import Compose
    from albumentations.pytorch import ToTensorV2
    _TO_TENSOR = Compose([ToTensorV2()])
except Exception:
    _TO_TENSOR = None  # We'll fallback to dataset default if albumentations isn't available


@dataclass
class DataInsights:
    num_samples: int
    num_classes: int
    class_counts: List[int]
    imbalance_ratio: float  # max_count / min_count (>=1)
    storage: str  # 'pixels' or 'encoded_bytes'
    channels: int
    height: int
    width: int
    per_channel_mean: Optional[List[float]] = None
    per_channel_std: Optional[List[float]] = None


@dataclass
class SuggestedTrain:
    device: str
    model_name: str
    img_size: int
    batch_size: int
    val_batch_size: int
    epochs: int
    lr: float
    weight_decay: float
    label_smoothing: float
    warmup_epochs: int
    grad_checkpoint: bool
    use_weighted_sampler: bool
    accumulate_steps: int
    mixup_alpha: float
    max_grad_norm: float
    val_max_batches: Optional[int] = None
    max_steps_per_epoch: Optional[int] = None


@dataclass
class SuggestedConfig:
    seed: int
    data: Dict[str, Any]
    train: SuggestedTrain
    paths: Dict[str, str]


def _read_h5_meta(h5_path: str) -> Tuple[set, str, List[str], Tuple[int,int,int] | None]:
    with h5py.File(h5_path, "r") as h:
        groups = set(h.keys())
        storage = h.attrs.get("storage", "pixels")
        classes = list(h.attrs.get("classes", []))
        shape = h.attrs.get("image_shape", None)  # optional (c,h,w) or (h,w,c)
        if shape is not None:
            shape = tuple(int(x) for x in shape)
    return groups, storage, classes, shape


def _class_counts(h5_path: str, split: str) -> np.ndarray:
    with h5py.File(h5_path, "r") as h:
        key = f"{split}/labels"
        if key not in h:
            raise RuntimeError(f"Missing '{key}' in {h5_path}")
        y = h[key][:]
    y = y.astype(np.int64)
    if y.size == 0:
        return np.zeros(1, dtype=np.int64)
    k = int(np.max(y)) + 1
    counts = np.bincount(y, minlength=k)
    return counts


def sample_mean_std(h5_path: str, split: str, n_samples: int = 512) -> Tuple[List[float], List[float], Tuple[int,int,int]]:
    """Compute per-channel mean/std over a sample. Works for both storage types via dataset classes."""
    # pick DS
    _, storage, _, _ = _read_h5_meta(h5_path)
    DS = BytesDS if storage == "encoded_bytes" else PixelsDS

    # minimal transform to tensor-only
    ds = DS(h5_path, split=split, atransforms=_TO_TENSOR)
    n = len(ds)
    if n == 0:
        raise RuntimeError(f"No samples in split '{split}'")

    # sample indices
    rng = np.random.default_rng(123)
    take = min(n_samples, n)
    idx = rng.choice(n, size=take, replace=False)
    # fetch
    ch_first = []
    shape = None
    for i in idx:
        x, _ = ds[i]  # tensor CxHxW
        if not torch.is_tensor(x):
            raise RuntimeError("Expected tensor from dataset")
        shape = tuple(x.shape)  # C,H,W
        ch_first.append(x.float().unsqueeze(0))
    X = torch.cat(ch_first, dim=0)  # N,C,H,W
    # normalize to [0,1] if needed
    if X.max() > 1.5:  # likely 0..255
        X = X / 255.0
    mean = X.mean(dim=[0,2,3]).tolist()
    std  = X.std(dim=[0,2,3], unbiased=False).tolist()
    return mean, std, shape


def get_data_insights(h5_path: str, img_size: Optional[int]) -> DataInsights:
    groups, storage, classes, shape_attr = _read_h5_meta(h5_path)
    # choose existing split
    split = "train" if "train" in groups else next(iter(groups))
    counts = _class_counts(h5_path, split=split)
    num_samples = int(counts.sum())
    num_classes = int(len(counts))
    imb = float((counts.max() / max(1, counts[counts > 0].min()))) if num_classes > 0 else 1.0

    # channel/shape inference
    ch = 3; h = img_size or 224; w = img_size or 224
    mean = std = None
    if shape_attr is not None:
        if len(shape_attr) == 3:
            # try to normalize to C,H,W
            if shape_attr[0] in (1,3,4):
                ch, h, w = shape_attr
            else:
                h, w, ch = shape_attr
    # try sampling if Albumentations available
    try:
        mean, std, shape = sample_mean_std(h5_path, split=split, n_samples=min(512, num_samples))
        ch, h, w = shape
    except Exception:
        pass

    return DataInsights(
        num_samples=num_samples,
        num_classes=num_classes,
        class_counts=counts.tolist(),
        imbalance_ratio=imb,
        storage=storage,
        channels=ch, height=h, width=w,
        per_channel_mean=mean, per_channel_std=std
    )


def _global_batch_size(local_bs: int, accumulate: int, world: int = 1) -> int:
    return local_bs * max(1, accumulate) * max(1, world)


def _linear_scaled_lr(base_lr: float, base_gbs: int, gbs: int) -> float:
    return base_lr * (gbs / base_gbs)


def _estimate_steps_and_epochs(n_samples: int, gbs: int, target_updates: int = 20000) -> Tuple[int,int]:
    """Pick epochs to hit ~target_updates optimizer steps."""
    steps_per_epoch = max(1, math.ceil(n_samples / gbs))
    epochs = max(1, round(target_updates / steps_per_epoch))
    return steps_per_epoch, epochs


def _detect_device(want: str) -> str:
    if want == "cuda" and torch.cuda.is_available():
        return "cuda"
    return "cpu"


def _binary_search_batch(model_name: str, img_sz: int, device: str, amp: bool, cap_mem_frac: float = 0.85) -> int:
    """
    Try to find the largest batch size that fits by actually building the model and running a fwd/bwd.
    We use timm; if not installed, fallback to a heuristic.
    """
    try:
        import timm
    except Exception:
        # heuristic fallback
        base = 64
        scale = (img_sz / 224) ** 2
        return max(8, int(base / max(1.0, scale)))

    dev = torch.device(device)
    model = timm.create_model(model_name, pretrained=False, num_classes=10).to(dev)
    if dev.type == "cuda":
        model = model.to(memory_format=torch.channels_last)
    criterion = torch.nn.CrossEntropyLoss().to(dev)
    opt = torch.optim.AdamW(model.parameters(), lr=1e-3)

    # crude search bounds
    lo, hi = 1, 1024
    best = 1
    dtype_ctx = torch.amp.autocast("cuda") if (amp and dev.type == "cuda") else torch.cuda.amp.autocast(enabled=False)

    while lo <= hi:
        mid = (lo + hi) // 2
        try:
            torch.cuda.empty_cache() if dev.type == "cuda" else None
            x = torch.randn(mid, 3, img_sz, img_sz, device=dev)
            if dev.type == "cuda":
                x = x.to(memory_format=torch.channels_last)
            y = torch.randint(0, 10, (mid,), device=dev)

            with dtype_ctx:
                out = model(x)
                loss = criterion(out, y)
            opt.zero_grad(set_to_none=True)
            if amp and dev.type == "cuda":
                scaler = torch.cuda.amp.GradScaler()
                scaler.scale(loss).backward()
                scaler.step(opt); scaler.update()
            else:
                loss.backward()
                opt.step()

            # simple headroom check
            if dev.type == "cuda":
                props = torch.cuda.get_device_properties(dev)
                used = torch.cuda.max_memory_allocated(dev)
                if used / props.total_memory > cap_mem_frac:
                    # too close to the edge, reduce
                    hi = mid - 1
                    continue

            best = mid
            lo = mid + 1
        except RuntimeError as e:
            if "out of memory" in str(e).lower():
                torch.cuda.empty_cache() if dev.type == "cuda" else None
                hi = mid - 1
            else:
                # unknown failure, bail to previous best
                hi = mid - 1
        except Exception:
            hi = mid - 1
    try:
        del model
    except Exception:
        pass
    return max(1, best)


def suggest_from_dataset(
    h5_path: str,
    model_name: str = "resnet50",
    device_want: str = "cuda",
    img_size: Optional[int] = None,
    target_updates: int = 20000,
    prefer_amp: bool = True,
) -> SuggestedConfig:
    """
    Look at the dataset and propose a training config:
    - batch size (by actual GPU probing when possible)
    - LR via linear scaling rule (base: lr=5e-4 at global_bs=64)
    - epochs to reach ~target_updates optimizer steps
    - mixup from class imbalance
    - weighted sampler when imbalance is high
    - class weights if needed
    """
    insights = get_data_insights(h5_path, img_size)
    if img_size is None:
        img_size = max(insights.height, insights.width)

    device = _detect_device(device_want)
    amp = prefer_amp and (device == "cuda")

    # Estimate a safe per-GPU batch size
    local_bs = _binary_search_batch(model_name, img_size, device, amp)

    # We'll keep accumulate=1 by default; leave room to bump it later
    accumulate = 1
    gbs = _global_batch_size(local_bs, accumulate, world=1)
    steps_per_epoch, epochs = _estimate_steps_and_epochs(insights.num_samples, gbs, target_updates=target_updates)

    # LR via linear scaling (base 5e-4 at global_bs=64 is a steady default for AdamW)
    base_lr = 5e-4
    base_gbs = 64
    lr = _linear_scaled_lr(base_lr, base_gbs, gbs)

    # Mixup heuristic: turn on for noticeable imbalance
    mixup_alpha = 0.0
    if insights.imbalance_ratio >= 1.5:
        mixup_alpha = 0.2 if insights.imbalance_ratio < 3 else 0.4

    # Weighted sampler if imbalanced
    use_weighted = insights.imbalance_ratio >= 1.5

    # Weight decay by architecture family
    wd = 0.05 if "vit" in model_name.lower() or "swin" in model_name.lower() else 1e-4

    # Warmup ~ 3–10 epochs depending on total epochs
    warmup = int(max(3, min(10, round(0.1 * epochs))))

    sug = SuggestedConfig(
        seed=42,
        data={
            "hdf5_path": h5_path,
            "img_size": img_size,
            "num_workers": min(8, os.cpu_count() or 2),
            "prefetch_factor": 2,
            "cuda_prefetch": device == "cuda",
        },
        train=SuggestedTrain(
            device=device,
            model_name=model_name,
            img_size=img_size,
            batch_size=local_bs,
            val_batch_size=min(max(32, local_bs * 2), local_bs * 4),
            epochs=epochs,
            lr=float(lr),
            weight_decay=wd,
            label_smoothing=0.0,
            warmup_epochs=warmup,
            grad_checkpoint=False,
            use_weighted_sampler=use_weighted,
            accumulate_steps=accumulate,
            mixup_alpha=mixup_alpha,
            max_grad_norm=1.0,
            val_max_batches=None,
            max_steps_per_epoch=None,
        ),
        paths={
            "best_ckpt": "ai/models/best.pt",
            "last_ckpt": "ai/models/last.pt",
        },
    )
    return sug


def to_yaml(cfg: SuggestedConfig) -> str:
    """Serialize SuggestedConfig to a tidy YAML string."""
    try:
        import yaml
    except Exception:
        # very simple yaml-like dump fallback
        import json
        return json.dumps(asdict(cfg), indent=2)
    def _num(x):
        if isinstance(x, float):
            return float(f"{x:.8g}")
        return x
    d = asdict(cfg)
    # numeric prettify
    d["train"]["lr"] = _num(d["train"]["lr"])
    txt = yaml.safe_dump(d, sort_keys=False)
    return txt
