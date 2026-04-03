# Project Report: MahaKumbh 2027 Smart Guide

**Date:** April 3, 2026  
**Status:** Phase 6 Complete (Surveillance & Panic Detection)  
**Primary Objective:** Pilgrim safety and coordination in high-density, low-connectivity environments.

---

## 1. Project Overview

### What is this project?
The **MahaKumbh 2027 Smart Guide** is an integrated safety and navigation ecosystem designed specifically for the world's largest religious gathering. It solves the "Triangle of Chaos" found in mega-gatherings: **Extreme Density**, **Limited Connectivity**, and **Navigational Complexity**.

### The Problem
During the MahaKumbh Mela, millions of people gather in a limited geographical area. Mobile networks often collapse (congest), traditional GPS routing fails due to temporary city structures, and crowd management becomes a life-critical task for authorities.

### The Solution
Our system provides an **Offline-First Mobile App** for pilgrims and an **AI-Powered Surveillance Dashboard** for authorities. By analyzing crowd density via AI and providing reliable offline tools to pilgrims, we create a safety net that doesn't rely on a stable internet connection for its most critical functions.

---

## 2. Core Features & Capabilities

### 📱 Pilgrim Safety & Navigation (Mobile)
*   **Resilient Navigation**: Uses `flutter_map` with a custom tile caching system. Pilgrims can download map sectors in advance and navigate between Ghats, Akhadas, and Medical Camps without any data signal.
*   **Smart SOS System**: A "Pulse" based emergency system. If a user triggers an SOS and the network is down, the app saves the request in a local **Isar Database** and continuously retries in the background until it reaches the server.
*   **Spiritual Timeline**: A centralized, offline-accessible guide for *Shahi Snan* (Royal Bath) dates, cultural events, and ritual procedures, preventing the need for physical brochures or live web searches.
*   **Emergency Contact Directory**: Pre-loaded database of local authorities, police stations, and medical centers based on the user's current sector.

### 🤖 AI Surveillance & Analytics (Backend/AI)
*   **Real-time Crowd Counting**: Utilizes **YOLOv8** (You Only Look Once) models to process multiple CCTV feeds simultaneously, providing exact headcounts and density levels (Low/Medium/High).
*   **Panic Detection (Optical Flow)**: Analyzes video frames for sudden, erratic motion spikes that indicate a panic or stampede-like situation, triggering instant high-priority alerts to authorities.
*   **Automated Alerting**: The backend monitors density thresholds. When a sector reaches "Critical" (Red) status, it automatically dispatches Firebase Cloud Messages (FCM) to all users in that vicinity to suggest safer routes.

### 🛡️ Authority Command Center (Dashboard)
*   **Streamlit Surveillance Panel**: A multi-tab dashboard for police and administrators to monitor live camera feeds with AI overlays showing density and detected events.
*   **Historical Trend Mapping**: Visualizes how crowd density shifted over the last 24 hours, allowing authorities to predict future bottlenecks.
*   **SOS Response Console**: A dedicated view that pins all active SOS requests on a map with precise GPS coordinates and user profiles.

---

## 3. Technical Architecture

### **The Stack**
| Layer | technology | Rationale |
|---|---|---|
| **Language** | Dart (Mobile), Python (Backend) | Industry standards for cross-platform UI and AI/Data processing. |
| **Mobile Framework** | Flutter | Rapid development of high-performance, beautiful UI. |
| **State Management** | Riverpod | Robust, testable, and compile-safe state handling. |
| **Local Database** | Isar / SharedPrefs | Extremely fast NoSQL storage for offline queuing and caching. |
| **API Framework** | FastAPI | Asynchronous, high-concurrency handling for real-time crowd data. |
| **Computer Vision** | YOLOv8 + OpenCV | State-of-the-art accuracy for real-time detection on edge devices. |
| **Database** | PostgreSQL | Relational integrity for user data and historical logs. |

### **System Workflow**
1.  **Detection**: AI Workers (YOLO) process camera feeds and send density metrics to the FastAPI backend.
2.  **Analysis**: Backend checks metrics against safety thresholds and historical data.
3.  **Action**: If a threat is detected, Backend sends a WebSocket alert to the Dashboard and an FCM notification to the Pilgrim App.
4.  **Assistance**: Pilgrim uses the App to find the nearest exit or medical camp via offline maps.

## 4. Technical Deep-Dive

### 💾 Data Schemas & Persistence
The system uses a unified data model across Backend (PostgreSQL) and Mobile (Isar).

| Entity | Attributes | Storage |
|---|---|---|
| **Users** | ID, DeviceID, Phone, LastSector | PostgreSQL |
| **SOS Pulse** | ID, UserID, Lat, Lng, Timestamp, Status | PostgreSQL + Isar |
| **Crowd Event** | ID, CameraID, DensityCount, PanicScore | PostgreSQL |
| **Alerts** | ID, Message, Severity, TargetSector | PostgreSQL |
| **Map Tiles** | Z/X/Y Coordinates, BLOB Data | Flutter File Cache |

### 🔌 Key API Endpoints (FastAPI)
- `POST /api/v1/sos/pulse`: Receives emergency signals from the mobile app.
- `GET /api/v1/crowd/density`: Fetches the current density levels for the map markers.
- `POST /api/v1/vision/camera-update`: Endpoint for YOLO workers to report counts.
- `GET /api/v1/alerts/active`: Long-polling or WebSocket endpoint for real-time safety notices.

### 🧩 Mobile State Management (Riverpod)
The application architecture is divided into specialized **Providers**:
- **Auth Provider**: Manages user registration and device persistent tokens.
- **SOS Provider**: Handles the background sync loop and Isar queueing logic.
- **Map Provider**: Controls tile caching, marker rendering, and static route overlays.
- **Guide Provider**: Parses and delivers local JSON ritual data to the UI.

---

## 5. Operational Guide: How to Run

### **Component 1: The Backend (Central Nervous System)**
1.  **Navigate**: `cd backend`
2.  **Environment**: Create a `.env` file based on `.env.example` with your PostgreSQL credentials.
3.  **Dependencies**: `pip install -r requirements.txt`
4.  **Database**: `alembic upgrade head` (Syncs the schema).
5.  **Start API**: `python main.py`
    *   *Default: http://localhost:8000*

### **Component 2: AI Vision Workers**
*Note: These run as parallel processes to avoid blocking the API.*
1.  **Hardware Check**: Ensure `yolov8n.pt` is in the root directory.
2.  **Launch**: `python backend/workers/supervisor.py` (This script manages multiple cameras defined in `cameras.json`).

### **Component 3: Authority Dashboard**
1.  **Navigate**: `cd backend/dashboard`
2.  **Launch**: `streamlit run main.py`
    *   *View locally at http://localhost:8501*

### **Component 4: Pilgrim Mobile App**
1.  **Navigate**: `cd mobile`
2.  **Dependencies**: `flutter pub get`
3.  **Build Assets**: `dart run build_runner build --delete-conflicting-outputs` (Required for Isar DB).
4.  **Run**: `flutter run` (Connect an Android/iOS device or emulator).

---

## 6. Resilience & Safety Protocols

### **The "Offline-First" Sync Loop**
1.  **Capture**: User hits SOS. Precise GPS and timestamp are captured instantly.
2.  **Queue**: Request is saved to **Isar DB**. UI turns Yellow ("Queued").
3.  **Listen**: A background service listens for any network heartbeat.
4.  **Sync**: As soon as a 2G/3G ping is successful, the queue is flushed.
5.  **Confirm**: UI turns Green ("Sent"). Authorities are notified.

### **Privacy & Security**
- **Anonymized Tracking**: Locations are only logged during active SOS or if the user explicitly enables "Find My Group".
- **Local-Only Data**: Ritual information and maps never leave the device, ensuring privacy and speed.
- **Encrypted Payloads**: All SOS pulses are transmitted over HTTPS to prevent interception.

---

## 7. Development Roadmap & Milestones

### **Completed Milestones**
*   ✅ **Phase 1**: High-concurrency AI pipeline and Backend foundations.
*   ✅ **Phase 2**: Offline-first mapping architecture implemented.
*   ✅ **Phase 3**: SOS synchronization and local queuing logic.
*   ✅ **Phase 5**: Spiritual guide integration and notification triggers.
*   ✅ **Phase 6**: Panic detection analytics and Authority Dashboard.

### **Upcoming: Phase 7 (Optimization & Scale)**
*   **Low-Bandwidth Mode**: Reducing JSON payload sizes for 2G/3G networks.
*   **Missing Person Reporting**: Integrating photo-upload capabilities for the community-driven search.
*   **Battery Optimization**: Tuning background SOS sync to preserve battery on low-end devices.

---

## 8. Conclusion
The **MahaKumbh 2027 Smart Guide** is more than just an app; it is a critical safety infrastructure. By bridging the gap between sophisticated AI vision and simple, reliable offline mobile tools, we provide a scalable solution for managing the safety of millions in one of the most challenging environments on Earth.

---
**Project Lead:** AI Development Team  
**Confidentiality:** For internal use by authorities and development partners.
