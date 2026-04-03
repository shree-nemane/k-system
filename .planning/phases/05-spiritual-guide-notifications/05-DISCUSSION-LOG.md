# Phase 5: Spiritual Guide & Notifications - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in 05-CONTEXT.md — this log preserves the analysis.

**Date:** 2026-04-03
**Phase:** 05-Spiritual Guide & Notifications
**Mode:** discuss

## Discussion Items

### Area 1: Ritual Data & Persistence
- **Q**: Local Assets (JSON) or Backend-fetched with caching?
- **Decision**: **Local Assets (JSON) + Optional Backend Sync (Hybrid)**. (D-25)
- **Rationale**: Max offline reliability for core content, with background sync for updates when online.

### Area 2: Spiritual Guide UI/UX
- **Q**: Timeline (chronological) or Map-Integrated view?
- **Decision**: **Timeline (Primary) + Map Integration (Secondary)**. (D-26)
- **Rationale**: Chronological flow is the primary user need; map context is useful for locating events.

### Area 3: Notification Architecture (FCM)
- **Q**: Global or Multi-level topics?
- **Decision**: **Granular Multi-level Topics**. (D-27)
- **Rationale**: Targeted alerts (sector-specific) reduce noise for users in unaffected areas.

### Area 4: Overcrowding Alert Logic
- **Q**: Immediate or Sustained breach for FCM push?
- **Decision**: **Sustained Breach (with time threshold)**. (D-28)
- **Rationale**: Prevent false alarms from brief, non-critical crowd bunching.

## Deferred/Skipped Items
- **Phase 4 (Group Coordination)**: Permanently skipped per user request.

---
*Generated: 2026-04-03 via /gsd-discuss-phase 5*
