import uuid
from pydantic import BaseModel

class SOSCreateRequest(BaseModel):
    latitude: float
    longitude: float
    altitude: float | None = None
    battery_level: float | None = None
    category: str = "GENERAL"
    device_id: str | None = None
    request_id: str | None = None # Support legacy mobile field name

class SOSCreateResponse(BaseModel):
    id: uuid.UUID
    status: str
    responder_name: str | None = None
    message: str = "SOS received"

    model_config = {"from_attributes": True}
