import time
import cv2
import httpx
import multiprocessing
import os
from typing import Dict, Any

from workers.detector import CrowdDetector


class CameraProcessor(multiprocessing.Process):
    """
    Independent worker process for a single camera.
    1. Connects to RTSP/Video source.
    2. Runs CrowdDetector (YOLOv8 + ByteTrack + Optical Flow).
    3. Handles alert state machine (Sustained Density + Panic Cooldown).
    4. Saves atomic snapshots for the dashboard.
    5. Posts results to backend API.
    """

    COOLDOWN_SECONDS = 60
    PANIC_COOLDOWN_SECONDS = 10  # D-25: Prevent alert spam
    CONSECUTIVE_THRESHOLD = 5
    # D-24: Targeting dashboard-specific directory
    SNAPSHOT_DIR = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
        "app", "static", "snapshots"
    )

    def __init__(self, camera_config: Dict[str, Any], api_url: str, api_key: str):
        super().__init__()
        self.config = camera_config
        self.api_url = f"{api_url}/crowd/update"
        self.api_key = api_key
        
        # State machine
        self.high_density_count = 0
        self.last_alert_time = 0
        self.last_panic_time = 0
        
        # Performance/Exit flags
        self.exit_event = multiprocessing.Event()

    def run(self):
        """Worker main loop."""
        print(f"[Worker {self.config['id']}] Starting...")
        
        detector = CrowdDetector(max_age=self.config.get('max_age', 10))
        cap = cv2.VideoCapture(self.config['source'])
        
        if not cap.isOpened():
            print(f"[Worker {self.config['id']}] FAILED to open source: {self.config['source']}")
            return

        with httpx.Client(timeout=10.0) as client:
            while not self.exit_event.is_set():
                ret, frame = cap.read()
                if not ret:
                    cap.release()
                    time.sleep(5)
                    cap = cv2.VideoCapture(self.config['source'])
                    continue

                # Process frame (D-31: includes Optical Flow every frame internally)
                result_dict = detector.process_frame(frame)
                
                # frame was skipped by detector logic (D-03)
                if result_dict is None:
                    continue

                person_count = result_dict["person_count"]
                panic_score = result_dict["panic_score"]
                is_panic_event = result_dict["is_panic"]
                
                density_level = self._get_density_level(person_count)
                trigger_alert = False
                
                now = time.time()

                # 1. Density Alert Logic (D-08: Sustained for 5 frames)
                if density_level == "high":
                    self.high_density_count += 1
                else:
                    self.high_density_count = 0
                
                if (self.high_density_count >= self.CONSECUTIVE_THRESHOLD and 
                    (now - self.last_alert_time) > self.COOLDOWN_SECONDS):
                    trigger_alert = True
                    self.last_alert_time = now

                # 2. Panic Cooldown Logic (D-25 refinement)
                final_panic = False
                if is_panic_event and (now - self.last_panic_time) > self.PANIC_COOLDOWN_SECONDS:
                    final_panic = True
                    self.last_panic_time = now

                # 3. Atomic Snapshot Write (D-24/2.4 refinement)
                # We save the processed frame (with potential overlays if added later)
                # Use temp + replace to avoid dashboard reading corrupted files
                self._save_snapshot(frame)

                # 4. Send update to backend
                self._send_update(
                    client, 
                    person_count, 
                    density_level, 
                    trigger_alert, 
                    panic_score, 
                    final_panic
                )

        cap.release()
        print(f"[Worker {self.config['id']}] Exiting.")

    def _save_snapshot(self, frame):
        """Atomic write of the latest frame for the dashboard (D-24)."""
        try:
            cam_id = self.config['id']
            temp_path = os.path.join(self.SNAPSHOT_DIR, f"{cam_id}_temp.jpg")
            final_path = os.path.join(self.SNAPSHOT_DIR, f"{cam_id}_last.jpg")
            
            # Ensure directory exists (init should have done this, but safe)
            os.makedirs(self.SNAPSHOT_DIR, exist_ok=True)
            
            cv2.imwrite(temp_path, frame)
            # D-24: ATOMIC replace
            os.replace(temp_path, final_path)
        except Exception as e:
            print(f"[Worker {self.config['id']}] Snapshot Error: {e}")

    def _get_density_level(self, count: int) -> str:
        """Categorize count based on camera-specific thresholds (D-07)."""
        if count <= self.config['low_thresh']:
            return "low"
        elif count <= self.config['high_thresh']:
            return "medium"
        else:
            return "high"

    def _send_update(self, client: httpx.Client, count: int, level: str, alert: bool, panic_score: float, is_panic: bool):
        """POST update to backend API with panic metrics."""
        payload = {
            "camera_id": self.config['id'],
            "person_count": count,
            "density_level": level,
            "trigger_alert": alert,
            "alert_threshold": self.config['high_thresh'],
            "panic_score": panic_score,
            "is_panic": is_panic
        }
        
        try:
            resp = client.post(
                self.api_url,
                json=payload,
                headers={"X-API-Key": self.api_key}
            )
            if resp.status_code != 200:
                print(f"[Worker {self.config['id']}] API Error {resp.status_code}: {resp.text}")
        except Exception as e:
            print(f"[Worker {self.config['id']}] Connection Error: {e}")

    def stop(self):
        self.exit_event.set()
