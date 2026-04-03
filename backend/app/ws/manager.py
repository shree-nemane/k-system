import json
import logging
from fastapi import WebSocket
from typing import Any

logger = logging.getLogger("app.ws")


class ConnectionManager:
    """
    Manages active WebSocket connections.
    Thread-safe for single-process FastAPI (not multi-instance).
    For multi-instance scale: replace with Redis pub/sub.
    """

    def __init__(self):
        # Maps topic name (str) to a set of active WebSockets
        self.active_connections: dict[str, set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, topic: str = "global") -> None:
        await websocket.accept()
        if topic not in self.active_connections:
            self.active_connections[topic] = set()
        self.active_connections[topic].add(websocket)
        logger.info(f"[WS] Client connected to '{topic}'. Total clients: {self.total_clients_count()}")

    def disconnect(self, websocket: WebSocket) -> None:
        """Remove websocket from ALL topics."""
        for topic in list(self.active_connections.keys()):
            if websocket in self.active_connections[topic]:
                self.active_connections[topic].remove(websocket)
            if not self.active_connections[topic]:
                del self.active_connections[topic]
        logger.info(f"[WS] Client disconnected. Total clients: {self.total_clients_count()}")

    def total_clients_count(self) -> int:
        return sum(len(conns) for conns in self.active_connections.values())

    async def broadcast(self, data: dict[str, Any], topic: str = "global") -> None:
        """
        Broadcast JSON payload to clients.
        If topic is 'global', it sends to EVERY topic.
        Otherwise, only sends to specified topic.
        """
        message = json.dumps(data, default=str)
        dead: list[WebSocket] = []

        # Determine target connection lists
        target_topics = []
        if topic == "global":
            target_topics = list(self.active_connections.values())
        elif topic in self.active_connections:
            target_topics = [self.active_connections[topic]]

        for connections in target_topics:
            for connection in list(connections):
                try:
                    await connection.send_text(message)
                except Exception:
                    dead.append(connection)

        for conn in dead:
            self.disconnect(conn)

    async def send_personal(self, websocket: WebSocket, data: dict[str, Any]) -> None:
        """Send to a specific client only."""
        message = json.dumps(data, default=str)
        await websocket.send_text(message)


# Singleton instance shared across routers
ws_manager = ConnectionManager()
