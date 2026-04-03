import json
import os
from fastapi import APIRouter, HTTPException
from typing import List, Any

router = APIRouter(prefix="/rituals", tags=["rituals"])

# Path to the ritual data
DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "rituals.json")

@router.get("/", response_model=List[Any])
async def get_rituals():
    """
    Returns the latest ritual and schedule data for the Spiritual Guide.
    Used by the mobile app's Optional Sync mechanism (D-25).
    """
    if not os.path.exists(DATA_FILE):
        return []
    
    try:
        with open(DATA_FILE, "r") as f:
            data = json.load(f)
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading ritual data: {str(e)}")
