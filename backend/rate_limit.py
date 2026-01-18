import os
import time
from typing import Dict, Tuple

# In-memory store: key -> (window_start, count)
_STORE: Dict[str, Tuple[float, int]] = {}

def _now() -> float:
    return time.time()

def allow(key: str, limit: int, window_seconds: int) -> bool:
    """
    Simple fixed-window counter.
    Returns True if request is allowed, False if rate-limited.

    Can be disabled with env:
      RATE_LIMIT_ENABLED=0
    """
    # ✅ Disable rate limiting via env var
    if os.getenv("RATE_LIMIT_ENABLED", "1") == "0":
        return True

    now = _now()
    window_start, count = _STORE.get(key, (now, 0))

    # New window
    if now - window_start >= window_seconds:
        _STORE[key] = (now, 1)
        return True

    # Limit reached
    if count >= limit:
        return False

    _STORE[key] = (window_start, count + 1)
    return True

def retry_after_seconds(key: str, window_seconds: int) -> int:
    window_start, _ = _STORE.get(key, (_now(), 0))
    remaining = int(window_seconds - (_now() - window_start))
    return max(0, remaining)
