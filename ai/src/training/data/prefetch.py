# ai/src/training/data/prefetch.py
import torch

try:
    # new location after refactor
    from ai.src.runtime.cuda_prefetcher import CUDAPrefetcher
except ModuleNotFoundError:
    # old location, in case you didn’t move it
    from ai.src.runtime.cuda_prefetcher import CUDAPrefetcher


def maybe_wrap_prefetch(loader, device: torch.device, enable: bool):
    if device.type == "cuda" and enable:
        return CUDAPrefetcher(loader, device)
    return loader
