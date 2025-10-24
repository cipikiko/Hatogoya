import argparse
import json
from pathlib import Path
import torch
import timm
import yaml
import onnx
import onnxruntime as ort
import numpy as np

def load_cfg(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def device_from_cfg(cfg):
    want = cfg["train"].get("device", "cuda")
    return torch.device("cuda") if (want == "cuda" and torch.cuda.is_available()) else torch.device("cpu")

def main(cfg_path):
    cfg = load_cfg(cfg_path)

    onnx_path = Path(cfg["export"]["onnx_path"])
    best_ckpt = Path(cfg["paths"]["best_ckpt"])
    input_name = cfg["export"].get("input_name", "input")
    output_name = cfg["export"].get("output_name", "logits")

    if not best_ckpt.exists():
        raise FileNotFoundError(f"Checkpoint not found: {best_ckpt}")

    # Load checkpoint
    ckpt = torch.load(best_ckpt, map_location="cpu")
    classes = ckpt.get("classes", [])
    num_classes = len(classes) if classes else None

    # Build model
    model_name = cfg["train"]["model_name"]
    model = timm.create_model(model_name, pretrained=False, num_classes=num_classes)
    state_dict = ckpt["model"] if "model" in ckpt else ckpt
    model.load_state_dict(state_dict, strict=True)
    model.eval()

    img_size = int(cfg["data"]["img_size"])
    dummy = torch.randn(1, 3, img_size, img_size)

    # Export
    print(f"Exporting model to {onnx_path} ...")
    Path(onnx_path).parent.mkdir(parents=True, exist_ok=True)

    torch.onnx.export(
        model,
        dummy,
        onnx_path,
        input_names=[input_name],
        output_names=[output_name],
        opset_version=17,
        dynamic_axes={input_name: {0: "batch"}, output_name: {0: "batch"}},
    )
    print("✔ Export complete.")

    # Validate
    print("Validating ONNX model ...")
    model_onnx = onnx.load(onnx_path)
    onnx.checker.check_model(model_onnx)
    print("✔ ONNX structure check passed.")

    # Inference test
    ort_sess = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])
    out = ort_sess.run(None, {input_name: dummy.numpy().astype(np.float32)})
    print(f"✔ ONNX runtime test passed. Output shape: {np.array(out[0]).shape}")

    if classes:
        txt_path = Path("ai/models/classes.txt")
        txt_path.write_text("\n".join(classes), encoding="utf-8")
        print("✔ Saved class labels to", txt_path)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", "-c", default="ai/config/train.yaml")
    args = ap.parse_args()
    main(args.config)
