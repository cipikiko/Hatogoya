# 🌱 Hatogoya AI Module — Comprehensive Training, Evaluation & Dataset Pipeline Manual

## 1. Overview

The **Hatogoya AI module** implements an end-to-end deep learning pipeline for image classification tasks.
It uses **PyTorch** with **HDF5-based datasets** to efficiently train and evaluate neural networks on large-scale image data (such as the PlantNet-300K dataset).
The workflow supports both **CPU** and **GPU (CUDA)** execution environments, with configurable batch size, learning rate, and model architecture.

---

## 2. Project Structure

```
Hatogoya/
├── ai/
│   ├── config/
│   │   └── train.yaml                     # Training configuration
│   ├── data/
│   │   └── plantnet_300K.h5               # HDF5 dataset file (≈ 40 GB)
│   ├── experiments/
│   │   ├── run_YYYYMMDD_HHMMSS/           # Training logs and metrics
│   │   └── report_YYYYMMDD_HHMMSS/        # Evaluation reports and plots
│   ├── models/
│   │   └── best.pt                        # Best trained model checkpoint
│   └── src/
│       ├── train.py                       # Main training script
│       ├── eval_report.py                 # Evaluation and metrics generation
│       ├── plot_training.py               # Visualization of training metrics
│       ├── plantnet_to_hdf5.py            # Dataset conversion script
│       ├── hdf5_dataset.py                # HDF5 dataset loader
│       ├── hdf5_dataset_bytes.py          # Variant for encoded datasets
│       └── model_zoo/                     # Model definitions (EfficientNet, etc.)
└── .venv/                                 # Python virtual environment
```

---

## 3. Environment Setup

### 3.1 Activate or create a virtual environment

```bash
cd ~/Hatogoya/ai
source .venv/bin/activate
```

If the environment doesn’t exist:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

If missing dependencies, install manually:

```bash
pip install torch torchvision albumentations h5py scikit-learn pandas matplotlib pyyaml tqdm
```

### 3.2 (Optional) Install CUDA-enabled PyTorch

If you have an NVIDIA GPU (e.g., RTX 2080 Ti):

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

---

## 4. Dataset Handling

### 4.1 Dataset structure

Your dataset (PlantNet-300K) should be located at:

```
/home/propagandalf/dataset/plantnet_300K/
```

Typical structure:
```
images/        # image files organized by class folders
metadata/      # auxiliary CSV or JSON with labels and taxonomy
labels.csv     # mapping of image filenames to class indices
```

### 4.2 Convert dataset to HDF5 format

The `plantnet_to_hdf5.py` script reads all image files, encodes them, and writes them into a single `.h5` binary container with corresponding labels.

```bash
python -m ai.src.plantnet_to_hdf5   --root ~/dataset/plantnet_300K/images   --out ~/Hatogoya/ai/data/plantnet_300K.h5
```

After completion, the file will appear at:
```
ai/data/plantnet_300K.h5  (~40 GB)
```

---

## 5. Configuration

### 5.1 Modify `train.yaml`

Defines **data paths**, **training hyperparameters**, and **model parameters**.

```yaml
data:
  hdf5_path: ai/data/plantnet_300K.h5
  img_size: 224

train:
  model_name: efficientnet_b0
  batch_size: 24
  lr: 0.0003
  epochs: 10
  early_stop_patience: 5
  num_workers: 2
  save_best_only: true
```

---

## 6. Training Pipeline

### 6.1 Launch training

```bash
python -m ai.src.train --config ai/config/train.yaml
```

### 6.2 What happens internally

1. Configuration parsing (`yaml.safe_load`)
2. Dataset loading from `.h5` using `H5ClassificationDataset`
3. Data augmentation (`albumentations`)
4. Model initialization from `model_zoo`
5. Training loop (Adam optimizer + mixed precision)
6. Early stopping and checkpointing

Each run creates:
```
ai/experiments/run_YYYYMMDD_HHMMSS/
├── metrics.csv
├── config_snapshot.yaml
├── training_log.txt
└── model_last.pt
```

---

## 7. Visualization and Analysis

### 7.1 Generate plots

```bash
RUN_DIR=$(ls -dt ai/experiments/run_* | head -1)
python -m ai.src.plot_training "$RUN_DIR/metrics.csv"
```

### 7.2 Output
```
loss_curve.png
f1_curve.png
lr_schedule.png
```

---

## 8. Evaluation and Reports

### 8.1 Run evaluation

```bash
python -m ai.src.eval_report   --config ai/config/train.yaml   --ckpt ai/models/best.pt
```

### 8.2 Output folder
```
ai/experiments/report_YYYYMMDD_HHMMSS/
├── summary.txt
├── per_class_metrics.csv
└── confusion_matrix_top50.png
```

---

## 9. GPU and Performance Optimization

### 9.1 Check GPU
```bash
python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```

### 9.2 Limit VRAM usage
Inside `train.py`:
```python
torch.cuda.set_per_process_memory_fraction(0.9)
```

Reduce to 0.8 for safety.

### 9.3 Reduce RAM load
Lower `batch_size` or `num_workers`.

---

## 10. Workflow Summary

1. Convert dataset → HDF5  
2. Edit config  
3. Train model  
4. Plot metrics  
5. Evaluate model  
6. Inspect results  

---

## 11. Script Reference

| Script | Purpose |
|--------|----------|
| **train.py** | Handles full training loop, checkpointing, early stopping |
| **eval_report.py** | Evaluates model, generates metrics and plots |
| **plot_training.py** | Creates loss/F1/LR graphs |
| **plantnet_to_hdf5.py** | Converts raw PlantNet dataset to `.h5` |
| **hdf5_dataset.py** | Loads unencoded datasets |
| **hdf5_dataset_bytes.py** | Loads byte-encoded datasets |
| **model_zoo/** | Contains neural network architectures |

---

## 12. Troubleshooting

| Issue | Likely Cause | Fix |
|--------|---------------|----|
| `ModuleNotFoundError: pandas` | Missing dependency | `pip install pandas matplotlib` |
| `Number of classes mismatch` | Class imbalance in validation set | Use latest `eval_report.py` |
| Training too slow | CPU fallback | Install CUDA build |
| GPU 0% usage | WSL GPU passthrough issue | Restart WSL / reinstall NVIDIA drivers |
| Memory overflow | High batch size | Reduce `batch_size` or workers |

---

## 13. Notes for Thesis Documentation

- HDF5 minimizes I/O overhead for large image datasets.
- Modular scripts support other classification datasets.
- Logs and metrics are CSV-based for reproducibility.
- Supports full GPU acceleration and mixed-precision training.
