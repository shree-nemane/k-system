from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import verify_api_key
from app.db.session import get_db
from app.models.camera import Camera
from app.schemas.camera import CamerasResponse, CameraRead

router = APIRouter(prefix="/cameras", tags=["cameras"])

@router.get("/", dependencies=[Depends(verify_api_key)], response_model=CamerasResponse)
async def list_cameras(db: AsyncSession = Depends(get_db)):
    """Return all configured cameras. Mobile uses this to build the map overlay."""
    stmt = select(Camera).where(Camera.is_active == True)
    result = await db.execute(stmt)
    cameras = result.scalars().all()
    return CamerasResponse(cameras=[CameraRead.model_validate(c) for c in cameras])
