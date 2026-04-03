from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import verify_api_key
from app.db.session import get_db
from app.models.alert import Alert
from app.schemas.alert import AlertsResponse, AlertRead

router = APIRouter(prefix="/alerts", tags=["alerts"])

@router.get("/recent", dependencies=[Depends(verify_api_key)], response_model=AlertsResponse)
async def get_recent_alerts(
    minutes: int = Query(default=15, ge=1, le=60),
    db: AsyncSession = Depends(get_db),
):
    """Return alerts from the last N minutes (default 15). Mobile fallback polling."""
    since = datetime.now(timezone.utc) - timedelta(minutes=minutes)
    stmt = select(Alert).where(Alert.fired_at >= since).order_by(Alert.fired_at.desc())
    result = await db.execute(stmt)
    alerts = result.scalars().all()
    return AlertsResponse(
        alerts=[AlertRead.model_validate(a) for a in alerts],
        total=len(alerts),
    )
