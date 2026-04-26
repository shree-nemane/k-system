import json
import time
import os
import signal
import multiprocessing
import sys
from typing import Dict

from backend.workers.processor import CameraProcessor


class WorkerSupervisor:
    """
    Main supervisor task managing lifecycle of all CameraProcessors.
    1. Loads camera configs from cameras.json.
    2. Spawns one process per active camera.
    3. Monitor (watchdog) for process failure/restoration.
    """

    def __init__(self, config_path: str, api_url: str, api_key: str):
        self.config_path = config_path
        self.api_url = api_url
        self.api_key = api_key
        self.workers: Dict[str, CameraProcessor] = {}
        self.active = True

    def _load_config(self):
        """Read cameras.json file."""
        if not os.path.exists(self.config_path):
            print(f"[Supervisor] ERROR: Config not found at {self.config_path}")
            return []
            
        with open(self.config_path, 'r') as f:
            data = json.load(f)
            return data.get('cameras', [])

    def start(self):
        """Spawn initial batch of workers."""
        print("[Supervisor] Starting monitoring service...")
        
        # D-01: spawn start method is mandatory for YOLO/CUDA isolation
        try:
            multiprocessing.set_start_method("spawn", force=True)
        except RuntimeError:
            pass

        cameras = self._load_config()
        for cam in cameras:
            if cam.get('active', True):
                self._start_worker(cam)

        # Main supervision loop
        try:
            while self.active:
                self._check_health()
                time.sleep(10)  # D-06: 10s watchdog interval
        except KeyboardInterrupt:
            self.stop()

    def _start_worker(self, cam_config: dict):
        """Initialize and start a single worker process."""
        worker = CameraProcessor(cam_config, self.api_url, self.api_key)
        worker.start()
        self.workers[cam_config['id']] = worker
        print(f"[Supervisor] Started worker for {cam_config['id']} (PID: {worker.pid})")

    def _check_health(self):
        """Watchdog: restart any worker that died unexpectedly."""
        # Find dead workers
        cameras = {c['id']: c for c in self._load_config() if c.get('active', True)}
        
        # Check existing workers
        for cam_id, worker in list(self.workers.items()):
            if not worker.is_alive():
                print(f"[Supervisor] WARNING: Worker {cam_id} died. Restarting...")
                # Cleanup and restart
                worker.join(timeout=1)
                if cam_id in cameras:
                    self._start_worker(cameras[cam_id])
                else:
                    del self.workers[cam_id]

        # Check for new cameras added to JSON during runtime
        for cam_id, cam_cfg in cameras.items():
            if cam_id not in self.workers:
                print(f"[Supervisor] Detected NEW camera {cam_id}. Starting...")
                self._start_worker(cam_cfg)

    def stop(self):
        """Signal all child processes to exit gracefully."""
        self.active = False
        print("[Supervisor] Stopping all workers...")
        for cam_id, worker in self.workers.items():
            worker.stop()
            worker.join(timeout=5)
            # Force kill if still alive
            if worker.is_alive():
                worker.terminate()
        print("[Supervisor] Shutdown complete.")


if __name__ == "__main__":
    # Load API details from env or hardcoded defaults
    # (In production, these should come from os.environ)
    # Path to cameras.json is in the parent directory (backend/)
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    CONFIG_FILE = os.path.join(BASE_DIR, "cameras.json")
    
    API_URL = "http://localhost:8000"
    API_KEY = "mahakumbh-secret-2027"  # Matches backend .env key

    # Handle termination signals
    supervisor = WorkerSupervisor(CONFIG_FILE, API_URL, API_KEY)
    
    def handle_sigterm(signum, frame):
        supervisor.stop()
        exit(0)

    signal.signal(signal.SIGINT, handle_sigterm)
    signal.signal(signal.SIGTERM, handle_sigterm)

    supervisor.start()
