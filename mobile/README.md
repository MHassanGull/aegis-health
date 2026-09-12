# AI Medical Assist — Mobile App (Flutter)

The user-facing app: a lifestyle questionnaire that returns your future risk of
diabetes and kidney disease, explains the key factors, and recommends what to
change — talking to the Django backend over REST.

## Screens
- **Login / Register** — JWT-secured accounts.
- **Home** — start an assessment, view history.
- **Questionnaire** — friendly grouped form (the 21 lifestyle inputs).
- **Result** — risk gauges for both diseases, top risk factors, what-if advice.
- **History** — your past assessments.

## Prerequisites
- Flutter SDK **3.27+** installed (`flutter doctor` all green).
- The backend running (see `../backend/README.md`).

## First-time setup
This folder contains `lib/` and `pubspec.yaml`. Generate the platform folders
(android/ios) without touching the code:

```bash
cd mobile
flutter create --project-name ai_medical_assist .
flutter pub get
```

## Point the app at your backend
Edit `lib/core/config.dart` → `apiBaseUrl`, or pass it at run time:

| How you run | Use this URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000` (default) |
| iOS simulator | `http://127.0.0.1:8000` |
| Real phone (USB/Wi-Fi) | `http://<YOUR-PC-IP>:8000` (run `ipconfig`) |

```bash
# example: real phone on the same Wi-Fi
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000
```

## Run
```bash
flutter run
```

> Note: I could not run `flutter analyze` in this environment (no SDK here). If
> the first build reports a version-specific API tweak, it will be a one or two
> line fix — share the message and it gets resolved fast.
