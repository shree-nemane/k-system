# Phase 3 Discussion Log: Safety Systems & SOS

**Discussion Date:** 2026-04-03
**Phase:** 03
**Status:** Completed

---

## Log Entries

### Area 1: Authentication & User Identity
- **Q:** How should we identify pilgrims?
- **Options:** Device ID (simplest), Phone OTP (standard), Anonymous JWT.
- **Decision:** **Device ID (for now)** to stay focused on safety pipe.
- **Q:** Where to store Emergency Contact info?
- **Decision:** **Local storage only**, sent as payload field.

### Area 2: Offline Retry Strategy
- **Q:** How should background retries work?
- **Decision:** **WorkManager (Background)** + Isar Queue. Reliable even when closed.
- **Q:** Limit retries to save battery?
- **Decision:** **Intelligent Exponential Backoff** (30s scaling up to 15m).

### Area 3: Trigger & Feedback UI
- **Q:** How should SOS be triggered?
- **Decision:** **Long Press (Primary)**.
- **Q:** Add cancel countdown?
- **Decision:** **YES — 5-second cancel window**.

### Area 4: Payload Enrichment
- **Q:** What extra data in SOS payload?
- **Decision:** **Battery Level + Altitude**.
- **Q:** Include emergency type enum?
- **Decision:** **YES — Enum:** `MEDICAL`, `LOST`, `FIRE`, `GENERAL`.

### Area 5: Status Feedback
- **Q:** Delivery channels for status updates?
- **Decision:** **FCM (Push) + Short-Polling (Fallback)**.
- **Q:** Visible status tiers?
- **Decision:** **3 Tiers (VERY IMPORTANT)**: 1. Sent, 2. Received, 3. Dispatched.

---
*Audit log generated automatically after /gsd-discuss-phase.*
