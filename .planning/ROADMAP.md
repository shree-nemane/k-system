# Roadmap: MahaKumbh 2027 Smart Guide

## Overview
A 7-phase journey to build a real-time, safety-critical, and offline-capable ecosystem for the MahaKumbh 2027, integrating computer vision, distributed backend services, and a resilient Flutter mobile interface.

## Phases
- [x] **Phase 1: Backend & AI Foundation** - Establish the YOLOv8 pipeline and core FastAPI services.
- [ ] **Phase 2: Mobile Core & Offline Mapping** - Build the foundational Flutter app with offline map support.
- [ ] **Phase 3: Safety Systems & SOS** - Implement the robust Emergency SOS and reporting mechanisms.
- [x] **Phase 4: Group Coordination** - Enable real-time location sharing via Firebase. *(Skipped — Not Implementing)*
- [ ] **Phase 5: Spiritual Guide & Notifications** - Add event content and real-time push alerts.
- [ ] **Phase 6: Surveillance & Panic Detection** - Launch the authority dashboard and motion analytics.
- [ ] **Phase 7: Optimization & Scale** - Refine performance for high-density network environments.

## Phase Details

### Phase 1: Backend & AI Foundation
**Goal**: Deliver a functioning crowd detection pipeline that transmits data to a central API.
**Depends on**: Nothing
**Requirements**: [CRWD-01, CRWD-02, BKND-01, BKND-02]
**Success Criteria**:
1.  Multiple camera feeds processed in parallel using YOLOv8.
2.  Accurate person counts and density levels derived from video streams.
3.  FastAPI endpoint receives and stores crowd metrics in PostgreSQL.
4.  Real-time "Heartbeat" established between AI workers and backend.

### Phase 2: Mobile Core & Offline Mapping
**Goal**: Setup the Flutter environment and provide a reliable map that works without internet.
**Depends on**: Phase 1
**Requirements**: [MOBL-01, MOBL-02, SPIRIT-01]
**Success Criteria**:
1.  Flutter app renders OpenStreetMap via `flutter_map`.
2.  Offline tile caching successfully stores and retrieves map data.
3.  Pre-defined routes (static overlays) visible on the map.
4.  Event schedules (JSON) load correctly from local assets.

### Phase 3: Safety Systems & SOS
**Goal**: Ensure pilgrims can request help even with intermittent connectivity.
**Depends on**: Phase 2
**Requirements**: [SAFE-01, SAFE-02, SAFE-03]
**Success Criteria**:
1.  SOS button triggers an immediate GPS capture and data transmission attempt.
2.  Local "Isar" queue handles background retries for failed SOS pulses.
3.  Visual feedback shows the user the status of their safety request.

### Phase 4: Group Coordination
**Goal**: Allow families and groups to find each other in dense crowds.
**Depends on**: Phase 3
**Requirements**: [SYNC-01, SYNC-02, SYNC-03, SYNC-04]
**Success Criteria**:
1.  Users can create/join groups using numerical codes.
2.  Live location syncs across devices via Firebase Realtime Database.
3.  Group markers appear on the map with "Time Since Last Update" indicators.

### Phase 5: Spiritual Guide & Notifications
**Goal**: Enhance the pilgrimage experience with real-time updates and ritual information.
**Depends on**: Phase 3 (Phase 4 deferred)
**Requirements**: [SPIRIT-02, SPIRIT-03, BKND-03]
**Success Criteria**:
1.  Detailed ritual guides and bathing schedules accessible offline.
2.  Firebase Cloud Messaging (FCM) delivers high-priority safety alerts.
3.  Backend triggers "Overcrowding Alerts" based on monitored thresholds.

### Phase 6: Surveillance & Panic Detection
**Goal**: Provide authorities with a strategic view of the crowd situation.
**Depends on**: Phase 5
**Requirements**: [CRWD-03, BKND-04]
**Success Criteria**:
1.  Streamlit dashboard shows a multi-camera grid with live density markers.
2.  Optical Flow analytics detect sudden motion spikes (panic warning).
3.  Dashboard provides a historical view of crowd trends per location.

### Phase 7: Optimization & Scale
**Goal**: Ensure the system remains stable under the load of millions of concurrent users.
**Depends on**: Phase 6
**Requirements**: [MOBL-04, SAFE-04]
**Success Criteria**:
1.  "Low Data Mode" reduces background bandwidth usage by 50%.
2.  Missing/Found system fully integrated with photo reporting.
3.  End-to-end performance audit for sub-second alert latency.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Backend & AI Foundation | 4/4 | Complete | 2026-03-30 |
| 2. Mobile Core & Mapping | 3/3 | Complete (Audited) | 2026-04-03 |
| 3. Safety Systems | 2/2 | Complete | 2026-04-03 |
| 4. Group Coord (Firebase) | -/- | Skipped | 2026-04-03 |
| 5. Spirits & Notifs | 2/2 | Complete | 2026-04-03 |
| 6. Surveillance | 2/2 | Complete | 2026-04-03 |
| 7. Scale & Polish | 0/2 | In Progress | - |

---
*Roadmap initialized: 2026-03-30*
*Last updated: 2026-03-30*
