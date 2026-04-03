# Phase 3: Safety Systems & SOS - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a reliable, offline-first emergency signaling system for high-density environments:
1. **SOS Trigger Logic**: 5-second cancelable "Long Press" button with immediate GPS capture.
2. **Offline-First Delivery**: Local Isar queue for storing failed pulses + Android WorkManager for background retries with intelligent backoff.
3. **Payload Enrichment**: Each SOS pulse includes location (lat/lon), altitude, battery level, emergency category, and device identifier.
4. **Rescuer Status Pipeline**: 3-tier feedback loop (Sent → Received → Dispatched) delivered via FCM and short-polling fallback.
5. **Entity Service**: Basic user management using persistent Device IDs and locally-stored Emergency Contact information.

This phase does NOT include: real-time location sharing (Phase 4), Lost & Found image reporting (Phase 5), or the full authority dispatch dashboard (Phase 6).
</domain>

<decisions>
## Implementation Decisions

### Authentication & User Identity (D-16, D-17)
- **D-16:** Identity Strategy = **Device ID (Temporary)**. Phase 3 uses a unique, persistent UUID generated on first launch. Account-based OTP registration is deferred to a later milestone.
- **D-17:** Emergency Contact Storage = **Local Only (Isar)**. Pilgrim's "Next of Kin" contact info is stored locally and transmitted as a payload field within the SOS pulse to ensure it's always accessible even if the backend user profile is missing.

### Offline Reliability & Retry Logic (D-18, D-19)
- **D-18:** Delivery Mechanism = **Isar Queue + WorkManager (Android)**. Failed pulses are persisted to Isar. WorkManager manages retries in the background, ensuring pulses are sent even if the app is closed or the phone reboots.
- **D-19:** Retry Policy = **Intelligent Exponential Backoff**. Initial retry after 30s, scaling to 15-minute intervals to preserve battery if the user is in a long-term "dead zone".

### SOS Payload & Interaction (D-20, D-21)
- **D-20:** SOS Payload Data = **Location + Vital Metadata**. Includes `latitude`, `longitude`, `altitude`, `battery_level`, `device_id`, and `emergency_type`.
- **D-21:** Emergency Categories = **Simple Enum**. Fixed list: `MEDICAL`, `LOST`, `FIRE`, `GENERAL`.
- **D-22:** Interaction Pattern = **Long Press + 5s Cancel Window**. A "press-and-hold" button initiates a 5-second visual countdown. If the user releases before 0, the request is aborted. This prevents accidental triggers in dense crowds.

### Status Feedback & Reassurance (D-23, D-24)
- **D-23:** Delivery Channels = **FCM (Push) + Short-Polling (15s)**. Backend pushes status updates via Firebase Cloud Messaging. If FCM fails or is blocked, the app polls the status of the "current" SOS request every 15 seconds.
- **D-24:** 3-Tier Status Visibility =
    - **Tier 1: Sent** (Confirmed receipt by backend API).
    - **Tier 2: Received** (Automatically or manually acknowledged by authority system).
    - **Tier 3: Dispatched** (A rescuer/medical team has been assigned and is moving).

### Agent's Discretion
- Choice of Isar schema versioning and initial migration approach for Mobile.
- Exact WorkManager constraint configuration (e.g., `requiresNetworkType(NetworkType.CONNECTED)`).
- Visual design for the 5-second countdown timer.
- Backend Pydantic schema for the enriched SOS payload.
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Planning
- `.planning/ROADMAP.md` — Requirement IDs (SAFE-01, SAFE-02, SAFE-03).
- `.planning/REQUIREMENTS.md` — SOS and Safety requirements.

### Phase Context
- `.planning/phases/01-backend-ai-foundation/01-CONTEXT.md` — For existing `sos_requests` table and POST endpoint.

### Research
- `.planning/research/STACK.md` — Infrastructure recommendations (Isar, WorkManager).

</canonical_refs>

<deferred>
## Deferred Ideas
- Phone Number OTP Authentication (to Phase 4 or Milestone 2).
- Image reporting for SOS (Phase 5).
- Real-time location sharing of rescuers (Phase 6).
</deferred>

---
*Phase: 03-safety-systems*
*Context gathered: 2026-04-03 via /gsd-discuss-phase 3*
