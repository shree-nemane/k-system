# Phase 3: Safety Systems & SOS - UI Design Contract

**Date:** 2026-04-03
**Status:** Draft

## 1. Design Objective
Create a high-stress, high-legibility interface for emergency SOS signaling that minimizes accidental triggers while providing maximum reassurance during the lifecycle of an emergency.

## 2. Component Specifications

### 2.1. The SOS Trigger (Enhanced)
- **Visuals**: A large, centered circular pulsing button.
- **Branding**: `Colors.redAccent` with a deep shadow.
- **Interaction**: **Hold-to-Trigger**.
    - **Initial State**: "HOLD FOR SOS"
    - **Active Press**: Progress ring fills around the button circumference.
    - **Success**: Vibrate and transition to Countdown Overlay.

### 2.2. The Countdown Overlay (5 Seconds)
- **Layout**: Full-screen modal with semi-transparent black background.
- **Header**: "PREPARING EMERGENCY SIGNAL" in bold white.
- **Center**: Large, animated numerical countdown (5 → 4 → 3 → 2 → 1).
- **Secondary Action**: A large **"CANCEL SOS"** button at the bottom.
    - **Style**: High-contrast (White background, Red text).
    - **Hitbox**: Minimum 80px height, full-width.
- **Haptics**: Rhythmic ticking vibration for every second.

### 2.3. The Safety Dashboard (Post-Trigger)
- **Layout**: Replaces the main map view or persists as a sticky bottom sheet.
- **States (The 3 Tiers)**:
    1.  **Tier 1: Synchronizing...** (Spinner icon, orange text).
        - "Pulse sent. Waiting for server confirmation."
    2.  **Tier 2: Received** (Checkmark icon, green text).
        - "Received by MahaKumbh Control Center."
    3.  **Tier 3: Help Dispatched** (Police/Ambulance icon, pulse animation).
        - "Rescuer assigned: Officer Singh. Moving to your location."
- **Additional Info**: Displays current Battery Level and shared Location coordinates.

---

## 3. Critical Interactions

### 3.1. Cancelation Flow
- If the user taps "CANCEL SOS" during the 5s window:
    - Stop all background timers.
    - Dismiss the overlay.
    - Provide a subtle "SOS Aborted" snackbar.
- **Rationale**: Prevents false alarms from becoming resource-draining events for authorities.

### 3.2. Background Persistence
- When the SOS is active, a **Persistent Notification** (Android) appears:
    - **Title**: "MahaKumbh SOS Active"
    - **Body**: "Reporting location... Status: Dispatched"
    - **Action**: "Open App" button.

---

## 4. Typography & Color Palette
- **Fonts**: Inter (Bold for urgency, Regular for secondary info).
- **Primary**: `#FF5252` (Red Accent) - Universal safety color.
- **Success**: `#4CAF50` (Green) - For confirmation and dispatched status.
- **Warning**: `#FFC107` (Amber) - For synchronization and pending states.

---
*UI-SPEC defined for high-legibility in direct sunlight and dense crowd conditions.*
