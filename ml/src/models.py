"""Model definitions for the diabetes risk model (Sprint 1).

We deliberately train two models:
  * a transparent baseline (Logistic Regression), and
  * a stronger champion (Histogram Gradient Boosting).
Comparing them is good engineering practice and good thesis material.
Both use class balancing because serious disease is the minority class.
"""
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import HistGradientBoostingClassifier

from . import config as C


def build_baseline() -> LogisticRegression:
    """A simple, explainable linear baseline."""
    return LogisticRegression(
        class_weight="balanced",
        max_iter=2000,
        random_state=C.RANDOM_STATE,
    )


def build_champion() -> HistGradientBoostingClassifier:
    """A strong gradient-boosting model for tabular data (no extra dependency)."""
    return HistGradientBoostingClassifier(
        learning_rate=0.08,
        max_iter=400,
        max_depth=None,
        l2_regularization=1.0,
        class_weight="balanced",
        random_state=C.RANDOM_STATE,
        early_stopping=True,
        validation_fraction=0.1,
    )
