# Research: Phase 2 - Mobile Core & Offline Mapping

## Tile Caching Strategy

The MahaKumbh 2027 app requires offline map availability for safe pilgrimage. We used `flutter_map_tile_caching` (FMTC) for this purpose.

### Configuration
- **Store Name**: `MahaKumbhCache` (defined in `AppConstants`).
- **Provider**: OpenStreetMap (OSM) standard tiles.
- **Initialization**: Managed via `FMTCStore(_storeName).manage.create()` in the `initState` of the home screen.

### Caching Layers
1. **Base Map Tiles**: Standard OSM tiles cached as the user browses the grounds.
2. **Static Overlays**: Polygons and Polylines are pre-computed and stored in `map_data.json` to avoid expensive remote fetching for site features.

## Data Structure: map_data.json

We use a flat JSON structure to define the geometry of the MahaKumbh grounds.

### Sectors (Polygons)
Each sector defines a safe zone or density area.
```json
{
  "name": "Sangam Main",
  "color": "0xFFFFCC80", // ARGB Hex
  "points": [{"lat": 25.43, "lng": 81.87}, ...]
}
```

### Routes (Polylines)
Walking routes are defined as paths of coordinates to guide users away from overcrowded zones.
```json
{
  "name": "Sangam Approach Path",
  "color": "0xFF1976D2",
  "path": [{"lat": 25.45, "lng": 81.85}, ...]
}
```

## Performance Considerations
- **Polygon Rendering**: We use a `PolygonLayer` which is hardware-accelerated in Flutter. To maintain performance, vertex counts per sector are kept low.
- **Memory Consumption**: Maps are a heavy resource. The app is optimized to clear markers and overlays when the screen is navigated away from, or put in the background.

## Future Research (Phase 3 Prep)
- **Background Processes**: Researching Android WorkManager for SOS retries (essential for next phase).
- **Isar Database**: Evaluating Isar as a local-first queue for offline SOS pulses.
