from locust import HttpUser, task, between

class SoCUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def store_metric(self):
        self.client.post("/api/store_metric", json={
            "cpu_usage": 50,
            "memory_usage": 512,
            "disk_io": 1024,
            "config_name": "test"
        })

    @task
    def get_metrics(self):
        self.client.get("/api/get_metrics")
