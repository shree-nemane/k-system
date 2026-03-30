# Research Summary — MahaKumbh 2027 Smart Guide

## Overview
Synthesized findings for building a safety-critical, high-density pilgrim assistance platform.

## Key Findings

### Tech Stack
- **Mobile**: Flutter 3.x + Riverpod + Isar (NoSQL) + `flutter_map`.
- **Backend**: FastAPI + PostgreSQL + Firebase RTDB (Live sync).
- **AI**: YOLOv8 + ByteTrack (Parallel Workers).
- **Surveillance**: Streamlit multi-camera dashboard.

### Core Features
- **Real-time Crowd Indicators**: Map-based Green/Yellow/Red indicators derived from parallel YOLO feeds.
- **Robust Emergency SOS**: GPS-aware requests with local queuing and background retries.
- **Offline Reliability**: Pre-cached map tiles and local JSON assets for spiritual content.
- **Group Coordination**: Real-time location sharing via low-latency Firebase sync.

### Architecture
- **Parallel Workers**: Decoupled AI workers for each camera feed to prevent dashboard bottlenecks.
- **Micro-Backend**: FastAPI handles logic for crowd thresholds, SOS alerts, and metadata.
- **Client Caching**: Hive/Isar for offline-first safety alerts and navigations.

### Bottlenecks & Pitfalls
- **Network Congestion**: Addressed via pre-cached tiles and background SOS retries.
- **Battery Drain**: Addressed via dynamic GPS polling and "Low Power Mode".
- **AI Crowding Limits**: Addressed via high camera placement and modern tracking (ByteTrack).

## Build Strategy
1.  **Phase 1: Detection Pipeline & Core Backend**. Establish the "Source of Truth" for crowd data.
2.  **Phase 2: Mobile - Safety & Offline Mapping**. Deliver the core reliability layer (SOS, Maps).
3.  **Phase 3: Group Sync & Notifications**. Add interaction (Firebase sync, FCM).
4.  **Phase 4: Surveillance Panel & Analytics**. Tools for authorities to monitor and respond.

---
*Last updated: 2026-03-30*
