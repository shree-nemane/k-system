import logging
import sys
from logging.handlers import RotatingFileHandler
from pathlib import Path

def setup_logging():
    """
    Configures standard logging for the FastAPI backend.
    Logs to both the console (stderr) and a rotating file.
    """
    log_format = "[%(asctime)s] [%(levelname)s] [%(name)s]: %(message)s"
    date_format = "%Y-%m-%d %H:%M:%S"
    
    # Create logs directory if it doesn't exist
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    log_file = log_dir / "app.log"

    # Root logger configuration
    logging.basicConfig(
        level=logging.DEBUG, # Default to DEBUG for troubleshooting
        format=log_format,
        datefmt=date_format,
        handlers=[
            logging.StreamHandler(sys.stdout),
            RotatingFileHandler(
                log_file,
                maxBytes=10*1024*1024, # 10MB
                backupCount=5
            )
        ]
    )

    # Specific logger for our app
    logger = logging.getLogger("app")
    logger.setLevel(logging.DEBUG)
    
    # Silence chatty third-party libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.INFO)
    
    logger.info("Logging infrastructure initialized (Plan Logging)")
    return logger
