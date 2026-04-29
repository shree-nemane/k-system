from pydantic import BaseModel


class UserRegisterRequest(BaseModel):
    device_id: str
    push_token: str | None = None
    emergency_contact: dict | None = None
