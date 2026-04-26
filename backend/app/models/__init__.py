"""
Models package initialization.
Exports all ORM models for easy access and Alembic detection.
"""
from backend.app.models.crowd_event import CrowdEvent
from backend.app.models.sos_request import SOSRequest
from backend.app.models.alert import Alert
from backend.app.models.camera import Camera

__all__ = ["CrowdEvent", "SOSRequest", "Alert", "Camera"]
