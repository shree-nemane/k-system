# Phase 3: Safety Systems & SOS - Research

**Date:** 2026-04-03
**Status:** Completed

## 1. Research Objective
Investigate technical patterns for high-reliability emergency signaling in Flutter/FastAPI, focusing on offline persistence, background resilience, and high-stress UI/UX.

## 2. Key Findings

### 2.1. Offline Persistence (Isar)
- **Local-First Pattern**: The UI should never trigger a network request directly. Instead, it writes to an Isar `SOSQueue` collection.
- **Sync Status**: The data model must include `syncStatus` (Enum: `pending`, `sent`, `failed`), `retryCount`, and `lastAttemptTimestamp`.
- **Atomic Reliability**: Using Isar transactions ensures that we don't end up with a "triggered" UI state without a corresponding database record.

### 2.2. Background Resilience (WorkManager & Services)
- **Foreground Service Requirement**: Android (especially OEM versions like MiUI/Samsung) aggressively kills background processes. For the active duration of an SOS (the countdown and initial transmission), a **Foreground Service** with a persistent "Emergency SOS Active" notification is required to ensure the CPU doesn't sleep.
- **WorkManager for Off-Band Retries**: If the initial foreground attempts fail and the user closes the app, WorkManager picks up the `pending` items from Isar using `NetworkType.CONNECTED` constraints and an **Exponential Backoff** strategy ($30s, 60s, 120s...$ capped at $15m$).

### 2.3. Safety Interaction (UI/UX)
- **The "Safety Exit"**: In emergency design, the "Cancel" button is as important as the trigger. Research suggests a full-screen countdown modal with a high-contrast, large-hitbox "Cancel" button at the bottom (thumb-reachable).
- **Haptic/Audio Breadcrumbs**: During the 5-second countdown, a rhythmic haptic "tick" provides non-visual confirmation that the system is preparing to send, which reduces panic-driven double-tapping.

### 2.4. Feedback Pipeline (3-Tier)
- **Status Tiers**:
    - **Sent**: Server ACK received by mobile.
    - **Received**: Backend sets `status=received` (triggered by authority dashboard or automated ingest).
    - **Dispatched**: Backend sets `status=dispatched` and specifies a `responder_id`.
- **Hybrid Delivery**:
    - **WebSocket**: Used while the app is in the foreground for sub-second updates.
    - **FCM (Push)**: The primary channel for status changes when the app is backgrounded.
    - **Polling (15s)**: A fallback `GET /sos/{id}/status` ensures that even if Firebase/WebSockets are blocked by network congestion, the user eventually sees an update.

## 3. Recommended Implementation Architecture

### Mobile (Flutter)
1. **Isar Schema**: `SOSRequest` collection.
2. **Provider (Riverpod)**: `SOSProvider` watches the Isar collection and handles the logic for transitions between "Countdown" -> "Writing to DB" -> "Attempting Sync".
3. **Connectivity**: Use `connectivity_plus` to trigger an immediate sync attempt when the signal returns.

### Backend (FastAPI)
1. **Database Schema**: Update `sos_requests` to include `status` (Enum), `responder_id`, and timestamps for each tier transition.
2. **Notification Dispatcher**: A background task (potentially using `BackgroundTasks` in FastAPI) that sends FCM messages when an authority updates an SOS status.

## 4. Risks & Mitigations
- **Battery Depletion**: Mitigation: Intelligent backoff caps the retry frequency.
- **OS Suspension**: Mitigation: Proper Android Foreground Service integration.
- **Network Congestion**: Mitigation: Payload minimization (sending minimal fields: lat, lon, bat, alt, cat, dev_id).

---
*Research synthesized from best practices for safety-critical mobile applications.*
