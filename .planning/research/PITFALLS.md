# Pitfalls Research — MahaKumbh 2027 Smart Guide

## Overview
Critical challenges and prevention strategies for high-scale religious gathering technology.

## Potential Pitfalls

### Network Congestion
- **Problem**: 2G/3G speeds or total network blackout due to millions of users in a single city cell.
- **Prevention**: Offline-first tile caching. Pre-package critical "Kumbh Sector" tiles in the app. Use aggressive `HTTP Etag` caching for small JSON updates (bathing dates).
- **Phase 1-3**: Core offline map and local asset strategy.

### YOLOv8 Accuracy in Extreme Crowds
- **Problem**: Occlusions (people blocking each other) leading to undercounting.
- **Prevention**: High camera placement (top-down view) to minimize overlap. Use tracking (ByteTrack) to maintain count even when individuals are briefly hidden.
- **Phase 4**: Detection pipeline and camera positioning tests.

### GPS Accuracy and Signal Loss
- **Problem**: Narrow pathways and high crowd density (GPS "shimmer") leading to inaccurate "Find My Group" locations.
- **Prevention**: Use "Last Updated" timestamps and "Accuracy Radius" circles on the map. Show "Last Known Position" clearly if signal is lost.
- **Phase 3**: Mobile UI location feedback.

### SOS Reliability
- **Problem**: SOS sent but the network fails before acknowledgment.
- **Prevention**: Implement a background local queue (Isar) that retries the SOS until the backend sends a 200 OK. Show a persistent "Sending..." status to the user.
- **Phase 1-2**: Emergency SOS robust retry logic.

### Device Power Consumption
- **Problem**: Heavy GPS polling and AI background updates draining batteries quickly.
- **Prevention**: Dynamic polling frequency. When stationary, reduce GPS updates. Provide a "Low Power Mode" that disables non-emergency background sync.
- **Phase 3-4**: Power consumption audits.

## Detection & Mitigation Summary
- **Early Warnings**: Higher-than-expected latency in Firebase or high error rates for SOS.
- **Monitoring**: Dashboard should track real-time "Connection Health" metrics from the mobile fleet.

---
*Confidence Level: High*
