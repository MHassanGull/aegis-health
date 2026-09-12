# AI Medical Assist — Backend (Django REST API)

Serves the trained multi-task model behind a secure REST API: JWT auth, risk
prediction for diabetes and kidney disease, SHAP-style factor explanations, and
what-if recommendations.

## Endpoints
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET  | `/api/health/` | — | Service health check |
| POST | `/api/auth/register/` | — | Create account |
| POST | `/api/auth/login/` | — | Get JWT access + refresh tokens |
| POST | `/api/auth/refresh/` | — | Refresh access token |
| GET  | `/api/auth/me/` | ✓ | Current user profile |
| GET  | `/api/schema/` | — | Questionnaire field schema |
| POST | `/api/predict/` | ✓ | Full risk assessment (saved to history) |
| GET  | `/api/history/` | ✓ | Past assessments |

## Setup & run
```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000      # 0.0.0.0 so a phone can reach it
```
The prediction service loads `../ml/artifacts/multitask_model.joblib`. If it is
missing, train it first: `python ../ml/run_sprint2.py`.

## Quick self-test
With the server running:
```bash
python _test_api.py
```
Expected: health 200, register 201, login 200, predict 200 (with risk + factors
+ recommendations), history 200, and 401 when calling predict without a token.

## Notes
- Dev uses SQLite + open CORS for easy device testing. For production: switch to
  PostgreSQL, set `DJANGO_DEBUG=0`, a real `DJANGO_SECRET_KEY`, and restrict
  `ALLOWED_HOSTS` / CORS.
