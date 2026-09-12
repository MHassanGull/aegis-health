"""Data loading and preprocessing for the diabetes risk model (Sprint 1).

The raw dataset is fetched once from the UCI repository and cached locally, so
subsequent runs are offline and fast.
"""
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

from . import config as C


def load_raw() -> pd.DataFrame:
    """Return the raw BRFSS diabetes dataset, downloading and caching if needed."""
    if C.RAW_CSV.exists():
        print(f"[data] Loading cached dataset -> {C.RAW_CSV.name}")
        return pd.read_csv(C.RAW_CSV)

    print("[data] Cache not found. Downloading from UCI (id=891) ...")
    from ucimlrepo import fetch_ucirepo

    repo = fetch_ucirepo(id=C.UCI_DATASET_ID)
    df = pd.concat([repo.data.features, repo.data.targets], axis=1)
    # Normalise the target column name across possible UCI variants.
    if C.TARGET_DIABETES not in df.columns:
        for cand in ("Diabetes_binary", "Diabetes_012", "class"):
            if cand in df.columns:
                df = df.rename(columns={cand: C.TARGET_DIABETES})
                break
    # Collapse any 3-class variant (0/1/2) to binary risk (0 vs 1).
    df[C.TARGET_DIABETES] = (df[C.TARGET_DIABETES] > 0).astype(int)
    df.to_csv(C.RAW_CSV, index=False)
    print(f"[data] Saved cache -> {C.RAW_CSV} ({len(df):,} rows)")
    return df


def summarise(df: pd.DataFrame) -> dict:
    """Produce a compact, report-friendly summary of the dataset."""
    pos = int(df[C.TARGET_DIABETES].sum())
    total = len(df)
    return {
        "rows": total,
        "features": len([c for c in df.columns if c != C.TARGET_DIABETES]),
        "positive_cases": pos,
        "positive_rate": round(100 * pos / total, 2),
        "missing_values": int(df.isna().sum().sum()),
    }


def make_splits(df: pd.DataFrame):
    """Split into train/test and standard-scale the features.

    Returns X_train, X_test, y_train, y_test, fitted_scaler.
    """
    available = [f for f in C.FEATURES if f in df.columns]
    X = df[available].astype(float)
    y = df[C.TARGET_DIABETES].astype(int)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=C.TEST_SIZE, random_state=C.RANDOM_STATE, stratify=y
    )
    scaler = StandardScaler()
    X_train_s = pd.DataFrame(
        scaler.fit_transform(X_train), columns=available, index=X_train.index
    )
    X_test_s = pd.DataFrame(
        scaler.transform(X_test), columns=available, index=X_test.index
    )
    return X_train_s, X_test_s, y_train, y_test, scaler, available
