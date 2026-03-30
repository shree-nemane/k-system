# Features Research — MahaKumbh 2027 Smart Guide

## Overview
Defining the core feature set to address safety, navigation, and coordination for approximately 300 million attendees.

## Table Stakes (Must-Have)
- **Real-Time Crowd Density (Ghat/Camp Focus)**: Visual Green/Yellow/Red status Indicators based on YOLOv8 counts.
- **Emergency SOS**: Single-button triggering with background GPS polling and auto-retry for API calls.
- **Offline Map Navigation**: `flutter_map` with pre-cached tiles and reliable static routes.
- **Lost and Found (Reporting)**: Basic forms (Name, Photo, Last Seen) stored in PostgreSQL with community search.
- **Find My Group**: Location sharing using Firebase Realtime Database for low latency.

## Differentiators (Competitive Advantage)
- **Multi-Camera Panic Detection**: Optical flow integration in the surveillance pipeline to detect "sudden motion spikes" (stampede warning).
- **Proximity Violation Alerts**: Automated backend detection of density thresholds at critical bottlenecks.
- **Spiritual & Event Content (Offline)**: High-quality ritual guides and bathing dates available even during network blackouts.
- **Low-Data Mode**: Optimization for congested network environments (minimal payload updates).

## Anti-Features (Explicitly NOT building)
- **Live Video Streaming to App**: Too heavy for congested networks; use discrete data indicators instead.
- **Heatmaps**: Too complex for common users to read and expensive to render; replaced by simple color markers.
- **Third-Party Real-Time Routing**: Unreliable in offline scenarios; replaced by predefined routes (overlays).

## Dependencies
- **Crowd Count Accuracy**: Depends on high-quality YOLOv8 inference and camera positioning.
- **GPS Reliability**: Depends on device hardware and satellite visibility (crowds can block signals).
- **Notification Delivery**: Depends on FCM (network connectivity required for pushes).

## Complexity Analysis
- **High**: Multi-camera parallel YOLOv8 processing and real-time density synchronization.
- **Medium**: Offline map tile caching and custom route overlays.
- **Medium**: Firebase-based live location sharing (Find My Group).
- **Low**: SOS reporting and spiritual content management.

---
*Confidence Level: High*
