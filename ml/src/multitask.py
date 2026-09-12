"""Multi-task model: one shared neural backbone, two disease risk heads.

A scikit-learn MLPClassifier trained on a 2-column label matrix is, in effect, a
shared-representation network: the hidden layers form the common backbone and the
two output neurons are the diabetes and kidney "heads". This mirrors the
architecture described in the project documentation, with no heavy dependencies.
"""
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.metrics import (
    recall_score, precision_score, f1_score, roc_auc_score,
    average_precision_score, confusion_matrix, precision_recall_curve,
)

from . import config as C

PROCESSED = C.ML_ROOT / "data" / "processed" / "brfss_multitask_2015.csv"
LABELS = ["Diabetes_binary", "Kidney_binary"]
# Screening goal: catch at least this fraction of true cases (sensitivity).
# The operating threshold for each disease is tuned to meet this, rather than
# guessed, because each head's probabilities are scaled differently.
TARGET_RECALL = 0.85


def tune_threshold(y_true, proba, target_recall=TARGET_RECALL):
    """Highest probability threshold that still achieves the target recall
    (i.e. the best-precision operating point that meets our sensitivity goal)."""
    prec, rec, thr = precision_recall_curve(y_true, proba)
    rec_t, thr = rec[:-1], thr            # align lengths
    mask = rec_t >= target_recall
    if not mask.any():
        return 0.0
    idxs = np.where(mask)[0]
    return float(thr[idxs[np.argmax(thr[idxs])]])


def load():
    df = pd.read_csv(PROCESSED)
    feats = [f for f in C.FEATURES if f in df.columns]
    X = df[feats].astype(float)
    Y = df[LABELS].astype(int)
    return X, Y, feats


def split_and_scale(X, Y):
    """Three-way split: fit (train model) / val (tune thresholds) / test (report)."""
    X_tr, X_te, Y_tr, Y_te = train_test_split(
        X, Y, test_size=C.TEST_SIZE, random_state=C.RANDOM_STATE,
        stratify=Y["Kidney_binary"],   # stratify on the rarer label
    )
    X_fit, X_val, Y_fit, Y_val = train_test_split(
        X_tr, Y_tr, test_size=0.20, random_state=C.RANDOM_STATE,
        stratify=Y_tr["Kidney_binary"],
    )
    scaler = StandardScaler()
    X_fit_s = scaler.fit_transform(X_fit)
    X_val_s = scaler.transform(X_val)
    X_te_s = scaler.transform(X_te)
    return (X_fit_s, X_val_s, X_te_s,
            Y_fit.reset_index(drop=True), Y_val.reset_index(drop=True),
            Y_te.reset_index(drop=True), scaler)


def build_multitask():
    """Shared backbone (two hidden layers) feeding two sigmoid output heads."""
    return MLPClassifier(
        hidden_layer_sizes=(96, 48),
        activation="relu",
        solver="adam",
        alpha=1e-4,
        batch_size=512,
        learning_rate_init=8e-4,
        max_iter=120,
        early_stopping=True,
        n_iter_no_change=8,
        random_state=C.RANDOM_STATE,
    )


def evaluate_head(y_true, proba, threshold):
    pred = (proba >= threshold).astype(int)
    cm = confusion_matrix(y_true, pred)
    return {
        "threshold": threshold,
        "recall": round(recall_score(y_true, pred, zero_division=0), 4),
        "precision": round(precision_score(y_true, pred, zero_division=0), 4),
        "f1": round(f1_score(y_true, pred, zero_division=0), 4),
        "roc_auc": round(roc_auc_score(y_true, proba), 4),
        "pr_auc": round(average_precision_score(y_true, proba), 4),
        "confusion": cm.tolist(),
    }


def plot_roc_panel(Y_te, test_proba, path):
    """Two-panel ROC (diabetes, kidney) for the multi-task model."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from sklearn.metrics import roc_curve, roc_auc_score

    fig, axes = plt.subplots(1, 2, figsize=(9, 4))
    colours = ["#2E6DB4", "#7E57A6"]
    for ax, i, label, col in zip(axes, range(2), LABELS, colours):
        y = Y_te[label].values
        p = test_proba[:, i]
        fpr, tpr, _ = roc_curve(y, p)
        auc = roc_auc_score(y, p)
        name = label.replace("_binary", "")
        ax.plot(fpr, tpr, color=col, lw=2, label=f"{name} (AUC = {auc:.3f})")
        ax.plot([0, 1], [0, 1], color="#999", lw=1, ls="--")
        ax.set_xlabel("False Positive Rate"); ax.set_ylabel("True Positive Rate")
        ax.set_title(f"ROC - {name} Risk (multi-task)", fontsize=11)
        ax.legend(loc="lower right", fontsize=9)
    fig.tight_layout(); fig.savefig(path, dpi=160); plt.close(fig)


def proba_matrix(model, X):
    """Return an (n_samples, 2) probability matrix, robust to sklearn's output shape."""
    p = model.predict_proba(X)
    if isinstance(p, list):              # list of per-label arrays
        return np.column_stack([col[:, 1] for col in p])
    return np.asarray(p)                 # already (n_samples, n_labels)
