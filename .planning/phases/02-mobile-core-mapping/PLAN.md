# Plan: Phase 2 - Mobile Core & Offline Mapping

This plan documents the foundational mobile architecture and mapping strategy used in Phase 2 for the MahaKumbh 2027 Smart Guide.

## Goal
Establish a resilient Flutter-based mobile platform with a high-performance, offline-capable mapping system for pilgrims.

## Core Requirements
- [x] Initializing Flutter project with standardized directory structure (`core`, `providers`, `screens`).
- [x] Integration of OpenStreetMap (OSM) via `flutter_map`.
- [x] Persistent tile caching using `flutter_map_tile_caching`.
- [x] Multi-layer map visualization: 
    - **Sectors (Polygons)**: Transparent color-coded zones for crowd management.
    - **Routes (Polylines)**: Verified walking paths for pilgrim navigation.
    - **Hubs/Ghats (Markers)**: Key interaction points and emergency infrastructure.
- [x] Offline asset management for schedules and guides.

## Technical Decisions

### State Management
**Decision**: Riverpod.
**Rationale**: Essential for managing deep provider trees (like `crowd_provider`) and ensuring reliable state updates with minimal boilerplate in a data-rich environment.

### Mapping Engine
**Decision**: `flutter_map`.
**Rationale**: Flexible, extensible, and integrates perfectly with Flutter's widget system. Allows for custom tile providers and complex overlay layers.

### Offline Strategy
**Decision**: `flutter_map_tile_caching` (FMTC).
**Rationale**: Provides robust SQLite-backed tile storage. Essential for functioning in the high-density/low-connectivity environment of the MahaKumbh grounds.

### Data Format
**Decision**: Static JSON Assets (`map_data.json`, `guide_data.json`).
**Rationale**: Fast loading, easy to update via OTA (Over-the-Air) mechanisms later, and completely functional without an internet connection.

## Implementation Details

| Component | File | Responsibility |
|-----------|------|----------------|
| **Core UI** | `home_map_screen.dart` | Main dashboard with interactive map and density overlay. |
| **Data Models** | `map_data.json` | Coordinates and styling for all map layers. |
| **Constants** | `constants.dart` | Theming (Saffron/Primary) and caching configuration. |
| **State** | `crowd_provider.dart` | Real-time density stream (simulated or API driven). |

## Success Criteria (Audit Results)
1. **App Boots & Responds**: Verified - Splash to Map transition is smooth.
2. **Offline Mode**: Tile caching is initialized on first boot via `FMTCStore`.
3. **Data Integrity**: Map overlays match JSON specifications.
4. **Resiliency**: The app handles missing or malformed JSON gracefully (audit pending).
