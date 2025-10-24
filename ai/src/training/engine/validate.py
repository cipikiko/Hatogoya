from typing import Optional, Tuple, List
import torch
import torch.nn as nn
from sklearn.metrics import f1_score

@torch.inference_mode()
def validate(model: nn.Module, loader, device: torch.device, criterion: nn.Module,
             max_batches: Optional[int] = None) -> Tuple[float, float]:
    model.eval()
    total_loss = 0.0
    preds: List[int] = []
    gts:   List[int] = []
    seen = 0

    for bi, batch in enumerate(loader, 1):
        x, y = batch
        x = x.to(device, non_blocking=True)
        y = y.to(device, non_blocking=True)
        if device.type == "cuda" and x.ndim == 4:
            x = x.to(memory_format=torch.channels_last)
        logits = model(x)
        loss = criterion(logits, y)
        total_loss += loss.item() * x.size(0)
        preds.extend(logits.argmax(1).detach().cpu().tolist())
        gts.extend(y.detach().cpu().tolist())
        seen += x.size(0)
        if max_batches is not None and bi >= max_batches:
            break

    denom = seen if seen > 0 else len(loader.dataset)
    avg_loss = total_loss / max(1, denom)
    macro_f1 = f1_score(gts, preds, average="macro") if len(set(gts)) > 1 else 0.0
    return avg_loss, macro_f1
