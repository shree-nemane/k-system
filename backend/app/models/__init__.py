"""
Models package initialization.
Exports all ORM models for easy access and Alembic detection.
"""
from app.models.crowd_event import CrowdEvent
from app.models.sos_request import SOSRequest
from app.models.alert import Alert
from app.models.camera import Camera

__all__ = ["CrowdEvent", "SOSRequest", "Alert", "Camera"]
