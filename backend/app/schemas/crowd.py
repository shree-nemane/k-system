from pydantic import BaseModel
from datetime import datetime

class CrowdUpdateRequest(BaseModel):
    camera_id: str
    person_count: int
    density_level: str           # 'low', 'medium', 'high'
    trigger_alert: bool = False
    alert_threshold: int | None = None
    panic_score: float = 0.0
    is_panic: bool = False

class CrowdStatusItem(BaseModel):
    camera_id: str
    person_count: int
    density_level: str
    panic_score: float = 0.0
    is_panic: bool = False
    timestamp: datetime

    model_config = {"from_attributes": True}

class CrowdStatusResponse(BaseModel):
    cameras: list[CrowdStatusItem]

class CrowdHistoryItem(BaseModel):
    bucket: datetime
    avg_count: float
    max_count: int
    panic_events: int
    panic_ratio: float

class CrowdHistoryResponse(BaseModel):
    camera_id: str
    history: list[CrowdHistoryItem]
