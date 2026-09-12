# AI Medical Assist

A predictive lifestyle health-risk assessment system. Users answer a short
questionnaire about their daily habits and receive their **future risk** of
**Diabetes** and **Chronic Kidney Disease** — with no blood test — plus an
explanation of the key factors and personalised advice on what to change.

## Architecture
```
┌──────────────┐   REST/JWT    ┌─────────────────────┐    loads    ┌──────────────┐
│ Flutter app  │ ────────────► │ Django REST backend │ ──────────► │ Multi-task   │
│ (mobile/)    │ ◄──────────── │ (backend/)          │             │ ML model     │
└──────────────┘   risk + why  └─────────────────────┘             │ (ml/)        │
                    + advice                                        └──────────────┘
```

## Components
| Folder | What it is | Status |
|---|---|---|
| `ml/` | Multi-task model (diabetes + kidney) trained on CDC BRFSS (~253k records) | ✅ trained & evaluated |
| `backend/` | Django REST API: auth, prediction, explainability, what-if, history | ✅ built & tested |
| `mobile/` | Flutter app: questionnaire, risk dashboard, recommendations, history | ✅ built (run on device) |

## End-to-end run order
```bash
# 1) Train the model (one time; auto-downloads the data)
cd ml
pip install -r requirements.txt
python src/extract_multitask.py
python run_sprint2.py

# 2) Start the backend API
cd ../backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000

# 3) Launch the app (new terminal)
cd ../mobile
flutter create --project-name ai_medical_assist .
flutter pub get
flutter run        # set API_BASE_URL for your device — see mobile/README.md
```

## Model performance (held-out test set)
| Disease | ROC-AUC | Recall (sensitivity) |
|---|---|---|
| Diabetes | 0.82 | 0.85 |
| Kidney | 0.79 | 0.86 |

One shared model predicts both diseases as well as two separate models.

> **Disclaimer:** educational screening tool, not a medical diagnosis.
