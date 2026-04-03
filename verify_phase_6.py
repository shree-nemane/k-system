import numpy as np
import cv2
import time
import os
import sys

# Add backend to path to import detector
sys.path.append(os.path.join(os.path.dirname(__file__), "backend"))
from workers.detector import CrowdDetector

def test_panic_logic():
    print("--- Testing Panic Detection Logic (EMA + Magnitude Spike) ---")
    detector = CrowdDetector()
    
    # 1. Create dummy frames (black frames)
    frame1 = np.zeros((480, 640, 3), dtype=np.uint8)
    frame2 = np.zeros((480, 640, 3), dtype=np.uint8) # No motion
    
    # Process frame 1 (baseline init)
    detector.process_frame(frame1)
    
    # Process frame 2 (no motion)
    res2 = detector.process_frame(frame2)
    if res2:
        print(f"No Motion Score: {res2['panic_score']} (Expected ~0.0-1.0)")
        assert res2['panic_score'] < 1.5
        assert res2['is_panic'] == False
    
    # 2. Simulate Motion Spike
    # We'll add some white noise or a moving block
    frame3 = np.zeros((480, 640, 3), dtype=np.uint8)
    cv2.rectangle(frame3, (100, 100), (300, 300), (255, 255, 255), -1) # Instant white block
    
    res3 = detector.process_frame(frame3)
    if res3:
        print(f"Spike Score: {res3['panic_score']} (Expected > 3.5 if baseline was low)")
        # Note: If baseline is 1.0 (init), and current_mag is high, it should trigger.
        if res3['panic_score'] > 3.5:
            print("✅ Spike Triggered!")
        else:
            print(f"❌ Spike DID NOT Trigger (Score: {res3['panic_score']})")

    print("\n--- Testing EMA Smoothing ---")
    # Send multiple frames with low motion to settle baseline
    for _ in range(20):
        detector.process_frame(frame1)
    settled_baseline = detector.panic_baseline
    print(f"Settled Baseline: {settled_baseline:.4f}")
    
    # Now a small spike
    frame_small_spike = np.zeros((480, 640, 3), dtype=np.uint8)
    cv2.rectangle(frame_small_spike, (0, 0), (50, 50), (255, 255, 255), -1)
    res_spike = detector.process_frame(frame_small_spike)
    if res_spike:
        print(f"Small Spike Score: {res_spike['panic_score']}")

if __name__ == "__main__":
    try:
        test_panic_logic()
    except Exception as e:
        print(f"Test Failed: {e}")
