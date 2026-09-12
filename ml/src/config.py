"""Central configuration for the AI Medical Assist ML core.

Keeping every path, feature name and tunable in one place follows the
single-source-of-truth principle and keeps the rest of the pipeline clean.
"""
from pathlib import Path

# --------------------------------------------------------------------------- paths
ML_ROOT = Path(__file__).resolve().parent.parent
DATA_RAW = ML_ROOT / "data" / "raw"
DATA_PROCESSED = ML_ROOT / "data" / "processed"
ARTIFACTS = ML_ROOT / "artifacts"
REPORTS = ML_ROOT / "reports"

for _d in (DATA_RAW, DATA_PROCESSED, ARTIFACTS, REPORTS):
    _d.mkdir(parents=True, exist_ok=True)

# --------------------------------------------------------------------------- dataset
# UCI Machine Learning Repository - "CDC Diabetes Health Indicators" (BRFSS 2015).
# 253,680 records, 21 lifestyle / behavioural features, binary diabetes target.
UCI_DATASET_ID = 891
RAW_CSV = DATA_RAW / "brfss_diabetes_health_indicators.csv"
TARGET_DIABETES = "Diabetes_binary"

# Human-readable meaning of every feature (used in reports and, later, the app form).
FEATURE_DESCRIPTIONS = {
    "HighBP": "Ever told blood pressure is high",
    "HighChol": "Ever told cholesterol is high",
    "CholCheck": "Cholesterol check in past 5 years",
    "BMI": "Body Mass Index",
    "Smoker": "Smoked at least 100 cigarettes in lifetime",
    "Stroke": "Ever told had a stroke",
    "HeartDiseaseorAttack": "Coronary heart disease or heart attack",
    "PhysActivity": "Physical activity in past 30 days",
    "Fruits": "Eats fruit one or more times per day",
    "Veggies": "Eats vegetables one or more times per day",
    "HvyAlcoholConsump": "Heavy alcohol consumption",
    "AnyHealthcare": "Has any health-care coverage",
    "NoDocbcCost": "Could not see doctor due to cost",
    "GenHlth": "Self-rated general health (1 best - 5 worst)",
    "PhysHlth": "Days of poor physical health (past 30)",
    "DiffWalk": "Serious difficulty walking or climbing stairs",
    "Sex": "Sex (0 female, 1 male)",
    "Age": "Age category (1 = 18-24 ... 13 = 80+)",
    # Education & Income removed for a friendlier, less intrusive questionnaire.
    # MentHlth removed too: asking how many days someone felt mentally unwell
    # is intrusive for a diabetes and kidney screening, and permutation
    # importance put it 15th of 19, worth about 0.001 AUC. Not a trade worth
    # making.
}
FEATURES = list(FEATURE_DESCRIPTIONS.keys())

# --------------------------------------------------------------------------- training
RANDOM_STATE = 42
TEST_SIZE = 0.20
# Decision threshold tuned for screening: we prefer catching at-risk people
# (high recall) over avoiding the occasional false alarm.
SCREENING_THRESHOLD = 0.30
