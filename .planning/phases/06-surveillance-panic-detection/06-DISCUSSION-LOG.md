# Phase 6: Surveillance & Panic Detection - Discussion Log

**Gathered:** 2026-04-03
**Status:** Audit Trail Complete

## Q&A Session

| Area | Question | Options Presented | User Choice |
|------|----------|-------------------|-------------|
| **Dashboard Refresh** | How should the Streamlit dashboard receive live updates? | ✅ **DB Polling** / ❌ WebSocket | **DB Polling** (D-29) |
| **Panic Detection** | How should we measure "panic" via OpenCV? | ✅ **Magnitude Spike** / ❌ Directional Entropy | **Magnitude Spike** (D-31) |
| **Visualization** | How to handle high camera counts in Streamlit? | ✅ **Dynamic Snapshots** / ❌ Live Grid | **Dynamic Snapshots** (D-30) |
| **Historical Analysis** | What level of detail for trend analysis? | ✅ **Aggregated Trends** / ❌ Raw Playback | **Aggregated Trends** (D-34) |
| **Proximity Alerts** | Should proximity violation alerts be integrated now? | ✅ Yes / ❌ **Defer** | **Defer** (D-36) |

## User Commentary & Refinements

- **D-29/D-30:** User opted for DB Polling and Dynamic Snapshots to ensure maximum stability and responsiveness in high-load scenarios.
- **D-31:** Magnitude Spike chosen for performance and simplicity in initial deployment.
- **D-36:** Proximity alerts deferred to focus on the core surveillance and safety (Panic) requirements.

---
*Generated: 2026-04-03*
