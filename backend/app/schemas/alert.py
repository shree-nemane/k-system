from datetime import datetime
from pydantic import BaseModel

class AlertRead(BaseModel):
    id: int
    event_type: str
    camera_id: str
    severity: str
    person_count: int | None
    threshold: int | None
    message: str | None
    recommendation: str | None
    fired_at: datetime

    model_config = {"from_attributes": True}

class AlertsResponse(BaseModel):
    alerts: list[AlertRead]
    total: int
