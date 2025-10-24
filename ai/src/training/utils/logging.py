from pathlib import Path

class CSVLogger:
    def __init__(self, out_dir: Path):
        self.out_dir = Path(out_dir)
        self.out_dir.mkdir(parents=True, exist_ok=True)
        self.fp = (self.out_dir / "metrics.csv").open("w", encoding="utf-8")
        self.fp.write("epoch,train_loss,val_loss,macro_f1,lr,seconds\n")
        self.fp.flush()

    def log(self, epoch, train_loss, val_loss, macro_f1, lr, seconds):
        self.fp.write(f"{epoch},{train_loss:.6f},{val_loss:.6f},{macro_f1:.6f},{lr:.8f},{seconds:.2f}\n")
        self.fp.flush()

    def close(self):
        try:
            self.fp.close()
        except Exception:
            pass
