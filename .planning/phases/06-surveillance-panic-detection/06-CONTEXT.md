# Phase 6: Surveillance & Panic Detection - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Provide authorities with a strategic oversight dashboard and automated panic detection capabilities:
1. **Streamlit Dashboard**: A multi-camera monitoring panel for real-time surveillance.
2. **Panic Detection (OpenCV)**: Optical Flow-based motion analysis to detect sudden surges/panic.
3. **Crowd Trends**: Historical visualization of density metrics and alert frequency.

This phase does NOT include: Mobile UI updates, Proximity/Social Distancing alerts, or Real-time video streaming to mobile devices.
</domain>

<decisions>
## Implementation Decisions

### Dashboard Refresh Strategy
- **D-29:** Data Source = **DB Polling**. Instead of WebSockets, the dashboard will poll the `crowd_events` table in PostgreSQL every 3–5 seconds. This ensures stability and allows for easy aggregation of historical trends in the same view.
- **D-30:** Grid Layout = **Dynamic Snapshot Grid**. To maintain Streamlit responsiveness, the dashboard will display the most recent inferenced frame (JPEG) from each camera as a still snapshot, rather than a high-FPS video stream. Snapshots refresh alongside the polling cycle.

### Panic Detection Logic (AI Workers)
- **D-31:** Algorithm = **Optical Flow (Magnitude Spike)**. The AI workers will use `cv2.calcOpticalFlowFarneback` to calculate the average pixel velocity across the frame.
- **D-32:** Panic Thresholding = **Baseline-relative Spike**. If the average motion magnitude exceeds a configurable baseline (e.g., 300% of the last 10-frame sliding average), a `panic_alert` is triggered.
- **D-33:** Alert Integration = Panic events are sent as a special type of `alert` to the backend, appearing on both the dashboard (with visual highlights) and mobile clients (high-priority FCM/WS push).

### Historical Analysis & Visualization
- **D-34:** Trend Granularity = **Aggregated Trends**. The dashboard will provide 5-minute buckets (Avg/Max density) for the last 48 hours. This allows authorities to identify growth patterns without overwhelming the frontend with raw logs.
- **D-35:** Visualization tool = **Plotly/Altair**. Interactive charts within the Streamlit app to filter trends by camera location.

### Proximity & Alerts
- **D-36:** Proximity Violations = **Deferred**. Social distancing/proximity checking is explicitly out of scope for Phase 6 to prioritize panic detection and dashboard stability.

### the agent's Discretion
- Choice of specific OpenCV Optical Flow parameters (pyr_scale, levels, winsize, etc.).
- Exact visual styling of "Panic" indicators on the dashboard (e.g., red border vs. status text).
- Database aggregation query optimization for historical trends.
- Streamlit application structure (single script vs. multi-page).
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Planning
- `.planning/ROADMAP.md` — Phase 6 success criteria and requirement IDs (CRWD-03, BKND-04)
- `.planning/REQUIREMENTS.md` — v1 requirements CRWD-03 (Panic detection) and BKND-04 (Dashboard)
- `.planning/PROJECT.md` — Core value and tech stack constraints (Streamlit, OpenCV)

### Prior Context
- `.planning/phases/01-backend-ai-foundation/01-CONTEXT.md` — Camera worker architecture and `crowd_events` schema details.
</canonical_refs>

<specifics>
## Specific Implementation Notes

- **AI Worker Update**: The `CrowdDetector` (in `detector.py`) needs to be Extended to calculate Optical Flow magnitude in parallel with YOLOv8 detection.
- **Panic Alert Payload**: Should follow the existing alert schema but with `type: "panic"`.
- **Database Indexing**: Ensure `crowd_events` has a BRIN or B-Tree index on `timestamp` to support efficient aggregation for the historical dashboard view.
</specifics>

<deferred>
## Deferred Ideas

- **Proximity Violation Alerts**: Distance-based inter-person tracking (Deferred to later milestone).
- **Multi-Page Authority Hub**: Exporting reports to PDF, user management for dashboard login (Deferred).
- **Real-time Video Feed in Dashboard**: Replaced by dynamic snapshots for performance.
</deferred>

---
*Phase: 06-surveillance-panic-detection*
*Context gathered: 2026-04-03 via /gsd-discuss-phase 6*
