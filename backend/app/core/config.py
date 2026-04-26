import os
from pydantic_settings import BaseSettings, SettingsConfigDict

# Path to the backend directory where .env is located
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=(
            os.path.join(BASE_DIR, ".env.example"),
            os.path.join(BASE_DIR, ".env")
        ),
        env_file_encoding="utf-8",
        extra="ignore"
    )

    DATABASE_URL: str
    API_KEY: str
    APP_ENV: str = "development"
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000

settings = Settings()
