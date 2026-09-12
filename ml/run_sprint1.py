"""AI Medical Assist - Sprint 1 entry point.

Runs the full diabetes-risk pipeline end to end:
    download -> summarise -> split -> train (baseline + champion) -> evaluate -> save.

Usage (from the ml/ folder):
    python run_sprint1.py
"""
import json
import time
import joblib
from importlib import import_module

# Allow running both as `python run_sprint1.py` and as a module.
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

from src import config as C
from src import data as D
from src import models as M
from src import evaluate as E


def main():
    t0 = time.time()
    print("=" * 64)
    print(" AI MEDICAL ASSIST  -  Sprint 1: Diabetes Risk Model")
    print("=" * 64)

    # 1) Data ------------------------------------------------------------
    df = D.load_raw()
    summary = D.summarise(df)
    print("\n[1] Dataset summary")
    for k, v in summary.items():
        print(f"    {k:16}: {v}")

    # 2) Split -----------------------------------------------------------
    X_tr, X_te, y_tr, y_te, scaler, feats = D.make_splits(df)
    print(f"\n[2] Split: train={len(X_tr):,}  test={len(X_te):,}  features={len(feats)}")

    # 3) Train + evaluate baseline --------------------------------------
    print("\n[3] Training baseline (Logistic Regression) ...")
    baseline = M.build_baseline().fit(X_tr, y_tr)
    base_metrics = E.evaluate(baseline, X_te, y_te)

    # 4) Train + evaluate champion --------------------------------------
    print("[4] Training champion (Hist Gradient Boosting) ...")
    champion = M.build_champion().fit(X_tr, y_tr)
    champ_metrics = E.evaluate(champion, X_te, y_te)

    # 5) Report ----------------------------------------------------------
    def show(name, m):
        print(f"\n    {name}")
        for k in ("accuracy", "precision", "recall", "f1", "roc_auc", "pr_auc"):
            print(f"        {k:10}: {m[k]}")

    print("\n[5] Results  (threshold = %.2f, screening-tuned)" % C.SCREENING_THRESHOLD)
    show("Baseline  - Logistic Regression", base_metrics)
    show("Champion  - Hist Gradient Boosting", champ_metrics)

    # 6) Plots + artifacts ----------------------------------------------
    E.plot_confusion(y_te, champ_metrics["_pred"],
                     "Confusion Matrix - Champion", C.REPORTS / "confusion_matrix.png")
    E.plot_roc(y_te, champ_metrics["_proba"], champ_metrics["roc_auc"],
               C.REPORTS / "roc_curve.png")

    joblib.dump({"model": champion, "scaler": scaler, "features": feats},
                C.ARTIFACTS / "diabetes_model.joblib")

    clean = lambda m: {k: v for k, v in m.items() if not k.startswith("_")}
    report = {
        "dataset": summary,
        "baseline": clean(base_metrics),
        "champion": clean(champ_metrics),
        "features": feats,
        "elapsed_seconds": round(time.time() - t0, 1),
    }
    with open(C.REPORTS / "sprint1_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print("\n[6] Saved:")
    print(f"    model    -> artifacts/diabetes_model.joblib")
    print(f"    report   -> reports/sprint1_report.json")
    print(f"    plots    -> reports/confusion_matrix.png, reports/roc_curve.png")
    print(f"\nDone in {report['elapsed_seconds']}s.")
    print("=" * 64)


if __name__ == "__main__":
    main()
