import logging
from datetime import datetime, timezone
from fastapi import APIRouter, Depends
from sqlalchemy import select, func, Integer, Float, String
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.core.security import verify_api_key
from backend.app.db.session import get_db
from backend.app.models.crowd_event import CrowdEvent
from backend.app.models.alert import Alert
from backend.app.schemas.crowd import CrowdUpdateRequest, CrowdStatusResponse, CrowdStatusItem, CrowdHistoryResponse, CrowdHistoryItem
from backend.app.ws.manager import ws_manager

logger = logging.getLogger("app.crowd")
router = APIRouter(prefix="/crowd", tags=["crowd"])

# In-memory store for tracking how long a camera has been at high density (D-28)
# camera_id -> first_high_density_timestamp
high_density_starts: dict[str, datetime] = {}

@router.post("/update", dependencies=[Depends(verify_api_key)])
async def update_crowd(
    payload: CrowdUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Receives crowd snapshot from AI worker.
    1. Saves CrowdEvent to DB.
    2. Sustained Logic (D-28): If 'high' for 120s, trigger Push Alert.
    3. Broadcasts density_update to relevant sector and Alert to global/sector.
    """
    now = datetime.now(timezone.utc)

    # 1. Save crowd event
    event = CrowdEvent(
        camera_id=payload.camera_id,
        person_count=payload.person_count,
        density_level=payload.density_level,
        panic_score=payload.panic_score,
        is_panic=payload.is_panic,
    )
    db.add(event)

    # 2. Check for sustained overcrowding (D-28)
    trigger_push = False
    if payload.density_level == "high":
        if payload.camera_id not in high_density_starts:
            high_density_starts[payload.camera_id] = now
            logger.info(f"[Crowd] Camera {payload.camera_id} HIGH density detected. Tracking for sustained alert...")
        else:
            elapsed = (now - high_density_starts[payload.camera_id]).total_seconds()
            logger.debug(f"[Crowd] Camera {payload.camera_id} steady HIGH for {elapsed:.1f}s")
            if elapsed >= 120:  # 2 minutes
                trigger_push = True
                logger.warning(f"[Crowd] Camera {payload.camera_id} SUSTAINED HIGH for {elapsed:.1f}s. Triggering alert!")
                # Reset to prevent spamming while still high
                high_density_starts[payload.camera_id] = now
    else:
        # Reset if density drops below 'high'
        if payload.camera_id in high_density_starts:
            high_density_starts.pop(payload.camera_id)
            logger.info(f"[Crowd] Camera {payload.camera_id} density normalized. Resetting tracker.")

    alert_data = None
    if trigger_push:
        alert = Alert(
            event_type="overcrowd",
            camera_id=payload.camera_id,
            severity="high",
            person_count=payload.person_count,
            threshold=payload.alert_threshold,
        )
        db.add(alert)
        alert_data = {
            "type": "alert",
            "event": "overcrowd",
            "camera_id": payload.camera_id,
            "severity": "high",
            "timestamp": now.isoformat(),
            "data": {
                "person_count": payload.person_count,
                "threshold": payload.alert_threshold,
            },
        }

    await db.commit()

    # 3. Broadcast density update (D-09)
    # Ideally we determine the sector from the camera's location_label
    # For now, we broadcast updates to the 'global' topic and specific camera ID topic
    update_payload = {
        "type": "density_update",
        "camera_id": payload.camera_id,
        "person_count": payload.person_count,
        "density_level": payload.density_level,
        "timestamp": now.isoformat(),
    }
    
    await ws_manager.broadcast(update_payload, topic="global")
    # Also send to a specific camera topic if mobile is listening for it
    await ws_manager.broadcast(update_payload, topic=f"camera_{payload.camera_id}")

    if alert_data:
        # High priority alerts go to 'global' and 'sector' topics (D-27)
        await ws_manager.broadcast(alert_data, topic="global")
        # In a real scenario, we'd lookup camera.location_label to find the sector
        await ws_manager.broadcast(alert_data, topic="alerts")

    return {"status": "ok", "alert_triggered": trigger_push}


@router.get("/status", dependencies=[Depends(verify_api_key)], response_model=CrowdStatusResponse)
async def get_crowd_status(db: AsyncSession = Depends(get_db)):
    """Return the most recent crowd event per camera."""
    # Subquery: max timestamp per camera_id
    subq = (
        select(CrowdEvent.camera_id, func.max(CrowdEvent.timestamp).label("max_ts"))
        .group_by(CrowdEvent.camera_id)
        .subquery()
    )
    stmt = select(CrowdEvent).join(
        subq,
        (CrowdEvent.camera_id == subq.c.camera_id)
        & (CrowdEvent.timestamp == subq.c.max_ts),
    )
    result = await db.execute(stmt)
    events = result.scalars().all()
    return CrowdStatusResponse(cameras=[CrowdStatusItem.model_validate(e) for e in events])


@router.get("/history/{camera_id}", dependencies=[Depends(verify_api_key)], response_model=CrowdHistoryResponse)
async def get_crowd_history(camera_id: str, db: AsyncSession = Depends(get_db)):
    """
    Return 5-minute aggregated metrics for the last 24 hours.
    SQL Logic (D-34): Buckets data into 5-minute intervals.
    """
    # 5-minute bucket SQL: date_trunc('minute', timestamp) - (extract(minute FROM timestamp)::int % 5) * interval '1 min'
    bucket = func.date_trunc("minute", CrowdEvent.timestamp) - (
        func.cast(func.extract("minute", CrowdEvent.timestamp), Integer) % 5
    ) * func.cast("1 minute", String).op("::interval")

    stmt = (
        select(
            bucket.label("bucket"),
            func.avg(CrowdEvent.person_count).label("avg_count"),
            func.max(CrowdEvent.person_count).label("max_count"),
            func.count(CrowdEvent.id).filter(CrowdEvent.is_panic == True).label("panic_events"),
            (func.cast(func.count(CrowdEvent.id).filter(CrowdEvent.is_panic == True), Float) / 
             func.cast(func.count(CrowdEvent.id), Float)).label("panic_ratio")
        )
        .where(CrowdEvent.camera_id == camera_id)
        .group_by("bucket")
        .order_by("bucket")
        .limit(288)  # 24 hours * 12 buckets/hr
    )
    
    result = await db.execute(stmt)
    rows = result.all()
    
    history = [
        CrowdHistoryItem(
            bucket=row.bucket,
            avg_count=float(row.avg_count),
            max_count=int(row.max_count),
            panic_events=int(row.panic_events),
            panic_ratio=float(row.panic_ratio or 0.0)
        )
        for row in rows
    ]
    
    return CrowdHistoryResponse(camera_id=camera_id, history=history)
