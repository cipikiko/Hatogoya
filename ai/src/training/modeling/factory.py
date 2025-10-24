import timm
import torch.nn as nn

def build_model(model_name: str, num_classes: int | None) -> nn.Module:
    # If num_classes None, timm will try to infer; but usually set explicitly.
    return timm.create_model(model_name, pretrained=True, num_classes=num_classes)
