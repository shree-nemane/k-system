---
status: testing
phase: 02-mobile-core-mapping
source: [02-SUMMARY.md]
started: "2026-04-03T17:15:00Z"
updated: "2026-04-03T17:30:00Z"
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 4
name: Global Density HUD
expected: |
  Check the top-right of the screen.
  1. A card should show "GLOBAL DENSITY" in small bold text.
  2. Below it, a large percentage (e.g., 50%) should be visible.
  3. The color of the percentage should be Green (low), Orange (medium), or Red (high) based on the value.
awaiting: user response

## Tests

### 1. Cold Start Smoke Test
expected: |
  Ensure the app starts cleanly from a fresh state. 
  1. If running in an emulator/device, stop the app.
  2. Clear any local caches if possible (simulating first run).
  3. Start the application via `flutter run`.
  4. The application should boot without errors, initialize the FMTC map store, and eventually display the 'MahaKumbh Explorer' title.
result: pass

### 2. Home Screen & Map Initialization
expected: |
  The app should land on the HomeMapScreen. 
  1. A live OpenStreetMap should render beneath the UI layers.
  2. You should be able to pan and zoom around the Prayagraj/Kumbh area.
result: pass

### 3. Offline Ready Status Badge
expected: |
  Check the top-left of the screen.
  1. A small white rounded badge should be visible.
  2. It should contain a gray `wifi_off` icon and the text "OFFLINE READY".
result: pass

### 4. Global Density HUD
expected: |
  Check the top-right of the screen.
  1. A card should show "GLOBAL DENSITY" in small bold text.
  2. Below it, a large percentage (e.g., 50%) should be visible.
  3. The color of the percentage should be Green (low), Orange (medium), or Red (high) based on the value.
result: pass

### 5. Ground Layout (Sectors & Routes)
expected: |
  Verify the map overlays:
  1. You should see transparent colored zones (like "Sangam Main" or "Arail Sector").
  2. You should see colored lines representing approach paths and trails.
  3. These layers should stay fixed to the ground as you zoom/pan.
result: pass

### 6. Hub & Ghat Markers
expected: |
  Look for markers on the map:
  1. Blue water icons for Ghats (e.g., Main Sangam Ghat).
  2. Saffron/Primary colored help_center icons for Hubs (e.g., Sector 4 Hub).
result: pass

### 7. Emergency SOS Button Navigation
expected: |
  Observe the Floating Action Button:
  1. A large red button with an emergency icon is in the bottom-right.
  2. Tapping it should attempt to navigate to the `/sos` route. 
  (Note: The SOS screen may still be a placeholder if Phase 3 hasn't started execution yet).
result: pass

## Summary

total: 7
passed: 7
issues: 0
pending: 0
skipped: 0

## Gaps

[none yet]
