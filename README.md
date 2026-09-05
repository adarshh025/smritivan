# 🌿 SMRITIVAN (स्मृतिवन)
**SIH 2026 | Problem Statement 26003**  
*Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in the North Eastern Region*

## 👥 Team: laccha paratha
* Adarsh A
* Twinkle B
* Kashish
* Utkarsh
* Pratibha
* Akash

## 🎯 The Vision
SMRITIVAN is a calm digital "memory garden". We moved away from clinical, hospital-like interfaces to create a warm, familiar, and highly accessible companion for elderly users suffering from dementia in the NER. It operates entirely **offline-first**, solving the critical geographical and connectivity barriers in remote regions.

## 🧠 Core Features
1. **Dynamic Cognitive Game Engine:** Culturally personalized games (e.g., Muga Silk Visual Memory, Bihu Auditory Focus).
2. **On-Device Adaptive Engine (DDA):** Dynamic difficulty adjustment adapts difficulty locally based on reaction time and error rates to prevent user frustration.
3. **Cognitive Vitality Score (CVS):** Tracks long-term cognitive health without making alarming medical claims.
4. **Deep Localization:** UI and voice interaction adapt entirely to English, Hindi, Assamese, Meitei, Khasi, and Bodo.
5. **Caregiver Ecosystem:** PIN-protected dashboards and offline-syncing queues that transmit data to healthcare workers only when internet is restored.

## 🛠️ Tech Stack
* **Frontend:** Flutter, Dart, Riverpod
* **Local Database:** Drift (SQLite) for 100% offline functionality.
* **Backend:** Python, FastAPI, PostgreSQL
* **Conflict Resolution:** CRDT-inspired background Sync Queue.

## 🚀 Setup Instructions
**Mobile App:**
```bash
cd mobile
flutter pub get
dart run build_runner build -d
flutter run
```

**Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```
