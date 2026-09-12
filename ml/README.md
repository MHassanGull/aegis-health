# AI Medical Assist — ML Core

Machine learning engine for predicting **future risk** of Diabetes and (Sprint 2) Chronic
Kidney Disease from everyday **lifestyle** data — no blood test required.

## Approach
- **Prevention, not detection.** Inputs are lifestyle/behavioural answers (activity, diet, BMI,
  blood-pressure history, smoking, etc.), not clinical lab values.
- **Real data.** Trained on the CDC BRFSS survey (~250,000 people) via the UCI repository.
- **Screening-appropriate metrics.** We optimise **Recall (sensitivity)** and **ROC-AUC**, not
  raw accuracy, because missing an at-risk person is the costly error.
- **Two models.** A transparent Logistic Regression baseline and a stronger Gradient Boosting
  champion, compared head-to-head.

## Project layout
```
ml/
  src/
    config.py     # paths, feature list, tunables (single source of truth)
    data.py       # auto-download (UCI id=891), cache, preprocess, split
    models.py     # baseline + champion model definitions
    evaluate.py   # screening metrics + confusion / ROC plots
  run_sprint1.py  # runs the whole diabetes pipeline end to end
  data/           # raw + processed (auto-created, git-ignored)
  artifacts/      # trained model (diabetes_model.joblib)
  reports/        # metrics JSON + plots
  requirements.txt
```

## How to run (Sprint 1 — Diabetes)
From the `ml/` folder:
```bash
pip install -r requirements.txt
python run_sprint1.py
```
The first run downloads the dataset automatically (~a few MB) and caches it; later runs are
offline. Outputs land in `reports/` and `artifacts/`.

## Roadmap
- **Sprint 1 (done):** Diabetes risk pipeline on BRFSS, baseline vs champion, full evaluation.
- **Sprint 2:** Add Chronic Kidney Disease label from raw BRFSS → **multi-task model** (one
  shared backbone, two risk heads).
- **Sprint 3:** SHAP explainability + counterfactual "what-if" recommendations.
- **Sprint 4:** Wrap the model behind the Django REST prediction service.
