#!/bin/bash

# Enhanced Testing Script for Each Service

# Define an array of services
services=(
  "soc-emulator"
  "api-backend"
  "prometheus"
  "grafana"
  "postgres"
  "prestosql"
  "spark-master"
  "spark-worker"
  "spark-app"
  "locust"
)

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found."
  exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Start testing each service
echo -e "\n${GREEN}Starting Service Tests...${NC}\n"

declare -A test_results

for service in "${services[@]}"; do
  echo -e "-----------------------------------------"
  echo -e "Testing service: ${GREEN}$service${NC}"

  # Get the container name
  container_name=$(docker ps --format '{{.Names}}' --filter "name=$service")

  if [ -z "$container_name" ]; then
    echo -e " - ${RED}Container for service '$service' is not running!${NC}"
    test_results[$service]="Failed"
    continue
  else
    echo -e " - Container is running: ${GREEN}$container_name${NC}"
  fi

  # Print the last 5 lines of logs
  echo -e " - Last 5 log entries:"
  docker logs "$container_name" --tail 5

  # Service-specific tests
  case $service in
    "soc-emulator")
      echo -e " - Testing soc-emulator service..."
      # Test SSH connectivity
      if sshpass -p 'raspberry' ssh -o StrictHostKeyChecking=no -p 5022 pi@localhost 'echo "SSH connection successful."' >/dev/null 2>&1; then
        echo -e " - SSH connectivity: ${GREEN}Success${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - SSH connectivity: ${RED}Failed${NC}"
        test_results[$service]="Failed"
      fi
      ;;
    
    "api-backend")
      echo -e " - Testing api-backend service..."
      # Test storing a metric
      store_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" \
        -d '{"cpu_usage":50,"memory_usage":512,"disk_io":1024,"config_name":"test"}' \
        http://localhost:${API_BACKEND_PORT}/api/store_metric)

      if [ "$store_response" -eq 200 ]; then
        echo -e " - Store metric endpoint: ${GREEN}Success${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Store metric endpoint: ${RED}Failed${NC} (HTTP $store_response)"
        test_results[$service]="Failed"
      fi
      ;;
    
    "prometheus")
      echo -e " - Testing prometheus service..."
      # Access Prometheus targets API
      targets=$(curl -s http://localhost:${PROMETHEUS_PORT}/api/v1/targets)

      if echo "$targets" | grep '"health":"up"' >/dev/null; then
        echo -e " - Prometheus targets: ${GREEN}Up${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Prometheus targets: ${RED}Down${NC}"
        test_results[$service]="Failed"
      fi
      ;;
    
    "grafana")
      echo -e " - Testing grafana service..."
      # Check if Grafana login page is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${GRAFANA_PORT}/login)

      if [ "$status_code" -eq 200 ]; then
        echo -e " - Grafana login page: ${GREEN}Accessible${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Grafana login page: ${RED}Not Accessible${NC} (HTTP $status_code)"
        test_results[$service]="Failed"
      fi
      ;;
    
    "postgres")
      echo -e " - Testing postgres service..."
      # Use psql client in the container to list tables
      tables=$(docker exec -i "$container_name" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt' | grep 'soc_metrics')
      if [ -n "$tables" ]; then
        echo -e " - Tables exist: ${GREEN}Yes${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Tables exist: ${RED}No${NC}"
        test_results[$service]="Failed"
      fi
      ;;
    
    "prestosql")
      echo -e " - Testing prestosql service..."
      # Run a query using Trino CLI inside the container
      query_result=$(docker exec -i "$container_name" trino --server localhost:8080 --catalog postgresql --schema public --execute 'SELECT COUNT(*) FROM soc_metrics;' 2>&1)
      if echo "$query_result" | grep -q '[0-9]'; then
        echo -e " - PrestoSQL query: ${GREEN}Success${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - PrestoSQL query: ${RED}Failed${NC}"
        echo "$query_result"
        test_results[$service]="Failed"
      fi
      ;;
    
    "spark-master")
      echo -e " - Testing spark-master service..."
      # Check if Spark Master Web UI is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${SPARK_MASTER_WEBUI_PORT})

      if [ "$status_code" -eq 200 ]; then
        echo -e " - Spark Master Web UI: ${GREEN}Accessible${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Spark Master Web UI: ${RED}Not Accessible${NC} (HTTP $status_code)"
        test_results[$service]="Failed"
      fi
      ;;
    
    "spark-worker")
      echo -e " - Testing spark-worker service..."
      # Verify worker registration by checking the Spark Master's Web UI
      worker_info=$(curl -s http://localhost:${SPARK_MASTER_WEBUI_PORT}/json | grep -o '"id":"worker-[^"]*","state":"ALIVE"')

      if [ -n "$worker_info" ]; then
        echo -e " - Spark Worker registration: ${GREEN}Successful${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Spark Worker registration: ${RED}Failed${NC}"
        test_results[$service]="Failed"
      fi
      ;;
    
    "spark-app")
      echo -e " - Testing spark-app service..."
      # Check logs for successful completion of data_analysis.py
      if docker logs "$container_name" 2>&1 | grep -q "CPU Usage Statistics:"; then
        echo -e " - Spark application execution: ${GREEN}Success${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Spark application execution: ${RED}Failed${NC}"
        test_results[$service]="Failed"
      fi
      ;;
    
    "locust")
      echo -e " - Testing locust service..."
      # Check if Locust web interface is accessible
      status_code=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${LOCUST_PORT})

      if [ "$status_code" -eq 200 ]; then
        echo -e " - Locust web interface: ${GREEN}Accessible${NC}"
        test_results[$service]="Passed"
      else
        echo -e " - Locust web interface: ${RED}Not Accessible${NC} (HTTP $status_code)"
        test_results[$service]="Failed"
      fi
      ;;
    
    *)
      echo -e " - No specific tests defined for service: $service"
      test_results[$service]="Skipped"
      ;;
  esac

  echo -e "-----------------------------------------\n"
done

# Summary of Test Results
echo -e "${GREEN}Test Summary:${NC}"
for service in "${services[@]}"; do
  result=${test_results[$service]}
  if [ "$result" == "Passed" ]; then
    echo -e " - $service: ${GREEN}Passed${NC}"
  elif [ "$result" == "Failed" ]; then
    echo -e " - $service: ${RED}Failed${NC}"
  else
    echo -e " - $service: Skipped"
  fi
done
