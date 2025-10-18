import argparse
from pathlib import Path
import requests
import sys
import json

def predict_one(url: str, image_path: Path, topk: int = 3, timeout: float = 15.0):
    files = {"file": (image_path.name, open(image_path, "rb"), "application/octet-stream")}
    params = {"topk": topk}
    try:
        r = requests.post(f"{url.rstrip('/')}/predict", files=files, params=params, timeout=timeout)
        r.raise_for_status()
    except requests.exceptions.RequestException as e:
        return {"error": f"{type(e).__name__}: {e}"}
    try:
        return r.json()
    except Exception:
        return {"error": f"Non-JSON response: {r.text[:200]}..."}

def main():
    ap = argparse.ArgumentParser(description="Client for ONNX FastAPI /predict")
    ap.add_argument("--url", default="http://127.0.0.1:8000", help="Base URL of the inference server")
    ap.add_argument("--topk", type=int, default=3, help="Top-k predictions")
    ap.add_argument("path", help="Path to an image file OR a directory of images")
    args = ap.parse_args()

    p = Path(args.path)
    if not p.exists():
        print(f"Path not found: {p}", file=sys.stderr)
        sys.exit(1)

    exts = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
    images = []
    if p.is_file():
        images = [p]
    else:
        images = sorted([x for x in p.rglob("*") if x.suffix.lower() in exts])

    if not images:
        print("No images found to send.", file=sys.stderr)
        sys.exit(2)

    for img in images:
        res = predict_one(args.url, img, topk=args.topk)
        print(f"\n=== {img} ===")
        if "error" in res:
            print("ERROR:", res["error"])
        else:
            
            for i, item in enumerate(res.get("topk", []), 1):
                print(f"{i:>2}. {item['label']:<30} p={item['prob']:.4f}")

if __name__ == "__main__":
    main()
