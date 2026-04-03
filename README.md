# MahaKumbh 2027 Smart Guide

![MahaKumbh 2027](https://img.shields.io/badge/Project-MahaKumbh%202027-orange)
![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-green)
![AI](https://img.shields.io/badge/AI-YOLOv8-red)

A comprehensive, safety-focused, and offline-capable ecosystem designed to assist millions of pilgrims and authorities during the **MahaKumbh Mela 2027**. 

## 🌟 Overview

The MahaKumbh 2027 Smart Guide addresses the extreme challenges of safety, coordination, and navigation in high-density religious gatherings. By combining **real-time AI crowd monitoring** with **offline-first mobile navigation**, the system ensures that pilgrims stay safe and informed even in environments with limited network connectivity.

---

## 🚀 Key Features

### 📱 Pilgrim Mobile App (Flutter)
- **Offline Maps & Navigation**: Pre-downloaded map tiles and predefined routes between ghats, camps, and medical centers.
- **Emergency SOS**: One-tap SOS alerts with local queuing and automatic background synchronization when connectivity returns.
- **Spiritual Guide**: Offline-accessible ritual calendars (Shahi Snan dates), event schedules, and cultural guides.
- **Lost & Found**: Community-driven reporting system for missing persons or belongings.
- **Crowd Alerts**: Real-time safety notifications based on AI-analyzed crowd density.

### ⚙️ Backend & AI Engine (FastAPI + YOLOv8)
- **AI Crowd Monitoring**: YOLOv8-powered multi-camera detection for real-time headcount and density estimation.
- **Panic Detection**: Computer vision algorithms (Optical Flow) to detect sudden erratic movements and potential stampedes.
- **Alert Dispatch**: WebSocket-based real-time alert system for instant notification of emergency services and pilgrims.
- **Data Persistence**: PostgreSQL with Alembic for structured data management.

### 🛡️ Authority Dashboard (Streamlit)
- **Multi-Camera Grid**: Live surveillance feed monitoring with AI overlays.
- **Trend Analysis**: Historical crowd density trends and panic event logs.
- **Density Heatmaps**: Visual indicators (Green/Yellow/Red) for critical sectors and ghats.
- **Emergency Response**: Centralized view of all SOS requests with precise GPS coordinates.

---

## 🛠️ Technology Stack

| Component | technologies |
|-----------|--------------|
| **Mobile** | Flutter, Dart, Riverpod (State), Isar (Local DB), `flutter_map` |
| **Backend** | FastAPI, Python, PostgreSQL, Alembic (Migrations) |
| **AI/CV** | YOLOv8 (Ultralytics), OpenCV, NumPy |
| **Dashboard** | Streamlit |
| **Real-time** | WebSockets, Firebase Cloud Messaging (FCM) |

---

## 📂 Project Structure

```text
k-system/
├── backend/            # FastAPI Server & AI Logic
│   ├── app/            # Core API, Models, Schemas
│   ├── dashboard/      # Streamlit Authority Dashboard
│   ├── workers/        # AI Worker processes (YOLO, Panic Detect)
│   ├── alembic/        # Database migration history
│   └── main.py         # Backend entry point
├── mobile/             # Flutter Mobile Application
│   ├── lib/            # App source code (Riverpod providers, UI)
│   ├── assets/         # Offline data (Maps, Rituals, Local JSON)
│   └── pubspec.yaml    # Flutter dependencies
├── scripts/            # Utility and testing scripts
├── app/                # Static assets and additional services
└── yolov8n.pt          # Pre-trained YOLOv8 model weights
```

---

## 🔧 Setup & Installation

### 1. Prerequisites
- **Python 3.10+**
- **Flutter 3.10+**
- **PostgreSQL**
- **Node.js** (for certain utility tools)

### 2. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
# Configure database in .env
alembic upgrade head
python main.py
```

### 3. Mobile Setup
```bash
cd mobile
flutter pub get
# Ensure Isar generators are run
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### 4. Running the Dashboard
```bash
cd backend/dashboard
streamlit run main.py
```

### 5. Starting AI Workers
To start the multi-camera monitoring pipeline (simulated or real):
```bash
python backend/workers/supervisor.py  # Launches parallel YOLO workers
```

---

## 📜 Roadmap & Status
- [x] **Phase 1-3**: Foundation, Mobile Core, and Safety Systems (Complete).
- [x] **Phase 5-6**: Spiritual Guide and AI Surveillance (Complete).
- [ ] **Phase 7**: Optimization & Scale (Next Steps).
- [ ] **Phase 8-9**: Hardening and Final Deployment.

---

## 🤝 Contributing
This project was developed using a **Modular AI-First Workflow**. For significant changes, please consult the `.planning/` directory for current architectural context and design decisions.

---

## 🛡️ License
Copyright © 2026 MahaKumbh 2027 Development Team. All rights reserved.
