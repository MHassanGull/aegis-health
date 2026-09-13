# -*- coding: utf-8 -*-
"""Regenerate every machine-learning figure in the report from the CURRENT model.

Everything here is measured, not drawn by hand: the curves come from running the
deployed artifact over the held-out split, so what the report shows is what the
system actually does. Run after any retrain:

    python _build/make_ml_figures.py
"""
import json
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import PercentFormatter

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "ml"))
OUT = ROOT / "docs" / "assets"
OUT.mkdir(parents=True, exist_ok=True)

# ---- House style ---------------------------------------------------------
INK = "#1B2733"
GRID = "#DCE3EA"
DIAB = "#2E6DB4"   # diabetes head
KID = "#C2557A"    # kidney head
MUTED = "#8A99A6"

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 11,
    "axes.edgecolor": INK,
    "axes.labelcolor": INK,
    "text.color": INK,
    "xtick.color": INK,
    "ytick.color": INK,
    "axes.grid": True,
    "grid.color": GRID,
    "grid.linewidth": 0.7,
    "figure.dpi": 200,
    "savefig.dpi": 200,
    "savefig.bbox": "tight",
})


def _frame(ax):
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    ax.set_axisbelow(True)


def main():
    from src import multitask as MT
    from sklearn.metrics import (
        roc_curve, roc_auc_score, precision_recall_curve, average_precision_score,
        confusion_matrix,
    )
    from sklearn.calibration import calibration_curve
    import joblib

    art = ROOT / "ml" / "artifacts" / "multitask_model.joblib"
    if not art.exists():
        print("No trained artifact; run ml/run_sprint3.py first.")
        return

    bundle = joblib.load(art)
    model, scaler = bundle["model"], bundle["scaler"]
    feats, labels = bundle["features"], bundle["labels"]
    thresholds, calibrators = bundle["thresholds"], bundle.get("calibrators")

    X, Y, _ = MT.load()
    X_fit, X_val, X_te, Y_fit, Y_val, Y_te, _ = MT.split_and_scale(X[feats], Y)

    P = MT.proba_matrix(model, X_te)
    if calibrators:
        P = P.astype(float, copy=True)
        for i, cal in enumerate(calibrators):
            P[:, i] = cal.predict(P[:, i])

    report = json.loads((ROOT / "ml" / "reports" / "sprint3_report.json").read_text())
    names = {"Diabetes_binary": "Diabetes", "Kidney_binary": "Chronic kidney disease"}
    colours = {"Diabetes_binary": DIAB, "Kidney_binary": KID}

    # ---------------------------------------------------------------- ROC
    fig, ax = plt.subplots(figsize=(6.2, 4.6))
    for i, lab in enumerate(labels):
        y, p = Y_te[lab].values, P[:, i]
        fpr, tpr, _ = roc_curve(y, p)
        auc = roc_auc_score(y, p)
        ax.plot(fpr, tpr, lw=2.2, color=colours[lab],
                label=f"{names[lab]}  (AUC = {auc:.3f})")
    ax.plot([0, 1], [0, 1], ls="--", lw=1.2, color=MUTED, label="Random (AUC = 0.500)")
    ax.set_xlabel("False positive rate")
    ax.set_ylabel("True positive rate (recall)")
    ax.set_title("ROC curves, held-out test set", pad=12)
    ax.legend(loc="lower right", frameon=False)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1.02)
    _frame(ax)
    fig.savefig(OUT / "fig_roc_curves.png"); plt.close(fig)
    print("  fig_roc_curves.png")

    # ------------------------------------------------- Precision / recall
    fig, ax = plt.subplots(figsize=(6.2, 4.6))
    for i, lab in enumerate(labels):
        y, p = Y_te[lab].values, P[:, i]
        prec, rec, _ = precision_recall_curve(y, p)
        apr = average_precision_score(y, p)
        ax.plot(rec, prec, lw=2.2, color=colours[lab],
                label=f"{names[lab]}  (AP = {apr:.3f})")
        ax.axhline(y.mean(), ls=":", lw=1.1, color=colours[lab], alpha=0.8)
    ax.set_xlabel("Recall")
    ax.set_ylabel("Precision")
    ax.set_title("Precision-recall curves\n(dotted lines mark prevalence, the no-skill floor)", pad=12)
    ax.legend(loc="upper right", frameon=False)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1.02)
    _frame(ax)
    fig.savefig(OUT / "fig_pr_curves.png"); plt.close(fig)
    print("  fig_pr_curves.png")

    # ------------------------------------------------------- Reliability
    fig, axes = plt.subplots(1, 2, figsize=(9.4, 4.3))
    raw = MT.proba_matrix(model, X_te)
    for ax, (i, lab) in zip(axes, enumerate(labels)):
        y = Y_te[lab].values
        for probs, tag, col in [(raw[:, i], "Before calibration", MUTED),
                                (P[:, i], "After calibration", colours[lab])]:
            frac, mean_pred = calibration_curve(y, probs, n_bins=10, strategy="quantile")
            ax.plot(mean_pred, frac, marker="o", ms=4.5, lw=1.9, color=col, label=tag)
        ax.plot([0, 1], [0, 1], ls="--", lw=1.1, color="#B9C4CE")
        ax.set_title(names[lab], fontsize=11)
        ax.set_xlabel("Predicted probability")
        ax.set_ylabel("Observed frequency")
        ax.legend(frameon=False, fontsize=9, loc="upper left")
        _frame(ax)
    fig.suptitle("Calibration: does a predicted 30% really mean 30%?", y=1.02)
    fig.tight_layout()
    fig.savefig(OUT / "fig_calibration.png"); plt.close(fig)
    print("  fig_calibration.png")

    # -------------------------------------------------- Confusion matrices
    fig, axes = plt.subplots(1, 2, figsize=(9.2, 4.0))
    for ax, (i, lab) in zip(axes, enumerate(labels)):
        thr = thresholds[lab]
        cm = confusion_matrix(Y_te[lab].values, (P[:, i] >= thr).astype(int))
        norm = cm / cm.sum(axis=1, keepdims=True)
        ax.imshow(norm, cmap="Blues", vmin=0, vmax=1)
        for r in range(2):
            for c in range(2):
                ax.text(c, r, f"{cm[r, c]:,}\n({norm[r, c]*100:.1f}%)",
                        ha="center", va="center", fontsize=10,
                        color="white" if norm[r, c] > 0.55 else INK)
        ax.set_xticks([0, 1], ["Predicted\nnegative", "Predicted\npositive"])
        ax.set_yticks([0, 1], ["Actually\nnegative", "Actually\npositive"])
        ax.set_title(f"{names[lab]}\nscreening threshold {thr:.3f}", fontsize=10.5)
        ax.grid(False)
    fig.suptitle("Confusion matrices at the screening operating point", y=1.03)
    fig.tight_layout()
    fig.savefig(OUT / "fig_confusion.png"); plt.close(fig)
    print("  fig_confusion.png")

    # ------------------------------------------------ Threshold trade-off
    fig, axes = plt.subplots(1, 2, figsize=(9.4, 4.0))
    for ax, (i, lab) in zip(axes, enumerate(labels)):
        y, p = Y_te[lab].values, P[:, i]
        prec, rec, thr_grid = precision_recall_curve(y, p)
        ax.plot(thr_grid, rec[:-1], lw=2, color=colours[lab], label="Recall")
        ax.plot(thr_grid, prec[:-1], lw=2, ls="--", color=MUTED, label="Precision")
        ax.axvline(thresholds[lab], color=INK, lw=1.3, ls=":")
        ax.annotate(f"chosen\n{thresholds[lab]:.3f}", (thresholds[lab], 0.55),
                    xytext=(8, 0), textcoords="offset points", fontsize=8.5, color=INK)
        ax.set_xlim(0, min(0.6, float(thr_grid.max())))
        ax.set_ylim(0, 1.02)
        ax.set_xlabel("Decision threshold")
        ax.set_ylabel("Score")
        ax.yaxis.set_major_formatter(PercentFormatter(xmax=1))
        ax.set_title(names[lab], fontsize=10.5)
        ax.legend(frameon=False, fontsize=9)
        _frame(ax)
    fig.suptitle("Why the threshold was moved: recall bought at the cost of precision", y=1.02)
    fig.tight_layout()
    fig.savefig(OUT / "fig_threshold_tradeoff.png"); plt.close(fig)
    print("  fig_threshold_tradeoff.png")

    # ------------------------------------------- Permutation importance
    rng = np.random.default_rng(0)
    base = {lab: roc_auc_score(Y_te[lab].values, P[:, i]) for i, lab in enumerate(labels)}
    rows = []
    for j, f in enumerate(feats):
        Xp = X_te.copy()
        Xp[:, j] = rng.permutation(Xp[:, j])
        Pp = MT.proba_matrix(model, Xp)
        if calibrators:
            Pp = Pp.astype(float, copy=True)
            for i, cal in enumerate(calibrators):
                Pp[:, i] = cal.predict(Pp[:, i])
        rows.append((f,
                     base[labels[0]] - roc_auc_score(Y_te[labels[0]].values, Pp[:, 0]),
                     base[labels[1]] - roc_auc_score(Y_te[labels[1]].values, Pp[:, 1])))
    rows.sort(key=lambda r: r[1] + r[2])

    pretty = {
        "GenHlth": "Self-rated general health", "Age": "Age band", "BMI": "Body mass index",
        "HighBP": "High blood pressure", "HighChol": "High cholesterol",
        "DiffWalk": "Difficulty walking", "HeartDiseaseorAttack": "Heart disease",
        "PhysHlth": "Poor physical-health days", "Sex": "Sex",
        "HvyAlcoholConsump": "Heavy alcohol use", "CholCheck": "Cholesterol checked",
        "Stroke": "History of stroke", "Smoker": "Smoker",
        "NoDocbcCost": "Skipped doctor, cost", "PhysActivity": "Physically active",
        "Fruits": "Eats fruit daily", "Veggies": "Eats vegetables daily",
        "AnyHealthcare": "Has health coverage",
    }
    ypos = np.arange(len(rows))
    fig, ax = plt.subplots(figsize=(7.4, 6.4))
    ax.barh(ypos - 0.2, [r[1] for r in rows], height=0.38, color=DIAB, label="Diabetes")
    ax.barh(ypos + 0.2, [r[2] for r in rows], height=0.38, color=KID, label="Kidney")
    ax.set_yticks(ypos, [pretty.get(r[0], r[0]) for r in rows], fontsize=9.5)
    ax.set_xlabel("Drop in ROC-AUC when the feature is shuffled")
    ax.set_title("Which answers the model actually relies on", pad=12)
    ax.legend(frameon=False, loc="lower right")
    ax.grid(axis="y", visible=False)
    _frame(ax)
    fig.savefig(OUT / "fig_feature_importance.png"); plt.close(fig)
    print("  fig_feature_importance.png")

    # ------------------------------------------------ Class imbalance
    prev = report["prevalence"]
    fig, ax = plt.subplots(figsize=(6.4, 3.2))
    for k, lab in enumerate(labels):
        p_pos = prev[lab]
        ax.barh(k, (1 - p_pos) * 100, color="#E8EEF4", edgecolor=INK, lw=0.8)
        ax.barh(k, p_pos * 100, color=colours[lab], edgecolor=INK, lw=0.8)
        ax.text(p_pos * 100 + 1.5, k, f"{p_pos*100:.1f}% have the condition",
                va="center", fontsize=9.5)
    ax.set_yticks(range(len(labels)), [names[l] for l in labels])
    ax.set_xlim(0, 100)
    ax.set_xlabel("Share of the 253,155 survey respondents")
    ax.set_title("Why accuracy misleads: both conditions are rare", pad=10)
    ax.grid(axis="y", visible=False)
    _frame(ax)
    fig.savefig(OUT / "fig_class_imbalance.png"); plt.close(fig)
    print("  fig_class_imbalance.png")


if __name__ == "__main__":
    print("Regenerating ML figures from the current artifact:")
    main()
