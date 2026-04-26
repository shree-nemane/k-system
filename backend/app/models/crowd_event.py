from datetime import datetime
from sqlalchemy import BigInteger, String, Integer, DateTime, func, Float, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from backend.app.db.base import Base

class CrowdEvent(Base):
    __tablename__ = "crowd_events"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    camera_id: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    person_count: Mapped[int] = mapped_column(Integer, nullable=False)
    density_level: Mapped[str] = mapped_column(String(10), nullable=False)  # 'low', 'medium', 'high'
    panic_score: Mapped[float] = mapped_column(Float, nullable=True, default=0.0)
    is_panic: Mapped[bool] = mapped_column(Boolean, nullable=True, default=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
