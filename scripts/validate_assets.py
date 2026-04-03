import json
import os

def validate_json(file_path):
    print(f"Validating {file_path}...")
    if not os.path.exists(file_path):
        print(f"  [ERROR] File not found: {file_path}")
        return False
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
            if "map_data.json" in file_path:
                required = ["markers", "sectors", "routes"]
                for key in required:
                    if key not in data:
                        print(f"  [ERROR] Missing key: {key}")
                        return False
                print(f"  [SUCCESS] Map data structure is valid. Markers: {len(data['markers'])}, Sectors: {len(data['sectors'])}, Routes: {len(data['routes'])}.")
            
            if "guide_data.json" in file_path:
                required = ["rituals", "safety", "contacts"]
                for key in required:
                    if key not in data:
                        print(f"  [ERROR] Missing key: {key}")
                        return False
                print(f"  [SUCCESS] Guide data structure is valid. Rituals: {len(data['rituals'])}, Safety tips: {len(data['safety'])}, Contacts: {len(data['contacts'])}.")
        return True
    except Exception as e:
        print(f"  [ERROR] Syntax error or problem processing file: {e}")
        return False

# Using absolute paths as per the workspace info
paths = [
    "d:/k-system/mobile/assets/data/map_data.json",
    "d:/k-system/mobile/assets/data/guide_data.json"
]

all_valid = True
for p in paths:
    if not validate_json(p):
        all_valid = False

if all_valid:
    print("\nAll Phase 2 assets validated successfully.")
    exit(0)
else:
    print("\nPhase 2 asset validation failed.")
    exit(1)
