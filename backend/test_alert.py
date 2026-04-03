import requests
import json
import time
import os
from dotenv import load_dotenv

# Load environment variables from backend/.env
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

API_BASE_URL = "http://localhost:8000"
API_KEY = os.getenv("API_KEY", "mahakumbh-secret-2027")

def trigger_mock_alert():
    print(f"🚀 Triggering High-Density Alert for Sector 4...")
    
    url = f"{API_BASE_URL}/crowd/update"
    headers = {
        "X-API-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    payload = {
        "camera_id": "CAM_04_SOUTH",
        "person_count": 850,
        "density_level": "high",
        "trigger_alert": True,
        "alert_threshold": 500
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200:
            print("✅ Alert Broadcast Successful!")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Failed to broadcast alert: {response.status_code}")
            if response.status_code == 403:
                print("\n💡 TIP: Verify your API_KEY matches in .env. If you just created .env, you MUST restart the backend (uvicorn) to pick up changes!")
            print(response.text)
    except Exception as e:
        print(f"❗ Error: {e}")

if __name__ == "__main__":
    trigger_mock_alert()
