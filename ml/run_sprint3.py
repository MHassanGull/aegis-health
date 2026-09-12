"""AI Medical Assist - Sprint 3 entry point: rigorous, calibrated evaluation.

Upgrades the multi-task model to industry-grade rigour WITHOUT changing the
project's core idea (one shared neural backbone, two disease heads):

  * 5-fold stratified CROSS-VALIDATION  -> honest metrics with confidence
    intervals (mean +/- std), instead of a single lucky split.
  * probability CALIBRATION (isotonic)  -> a predicted "30% risk" really means
    30%, validated with a reliability curve.
  * a FULL metric suite reported at TWO operating points:
      - standard 0.5 threshold  -> Accuracy + Balanced Accuracy (the headline
        "how often is it right" numbers),
      - screening threshold      -> Recall + Precision (the "how many real
        cases do we catch" safety numbers).

Run (from ml/):  python run_sprint3.py
(Run `python src/extract_multitask.py` first if the processed CSV is missing.)
"""
import json, time, sys, pathlib
import numpy as np
import joblib

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from src import config as C
from src import multitask as MT
from sklearn.model_selection import StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.isotonic import IsotonicRegression
from sklearn.metrics import (
    roc_auc_score, average_precision_score, recall_score, precision_score,
    f1_score, accuracy_score, balanced_accuracy_score, confusion_matrix,
)

N_FOLDS = 5


def _mean_std(vals):
    return {"mean": round(float(np.mean(vals)), 4), "std": round(float(np.std(vals)), 4)}


def cross_validate(X, Y):
    """5-fold stratified CV of the multi-task network. Stratifies on the joint
    (diabetes, kidney) label so both prevalences are preserved in every fold."""
    Xv, Yv = X.values, Y.values
    joint = Yv[:, 0] * 2 + Yv[:, 1]                 # 4 strata: 00,01,10,11
    skf = StratifiedKFold(n_splits=N_FOLDS, shuffle=True, random_state=C.RANDOM_STATE)
    acc = {l: {"roc_auc": [], "accuracy": [], "balanced_accuracy": [], "recall": []}
           for l in MT.LABELS}
    for k, (tr, te) in enumerate(skf.split(Xv, joint), 1):
        sc = StandardScaler().fit(Xv[tr])
        model = MT.build_multitask().fit(sc.transform(Xv[tr]), Yv[tr])
        P = MT.proba_matrix(model, sc.transform(Xv[te]))
        for i, l in enumerate(MT.LABELS):
            yt, p = Yv[te][:, i], P[:, i]
            pred = (p >= 0.5).astype(int)
            acc[l]["roc_auc"].append(roc_auc_score(yt, p))
            acc[l]["accuracy"].append(accuracy_score(yt, pred))
            acc[l]["balanced_accuracy"].append(balanced_accuracy_score(yt, pred))
            acc[l]["recall"].append(recall_score(yt, pred, zero_division=0))
        print(f"    fold {k}/{N_FOLDS} done")
    return {l: {m: _mean_std(v) for m, v in acc[l].items()} for l in MT.LABELS}


def reliability_plot(y_true_by_label, raw_by_label, cal_by_label, path):
    """Before/after calibration reliability curves (a strong viva artefact)."""
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        from sklearn.calibration import calibration_curve
    except Exception:
        return
    fig, axes = plt.subplots(1, 2, figsize=(9, 4))
    for ax, l in zip(axes, MT.LABELS):
        name = l.replace("_binary", "")
        yt = y_true_by_label[l]
        for probs, tag, col in [(raw_by_label[l], "raw", "#bbb"),
                                (cal_by_label[l], "calibrated", "#2E6DB4")]:
            frac, mean_pred = calibration_curve(yt, probs, n_bins=10, strategy="quantile")
            ax.plot(mean_pred, frac, marker="o", ms=4, lw=1.8, color=col, label=tag)
        ax.plot([0, 1], [0, 1], "--", color="#999", lw=1)
        ax.set_title(f"Reliability - {name}", fontsize=11)
        ax.set_xlabel("Predicted probability"); ax.set_ylabel("Observed frequency")
        ax.legend(loc="upper left", fontsize=9)
    fig.tight_layout(); fig.savefig(path, dpi=160); plt.close(fig)


def main():
    t0 = time.time()
    print("=" * 66)
    print(" AI MEDICAL ASSIST  -  Sprint 3: Calibrated + Cross-Validated Model")
    print("=" * 66)

    if not MT.PROCESSED.exists():
        print("ERROR: processed dataset missing. Run: python src/extract_multitask.py")
        sys.exit(1)

    X, Y, feats = MT.load()
    print(f"\n[1] Data: {len(X):,} real people, {len(feats)} lifestyle features")
    print(f"    Diabetes prevalence: {Y['Diabetes_binary'].mean()*100:.2f}%"
          f"  |  Kidney prevalence: {Y['Kidney_binary'].mean()*100:.2f}%")

    print(f"\n[2] {N_FOLDS}-fold cross-validation (honest confidence intervals) ...")
    cv = cross_validate(X, Y)

    print("\n[3] Final model: train -> calibrate (isotonic) -> tune thresholds ...")
    X_fit, X_val, X_te, Y_fit, Y_val, Y_te, scaler = MT.split_and_scale(X, Y)
    model = MT.build_multitask().fit(X_fit, Y_fit.values)
    val_raw, te_raw = MT.proba_matrix(model, X_val), MT.proba_matrix(model, X_te)

    calibrators, final = [], {}
    y_true_by, raw_by, cal_by = {}, {}, {}
    for i, l in enumerate(MT.LABELS):
        iso = IsotonicRegression(out_of_bounds="clip").fit(val_raw[:, i], Y_val[l].values)
        calibrators.append(iso)
        val_cal, te_cal = iso.predict(val_raw[:, i]), iso.predict(te_raw[:, i])
        thr = MT.tune_threshold(Y_val[l].values, val_cal)
        yt = Y_te[l].values
        pred_scr, pred_std = (te_cal >= thr).astype(int), (te_cal >= 0.5).astype(int)
        final[l] = {
            "roc_auc": round(roc_auc_score(yt, te_cal), 4),
            "pr_auc": round(average_precision_score(yt, te_cal), 4),
            "threshold": float(thr),
            # screening operating point (safety: catch real cases)
            "recall": round(recall_score(yt, pred_scr, zero_division=0), 4),
            "precision": round(precision_score(yt, pred_scr, zero_division=0), 4),
            "f1": round(f1_score(yt, pred_scr, zero_division=0), 4),
            "confusion": confusion_matrix(yt, pred_scr).tolist(),
            # standard 0.5 operating point (headline accuracy)
            "accuracy": round(accuracy_score(yt, pred_std), 4),
            "balanced_accuracy": round(balanced_accuracy_score(yt, pred_std), 4),
        }
        y_true_by[l], raw_by[l], cal_by[l] = yt, te_raw[:, i], te_cal

    overall_accuracy = round(np.mean([final[l]["accuracy"] for l in MT.LABELS]), 4)

    reliability_plot(y_true_by, raw_by, cal_by, C.REPORTS / "reliability.png")

    # ---- report ----------------------------------------------------------
    print("\n[4] RESULTS (held-out test set, calibrated probabilities)")
    for l in MT.LABELS:
        m, c = final[l], cv[l]
        name = l.replace("_binary", "")
        print(f"\n    {name}")
        print(f"      Accuracy         {m['accuracy']*100:5.1f}%   "
              f"(CV {c['accuracy']['mean']*100:.1f}% +/- {c['accuracy']['std']*100:.1f})")
        print(f"      Balanced Acc.    {m['balanced_accuracy']*100:5.1f}%")
        print(f"      ROC-AUC          {m['roc_auc']:.3f}   "
              f"(CV {c['roc_auc']['mean']:.3f} +/- {c['roc_auc']['std']:.3f})")
        print(f"      Recall (screen)  {m['recall']*100:5.1f}%   thr={m['threshold']:.3f}")
        print(f"      Precision        {m['precision']*100:5.1f}%   F1={m['f1']:.3f}")
    print(f"\n    >> Overall accuracy across both diseases: {overall_accuracy*100:.1f}%")

    # ---- save ------------------------------------------------------------
    joblib.dump(
        {"model": model, "scaler": scaler, "features": feats, "labels": MT.LABELS,
         "thresholds": {l: final[l]["threshold"] for l in MT.LABELS},
         "calibrators": calibrators},
        C.ARTIFACTS / "multitask_model.joblib")

    report = {
        "records": len(X), "features": feats,
        "prevalence": {l: round(float(Y[l].mean()), 4) for l in MT.LABELS},
        "n_folds": N_FOLDS,
        "calibrated": True,
        "overall_accuracy": overall_accuracy,
        "cv": cv,
        "final": final,
        "elapsed_seconds": round(time.time() - t0, 1),
    }
    (C.REPORTS / "sprint3_report.json").write_text(json.dumps(report, indent=2))
    print(f"\n[5] Saved: artifacts/multitask_model.joblib (now calibrated), "
          f"reports/sprint3_report.json, reports/reliability.png")
    print(f"\nDone in {report['elapsed_seconds']}s.")
    print("=" * 66)


if __name__ == "__main__":
    main()
