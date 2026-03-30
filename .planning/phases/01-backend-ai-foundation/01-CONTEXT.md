# Phase 1: Backend & AI Foundation — Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a functioning crowd detection pipeline and core backend services:
1. **AI Detection Workers**: YOLOv8 + ByteTrack running in parallel Python processes, one per camera, reading from `cameras.json`, pushing crowd snapshots to FastAPI via HTTP POST.
2. **FastAPI Backend**: Receives crowd data, stores in PostgreSQL, fires structured alerts when density thresholds are breached, and broadcasts live updates to mobile clients over WebSocket.
3. **PostgreSQL Schema**: 4-table foundation (`crowd_events`, `sos_requests`, `alerts`, `cameras`) managed via Alembic + SQLAlchemy ORM.

This phase does NOT include: mobile app UI, Firebase integration, Streamlit dashboard, or notification delivery (FCM). Those are later phases.
</domain>

<decisions>
## Implementation Decisions

### YOLOv8 Model & Camera Configuration
- **D-01:** Model variant = `yolov8n` (nano). Prioritize parallel throughput and speed over accuracy. Single shared model weights across all camera workers.
- **D-02:** Camera configuration = `cameras.json` Python config file. No DB-driven camera management in Phase 1. Restart required to add cameras.
- **D-03:** Frame processing = every 3rd frame (`if frame_count % 3 != 0: skip`). Max speed mode. Applied per worker process.
- **D-04:** Camera count = configurable with no hardcoded limit (however many entries in `cameras.json` run). v1 deployment optimized for 4–6 concurrent cameras. Multiprocessing pool sized dynamically to camera count.

### Tracking Strategy
- **D-05:** Tracker = **ByteTrack** (not DeepSORT). Better for dense crowd counting — no re-ID network overhead, excellent occlusion handling, lower latency.
- **D-06:** ByteTrack `max_age=10` frames as default (conservative, fewer ghost tracks). Configurable per camera entry in `cameras.json` via a `max_age` field.

### Crowd Density Thresholds & Alert Logic
- **D-07:** Density thresholds = **configurable per camera** in `cameras.json` via `low_thresh` and `high_thresh` integer fields. Default preset = **Moderate**: Low < 30 people, Medium 30–75, High > 75. Override per location (e.g., narrow pathways use lower thresholds).
- **D-08:** Alert firing logic = **Cooldown + Sustained combined**: alert fires only when density is High for **5+ consecutive frames** AND **60-second cooldown** has passed since the last alert for that camera. Both conditions must be true simultaneously.
- **D-09:** Alert delivery pipeline = AI worker → **HTTP POST** to FastAPI (persisted to `alerts` table in PostgreSQL) → FastAPI **WebSocket broadcast** (`WS /ws/crowd`) to connected mobile clients. Mobile fallback = REST polling `GET /alerts/recent` every 30s if WebSocket drops.

### PostgreSQL Schema Design
- **D-10:** Phase 1 tables = **4 tables**: `crowd_events`, `sos_requests`, `alerts`, `cameras`. Users table deferred to Phase 3.
- **D-11:** Primary key strategy = **UUID v4** for public-facing tables (`sos_requests`) since they are referenced by external mobile clients. **SERIAL/BIGSERIAL** for internal tables (`crowd_events`, `alerts`, `cameras`) for compact, fast joins.
- **D-12:** Schema migrations = **Alembic + SQLAlchemy ORM**. SQLAlchemy models are the source of truth. Alembic auto-generates versioned migration scripts. Standard FastAPI pattern.

### API Contract Design
- **D-13:** FastAPI project structure = **Router-based by feature**: `routers/crowd.py`, `routers/sos.py`, `routers/alerts.py`. Feature-scoped modules, no global `main.py` bloat.
- **D-14:** Phase 1 API surface = **5 REST endpoints + 1 WebSocket**:
  - `POST /crowd/update` — AI worker pushes per-camera crowd snapshot (person_count, density_level, camera_id, timestamp)
  - `GET /crowd/status` — Mobile fetches current density for all cameras
  - `POST /sos/request` — Mobile submits SOS with GPS lat/lon + device identifier
  - `GET /alerts/recent` — Mobile polling fallback, returns last N alerts
  - `GET /cameras` — Mobile syncs camera metadata (id, name, location label)
  - `WS /ws/crowd` — Live push of density updates AND alerts to connected mobile clients
- **D-15:** API authentication = **Static API key** via `X-API-Key` request header. A single shared secret configured via environment variable. Applied to all endpoints. JWT/device auth deferred to Phase 3.

### Agent's Discretion
- Internal implementation of the ByteTrack integration (library choice: `ultralytics` built-in tracker vs standalone `bytetrack` package — agent picks what integrates cleanest with YOLOv8).
- Exact Pydantic schema field names and response envelopes for each endpoint.
- WebSocket connection manager implementation details (connection registry, broadcast strategy).
- PostgreSQL connection pooling config (pool size, timeout).
- Alembic initial migration naming convention.
- Process supervisor strategy for worker fault recovery (how to restart a dead camera process).
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Planning
- `.planning/ROADMAP.md` — Phase 1 goal, success criteria, and requirement IDs (CRWD-01, CRWD-02, BKND-01, BKND-02)
- `.planning/REQUIREMENTS.md` — Full v1 requirement definitions for CRWD-01/02 and BKND-01/02
- `.planning/PROJECT.md` — Tech stack constraints and key decisions

### Research
- `.planning/research/STACK.md` — Recommended stack (FastAPI, SQLAlchemy, YOLOv8, ByteTrack)
- `.planning/research/ARCHITECTURE.md` — Component boundaries and data flow diagram
- `.planning/research/PITFALLS.md` — Known risks: network congestion, YOLOv8 accuracy in crowds, battery/performance
- `.planning/research/SUMMARY.md` — Synthesized build strategy

### No external ADRs or specs yet — requirements fully captured in decisions above.
</canonical_refs>

<specifics>
## Specific Implementation Notes

- **`cameras.json` schema** should include fields: `id` (string), `source` (int for device index or string for RTSP/file path), `active` (bool), `low_thresh` (int, default 30), `high_thresh` (int, default 75), `max_age` (int, default 10), `location_label` (string for display on mobile map).
- **WebSocket payload** for `WS /ws/crowd` should be JSON with a `type` field: `"density_update"` or `"alert"`, so mobile client can route the message correctly.
- **Alert JSON format** must match the spec in the project description: `{ "event": "overcrowd", "camera_id": "...", "timestamp": unix_epoch, "severity": "high", "data": { "person_count": N, "threshold": T } }`.
- **SOS endpoint** must return a UUID confirmation to the mobile app so it can display "SOS sent, ID: xxxx" and use this ID for retry deduplication.
- **Frame resolution** for inference = `imgsz=416` (as specified in project docs for performance optimization).
</specifics>

<deferred>
## Deferred Ideas

- `GET /crowd/history/{cam_id}` — Historical analytics endpoint. Deferred to Phase 6 (Surveillance dashboard).
- `PATCH /sos/{id}/status` — SOS status updates (responded/resolved). Deferred to Phase 3.
- `GET /cameras` admin CRUD — Add/remove cameras via API (vs config file). Deferred to later milestone.
- JWT/device-level authentication. Deferred to Phase 3.
- `users` table and device registration. Deferred to Phase 3.
- Facial recognition or re-identification. Explicitly out of scope (privacy).
</deferred>

---
*Phase: 01-backend-ai-foundation*
*Context gathered: 2026-03-30 via /gsd-discuss-phase 1*
