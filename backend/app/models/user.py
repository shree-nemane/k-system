from datetime import datetime
from sqlalchemy import String, DateTime, func, JSON
from sqlalchemy.orm import Mapped, mapped_column
from backend.app.db.base import Base

class User(Base):
    __tablename__ = "users"

    device_id: Mapped[str] = mapped_column(String(255), primary_key=True)
    push_token: Mapped[str | None] = mapped_column(String(255), nullable=True)
    emergency_contact: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    last_seen: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )
