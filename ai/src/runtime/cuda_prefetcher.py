# ai/src/cuda_prefetcher.py
import torch

class CUDAPrefetcher:
    """
    Wrap a DataLoader to prefetch batches to GPU asynchronously via a CUDA stream.
    Use only when device.type == 'cuda'.
    """
    def __init__(self, loader, device: torch.device, non_blocking=True):
        self.loader = loader
        self.device = device
        self.stream = torch.cuda.Stream()
        self.non_blocking = non_blocking
        self.iter = None
        self.next_batch = None

    def __len__(self):
        return len(self.loader)

    def __iter__(self):
        self.iter = iter(self.loader)
        self.next_batch = None
        self._preload()
        return self

    def __next__(self):
        torch.cuda.current_stream().wait_stream(self.stream)
        if self.next_batch is None:
            raise StopIteration
        batch = self.next_batch
        self._preload()
        return batch

    def _preload(self):
        try:
            x, y = next(self.iter)
        except StopIteration:
            self.next_batch = None
            return
        with torch.cuda.stream(self.stream):
            x = x.to(self.device, non_blocking=self.non_blocking)
            y = y.to(self.device, non_blocking=self.non_blocking)
            self.next_batch = (x, y)
