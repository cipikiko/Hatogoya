from typing import Optional

import torch
import torch.nn as nn
from tqdm import tqdm

from ai.src.training.data.prefetch import maybe_wrap_prefetch
from ai.src.training.engine.mixup import do_mixup, mixup_loss
try:
    # new location after refactor
    from ai.src.runtime.cuda_prefetcher import CUDAPrefetcher
except ModuleNotFoundError:
    # legacy location (pre-refactor)
    from ai.src.runtime.cuda_prefetcher import CUDAPrefetcher

def train_one_epoch(
    model,
    loader,
    device,
    optimizer,
    criterion,
    scaler: Optional[torch.amp.GradScaler],
    use_amp: bool,
    max_grad_norm: Optional[float],
    use_prefetch: bool,
    num_classes: int,
    mixup_alpha: float = 0.2,
    max_steps: Optional[int] = None,
    accumulate_steps: int = 1,
):
    model.train()
    running = 0.0
    wrapped = maybe_wrap_prefetch(loader, device, use_prefetch)
    pbar = tqdm(wrapped, desc="train", leave=False)
    optimizer.zero_grad(set_to_none=True)
    steps = 0

    for batch in pbar:
        if isinstance(wrapped, CUDAPrefetcher):
            x, y = batch
        else:
            x, y = batch
            x = x.to(device, non_blocking=True)
            y = y.to(device, non_blocking=True)
            if device.type == "cuda" and x.ndim == 4:
                x = x.to(memory_format=torch.channels_last)

        xm, y_raw, mix = do_mixup(x, y, num_classes, alpha=mixup_alpha)

        if use_amp:
            with torch.amp.autocast("cuda"):
                logits = model(xm)
                loss = mixup_loss(logits, mix) if mix is not None else criterion(logits, y_raw)
            loss = loss / max(1, accumulate_steps)
            scaler.scale(loss).backward()
            if (steps + 1) % accumulate_steps == 0:
                if max_grad_norm is not None:
                    scaler.unscale_(optimizer)
                    nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm)
                scaler.step(optimizer)
                scaler.update()
                optimizer.zero_grad(set_to_none=True)
        else:
            logits = model(xm)
            loss = mixup_loss(logits, mix) if mix is not None else criterion(logits, y_raw)
            loss = loss / max(1, accumulate_steps)
            loss.backward()
            if (steps + 1) % accumulate_steps == 0:
                if max_grad_norm is not None:
                    nn.utils.clip_grad_norm_(model.parameters(), max_grad_norm)
                optimizer.step()
                optimizer.zero_grad(set_to_none=True)

        running += (loss.item() * max(1, accumulate_steps)) * x.size(0)
        pbar.set_postfix(loss=f"{(loss.item() * max(1, accumulate_steps)):.4f}")
        steps += 1
        if max_steps is not None and steps >= max_steps:
            break

    denom = min(len(loader.dataset), steps * loader.batch_size) or 1
    return running / denom
