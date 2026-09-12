"""Feature schema for the lifestyle questionnaire and the what-if engine.

This is the single source of truth the API uses to validate input, label the
explanation factors, and know which habits are realistically changeable.
"""

# Human-readable label + valid range for every model input.
FEATURE_META = {
    "HighBP":               {"label": "High blood pressure", "type": "binary"},
    "HighChol":             {"label": "High cholesterol", "type": "binary"},
    "CholCheck":            {"label": "Cholesterol checked in 5 years", "type": "binary"},
    "BMI":                  {"label": "Body Mass Index", "type": "float", "min": 12, "max": 70},
    "Smoker":               {"label": "Smoker (100+ cigarettes in life)", "type": "binary"},
    "Stroke":               {"label": "History of stroke", "type": "binary"},
    "HeartDiseaseorAttack": {"label": "Heart disease or heart attack", "type": "binary"},
    "PhysActivity":         {"label": "Physically active", "type": "binary"},
    "Fruits":               {"label": "Eats fruit daily", "type": "binary"},
    "Veggies":              {"label": "Eats vegetables daily", "type": "binary"},
    "HvyAlcoholConsump":    {"label": "Heavy alcohol consumption", "type": "binary"},
    "AnyHealthcare":        {"label": "Has health-care coverage", "type": "binary"},
    "NoDocbcCost":          {"label": "Skipped doctor due to cost", "type": "binary"},
    "GenHlth":              {"label": "General health (1 best - 5 worst)", "type": "ordinal", "min": 1, "max": 5},
    "PhysHlth":             {"label": "Poor physical-health days (0-30)", "type": "count", "min": 0, "max": 30},
    "DiffWalk":             {"label": "Difficulty walking", "type": "binary"},
    "Sex":                  {"label": "Sex (0 female, 1 male)", "type": "binary"},
    "Age":                  {"label": "Age group (1=18-24 ... 13=80+)", "type": "ordinal", "min": 1, "max": 13},
}

# Habits the user can realistically change, with the "healthier" target value and
# the advice text shown to them. Used by the what-if recommendation engine.
MODIFIABLE = {
    "BMI":               {"target": 24.0, "only_if_worse": True,
                          "action": "Bring your BMI toward a healthy range (around 24)"},
    "PhysActivity":      {"target": 1, "action": "Become physically active (30 min on most days)"},
    "Smoker":            {"target": 0, "action": "Stop smoking"},
    "Fruits":            {"target": 1, "action": "Eat fruit at least once a day"},
    "Veggies":           {"target": 1, "action": "Eat vegetables at least once a day"},
    "HvyAlcoholConsump": {"target": 0, "action": "Cut down heavy alcohol consumption"},
}


def risk_tier(prob: float, threshold: float) -> str:
    """Map a probability to an interpretable tier, anchored on the model's
    validated screening threshold (the operating point)."""
    if prob >= threshold:
        return "High"
    if prob >= threshold / 2:
        return "Moderate"
    return "Low"
