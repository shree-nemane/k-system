from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from backend.app.db.session import get_db
from backend.app.models.user import User
from pydantic import BaseModel

router = APIRouter()

class UserRegister(BaseModel):
    device_id: str
    push_token: str | None = None
    emergency_contact: dict | None = None

@router.post("/register")
def register_user(data: UserRegister, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.device_id == data.device_id).first()
    if user:
        user.push_token = data.push_token
        user.emergency_contact = data.emergency_contact
    else:
        user = User(
            device_id=data.device_id,
            push_token=data.push_token,
            emergency_contact=data.emergency_contact
        )
        db.add(user)
    
    db.commit()
    return {"status": "success", "device_id": data.device_id}
