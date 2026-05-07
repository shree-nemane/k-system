# MahaKumbh 2027 Smart Guide - Basic Test Plan

This document outlines 10 basic test cases to verify the core functionality of the MahaKumbh Smart Guide system, covering the Mobile App, AI Surveillance, and Authority Dashboard.

## 1. Test Case Suite: Mobile Application (Pilgrim Side)

| TC ID | Test Case Title | Prerequisite | Test Steps | Expected Result | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | **App Launch & Permissions** | App installed for the first time | 1. Open the app.<br>2. Grant Location/GPS permissions. | Home screen loads; user's current location is shown on the map. | High |
| **TC-02** | **SOS Trigger (Online)** | Internet active | 1. Tap the SOS button.<br>2. Confirm the SOS prompt. | Success message shown; SOS details appear on Authority Dashboard. | High |
| **TC-03** | **SOS Queuing (Offline)** | **No Internet** | 1. Tap the SOS button.<br>2. Confirm the prompt. | App notifies "No connection - SOS queued". Data saved locally in Isar. | High |
| **TC-04** | **SOS Auto-Sync** | SOS queued from TC-03 | 1. Turn ON internet/Wi-Fi.<br>2. Wait for 30-60 seconds. | Queued SOS is automatically transmitted to the backend. | High |
| **TC-05** | **Offline Map & Search** | Map data pre-cached | 1. Turn OFF internet.<br>2. Search for "Sangam Ghat" in the map. | Map tiles render and POI is found using local cache. | Medium |
| **TC-06** | **Spiritual Guide Access** | App installed | 1. Open "Ritual Calendar".<br>2. Select a bathing date (Snan). | Ritual details and timings are displayed correctly offline. | Low |
| **TC-07** | **Crowd Count Accuracy** | Camera feed active | 1. Place 5+ people in the camera view.<br>2. Observe the count on the AI worker console. | AI correctly identifies and counts the individuals within +/- 10% accuracy. | High |
| **TC-08** | **High Density Alert** | Density threshold set to 10 | 1. Increase people count to 12.<br>2. Wait for 5 consecutive frames. | Dashboard indicator turns **RED** and logs a "High Density" alert. | High |
| **TC-09** | **Panic Detection** | Camera feed active | 1. Simulate sudden erratic movement (e.g., running) in view.<br>2. Observe dashboard. | "Panic Detected" alert pops up with a snapshot of the event. | High |
| **TC-10** | **Dashboard Live Sync** | Backend running | 1. Trigger an SOS from the mobile app.<br>2. Monitor the "Live Alerts" panel. | The SOS appears on the dashboard map within 2-3 seconds. | Medium |

---

### Verification Summary
*   **Success Criteria:** 100% of "High" priority cases must pass.
*   **Tools Used:** Flutter Integration Test, Postman (for API), Python Pytest.

## 3. How to Use This Document
1.  **Preparation:** Ensure the backend is running (`python main.py`) and the mobile app is built.
2.  **Execution:** Perform each step manually as described in the "Test Steps" column.
3.  **Logging:** Record the results (Pass/Fail) in your testing log.
4.  **Reporting:** If a test fails, create a bug report using the template below.

## 4. Bug Report Template
| Field | Description |
| :--- | :--- |
| **Test Case ID** | e.g., TC-03 |
| **Status** | FAIL |
| **Observed Result** | What actually happened? (e.g., App crashed) |
| **Steps to Reproduce** | 1. Open app. 2. Tap SOS. 3. ... |
| **Environment** | Android 13, Backend v0.1.0 |
| **Screenshot** | [Link to Image] |
