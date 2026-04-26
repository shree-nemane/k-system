import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from backend.app.core.security import verify_api_key
from backend.app.db.session import get_db
from backend.app.models.sos_request import SOSRequest
from backend.app.schemas.sos import SOSCreateRequest, SOSCreateResponse

router = APIRouter(prefix="/sos", tags=["sos"])

@router.post("/request", dependencies=[Depends(verify_api_key)], response_model=SOSCreateResponse)
async def submit_sos(payload: SOSCreateRequest, db: AsyncSession = Depends(get_db)):
    """
    Accept SOS from mobile app. Returns UUID for retry deduplication.
    """
    sos = SOSRequest(
        latitude=payload.latitude,
        longitude=payload.longitude,
        altitude=payload.altitude,
        battery_level=payload.battery_level,
        category=payload.category,
        device_id=payload.device_id,
        status="pending",
    )
    db.add(sos)
    await db.commit()
    await db.refresh(sos)
    return SOSCreateResponse(id=sos.id, status=sos.status)

@router.get("/{sos_id}/status", response_model=SOSCreateResponse)
async def get_sos_status(sos_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    """
    Check current status of an SOS request.
    """
    result = await db.execute(select(SOSRequest).filter(SOSRequest.id == sos_id))
    sos = result.scalars().first()
    if not sos:
        raise HTTPException(status_code=404, detail="SOS request not found")
    return SOSCreateResponse(
        id=sos.id, 
        status=sos.status, 
        responder_name=sos.responder_name,
        message=f"SOS is currently {sos.status}"
    )
