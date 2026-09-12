"""AI Medical Assist - Sprint 2 entry point: the multi-task model.

Trains one shared-backbone network that predicts BOTH diabetes and kidney risk,
and compares each head against a single-task gradient-boosting baseline.

Usage (from ml/):  python run_sprint2.py
(Run `python src/extract_multitask.py` first to build the dataset.)
"""
import json, time, sys, pathlib
import joblib
import numpy as np

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from src import config as C
from src import multitask as MT
from sklearn.ensemble import HistGradientBoostingClassifier


def main():
    t0 = time.time()
    print("=" * 64)
    print(" AI MEDICAL ASSIST  -  Sprint 2: Multi-Task Risk Model")
    print("=" * 64)

    if not MT.PROCESSED.exists():
        print("ERROR: processed dataset missing. Run: python src/extract_multitask.py")
        sys.exit(1)

    X, Y, feats = MT.load()
    print(f"\n[1] Data: {len(X):,} records, {len(feats)} features")
    print(f"    Diabetes positive: {Y['Diabetes_binary'].mean()*100:.2f}%")
    print(f"    Kidney   positive: {Y['Kidney_binary'].mean()*100:.2f}%")

    X_fit, X_val, X_te, Y_fit, Y_val, Y_te, scaler = MT.split_and_scale(X, Y)
    print(f"\n[2] Split: fit={len(X_fit):,}  val={len(X_val):,}  test={len(X_te):,}")
    print(f"    Target screening recall (sensitivity): {MT.TARGET_RECALL:.0%}")

    # ---- Multi-task champion (shared backbone, two heads) -----------------
    print("\n[3] Training MULTI-TASK model (shared backbone -> 2 heads) ...")
    mt = MT.build_multitask().fit(X_fit, Y_fit.values)
    val_proba = MT.proba_matrix(mt, X_val)
    test_proba = MT.proba_matrix(mt, X_te)

    mt_results = {}
    for i, label in enumerate(MT.LABELS):
        thr = MT.tune_threshold(Y_val[label].values, val_proba[:, i])   # tune on val
        mt_results[label] = MT.evaluate_head(Y_te[label].values, test_proba[:, i], thr)

    # ---- Single-task baselines (one GB model per disease) ----------------
    print("[4] Training single-task baselines (one model per disease) ...")
    base_results = {}
    for label in MT.LABELS:
        gb = HistGradientBoostingClassifier(
            learning_rate=0.08, max_iter=300, l2_regularization=1.0,
            class_weight="balanced", random_state=C.RANDOM_STATE,
            early_stopping=True,
        ).fit(X_fit, Y_fit[label].values)
        val_p = gb.predict_proba(X_val)[:, 1]
        test_p = gb.predict_proba(X_te)[:, 1]
        thr = MT.tune_threshold(Y_val[label].values, val_p)
        base_results[label] = MT.evaluate_head(Y_te[label].values, test_p, thr)

    # ---- Report ----------------------------------------------------------
    def show(tag, r):
        print(f"\n    {tag}")
        for label in MT.LABELS:
            m = r[label]
            name = label.replace("_binary", "")
            print(f"      {name:9}  AUC={m['roc_auc']:.3f}  Recall={m['recall']:.3f}  "
                  f"Precision={m['precision']:.3f}  F1={m['f1']:.3f}  "
                  f"PR-AUC={m['pr_auc']:.3f}  thr={m['threshold']:.3f}")

    print("\n[5] RESULTS  (thresholds tuned to >= %.0f%% recall on validation)" % (MT.TARGET_RECALL*100))
    show("Multi-task model (shared backbone)", mt_results)
    show("Single-task baselines (per disease)", base_results)

    # ---- Save ------------------------------------------------------------
    MT.plot_roc_panel(Y_te, test_proba, C.REPORTS / "multitask_roc.png")

    tuned_thresholds = {label: mt_results[label]["threshold"] for label in MT.LABELS}
    joblib.dump({"model": mt, "scaler": scaler, "features": feats,
                 "labels": MT.LABELS, "thresholds": tuned_thresholds},
                C.ARTIFACTS / "multitask_model.joblib")
    report = {
        "records": len(X), "features": feats,
        "prevalence": {l: round(float(Y[l].mean()), 4) for l in MT.LABELS},
        "multitask": mt_results, "baseline": base_results,
        "elapsed_seconds": round(time.time() - t0, 1),
    }
    with open(C.REPORTS / "sprint2_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print("\n[6] Saved: artifacts/multitask_model.joblib, reports/sprint2_report.json")
    print(f"\nDone in {report['elapsed_seconds']}s.")
    print("=" * 64)


if __name__ == "__main__":
    main()
