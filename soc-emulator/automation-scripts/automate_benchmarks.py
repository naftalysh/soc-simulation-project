import time
import psutil
import requests
import os
import subprocess

def run_disk_benchmark():
    """
    Run the disk benchmark test using the compiled C program.
    Uses ./benchmarks/disk_benchmark to measure disk I/O.
    
    Returns:
        float: The disk I/O throughput in MB/s.
    """
    try:
        # Run the disk_benchmark program and capture its output
        result = subprocess.run(
            ['./benchmarks/disk_benchmark'],
            stdout=subprocess.PIPE,
            text=True,
            check=True
        )
        return float(result.stdout.strip())
    except subprocess.CalledProcessError:
        print("Error running disk benchmark.")
        return 0.0

def collect_system_metrics():
    """
    Collect CPU, memory, and disk I/O usage metrics using psutil.
    
    Returns:
        tuple: A tuple containing CPU usage (%), memory usage (MB), and disk I/O (MB/s).
    """
    cpu_usage = psutil.cpu_percent(interval=1)
    memory_usage = psutil.virtual_memory().used / (1024 * 1024)  # in MB
    disk_io = run_disk_benchmark()
    return cpu_usage, memory_usage, disk_io

def send_metrics(data, api_url):
    """
    Send the collected metrics to the specified API endpoint.
    
    Args:
        data (dict): The data dictionary containing metrics.
        api_url (str): The URL of the API endpoint.
    """
    try:
        response = requests.post(api_url, json=data, timeout=10)
        print("Data sent:", response.status_code)
    except requests.exceptions.RequestException as request_exception:
        print(f"Failed to send data: {request_exception}")

def main():
    """
    Main function to collect system metrics (CPU, memory, disk I/O) 
    and send the data to the API.
    """
    API_BACKEND_URL = os.getenv("API_BACKEND_URL", "http://10.0.2.2:5000")
    api_endpoint = f"{API_BACKEND_URL}/api/store_metric"

    # Collect metrics
    print("Collecting CPU, memory, and disk I/O metrics...")
    cpu_usage, memory_usage, disk_io = collect_system_metrics()
    print(f"CPU Usage: {cpu_usage}%")
    print(f"Memory Usage: {memory_usage:.2f} MB")
    print(f"Disk I/O (in MB/s): {disk_io}")

    # Construct the data dictionary
    data = {
        "cpu_usage": cpu_usage,
        "memory_usage": memory_usage,
        "disk_io": disk_io,
        "config_name": "baseline"
    }

    # Send the data to the API
    print("Sending data to API...")
    send_metrics(data, api_endpoint)

if __name__ == "__main__":
    main()
