# IronMind AI

An Android-first AI home fitness trainer. The MVP includes an onboarding flow,
goal-based plans, five exercises, a workout-session UI, and a local FastAPI
service ready for MediaPipe pose analysis.

## Run the app

```powershell
cd D:\FlutterProjects\ironmind_ai
flutter run -d R5CY51TNWYA
```

## Run the local API

```powershell
cd D:\FlutterProjects\ironmind_ai\backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Open `http://127.0.0.1:8000/docs` to test the API.
