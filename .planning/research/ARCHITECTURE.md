# Architecture Research — MahaKumbh 2027 Smart Guide

## Overview
A micro-services and parallel processing architecture to handle real-time AI and high-density mobile synchronization.

## Component Boundaries
- **Inference Workers**: Separate Python processes for each camera stream, running YOLOv8 + ByteTrack.
- **Alert Dispatcher**: FastAPI service that manages logic for threshold violations (e.g., density > 0.8 people/sqm).
- **Client Mobile App**: Flutter/Riverpod for managing local state, map tiles, and live location synchronization.
- **Surveillance UI**: Streamlit for internal monitoring, displaying multi-camera alerts and historical counts.

## Data Flow
- **Crowd Intelligence**: `Video Stream` → `YOLOv8 + Tracking` → `FastAPI Payload` → `PostgreSQL/WebSocket` → `Mobile App`.
- **SOS Data**: `Mobile Trigger` → `FastAPI POST` → `PostgreSQL (Alarm Status)` → `Surveillance Panel Alert`.
- **Group Locations**: `Mobile App` → `Firebase Realtime DB` → `All Group Members`.

## Suggested Build Order
1.  **AI Detection Pipeline**: YOLOv8 + Multiprocessing + ByteTrack.
2.  **API Gateway**: FastAPI for crowd updates and SOS.
3.  **Client Mapping**: `flutter_map` with offline tile caching and static routes.
4.  **Real-Time Sync**: Firebase integration for group location sharing.
5.  **Analytics & UI**: Streamlit dashboard and mobile UI components.

## Integration Strategy
- **Crowd Indicators**: Map markers should update via WebSocket for low latency, with fallback to HTTP polling (every 30s) if WebSockets fail.
- **Offline Maps**: Pre-package the "Kumbh Sector" tiles in the app assets to ensure day-one functionality without initial downloads.

---
*Confidence Level: High*
