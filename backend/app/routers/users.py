from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.core.security import verify_api_key
from backend.app.db.session import get_db
from backend.app.models.user import User
from backend.app.schemas.user import UserRegisterRequest

router = APIRouter()

@router.post("/register", dependencies=[Depends(verify_api_key)])
async def register_user(data: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register or update a mobile device for push notifications."""
    result = await db.execute(select(User).where(User.device_id == data.device_id))
    user = result.scalars().first()

    if user:
        user.push_token = data.push_token
        user.emergency_contact = data.emergency_contact
    else:
        user = User(
            device_id=data.device_id,
            push_token=data.push_token,
            emergency_contact=data.emergency_contact,
        )
        db.add(user)

    await db.commit()
    return {"status": "success", "device_id": data.device_id}
