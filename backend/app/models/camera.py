from sqlalchemy import BigInteger, String, Boolean, Integer
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Camera(Base):
    __tablename__ = "cameras"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    camera_id: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    location_label: Mapped[str] = mapped_column(String(200), nullable=True)
    source: Mapped[str] = mapped_column(String(500), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    low_thresh: Mapped[int] = mapped_column(Integer, default=30, nullable=False)
    high_thresh: Mapped[int] = mapped_column(Integer, default=75, nullable=False)
    max_age: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
