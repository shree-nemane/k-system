# MahaKumbh 2027 Smart Guide

## What This Is

The MahaKumbh 2027 Smart Guide is a comprehensive, safety-focused, and offline-capable mobile application designed to assist pilgrims during the MahaKumbh Mela. It integrates AI-driven crowd monitoring, real-time coordination, and offline navigation to ensure safety and enhance the spiritual experience in an environment characterized by extremely high crowd density and limited network connectivity.

## Core Value

Ensuring pilgrim safety and group coordination in a high-density, low-connectivity environment through real-time crowd intelligence and reliable offline-first navigation.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] **Crowd Monitoring Pipeline**: YOLOv8-powered multi-camera detection and counting, transmitted via FastAPI to mobile clients.
- [ ] **Mobile Interface**: Flutter-based app using Riverpod for state management, displaying crowd density via discrete markers (Green/Yellow/Red).
- [ ] **Emergency SOS**: GPS-based help requests with local queuing and retry logic for intermittent connectivity.
- [ ] **Lost and Found**: Community-driven reporting system for missing or found individuals with image support.
- [ ] **Find My Group**: Real-time location sharing via Firebase Realtime Database with live map updates.
- [ ] **Offline Navigation**: `flutter_map` with local tile caching and predefined routes between key locations (ghats, camps, medical centers).
- [ ] **Spiritual Guide**: Offline-accessible bathing dates, event schedules, and ritual guides stored as local JSON assets.
- [ ] **Surveillance Dashboard**: Streamlit-based multi-camera monitoring with panic detection (Optical Flow) and proximity violation alerts.
- [ ] **Notifications**: Real-time alerts and event updates via Firebase Cloud Messaging.

### Out of Scope

- **Heatmaps**: Decided against for better clarity and performance on low-end devices; replaced by discrete indicators.
- **Real-time Routing Algorithms**: Replaced by predefined local routes to ensure reliability without internet access.

## Context

The MahaKumbh is one of the world's largest religious gatherings, presenting extreme challenges for safety, communication, and navigation. The system must operate reliably with congested networks and high user density. It uses a hybrid storage approach (PostgreSQL for structure, Firebase for real-time tracking, Hive/Isar for local caching).

## Constraints

- **Tech Stack**: Flutter/Dart (Mobile), FastAPI/Python (Backend), PostgreSQL, Firebase, YOLOv8 (AI).
- **Environment**: High crowd density, limited network connectivity, diverse hardware (low-end devices).
- **Architecture**: Decoupled parallel processing for multi-camera feeds to maintain real-time performance.
- **Mapping**: Offline-first requirement for all critical navigation features.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Discrete Indicators over Heatmaps | Better legibility and performance on low-end mobile devices. | — Pending |
| Predefined Routes | Ensures navigation works without real-time routing computations over high-latency networks. | — Pending |
| Parallel Worker Processes | Required to handle multiple video feeds for YOLOv8 without bottlenecking the dashboard. | — Pending |
| Firebase Realtime DB | Chosen for low-latency synchronization of live group locations. | — Pending |
| Hive/Isar Local Caching | Fast, nosql local storage to support offline-first requirements. | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-29 after project initialization*
