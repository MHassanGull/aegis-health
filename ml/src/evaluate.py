"""Evaluation utilities: screening-appropriate metrics and clear plots."""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, average_precision_score, confusion_matrix, roc_curve,
)

from . import config as C


def evaluate(model, X_test, y_test, threshold=C.SCREENING_THRESHOLD) -> dict:
    """Score a fitted model using metrics that matter for medical screening."""
    proba = model.predict_proba(X_test)[:, 1]
    pred = (proba >= threshold).astype(int)
    return {
        "threshold": threshold,
        "accuracy": round(accuracy_score(y_test, pred), 4),
        "precision": round(precision_score(y_test, pred, zero_division=0), 4),
        "recall": round(recall_score(y_test, pred), 4),       # sensitivity - key metric
        "f1": round(f1_score(y_test, pred), 4),
        "roc_auc": round(roc_auc_score(y_test, proba), 4),    # threshold-independent
        "pr_auc": round(average_precision_score(y_test, proba), 4),
        "_proba": proba,
        "_pred": pred,
    }


def plot_confusion(y_test, pred, title, path):
    cm = confusion_matrix(y_test, pred)
    fig, ax = plt.subplots(figsize=(4.2, 3.8))
    im = ax.imshow(cm, cmap="Blues")
    for (i, j), v in np.ndenumerate(cm):
        ax.text(j, i, f"{v:,}", ha="center", va="center",
                color="white" if v > cm.max() / 2 else "#1B2733", fontsize=11)
    ax.set_xticks([0, 1]); ax.set_yticks([0, 1])
    ax.set_xticklabels(["No diabetes", "At risk"])
    ax.set_yticklabels(["No diabetes", "At risk"])
    ax.set_xlabel("Predicted"); ax.set_ylabel("Actual")
    ax.set_title(title, fontsize=11)
    fig.colorbar(im, fraction=0.046, pad=0.04)
    fig.tight_layout(); fig.savefig(path, dpi=160); plt.close(fig)


def plot_roc(y_test, proba, auc, path):
    fpr, tpr, _ = roc_curve(y_test, proba)
    fig, ax = plt.subplots(figsize=(4.4, 3.8))
    ax.plot(fpr, tpr, color="#2E6DB4", lw=2, label=f"Champion (AUC = {auc:.3f})")
    ax.plot([0, 1], [0, 1], color="#999", lw=1, ls="--", label="Random")
    ax.set_xlabel("False Positive Rate"); ax.set_ylabel("True Positive Rate")
    ax.set_title("ROC Curve - Diabetes Risk", fontsize=11)
    ax.legend(loc="lower right", fontsize=9)
    fig.tight_layout(); fig.savefig(path, dpi=160); plt.close(fig)
