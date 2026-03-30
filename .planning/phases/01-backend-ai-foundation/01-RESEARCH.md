# Phase 1: Backend & AI Foundation — Research

**Phase:** 01 — Backend & AI Foundation
**Researched:** 2026-03-30
**Status:** RESEARCH COMPLETE

---

## 1. YOLOv8 + ByteTrack Multiprocessing Architecture

### Key Finding: Use `spawn` start method
When using `multiprocessing` with PyTorch/Ultralytics, the start method **must** be set to `'spawn'` (not the default `'fork'` on Linux). This ensures CUDA context and model weights are correctly initialized in each child process. Set this in the main entry point:
```python
import multiprocessing as mp
mp.set_start_method('spawn', force=True)
```

### Key Finding: Model instance per process
Each worker process **must initialize its own YOLO model instance**. Sharing a single model object across processes causes crashes. The pattern:
```python
def run_camera(cam_config):
    model = YOLO("yolov8n.pt")  # Each process gets its own model
    cap = cv2.VideoCapture(cam_config["source"])
    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break  # Supervisor handles restart
        frame_count += 1
        if frame_count % 3 != 0:  # D-03: skip 2/3 frames
            continue
        results = model.track(frame, tracker="bytetrack.yaml", persist=True, imgsz=416)
        # process results...
```

### Key Finding: ByteTrack is built into Ultralytics
ByteTrack is natively supported in the `ultralytics` package via `model.track(tracker="bytetrack.yaml")`. No separate package installation needed. The `persist=True` flag maintains track IDs across frames — critical for accurate counting.

### Key Finding: `imgsz=416` for speed
Using `imgsz=416` instead of the default 640 significantly reduces inference time with minimal accuracy impact for crowd counting (exact pixel count matters less than person detection).

### Architecture Decision: Hybrid Producer-Consumer
Optimal pattern for multiple cameras:
- **Producer threads**: Read frames from RTSP/file sources (I/O bound — use threads)
- **Consumer processes**: Run inference (CPU/GPU bound — use processes)

For v1 (4–6 cameras), a simpler approach works: **one process per camera** with frame skipping. The supervisor process manages all workers.

---

## 2. FastAPI WebSocket Connection Manager

### Standard Pattern (FastAPI Official)
```python
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, data: dict):
        message = json.dumps(data)
        dead = []
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception:
                dead.append(connection)
        for conn in dead:
            self.disconnect(conn)  # Remove broken connections
```

### Key Finding: Always handle disconnects in broadcast
Without the `try/except` wrapper in `broadcast()`, a single dropped mobile connection will crash the broadcast loop and stop all other clients from receiving updates. Always collect and clean up dead connections.

### Key Finding: Async database for FastAPI
Use `asyncpg` driver with `create_async_engine` from `sqlalchemy.ext.asyncio`:
```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
DATABASE_URL = "postgresql+asyncpg://user:pass@localhost/dbname"
engine = create_async_engine(DATABASE_URL, pool_size=10, max_overflow=5)
AsyncSessionFactory = async_sessionmaker(engine, expire_on_commit=False)
```
Use FastAPI's dependency injection for session management:
```python
async def get_db():
    async with AsyncSessionFactory() as session:
        yield session
```

### Key Finding: Use FastAPI `lifespan` for startup/shutdown
```python
from contextlib import asynccontextmanager
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await engine.connect()
    yield
    # Shutdown
    await engine.dispose()
app = FastAPI(lifespan=lifespan)
```
This is the current FastAPI best practice (replaces deprecated `@app.on_event` hooks).

### Key Finding: Bridging workers→WebSocket
AI workers run in separate processes — they cannot call `manager.broadcast()` directly (different process memory). Use a `multiprocessing.Queue` or an HTTP POST endpoint:
- Worker sends `POST /crowd/update` to FastAPI (D-09)
- FastAPI saves to DB AND calls `await manager.broadcast(payload)`
- This keeps inter-process communication simple and avoids shared memory complexity

---

## 3. Alembic + SQLAlchemy Setup

### Recommended Project Structure
```
backend/
├── alembic/
│   ├── versions/          # Auto-generated migration scripts
│   ├── env.py             # Import all models here
│   └── script.py.mako
├── app/
│   ├── api/
│   │   ├── routers/
│   │   │   ├── crowd.py
│   │   │   ├── sos.py
│   │   │   └── alerts.py
│   ├── core/
│   │   └── config.py      # Settings/env vars
│   ├── db/
│   │   ├── base.py        # Base = declarative_base()
│   │   └── session.py     # Async engine + session factory
│   ├── models/
│   │   ├── __init__.py    # Import ALL models here (Alembic needs this)
│   │   ├── crowd_event.py
│   │   ├── sos_request.py
│   │   ├── alert.py
│   │   └── camera.py
│   └── schemas/           # Pydantic schemas (separate from ORM models)
├── alembic.ini
├── cameras.json           # D-02: Camera config file
├── .env
└── main.py
```

### Key Finding: Models __init__.py is critical
Alembic's `env.py` must import all models to detect changes:
```python
# app/models/__init__.py
from app.models.crowd_event import CrowdEvent
from app.models.sos_request import SOSRequest
from app.models.alert import Alert
from app.models.camera import Camera
```
If any model is not imported, `alembic revision --autogenerate` will miss it.

### Key Finding: Naming conventions prevent migration drift
```python
from sqlalchemy import MetaData
NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}
Base = declarative_base(metadata=MetaData(naming_convention=NAMING_CONVENTION))
```

---

## 4. Process Fault Recovery (Camera Workers)

### Key Finding: Heartbeat pattern for stuck process detection
`process.is_alive()` alone is insufficient — a process can be alive but blocked waiting on a hung camera stream. Use a shared heartbeat:
```python
import multiprocessing
import time

def camera_worker(cam_config, heartbeat: multiprocessing.Value):
    model = YOLO("yolov8n.pt")
    cap = cv2.VideoCapture(cam_config["source"])
    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                time.sleep(2)
                cap.release()
                cap = cv2.VideoCapture(cam_config["source"])  # Reconnect
                continue
            heartbeat.value = time.time()  # Update heartbeat
            # ... inference ...
    finally:
        cap.release()  # Always release camera on exit
```

### Supervisor pattern:
```python
def supervisor(cameras_config):
    workers = {}
    for cam in cameras_config:
        hb = multiprocessing.Value('d', time.time())
        p = multiprocessing.Process(target=camera_worker, args=(cam, hb))
        p.start()
        workers[cam["id"]] = {"process": p, "heartbeat": hb, "config": cam}

    while True:
        for cam_id, w in workers.items():
            p = w["process"]
            hb_age = time.time() - w["heartbeat"].value
            if not p.is_alive() or hb_age > 30:  # 30s timeout
                p.terminate()
                p.join()
                # Restart the worker
                new_hb = multiprocessing.Value('d', time.time())
                new_p = multiprocessing.Process(target=camera_worker, args=(w["config"], new_hb))
                new_p.start()
                workers[cam_id] = {"process": new_p, "heartbeat": new_hb, "config": w["config"]}
        time.sleep(5)  # Check every 5 seconds
```

### Key Finding: Use `spawn` start method (critical for PyTorch)
Already noted above, restating for emphasis — **required** for PyTorch/CUDA child processes.

---

## 5. Table Schema Design

Based on D-10/D-11 decisions, recommended schemas:

```python
# crowd_event.py — SERIAL PK (internal analytics)
class CrowdEvent(Base):
    __tablename__ = "crowd_events"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    camera_id = Column(String(50), nullable=False, index=True)
    person_count = Column(Integer, nullable=False)
    density_level = Column(String(10), nullable=False)  # 'low', 'medium', 'high'
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

# sos_request.py — UUID PK (public-facing)
class SOSRequest(Base):
    __tablename__ = "sos_requests"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(100), nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    status = Column(String(20), default='pending')  # pending/acknowledged/resolved
    created_at = Column(DateTime(timezone=True), server_default=func.now())

# alert.py — SERIAL PK (internal log)
class Alert(Base):
    __tablename__ = "alerts"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    event_type = Column(String(50), nullable=False)  # 'overcrowd', 'panic'
    camera_id = Column(String(50), nullable=False, index=True)
    severity = Column(String(10), nullable=False)
    person_count = Column(Integer)
    threshold = Column(Integer)
    fired_at = Column(DateTime(timezone=True), server_default=func.now())

# camera.py — SERIAL PK (internal metadata)
class Camera(Base):
    __tablename__ = "cameras"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    camera_id = Column(String(50), unique=True, nullable=False)
    location_label = Column(String(200))
    source = Column(String(500))
    is_active = Column(Boolean, default=True)
```

---

## Validation Architecture

### Dimension 8 Validation Strategies

**V-01: YOLOv8 + ByteTrack Integration**
- Validate: Run `yolov8n.pt` with `bytetrack.yaml` on a test video, confirm track IDs persist across frames
- Tool: `model.track(source="test.mp4", tracker="bytetrack.yaml", persist=True, show=True)`

**V-02: Multiprocessing Stability**
- Validate: Start 4 worker processes simultaneously, run for 60 seconds without crashes
- Check: No zombie processes after `supervisor` cleanup cycle

**V-03: API Endpoints**
- Validate: Use FastAPI's `/docs` Swagger UI to test all 5 REST endpoints + manual WebSocket test
- Tool: `wscat -c ws://localhost:8000/ws/crowd` for WebSocket verification

**V-04: Database Schema**
- Validate: `alembic upgrade head` runs without errors; describe tables in `psql` match ORM definitions
- Check: UUID generation for `sos_requests`, SERIAL autoincrement for other tables

**V-05: Alert Logic**
- Validate: With a test camera showing >75 people, confirm alert fires after 5+ consecutive frames AND does not fire again within 60 seconds
- Tool: A script simulating crowd event data with timing assertions
