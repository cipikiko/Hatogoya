from typing import Dict, Any
import torch

def device_from_cfg(cfg: Dict[str, Any]) -> torch.device:
    want = cfg.get("train", {}).get("device", "cuda")
    if want == "cuda" and torch.cuda.is_available():
        return torch.device("cuda")
    return torch.device("cpu")
