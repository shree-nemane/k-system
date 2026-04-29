from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import os
import sys

# Add project root to sys.path to resolve 'backend' module imports
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from backend.app.core.logging_config import setup_logging
from backend.app.routers import crowd, sos, alerts, cameras, users, rituals
from backend.app.ws.manager import ws_manager

# Ensure static directory exists
STATIC_DIR = "app/static"
os.makedirs(STATIC_DIR, exist_ok=True)

# Initialize core logging
logger = setup_logging()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialize DB connections, etc.
    logger.info("MahaKumbh Smart Guide API — Starting up")
    yield
    # Shutdown
    logger.info("MahaKumbh Smart Guide API — Shutting down")

app = FastAPI(
    title="MahaKumbh 2027 Smart Guide API",
    version="0.1.0",
    description="Real-time crowd monitoring and safety coordination API",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(crowd.router)
app.include_router(sos.router)
app.include_router(alerts.router)
app.include_router(cameras.router)
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(rituals.router)

@app.websocket("/ws/crowd")
async def websocket_crowd(websocket: WebSocket, topic: str = "global"):
    """
    WebSocket endpoint for live crowd density and alert push.
    Topic parameter (e.g. ?topic=sector_1) allows targeted broadcasts.
    """
    client_host = websocket.client.host if websocket.client else "unknown"
    logger.info(f"[WS] Handshake started: client={client_host}, topic={topic}")
    await ws_manager.connect(websocket, topic=topic)
    try:
        while True:
            # Keep connection alive; server pushes data via broadcast()
            await websocket.receive_text()
    except WebSocketDisconnect:
        ws_manager.disconnect(websocket)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "MahaKumbh Smart Guide API"}

if __name__ == "__main__":
    import uvicorn
    from backend.app.core.config import settings
    uvicorn.run("main:app", host=settings.APP_HOST, port=settings.APP_PORT, reload=True)
