# README.md

## 👀 Project Overview

This is a **Feature Voting System** developed as part of a hands-on challenge for an AI-powered software developer position. The solution demonstrates full-stack implementation, AI-assisted workflows, and clear system thinking.

---

## 🔧 Tech Stack

- **Backend**: FastAPI (Python) deployed on [Render](https://render.com) (free tier)
- **Database**: Firestore (Google Firebase) via Firebase Admin SDK
- **Web Frontend**: HTML + JavaScript (Vanilla), deployed via [Netlify Drop](https://feature-request-ui.netlify.app/)
- **Mobile Frontend**: Flutter (Android only)
- **AI Assistance**: Google Gemini for prompt engineering and code generation

---

## 🌐 Live Web Frontend

The frontend is deployed at:

**→ https://feature-request-ui.netlify.app/**

> ⚠️ Note: The backend is hosted on Render's **free tier**, which may cause cold start delays. If the frontend seems unresponsive, just wait and try again.

---

## 📱 Mobile App

The Android app was built using **Flutter**, with:
- Feature list screen
- Add feature form
- Vote functionality (via REST API)

> ⚡ Due to time constraints, the UI was not fully tested. The logic is implemented and ready to be validated.

---

## 📂 Project Structure

```bash
METACTO-EXERCISE/
├── backend/                    # FastAPI Backend (Python)
│   ├── main.py
│   ├── schemas.py
│   ├── firestore_client.py
│   └── requirements.txt
│
├── frontend/
│   ├── web/                    # Web App (HTML + JS)
│   │   └── index.html
│   │
│   └── mobile/                 # Mobile App (Flutter)
│       ├── pubspec.yaml
│       └── lib/
│           ├── main.dart
│           ├── models/
│           │   └── feature_model.dart
│           ├── screens/
│           │   ├── add_feature_screen.dart
│           │   └── feature_list_screen.dart
│           ├── services/
│           │   └── api_service.dart
│           └── utils/
│               └── device_identifier.dart
│
├── .gitignore
└── prompts.txt                 # Prompts used with Gemini
```

---

## ⚙️ Running the Backend Locally

```bash
cd backend
pip install -r requirements.txt
export GOOGLE_APPLICATION_CREDENTIALS="path/to/firebase-key.json"
uvicorn main:app --reload
```

---

## 🚀 Deployment

- **Backend**: Deployed on Render (cold starts expected)
- **Frontend Web**: Deployed via Netlify Drop
- **Mobile App**: Can be compiled using `flutter run`

---

## 📡 API Reference

### `GET /features`
Returns a list of all features with vote counts.

### `POST /features`
Creates a new feature.
```json
{
  "title": "Dark Mode",
  "description": "Add dark mode support"
}
```

### `POST /features/{id}/vote`
Registers a vote for a specific feature.
```json
{
  "user_identifier": "abc123"  // Unique ID for deduplication
}
```

---

## ✅ Notes

- Focused on simplicity, readability, and logging
- No authentication implemented
- Voting limited by simulated `user_identifier`
- Gemini used to guide design and generate code
- Logs and exception handling implemented across the stack

---

## 🔹 Prompt Log
See `prompts.txt` for the full list of structured prompts used throughout the development process.
