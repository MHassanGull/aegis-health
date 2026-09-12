"""Standalone smoke test for the prediction service (no Django needed)."""
import json
from predictions.service import PredictionService

# A higher-risk example profile (sedentary, overweight, poor general health).
profile = {
    "HighBP": 1, "HighChol": 1, "CholCheck": 1, "BMI": 34.0, "Smoker": 1,
    "Stroke": 0, "HeartDiseaseorAttack": 0, "PhysActivity": 0, "Fruits": 0,
    "Veggies": 0, "HvyAlcoholConsump": 0, "AnyHealthcare": 1, "NoDocbcCost": 0,
    "GenHlth": 4, "MentHlth": 5, "PhysHlth": 10, "DiffWalk": 1, "Sex": 1,
    "Age": 10, "Education": 4, "Income": 5,
}

svc = PredictionService.instance()
print("Loaded model. Features:", len(svc.features))
result = svc.assess(profile)
print(json.dumps(result, indent=2))
