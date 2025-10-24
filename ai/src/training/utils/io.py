from pathlib import Path
import torch
import torch.nn as nn

def ensure_parent(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)

def save_best(ckpt_path: Path, model: nn.Module, classes: list[str] | None):
    ensure_parent(ckpt_path)
    torch.save({"model": model.state_dict(), "classes": classes or []}, ckpt_path)
