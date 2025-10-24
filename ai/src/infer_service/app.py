from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import io, os, json
from pathlib import Path

import numpy as np
from PIL import Image
import onnxruntime as ort


DEFAULT_MODEL_PATH = os.getenv("MODEL_PATH", "ai/models/model.onnx")
DEFAULT_CLASSES_TXT = os.getenv("CLASSES_PATH", "ai/models/classes.txt")
IMG_SIZE = int(os.getenv("IMG_SIZE", "224"))  # must match training/export

IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
IMAGENET_STD  = np.array([0.229, 0.224, 0.225], dtype=np.float32)


app = FastAPI(title="Vision Inference (ONNX)")


app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ALLOW_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def load_classes(path: str):
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(f"classes.txt not found at {p}")
    return [l.strip() for l in p.read_text(encoding="utf-8").splitlines() if l.strip()]

def load_session(model_path: str):
    p = Path(model_path)
    if not p.exists():
        raise FileNotFoundError(f"ONNX model not found at {p}")
   
    providers = ["CPUExecutionProvider"]
    return ort.InferenceSession(p.as_posix(), providers=providers)

CLASS_NAMES = load_classes(DEFAULT_CLASSES_TXT)
ORT_SESS = load_session(DEFAULT_MODEL_PATH)
INPUT_NAME = ORT_SESS.get_inputs()[0].name
OUTPUT_NAME = ORT_SESS.get_outputs()[0].name


def preprocess(pil_img: Image.Image, size: int = IMG_SIZE) -> np.ndarray:
    img = pil_img.convert("RGB").resize((size, size), Image.BILINEAR)
    x = np.asarray(img).astype("float32") / 255.0  # HWC, [0,1]
    x = (x - IMAGENET_MEAN) / IMAGENET_STD
    x = np.transpose(x, (2, 0, 1))  # CHW
    x = np.expand_dims(x, 0)        # NCHW
    return x

def softmax(x: np.ndarray) -> np.ndarray:
    x = x - np.max(x, axis=1, keepdims=True)
    e = np.exp(x)
    return e / np.sum(e, axis=1, keepdims=True)

def postprocess(logits: np.ndarray, topk: int = 3):
    probs = softmax(logits)[0]  # 1 x C -> C
    idxs = probs.argsort()[::-1][:topk]
    return [{"label": CLASS_NAMES[i], "prob": float(probs[i])} for i in idxs]


class PredictResponse(BaseModel):
    topk: list[dict]


@app.get("/health")
def health():
    return {
        "status": "ok",
        "model": Path(DEFAULT_MODEL_PATH).name,
        "num_classes": len(CLASS_NAMES),
        "input_name": INPUT_NAME,
        "output_name": OUTPUT_NAME,
        "img_size": IMG_SIZE,
    }

@app.post("/predict", response_model=PredictResponse)
async def predict(file: UploadFile = File(...), topk: int = 3):
    try:
        raw = await file.read()
        pil = Image.open(io.BytesIO(raw))
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file")

    x = preprocess(pil, IMG_SIZE)
    logits = ORT_SESS.run([OUTPUT_NAME], {INPUT_NAME: x})[0]  # (1, C)
    return {"topk": postprocess(logits, topk=topk)}
