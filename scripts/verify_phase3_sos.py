import requests
import uuid
import time

BASE_URL = "http://localhost:8000"
API_KEY = "mahakumbh-secret-2027"

def test_sos_lifecycle():
    headers = {"X-API-KEY": API_KEY}
    
    # 1. Trigger SOS
    payload = {
        "latitude": 25.4412,
        "longitude": 81.8864,
        "altitude": 102.5,
        "battery_level": 0.85,
        "category": "MEDICAL",
        "device_id": "test-device-uuid"
    }
    
    print("\n--- Phase 3 SOS Trigger Test ---")
    response = requests.post(f"{BASE_URL}/sos/request", json=payload, headers=headers)
    if response.status_code != 200:
        print(f"FAILED: SOS Trigger ({response.status_code})")
        print(response.text)
        return
    
    sos_data = response.json()
    sos_id = sos_data["id"]
    print(f"SUCCESS: SOS Triggered (ID: {sos_id}, Status: {sos_data['status']})")

    # 2. Poll Status
    print("\n--- Phase 3 Status Polling Test ---")
    response = requests.get(f"{BASE_URL}/sos/{sos_id}/status", headers=headers)
    status_data = response.json()
    print(f"SUCCESS: Received Status ({status_data['status']})")

    # 3. Simulate Authority Dispatch (Manual DB update or direct model status change?)
    # For now, we'll just verify the retrieval works.
    print(f"Message: {status_data['message']}")

if __name__ == "__main__":
    try:
        test_sos_lifecycle()
    except Exception as e:
        print(f"Error connecting to backend: {e}")
