# Requirements: MahaKumbh 2027 Smart Guide

**Defined:** 2026-03-30
**Core Value:** Ensuring pilgrim safety and group coordination in a high-density, low-connectivity environment through real-time crowd intelligence and reliable offline-first navigation.

## v1 Requirements

### Crowd Monitoring (CRWD)
- [ ] **CRWD-01**: System can process multiple video feeds in parallel using YOLOv8.
- [ ] **CRWD-02**: System can count individuals and derive density levels (Low/Medium/High).
- [ ] **CRWD-03**: System detects "panic" events via sudden motion spikes (Optical Flow).
- [ ] **CRWD-04**: Real-time density data is transmitted to the backend via HTTP/WebSocket.

### Mobile Foundation (MOBL)
- [ ] **MOBL-01**: App renders interactive maps using `flutter_map` (OpenStreetMap).
- [ ] **MOBL-02**: App implements offline tile caching for pre-selected sectors.
- [ ] **MOBL-03**: App displays discrete crowd density markers (Green/Yellow/Red) on the map.
- [ ] **MOBL-04**: App supports a "Low Data Mode" to minimize network usage.

### Safety & SOS (SAFE)
- [ ] **SAFE-01**: User can trigger an Emergency SOS with a single action.
- [ ] **SAFE-02**: SOS payload includes GPS coordinates and User ID.
- [ ] **SAFE-03**: App uses a local queue (Isar) to retry SOS delivery if the network is unavailable.
- [ ] **SAFE-04**: User can report Missing/Found individuals with photos and descriptions.

### Group Coordination (SYNC)
- [ ] **SYNC-01**: User can create or join a group via a unique code.
- [ ] **SYNC-02**: App shares live location with group members via Firebase Realtime Database.
- [ ] **SYNC-03**: App displays group member locations on the map with "Last Updated" timestamps.
- [ ] **SYNC-04**: User can stop location sharing at any time.

### Spiritual & Content (SPIRIT)
- [ ] **SPIRIT-01**: App provides offline access to bathing dates and event schedules (JSON-based).
- [ ] **SPIRIT-02**: App includes ritual guides accessible without an internet connection.
- [ ] **SPIRIT-03**: User receives push notifications for significant events via FCM.

### Backend & API (BKND)
- [ ] **BKND-01**: FastAPI handles incoming crowd data and SOS requests.
- [ ] **BKND-02**: PostgreSQL stores structured data (users, SOS, reports, alerts).
- [ ] **BKND-03**: System generates and pushes "High Density" alerts to mobile clients when thresholds are met.
- [ ] **BKND-04**: Streamlit dashboard provides a real-time surveillance panel for authorities.

## v2 Requirements
- **BKND-05**: Automated resource allocation suggestions based on historical crowd trends.
- **SYNC-05**: In-group messaging (low-bandwidth text).
- **MOBL-05**: Augmented Reality (AR) markers for finding key locations in dense crowds.

## Out of Scope
| Feature | Reason |
|---------|--------|
| Live Video Streaming to App | Prohibitive bandwidth requirements in congested networks. |
| Real-time Map Heatmaps | Replaced by discrete indicators for better clarity and performance. |
| AI Facial Recognition | Privacy concerns and massive computational overhead. |
| Dynamic Rerouting | Network dependency makes it unreliable; replaced by static routes. |

## Traceability
*To be populated during Roadmap creation.*

| Requirement | Phase | Status |
|-------------|-------|--------|
| CRWD-01 | Phase 1 | Pending |
| CRWD-02 | Phase 1 | Pending |
| BKND-01 | Phase 1 | Pending |
| BKND-02 | Phase 1 | Pending |
| MOBL-01 | Phase 2 | Pending |
| MOBL-02 | Phase 2 | Pending |
| SAFE-01 | Phase 2 | Pending |
| SAFE-03 | Phase 2 | Pending |
| SPIRIT-01 | Phase 2 | Pending |
| SYNC-01 | Phase 3 | Pending |
| SYNC-02 | Phase 3 | Pending |
| SYNC-03 | Phase 3 | Pending |
| CRWD-03 | Phase 4 | Pending |
| BKND-04 | Phase 4 | Pending |
| SAFE-04 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 24 total
- Mapped to phases: 15 (Initial mapping)
- Unmapped: 9 ⚠️ (Will be finalized in ROADMAP.md)

---
*Requirements defined: 2026-03-30*
*Last updated: 2026-03-30 after initial definition*
