import numpy as np
import torch

class WarmupCosine(torch.optim.lr_scheduler._LRScheduler):
    def __init__(self, optimizer, warmup_epochs, total_epochs, min_lr=1e-6, last_epoch=-1):
        self.warmup_epochs = int(warmup_epochs)
        self.total_epochs = int(total_epochs)
        self.min_lr = float(min_lr)
        super().__init__(optimizer, last_epoch)

    def get_lr(self):
        e = max(0, self.last_epoch)
        lrs = []
        for base_lr in self.base_lrs:
            if e < self.warmup_epochs:
                lrs.append(base_lr * (e + 1) / max(1, self.warmup_epochs))
            else:
                t = (e - self.warmup_epochs) / max(1, self.total_epochs - self.warmup_epochs)
                lr = self.min_lr + 0.5 * (base_lr - self.min_lr) * (1 + np.cos(np.pi * t))
                lrs.append(lr)
        return lrs
