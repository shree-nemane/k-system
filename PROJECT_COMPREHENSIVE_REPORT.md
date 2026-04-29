# MahaKumbh 2027 Smart Guide - Comprehensive Project Report

## 1. Executive Summary

The **MahaKumbh 2027 Smart Guide** is a mission-critical, offline-first ecosystem designed to manage the immense scale and complexity of the 2027 MahaKumbh Mela in Prayagraj. It provides a seamless blend of spiritual guidance for pilgrims and advanced, AI-driven surveillance for authorities.

The system is composed of four primary pillars:
1.  **Mobile Application (Flutter):** An offline-capable guide for pilgrims offering maps, ritual timelines, and an emergency SOS system that works even in disconnected environments.
2.  **Backend API (FastAPI):** The central nervous system managing data persistence, real-time event broadcasting, and API coordination.
3.  **AI Surveillance Engine (Python/YOLOv8/OpenCV):** A multi-processing computer vision system analyzing RTSP camera feeds for crowd density and panic detection.
4.  **Authority Dashboard (Streamlit):** A real-time command center for monitoring crowd flow, reviewing safety alerts, and responding to SOS pulses.

## 2. System Architecture

The architecture is designed for resilience, concurrent processing, and offline availability.

### 2.1 Backend & Infrastructure (FastAPI + PostgreSQL)
-   **Framework:** FastAPI for high-performance, asynchronous HTTP and WebSocket endpoints.
-   **Database:** PostgreSQL with `asyncpg` and SQLAlchemy 2.0. Database migrations are managed via Alembic (`env.py` configured for async).
-   **Real-time Communication:** A thread-safe `ConnectionManager` (`ws_manager.py`) handles WebSocket connections, broadcasting messages based on specific topics (e.g., `global`, `camera_specific`).
-   **Design Patterns:** Uses dependency injection for database sessions and API key authentication (`Depends(get_api_key)`).

### 2.2 AI Surveillance Engine (Multi-Processing)
-   **Process Isolation:** The `CameraProcessor` (`processor.py`) utilizes Python's `multiprocessing` with the `spawn` start method. This ensures that each camera feed operates in a completely isolated memory space, preventing memory leaks or crashes in one OpenCV/CUDA context from affecting the entire system.
-   **Supervisor:** `supervisor.py` acts as a watchdog, monitoring worker processes and automatically restarting any that terminate unexpectedly after a 10-second cooldown.
-   **Detection Logic (`detector.py`):**
    -   **Density:** Uses YOLOv8 object detection to count persons. A sustained "high" density (over a threshold for 5 consecutive frames) triggers a density alert.
    -   **Panic:** Implements dense Optical Flow (Farneback) to calculate motion magnitude. It uses an Exponential Moving Average (EMA) baseline to detect sudden, abnormal spikes in movement, indicative of a stampede or panic.

### 2.3 Mobile Application (Flutter)
-   **State Management:** Riverpod (`flutter_riverpod`) is used extensively for predictable state management across providers (e.g., `LiveAlertNotifier`, `NavigationNotifier`, `TabProvider`).
-   **Offline-First Strategy (Isar DB):** The app uses Isar Database for local persistence of `SOSRequest`, `Ritual`, and `EmergencyContact` models. This allows pilgrims to view data and queue SOS requests without internet access.
-   **Background Sync:** Uses `workmanager` to run headless tasks (`workmanager_callback.dart`). When an offline SOS is queued, Workmanager attempts to sync it with the backend once network connectivity is restored.
-   **Mapping & Navigation:**
    -   Uses `flutter_map` with `flutter_map_tile_caching` (FMTC) for offline map viewing.
    -   Integrates `RoutingService` using OSRM (Open Source Routing Machine) to provide actual road-following paths rather than simple straight lines, ensuring pilgrims are directed along safe, walkable routes.

### 2.4 Authority Dashboard (Streamlit)
-   **Live Monitoring:** Connects to the backend via REST (for historical data) and WebSockets (for live updates) to display crowd density trends, camera statuses, and active alerts.

## 3. Data Models & Information Flow

### 3.1 Backend Models (`models.py`)
-   **`Camera`:** Stores metadata for RTSP streams (location, active status).
-   **`DensityLog`:** Records timestamped person counts for historical analysis.
-   **`SafetyAlert`:** Logs critical events (density breach, panic detected).
-   **`SOSRequest`:** Stores emergency pulses received from mobile devices.

### 3.2 Mobile Models (Isar)
-   **`SOSRequest`:** `uuid`, coordinates, battery level, category, status (`pending`, `sent`, `received`, `dispatched`).
-   **`Ritual`:** ID, title, description, location coordinates, start time, and importance level. Pre-loaded from `assets/data/rituals.json`.
-   **`EmergencyContact`:** Locally stored emergency contact details.

### 3.3 Event Flow Example: Density Alert
1.  **AI Worker** detects > `high_thresh` persons for 5 frames.
2.  Worker sends a `POST /alerts/internal` to the FastAPI backend.
3.  FastAPI saves the alert to PostgreSQL.
4.  FastAPI pushes the alert to the `ConnectionManager`.
5.  `ConnectionManager` broadcasts via WebSockets to all connected clients.
6.  **Mobile App** (`LiveAlertNotifier`) receives the WS message and updates the UI (e.g., Saffron/Red alert card).
7.  **Dashboard** receives the WS message and updates the central command view.

## 4. Key UI/UX Implementations (Mobile)

-   **Design System:** The app utilizes an "Ethereal Infrastructure" inspired theme (`AppTheme`), featuring saffron gradients (`saffronGradientDecoration`), tonal surface layering (`sanctuaryCardDecoration`), and deep blue/saffron brand colors.
-   **Screens:**
    -   `WelcomeScreen`: Handles GPS permission requests dynamically on startup with a spiritual greeting.
    -   `DashboardScreen`: Provides a summary of rituals, smart hubs, and live safety alerts.
    -   `HomeMapScreen`: The interactive map featuring polygon zones, polylines (routes), POI markers, and dynamic OSRM routing overlays.
    -   `SOSScreen`: A highly robust emergency screen requiring a long-press (with haptic feedback) and a 5-second countdown to prevent accidental triggers, showing real-time feedback on dispatch status.
    -   `GuideScreen`: A tabbed interface outlining the timeline of sacred rituals, synchronized via `SyncService`.

## 5. Deployment & Configuration

### 5.1 Environment Variables
A `.env` file is required at the root containing:
```env
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/kumbh_db
API_KEY=your_shared_secret
APP_HOST=0.0.0.0
APP_PORT=8000
```

### 5.2 Operational Commands
-   **Backend:** `uvicorn backend.main:app --reload`
-   **AI Supervisor:** `python backend/workers/supervisor.py`
-   **Dashboard:** `streamlit run backend/dashboard/main.py`
-   **Mobile App:**
    -   Generate Isar files: `dart run build_runner build`
    -   Run app: `flutter run`

## 6. Recent Enhancements & Known Issues

### 6.1 Recent Successes
-   **Robust Database Handling:** Implemented retry logic (`queryWithRetry`) to handle connection drops and optimized queries to prevent connection pool exhaustion.
-   **Road-Compliant Navigation:** Replaced straight-line map routing with OSRM, ensuring realistic pathfinding on the `HomeMapScreen`.
-   **Worker Stability:** Transitioned AI workers from threading to `multiprocessing(spawn)`, resolving OpenCV context clashes and CUDA errors.

### 6.2 Known Limitations / Future Work
-   **Payload Optimization:** Mobile payloads should be further compressed to ensure reliability over heavily congested 2G/3G networks expected during peak bathing days.
-   **WebSocket Scalability:** The current `ConnectionManager` is in-memory. For horizontal scaling across multiple backend instances, a Redis Pub/Sub backplane must be integrated.
-   **Missing Persons Feature:** Photo upload functionality for missing persons is planned but not fully implemented in the current API schema.
