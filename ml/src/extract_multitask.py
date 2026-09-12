"""Extract a clean, multi-task dataset from the raw BRFSS 2015 file.

The raw file uses survey codes (e.g. 1=Yes, 2=No, 7=Don't know, 9=Refused). This
module recodes the two disease labels (diabetes, kidney) and the 21 shared
lifestyle features into clean 0/1 (and small ordinal) values, dropping
"don't know / refused / missing" responses. The result is consistent with the
Sprint-1 feature schema so the rest of the pipeline reuses it unchanged.

Run (from ml/):  python src/extract_multitask.py
"""
import numpy as np
import pandas as pd
from pathlib import Path

ML_ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ML_ROOT / "data" / "raw"
XPT = RAW_DIR / "LLCP2015.XPT"
ZIP = RAW_DIR / "LLCP2015XPT.zip"
BRFSS_URL = "https://www.cdc.gov/brfss/annual_data/2015/files/LLCP2015XPT.zip"
OUT = ML_ROOT / "data" / "processed" / "brfss_multitask_2015.csv"
OUT.parent.mkdir(parents=True, exist_ok=True)


def ensure_xpt():
    """Make sure the raw BRFSS XPT is present, downloading & unzipping if needed."""
    if XPT.exists():
        return
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    if not ZIP.exists():
        import urllib.request
        print(f"[extract] Downloading raw BRFSS 2015 (~99 MB) ...")
        urllib.request.urlretrieve(BRFSS_URL, ZIP)
    import zipfile
    print("[extract] Unzipping ...")
    with zipfile.ZipFile(ZIP) as z:
        member = z.namelist()[0]
        with z.open(member) as src, open(XPT, "wb") as dst:
            dst.write(src.read())   # writes with a clean filename (no trailing space)

# Raw BRFSS columns we read from the file.
RAW_COLS = [
    "DIABETE3", "CHCKIDNY", "_RFHYPE5", "TOLDHI2", "_CHOLCHK", "_BMI5",
    "SMOKE100", "CVDSTRK3", "_MICHD", "_TOTINDA", "_FRTLT1", "_VEGLT1",
    "_RFDRHV5", "HLTHPLN1", "MEDCOST", "GENHLTH", "MENTHLTH", "PHYSHLTH",
    "DIFFWALK", "SEX", "_AGEG5YR", "EDUCA", "INCOME2",
]


def _map(series, mapping):
    """Map survey codes to clean values; unmapped codes become NaN (dropped later)."""
    return series.map(mapping)


def recode(df: pd.DataFrame) -> pd.DataFrame:
    out = pd.DataFrame(index=df.index)

    # ---- Targets ----------------------------------------------------------
    # Diabetes: 1 = diabetes; 2 (pregnancy only), 3 (no), 4 (pre/borderline) -> 0.
    out["Diabetes_binary"] = _map(df["DIABETE3"], {1: 1, 2: 0, 3: 0, 4: 0})
    # Kidney disease: 1 = Yes, 2 = No.
    out["Kidney_binary"] = _map(df["CHCKIDNY"], {1: 1, 2: 0})

    # ---- Binary features (1=Yes -> 1, 2=No -> 0) --------------------------
    out["HighChol"] = _map(df["TOLDHI2"], {1: 1, 2: 0})
    out["Smoker"] = _map(df["SMOKE100"], {1: 1, 2: 0})
    out["Stroke"] = _map(df["CVDSTRK3"], {1: 1, 2: 0})
    out["HeartDiseaseorAttack"] = _map(df["_MICHD"], {1: 1, 2: 0})
    out["PhysActivity"] = _map(df["_TOTINDA"], {1: 1, 2: 0})
    out["Fruits"] = _map(df["_FRTLT1"], {1: 1, 2: 0})
    out["Veggies"] = _map(df["_VEGLT1"], {1: 1, 2: 0})
    out["AnyHealthcare"] = _map(df["HLTHPLN1"], {1: 1, 2: 0})
    out["NoDocbcCost"] = _map(df["MEDCOST"], {1: 1, 2: 0})
    out["DiffWalk"] = _map(df["DIFFWALK"], {1: 1, 2: 0})

    # ---- "Risk factor" calculated vars (1=No -> 0, 2=Yes -> 1) ------------
    out["HighBP"] = _map(df["_RFHYPE5"], {1: 0, 2: 1})
    out["HvyAlcoholConsump"] = _map(df["_RFDRHV5"], {1: 0, 2: 1})

    # ---- Cholesterol check: 1 = checked in last 5 yrs -> 1, else 0 --------
    out["CholCheck"] = _map(df["_CHOLCHK"], {1: 1, 2: 0, 3: 0})

    # ---- Sex: 1=Male -> 1, 2=Female -> 0 ---------------------------------
    out["Sex"] = _map(df["SEX"], {1: 1, 2: 0})

    # ---- BMI: stored x100 ------------------------------------------------
    out["BMI"] = df["_BMI5"] / 100.0

    # ---- Ordinal / count features ----------------------------------------
    out["GenHlth"] = df["GENHLTH"].where(df["GENHLTH"].between(1, 5))
    # 88 = "none" -> 0 days; 77/99 = DK/refused -> NaN
    out["MentHlth"] = df["MENTHLTH"].replace(88, 0).where(lambda s: s.between(0, 30))
    out["PhysHlth"] = df["PHYSHLTH"].replace(88, 0).where(lambda s: s.between(0, 30))
    out["Age"] = df["_AGEG5YR"].where(df["_AGEG5YR"].between(1, 13))
    out["Education"] = df["EDUCA"].where(df["EDUCA"].between(1, 6))
    out["Income"] = df["INCOME2"].where(df["INCOME2"].between(1, 8))
    return out


def main():
    ensure_xpt()
    print("[extract] Reading raw BRFSS 2015 in chunks ...")
    cleaned = []
    total_raw = 0
    reader = pd.read_sas(XPT, format="xport", chunksize=50_000)
    for i, chunk in enumerate(reader, 1):
        total_raw += len(chunk)
        chunk = chunk[RAW_COLS]
        cleaned.append(recode(chunk))
        print(f"   chunk {i:>2}: read {total_raw:,} rows", end="\r")
    print()

    df = pd.concat(cleaned, ignore_index=True)
    before = len(df)
    df = df.dropna().reset_index(drop=True)
    # Cast everything to compact numeric types.
    for c in df.columns:
        df[c] = pd.to_numeric(df[c])
    int_cols = [c for c in df.columns if c != "BMI"]
    df[int_cols] = df[int_cols].astype(int)

    df.to_csv(OUT, index=False)

    print(f"[extract] Raw rows read     : {total_raw:,}")
    print(f"[extract] After recoding    : {before:,}")
    print(f"[extract] After dropping NA : {len(df):,}")
    print(f"[extract] Diabetes positive : {df['Diabetes_binary'].mean()*100:.2f}%")
    print(f"[extract] Kidney   positive : {df['Kidney_binary'].mean()*100:.2f}%")
    print(f"[extract] Saved -> {OUT}")


if __name__ == "__main__":
    main()
