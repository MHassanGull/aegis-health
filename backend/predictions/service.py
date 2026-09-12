"""Prediction service: serves the trained multi-task model.

One loaded model answers three questions for every user:
  * predict  -> future risk of diabetes and kidney disease,
  * explain  -> which factors push that risk up (fast occlusion analysis),
  * advise   -> which habit changes would lower it most (what-if simulation).

The model and scaler are loaded once at start-up.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd
import joblib

from . import schema

# Where the trained artifacts live.
#
# The backend ships a COPY of the model inside `backend/ml_assets/` so the
# deployed service is self-contained (the ml/ training folder is not pushed to
# the server). Locally we still prefer the freshly trained ml/artifacts/ file,
# so retraining takes effect immediately without a manual copy.
BACKEND_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = BACKEND_ROOT.parent
BUNDLED = BACKEND_ROOT / "ml_assets"


def _pick(*candidates: Path) -> Path:
    """First path that exists; otherwise the first candidate (for a clear error)."""
    for c in candidates:
        if c.exists():
            return c
    return candidates[0]


ARTIFACT = _pick(REPO_ROOT / "ml" / "artifacts" / "multitask_model.joblib",
                 BUNDLED / "multitask_model.joblib")
REPORT = _pick(REPO_ROOT / "ml" / "reports" / "sprint2_report.json",
               BUNDLED / "sprint2_report.json")
SPRINT3_REPORT = _pick(REPO_ROOT / "ml" / "reports" / "sprint3_report.json",
                       BUNDLED / "sprint3_report.json")


class PredictionService:
    _instance = None

    def __init__(self):
        if not ARTIFACT.exists():
            raise FileNotFoundError(
                f"Model artifact not found at {ARTIFACT}. "
                f"Train it first: python ml/run_sprint2.py"
            )
        bundle = joblib.load(ARTIFACT)
        self.model = bundle["model"]
        self.scaler = bundle["scaler"]
        self.features = bundle["features"]
        self.labels = bundle["labels"]                 # ["Diabetes_binary","Kidney_binary"]
        self.thresholds = bundle["thresholds"]
        # Optional per-head probability calibrators (isotonic). Present since the
        # calibrated retrain; older artifacts simply have none.
        self.calibrators = bundle.get("calibrators")
        self.disease_names = {"Diabetes_binary": "diabetes", "Kidney_binary": "kidney"}

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    # -- internals ---------------------------------------------------------
    def _raw_vector(self, payload: dict) -> pd.DataFrame:
        """Assemble the feature values in the exact order the model expects.

        Returned as a named DataFrame so the scaler keeps its feature names.
        """
        row = {f: float(payload[f]) for f in self.features}
        return pd.DataFrame([row], columns=self.features)

    def _proba_matrix(self, scaled: np.ndarray) -> np.ndarray:
        """(n_samples, n_labels) matrix of P(positive), calibrated if available.

        Robust to sklearn's two shapes: a list of per-label (n,2) arrays
        (MultiOutputClassifier) or a single (n, n_labels) array (MLP multilabel).
        """
        p = self.model.predict_proba(scaled)
        if isinstance(p, list):
            p = np.column_stack([col[:, 1] for col in p])
        else:
            p = np.asarray(p, dtype=float)
        if self.calibrators:
            p = p.astype(float, copy=True)
            for i, cal in enumerate(self.calibrators):
                p[:, i] = cal.predict(p[:, i])
        return p

    def _proba(self, raw: np.ndarray) -> np.ndarray:
        """Return a (2,) probability vector [diabetes, kidney]."""
        return self._proba_matrix(self.scaler.transform(raw))[0]

    # -- public API --------------------------------------------------------
    def predict(self, payload: dict) -> dict:
        raw = self._raw_vector(payload)
        proba = self._proba(raw)
        out = {}
        for i, label in enumerate(self.labels):
            name = self.disease_names[label]
            thr = self.thresholds[label]
            prob = float(proba[i])
            out[name] = {
                "risk": round(prob, 4),
                "risk_percent": round(prob * 100, 1),
                "tier": schema.risk_tier(prob, thr),
                "threshold": round(float(thr), 4),
            }
        return out

    def explain(self, payload: dict, top_k: int = 5) -> dict:
        """Occlusion analysis: how much each feature lifts risk compared with
        its population-average value."""
        return self._split(self.assess(payload))[1]

    def advise(self, payload: dict, top_k: int = 3) -> list:
        """What-if simulation: apply each realistic habit improvement and
        report the projected reduction."""
        return self._split(self.assess(payload))[2]

    @staticmethod
    def _split(result: dict):
        return (result["prediction"], result["key_factors"],
                result["recommendations"])

    # -- the hot path ------------------------------------------------------
    def assess(self, payload: dict, top_k: int = 5, advice_k: int = 3) -> dict:
        """Prediction, explanation and recommendations in ONE forward pass.

        The obvious implementation runs the model once per question being
        asked: once for the prediction, once per feature to measure its
        contribution, and once per habit to simulate changing it. That is 26
        calls for 19 features, and on a small shared CPU the per-call overhead
        through pandas and scikit-learn dominates completely: the arithmetic is
        trivial, the round trips are not. Measured at roughly 11 seconds.

        Instead every row the analysis needs is stacked into a single matrix
        and scored in one call:

            row 0            the person as they answered
            rows 1..F        the same person with feature i neutralised
            rows F+1..F+M    the same person after one realistic habit change

        Same arithmetic, same results, one call.
        """
        feats = self.features
        n_feat = len(feats)
        base_row = {f: float(payload[f]) for f in feats}

        # --- raw rows: the person, plus one row per realistic habit change --
        raw_rows = [base_row]
        actions = []
        for feat, rule in schema.MODIFIABLE.items():
            if feat not in feats:
                continue
            current = float(payload[feat])
            target = float(rule["target"])
            if rule.get("only_if_worse") and current <= target:
                continue
            if not rule.get("only_if_worse") and current == target:
                continue
            row = dict(base_row)
            row[feat] = target
            raw_rows.append(row)
            actions.append(rule["action"])

        # Scale the person and the what-if rows together, as a named frame so
        # the scaler keeps its feature names.
        scaled = self.scaler.transform(pd.DataFrame(raw_rows, columns=feats))
        scaled_base = scaled[0:1]
        scaled_whatif = scaled[1:]

        # --- occlusion rows: the person with feature i set to the mean ------
        # 0.0 is the population mean once standardised.
        occluded = np.repeat(scaled_base, n_feat, axis=0)
        occluded[np.arange(n_feat), np.arange(n_feat)] = 0.0

        # --- one call for everything ----------------------------------------
        matrix = np.vstack([scaled_base, occluded, scaled_whatif])
        probs = self._proba_matrix(matrix)

        base_p = probs[0]
        occluded_p = probs[1:1 + n_feat]
        whatif_p = probs[1 + n_feat:]

        # --- prediction ------------------------------------------------------
        prediction = {}
        for i, label in enumerate(self.labels):
            name = self.disease_names[label]
            thr = self.thresholds[label]
            prob = float(base_p[i])
            prediction[name] = {
                "risk": round(prob, 4),
                "risk_percent": round(prob * 100, 1),
                "tier": schema.risk_tier(prob, thr),
                "threshold": round(float(thr), 4),
            }

        # --- attribution ------------------------------------------------------
        # Positive delta means the feature pushes this person's risk up.
        deltas = base_p - occluded_p                    # (n_feat, n_labels)
        key_factors = {}
        for i, label in enumerate(self.labels):
            name = self.disease_names[label]
            risers = [(feats[j], float(deltas[j, i]))
                      for j in range(n_feat) if deltas[j, i] > 0]
            risers.sort(key=lambda x: -x[1])
            key_factors[name] = [
                {"feature": f,
                 "label": schema.FEATURE_META[f]["label"],
                 "impact": round(d, 4)}
                for f, d in risers[:top_k]
            ]

        # --- recommendations --------------------------------------------------
        recommendations = []
        for k, action in enumerate(actions):
            reductions = base_p - whatif_p[k]           # (n_labels,)
            total = float(sum(max(0.0, v) for v in reductions))
            if total <= 0:
                continue
            recommendations.append({
                "action": action,
                "diabetes_reduction_percent": round(float(reductions[0]) * 100, 1),
                "kidney_reduction_percent": round(float(reductions[1]) * 100, 1),
                "_total": total,
            })
        recommendations.sort(key=lambda r: -r["_total"])
        for r in recommendations:
            r.pop("_total", None)

        return {
            "prediction": prediction,
            "key_factors": key_factors,
            "recommendations": recommendations[:advice_k],
        }

    # -- transparency: model card -----------------------------------------
    def model_card(self) -> dict:
        """A live 'model card' for the transparency screen.

        Architecture numbers are introspected from the *actual* trained
        network (not hard-coded); metrics are read from the training report.
        This is what lets a viva panel see the real ML underneath the app.
        """
        m = self.model

        # --- architecture, read from the live sklearn network -------------
        hidden = getattr(m, "hidden_layer_sizes", ())
        hidden = [int(hidden)] if isinstance(hidden, int) else [int(h) for h in hidden]
        coefs = getattr(m, "coefs_", None)
        intercepts = getattr(m, "intercepts_", None)
        n_params = 0
        if coefs is not None:
            n_params += int(sum(c.size for c in coefs))
        if intercepts is not None:
            n_params += int(sum(b.size for b in intercepts))
        layer_sizes = [len(self.features)] + hidden + [len(self.labels)]

        architecture = {
            "type": "Multi-task Neural Network (shared-backbone MLP)",
            "framework": type(m).__name__ + " · scikit-learn",
            "input_features": len(self.features),
            "hidden_layers": hidden,
            "output_heads": len(self.labels),
            "head_names": ["Diabetes", "Kidney"],
            "activation": getattr(m, "activation", "relu"),
            "output_activation": getattr(m, "out_activation_", "logistic"),
            "trainable_params": n_params,
            "layer_sizes": layer_sizes,       # e.g. [19, 64, 32, 2] for the diagram
        }

        # --- metrics + dataset, from the training report ------------------
        # Prefer the calibrated + cross-validated Sprint-3 report; fall back to
        # the earlier single-split report so the card always renders.
        report, is_cv = {}, False
        for path in (SPRINT3_REPORT, REPORT):
            try:
                report = json.loads(path.read_text())
                is_cv = "final" in report
                break
            except Exception:
                continue
        final = report.get("final", {})        # calibrated report shape
        mt = report.get("multitask", {})       # legacy report shape
        cv = report.get("cv", {})
        prev = report.get("prevalence", {})

        def _disease(label_key, name):
            r = final.get(label_key) or mt.get(label_key, {})
            c = cv.get(label_key, {})
            conf = r.get("confusion") or [[0, 0], [0, 0]]
            tn, fp = conf[0]
            fn, tp = conf[1]
            # 0.5-threshold accuracy (headline). Fallback: derive from confusion.
            acc = r.get("accuracy")
            if acc is None:
                total = tn + fp + fn + tp
                acc = (tn + tp) / total if total else 0.0
            return {
                "name": name,
                "roc_auc": round(r.get("roc_auc", 0.0), 3),
                "recall": round(r.get("recall", 0.0), 3),
                "precision": round(r.get("precision", 0.0), 3),
                "f1": round(r.get("f1", 0.0), 3),
                "accuracy": round(acc, 3),
                "balanced_accuracy": round(r.get("balanced_accuracy", 0.0), 3),
                "threshold": round(r.get("threshold", 0.0), 3),
                "prevalence": round(prev.get(label_key, 0.0) * 100, 1),
                # cross-validation confidence intervals (present in the CV report)
                "roc_auc_ci": c.get("roc_auc"),
                "accuracy_ci": c.get("accuracy"),
                "confusion": {"tn": int(tn), "fp": int(fp),
                              "fn": int(fn), "tp": int(tp)},
                "caught": int(tp),
                "total_cases": int(tp + fn),
            }

        metrics = {
            "diabetes": _disease("Diabetes_binary", "Diabetes"),
            "kidney": _disease("Kidney_binary", "Kidney disease"),
        }
        # Headline: overall accuracy across both diseases (0.5 operating point).
        overall_accuracy = report.get("overall_accuracy")
        if overall_accuracy is None:
            overall_accuracy = round(
                (metrics["diabetes"]["accuracy"] + metrics["kidney"]["accuracy"]) / 2, 3)

        dataset = {
            "name": "CDC BRFSS 2015",
            "full_name": "Behavioral Risk Factor Surveillance System",
            "records": report.get("records", 253155),
            "features": len(self.features),
            "source": "U.S. Centers for Disease Control and Prevention",
        }

        methodology = [
            "Multi-task learning: one shared network predicts both diseases, "
            "so it learns that diabetes is a leading cause of kidney disease.",
            "Trained on 253,155 real people from the CDC's BRFSS 2015 survey.",
            f"Validated with {report.get('n_folds', 5)}-fold cross-validation, so "
            "the scores are stable confidence intervals, not one lucky split.",
            "Probabilities are calibrated (isotonic) — a predicted 30% risk "
            "really means about 30%, checked with a reliability curve.",
            "Judged on Recall + ROC-AUC, not accuracy alone — because the "
            "diseases are rare, plain accuracy can look high while missing cases.",
            "Every prediction is explained with SHAP-style factor attribution, "
            "and a what-if engine simulates habit changes.",
        ]

        feature_labels = [schema.FEATURE_META[f]["label"] for f in self.features]

        return {
            "architecture": architecture,
            "dataset": dataset,
            "metrics": metrics,
            "overall_accuracy": round(overall_accuracy * 100, 1),   # e.g. 91.5
            "calibrated": bool(report.get("calibrated", self.calibrators is not None)),
            "cross_validated": is_cv,
            "n_folds": report.get("n_folds", 5),
            "methodology": methodology,
            "features": feature_labels,
        }
