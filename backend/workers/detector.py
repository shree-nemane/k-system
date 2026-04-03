import cv2
import numpy as np
from ultralytics import YOLO


class CrowdDetector:
    """
    Initializes YOLOv8n model with ByteTrack tracker and OpenCV Optical Flow.
    MUST be instantiated inside the worker process, not before fork/spawn.
    """

    MODEL_PATH = "yolov8n.pt"
    TRACKER_CONFIG = "bytetrack.yaml"
    INFERENCE_SIZE = 416  # imgsz=416 for speed optimization

    # Panic Detection Parameters (D-31, D-32)
    EMA_ALPHA = 0.02  # smoothing for baseline
    PANIC_THRESHOLD = 3.5  # Critical if current > baseline * 3.5
    WARNING_THRESHOLD = 2.0 # Warning if current > baseline * 2.0

    def __init__(self, max_age: int = 10):
        # Note: downloads model weights on first init
        self.model = YOLO(self.MODEL_PATH)
        self.max_age = max_age
        self.frame_count = 0
        
        # State mapping
        self.prev_gray = None
        self.panic_baseline = 1.0  # Initial baseline
        self.last_panic_score = 0.0

    def process_frame(self, frame) -> dict | None:
        """
        Process a video frame for crowd count and panic metrics.
        Returns dict if frame was processed, or None if skipped.
        """
        self.frame_count += 1
        
        # 1. Optical Flow (Every frame to avoid jumpiness)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        current_mag = 0.0
        
        if self.prev_gray is not None:
            # D-31: Magnitude Spike calculate
            flow = cv2.calcOpticalFlowFarneback(
                self.prev_gray, gray, None, 0.5, 3, 15, 3, 5, 1.2, 0
            )
            # Calculate magnitude: sqrt(u^2 + v^2)
            mag, _ = cv2.cartToPolar(flow[..., 0], flow[..., 1])
            current_mag = float(np.mean(mag))
            
            # EMA Smoothing (D-33 refinement)
            # baseline = 0.98 * baseline + 0.02 * current_mag
            self.panic_baseline = (1 - self.EMA_ALPHA) * self.panic_baseline + (self.EMA_ALPHA * current_mag)
            
        self.prev_gray = gray

        # 2. YOLO Skip Logic (D-03: every 3rd frame)
        if self.frame_count % 3 != 0:
            return None

        # 3. Running YOLOv8 Detection
        results = self.model.track(
            frame,
            tracker=self.TRACKER_CONFIG,
            persist=True,
            imgsz=self.INFERENCE_SIZE,
            verbose=False,
        )

        person_count = 0
        if results and results[0].boxes is not None:
            person_boxes = [box for box in results[0].boxes if int(box.cls) == 0]
            person_count = len(person_boxes)

        # 4. Calculate Panic Severity (D-31)
        # Avoid division by zero
        safe_baseline = max(self.panic_baseline, 0.1)
        panic_score = current_mag / safe_baseline
        is_panic = panic_score > self.PANIC_THRESHOLD
        
        return {
            "person_count": person_count,
            "panic_score": round(panic_score, 2),
            "is_panic": is_panic
        }
