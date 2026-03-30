# Stack Research — MahaKumbh 2027 Smart Guide

## Overview
The 2027 stack for a high-density, safety-critical event like MahaKumbh requires a focus on **efficiency, offline reliability, and real-time AI performance**.

## Recommended Stack

### Mobile (Pilgrim App)
- **Framework**: `Flutter 3.x` (or latest 2027 stable).
- **State Management**: `Riverpod`. Provides robust, testable, and reactive state handling.
- **Mapping**: `flutter_map` with `OpenStreetMap`.
  - **Offline**: Use `flutter_map_tile_caching` for pre-loading and on-the-fly caching.
- **Local Storage**: `Isar` or `Hive`. Fast NoSQL storage for alerts, schedules, and cached SOS data.
- **Notifications**: `Firebase Cloud Messaging (FCM)` for push alerts.

### Backend (Core & Data)
- **API Framework**: `FastAPI` (Python 3.12+). High performance, asynchronous, and excellent for ML integration.
- **Primary Database**: `PostgreSQL` with `PostGIS` (for geospatial SOS and location data).
- **Real-time Sync**: `Firebase Realtime Database`. Specifically for "Find My Group" to leverage low-latency synchronization without heavy backend overhead.
- **WebSockets**: Native FastAPI implementation for real-time crowd density updates to mobile clients.

### AI & Computer Vision (Crowd Monitoring)
- **Detection Model**: `YOLOv8` (Ultralytics). 
  - **Version**: `yolov8n` (Nano) for speed on edge/server or `yolov8m` for balanced accuracy if hardware permits.
- **Tracking**: `ByteTrack` or `BoT-SORT`. More modern and efficient than DeepSORT for high-density crowds.
- **Processing**: `OpenCV` + `Multiprocessing` in Python to handle parallel camera feeds.

### Surveillance Dashboard
- **Frontend**: `Streamlit`. Quick development of interactive AI dashboards with real-time charting.
- **Analytics**: `Pandas` + `Plotly` for historical trend visualization.

## Hardware & Deployment
- **Edge Inference**: NVIDIA Jetson Orin or high-end server with RTX GPUs for parallel YOLO processing.
- **Network**: Deployment of local Wi-Fi meshes or 5G private networks where possible; otherwise, must rely on the offline-first strategies defined in the app.

## What NOT to use
- **Heavy React Native**: Flutter's drawing engine is preferred for smooth map interactions on lower-end devices.
- **Django**: Too heavy for the specific real-time high-throughput requirements of crowd data pulses; FastAPI's async nature is superior here.
- **Google Maps API (for primary map)**: Cost and offline limitations make OSM + `flutter_map` a better choice for this specific use case.

## Rationale
- **FastAPI**: Minimizes latency between YOLO detections and mobile alerts.
- **Riverpod**: Ensures the app state (e.g., SOS status, group locations) stays consistent even during connectivity drops.
- **Isar**: Offers better performance and acid compliance for critical safety data compared to older solutions.

---
*Confidence Level: High*
