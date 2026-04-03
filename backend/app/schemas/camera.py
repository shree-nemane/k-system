from pydantic import BaseModel

class CameraRead(BaseModel):
    camera_id: str
    name: str
    location_label: str | None
    is_active: bool
    low_thresh: int
    high_thresh: int

    model_config = {"from_attributes": True}

class CamerasResponse(BaseModel):
    cameras: list[CameraRead]
