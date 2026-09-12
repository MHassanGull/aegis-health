"""Quick inspection of the raw BRFSS 2015 XPT: confirm the columns we need exist."""
import pandas as pd
from pathlib import Path

XPT = Path(__file__).resolve().parent.parent / "data" / "raw" / "LLCP2015.XPT"

NEEDED = [
    "DIABETE3", "CHCKIDNY",                       # targets: diabetes, kidney
    "_RFHYPE5", "TOLDHI2", "_CHOLCHK", "_BMI5",   # features
    "SMOKE100", "CVDSTRK3", "_MICHD", "_TOTINDA",
    "_FRTLT1", "_VEGLT1", "_RFDRHV5", "HLTHPLN1",
    "MEDCOST", "GENHLTH", "MENTHLTH", "PHYSHLTH",
    "DIFFWALK", "SEX", "_AGEG5YR", "EDUCA", "INCOME2",
]

# Read only the first chunk to inspect schema cheaply.
itr = pd.read_sas(XPT, format="xport", chunksize=2000)
chunk = next(itr)
cols = set(chunk.columns)
print(f"Total columns in file: {len(chunk.columns)}")
print(f"Rows in first chunk:   {len(chunk)}\n")
present, missing = [], []
for c in NEEDED:
    (present if c in cols else missing).append(c)
print("PRESENT:", present)
print("\nMISSING:", missing)
if missing:
    # try to suggest near-matches
    for m in missing:
        cand = [c for c in cols if m.replace("_", "") in c.replace("_", "")]
        print(f"  near-match for {m}: {cand[:5]}")
