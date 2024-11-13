#!/bin/bash

# Automating the Tests for Each Service

# Define an array of services
services=(
  "soc-emulator"
  "prometheus"
  "grafana"
  "postgres"
  "prestosql"
  "spark-master"
  "spark-worker"
  "spark-app"
  "api-backend"
  "locust"
)

# Function to get container name
get_container_name() {
  docker ps --format '{{.Names}}' --filter "name=$1"
}

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Start testing each service
for service in "${services[@]}"; do
  echo "-----------------------------------------"
  echo "Testing service: $service"

  # Get the container name
  container_name=$(get_container_name $service)

  if [ -z "$container_name" ]; then
    echo " - Container for service '$service' is not running!"
    continue
  else
    echo " - Container is running: $container_name"
  fi

  # Print the last 5 lines of logs
  echo " - Last 5 log entries:"
  docker logs "$container_name" --tail 5

  # Service-specific tests
  case $service in
    "soc-emulator")
      # SSH into emulated SoC and verify benchmarks
      echo " - Testing soc-emulator service..."

      # Test SSH connectivity
      sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no -p 5022 pi@localhost 'echo "SSH connection successful."'

      # Run a benchmark script via SSH
      sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no -p 5022 pi@localhost 'python3 /home/pi/automate_benchmarks.py'

      ;;

    "prometheus")
      # Check Prometheus targets and query metrics
      echo " - Testing prometheus service..."

      # Access Prometheus targets API
      targets=$(curl -s http://localhost:9090/api/v1/targets)

      if echo "$targets" | grep '"health":"up"' >/dev/null; then
        echo " - Prometheus targets are up."
      else
        echo " - Prometheus targets are down!"
      fi

      # Query a metric
      up_metric=$(curl -s 'http://localhost:9090/api/v1/query?query=up')
      echo " - Prometheus 'up' metric query result:"
      echo "$up_metric"

      ;;

    "grafana")
      # Test Grafana accessibility and verify dashboards
      echo " - Testing grafana service..."

      # Check if Grafana login page is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:3001/login)

      if [ "$status_code" -eq 200 ]; then
        echo " - Grafana login page is accessible."
      else
        echo " - Grafana login page is not accessible! HTTP status code: $status_code"
      fi

      # Log in to Grafana and verify dashboards using API
      echo " - Verifying Grafana dashboards..."

      # Obtain Grafana API token (assuming you have one set up)
      # Replace 'your_grafana_api_token' with an actual API token
      GRAFANA_API_TOKEN="your_grafana_api_token"

      if [ "$GRAFANA_API_TOKEN" != "your_grafana_api_token" ]; then
        dashboards=$(curl -s -H "Authorization: Bearer $GRAFANA_API_TOKEN" \
          http://localhost:3001/api/search?query=&)
        if echo "$dashboards" | grep -q 'soc_performance_dashboard'; then
          echo " - 'soc_performance_dashboard' is present."
        else
          echo " - 'soc_performance_dashboard' is missing!"
        fi
        if echo "$dashboards" | grep -q 'soc_analysis_results_dashboard'; then
          echo " - 'soc_analysis_results_dashboard' is present."
        else
          echo " - 'soc_analysis_results_dashboard' is missing!"
        fi
      else
        echo " - Grafana API token not set. Skipping dashboard verification."
      fi

      ;;

    "postgres")
      # Test PostgreSQL database
      echo " - Testing postgres service..."

      # Use psql client in the container to list tables
      docker exec -i "$container_name" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt'

      # Query data from soc_metrics
      docker exec -i "$container_name" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c 'SELECT * FROM soc_metrics LIMIT 5;'

      ;;

    "prestosql")
      # Test Presto CLI and run a query
      echo " - Testing prestosql service..."

      # Run a query using Presto CLI inside the container
      docker exec -i "$container_name" presto --server localhost:8080 --catalog postgresql --schema public --execute 'SELECT * FROM soc_metrics LIMIT 5;'

      ;;

    "spark-master")
      # Test Spark Master service
      echo " - Testing spark-master service..."

      # Check if Spark Master Web UI is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8081)

      if [ "$status_code" -eq 200 ]; then
        echo " - Spark Master Web UI is accessible."
      else
        echo " - Spark Master Web UI is not accessible! HTTP status code: $status_code"
      fi

      ;;

    "spark-worker")
      # Test Spark Worker service
      echo " - Testing spark-worker service..."

      # Verify worker registration by checking the Spark Master Web UI
      worker_info=$(curl -s http://localhost:8081/json/ | grep -o '"Alive":true')

      if [ -n "$worker_info" ]; then
        echo " - Spark Worker is registered and alive."
      else
        echo " - Spark Worker is not registered!"
      fi

      ;;

    "spark-app")
      # Test Spark Application
      echo " - Testing spark-app service..."

      # Check logs for successful completion of data_analysis.py
      if docker logs "$container_name" 2>&1 | grep -q "CPU Usage Statistics:"; then
        echo " - Spark application ran successfully."
      else
        echo " - Spark application did not run successfully!"
      fi

      # Verify analysis results in PostgreSQL
      docker exec -i soc-simulation-project-new_postgres_1 psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c 'SELECT * FROM soc_analysis_results LIMIT 5;'

      ;;

    "api-backend")
      # Test API endpoints
      echo " - Testing api-backend service..."

      # Test storing a metric
      store_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
        -d '{"cpu_usage":50,"memory_usage":512,"disk_io":1024,"config_name":"test"}' \
        http://localhost:5000/api/store_metric)

      if [ "$store_response" -eq 200 ]; then
        echo " - Successfully stored a metric."
      else
        echo " - Failed to store a metric! HTTP status code: $store_response"
      fi

      # Test retrieving metrics
      get_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/get_metrics)

      if [ "$get_response" -eq 200 ]; then
        echo " - Successfully retrieved metrics."
      else
        echo " - Failed to retrieve metrics! HTTP status code: $get_response"
      fi

      ;;

    "locust")
      # Test Locust service
      echo " - Testing locust service..."

      # Check if Locust web interface is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:8089)

      if [ "$status_code" -eq 200 ]; then
        echo " - Locust web interface is accessible."
      else
        echo " - Locust web interface is not accessible! HTTP status code: $status_code"
      fi

      # Start a headless Locust test
      echo " - Running Locust load test..."

      docker run --rm --net=host locustio/locust -f /locustfile.py --headless -u 10 -r 2 -t 30s --host http://api-backend:5000

      ;;

    *)
      echo " - No specific tests defined for service: $service"
      ;;
  esac

  echo "-----------------------------------------"
  echo ""
done
