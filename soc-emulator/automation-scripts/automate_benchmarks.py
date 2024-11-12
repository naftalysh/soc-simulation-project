import time
import psutil
import requests
import os

# Simulate benchmark results
cpu_usage = psutil.cpu_percent(interval=1)
memory_usage = psutil.virtual_memory().used / (1024 * 1024)  # in MB
disk_io = psutil.disk_io_counters().read_bytes + psutil.disk_io_counters().write_bytes

# Get API backend URL from environment variable or default
API_BACKEND_URL = os.getenv("API_BACKEND_URL", "http://10.0.2.2:5000")

# Send data to API
data = {
    "cpu_usage": cpu_usage,
    "memory_usage": memory_usage,
    "disk_io": disk_io,
    "config_name": "baseline"
}
# Send the POST request with a timeout (e.g., 10 seconds)
response = requests.post(f"{API_BACKEND_URL}/api/store_metric", json=data, timeout=10)
print("Data sent:", response.status_code)


# Explanation
# ===========
# API Backend URL:

# Uses 10.0.2.2 as the default gateway from QEMU guest to the host (QEMU's user networking).
# Alternatively, you can set an environment variable API_BACKEND_URL if needed.
# Data Transmission:

# Sends the collected metrics to the API backend from within the emulated system.
