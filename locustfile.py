# 
# Locust Performance Testing Script
# 

from locust import HttpUser, task, between

class SoCUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def benchmark(self):
        self.client.get("/")
