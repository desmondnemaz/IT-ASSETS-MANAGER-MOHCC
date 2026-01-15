import urllib.request
import json

url = "http://127.0.0.1:8000/api/locations/districts/"

try:
    with urllib.request.urlopen(url) as response:
        print(f"Status Code: {response.getcode()}")
        data = json.loads(response.read().decode('utf-8'))
        print(f"Count of districts: {len(data)}")
        if len(data) > 0:
            print(f"Sample district: {data[0]}")
except Exception as e:
    print(f"Error: {e}")
