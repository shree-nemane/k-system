# Phase 5: Spiritual Guide & Notifications - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a robust offline-first content system and real-time push alert infrastructure:
1. **Hybrid Ritual Guide**: Bundled JSON assets for default offline access, with an optional background sync to update schedules when connectivity allows.
2. **Timeline-First UX**: A chronological event feed as the primary interface, with secondary map-integration to show where rituals and events are located (e.g., specific 'Ghats').
3. **Granular FCM Notifications**: Multi-level Firebase Topic organization (Global + Sector-specific) to deliver targeted safety and spiritual updates.
4. **Sustained Overcrowding Alerts**: Backend-triggered FCM push when density thresholds are breached for a sustained duration (e.g., 2+ minutes), reducing transient noise.

This phase does NOT include: real-time location sharing (skipped Phase 4), group coordination, or the authority dispatch dashboard (Phase 6).
</domain>

<decisions>
## Implementation Decisions

### Ritual Content & Persistence (D-25)
- **D-25: Hybrid Data Strategy**. The app bundles a core `rituals.json` and `schedules.json` as assets for 100% offline reliability. An "optional sync" mechanism fetches updates from the backend and persists them to the local Isar database, overriding the asset defaults when newer data exists.

### UI/UX Presentation (D-26)
- **D-26: Timeline-First Navigation**. The primary interface for the Spiritual Guide is a vertical chronological timeline. Each entry includes a "See on Map" link that switches to the MapView and centers on the relevant location marker.

### Notification Architecture & Targeting (D-27)
- **D-27: Granular Topic Hierarchy**. Firebase topics follow a tiered structure:
    - `/topics/all` (Universal safety/emergency)
    - `/topics/sector_{id}` (Location-specific crowd alerts)
    - `/topics/spiritual` (General schedule updates)
  Users are subscribed to `all` by default and to their current/relevant `sector_` topics based on last known location or user selection.

### Overcrowding Alert Logic (D-28)
- **D-28: Sustained Breach Filter**. The backend `AlertManager` triggers an FCM push only when a camera's "HIGH" density status is sustained for **at least 2 minutes** (120 seconds). This avoids notifying the entire sector during brief, transient bottlenecks.

### the agent's Discretion
- Exact JSON schema for the ritual and schedule metadata.
- Implementation of the "Optional Sync" background worker (scheduling and conflict resolution).
- Visual design of the timeline UI (list styling, icons for different ritual types).
- Selection of the FCM high-priority payload keys (e.g., sound, vibration, TTL).
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` — SPIRIT-02, SPIRIT-03 (Guides & Notifications), BKND-03 (FCM Backend).
- `.planning/ROADMAP.md` — Phase 5 goals and success criteria.

### Prior Context
- `.planning/phases/01-backend-ai-foundation/01-CONTEXT.md` — Current density monitoring and `alerts` table structure.
- `.planning/phases/03-safety-systems/03-CONTEXT.md` — FCM initial setup and safety status feedback loop.

### No external specs yet — requirements fully captured in decisions above.
</canonical_refs>

<deferred>
## Deferred Ideas
- Real-time location sharing (formerly Phase 4) — Permanently skipped per user request.
- Multi-language localization (Hindi/English) — Initial implementation will used English keys with Hindi content strings, full localization system deferred.
</deferred>

---
*Phase: 05-spiritual-guide-notifications*
*Context gathered: 2026-04-03 via /gsd-discuss-phase 5*
