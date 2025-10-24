import numpy as np
import torch

def do_mixup(x, y, num_classes: int, alpha: float = 0.2):
    if alpha <= 0:
        return x, y, None
    lam = np.random.beta(alpha, alpha)
    idx = torch.randperm(x.size(0), device=x.device)
    mixed_x = lam * x + (1 - lam) * x[idx]
    y1 = torch.nn.functional.one_hot(y, num_classes=num_classes).float()
    y2 = y1[idx]
    return mixed_x, y, (y1, y2, lam)

def mixup_loss(logits, mix_target):
    if mix_target is None:
        raise ValueError("mix_target is None; call only when mixup is applied")
    y1, y2, lam = mix_target
    ce = torch.nn.functional.cross_entropy
    return lam * ce(logits, y1.argmax(1)) + (1 - lam) * ce(logits, y2.argmax(1))
