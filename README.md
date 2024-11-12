# Project description
The project simulates a SoC (System-on-Chip) system using Docker Compose, 
integrating various components required for performance analysis, monitoring, data processing, and testing

Creating a local test environment using Docker Compose to simulate a SOC (System-on-Chip) system requires integrating various components to handle monitoring, data processing, and performance analysis. Below is a proposed setup with each component explained, as well as its integration and the workflows. 

# Overview of the SOC Simulation Environment
This setup aims to create an environment for performance analysis, monitoring, and data collection. 
The environment includes components for:

SOC Hardware Emulation (via QEMU)
Performance Monitoring and Visualization (Prometheus and Grafana)
Data Processing and Querying (PostgreSQL and PrestoSQL)
Automated Performance Testing (Custom benchmarks and GitHub Actions simulation)
Backend and API for Data Collection (Python Flask API)
Each component will be containerized and orchestrated through Docker Compose.

# components include:

* SoC Hardware Emulator (QEMU)
* Prometheus (Monitoring)
* Grafana (Visualization)
* PostgreSQL (Data Storage)
* PrestoSQL (Distributed Query Engine)
* Apache Spark (Data Processing)
* API Backend (Python Flask)
* Performance Testing Tool (Locust)
* Automation Scripts (Python, Bash)

# Folder Structure
soc-simulation-project/
├── docker-compose.yml
├── prometheus.yml
├── locustfile.py
├── README.md
├── soc-emulator/
│   └── automation-scripts/
│   |   └── automate_benchmarks.py
│   ├── Dockerfile
│   ├── run_benchmarks.sh
│   └── benchmarks/
├── api-backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
├── spark-app/
├── grafana/
│   └── provisioning/
│       ├── dashboards/
│       │   ├── dashboards.yml
│       │   └── soc_performance_dashboard.json
│       │   └── soc_analysis_results_dashboard.json
│       └── datasources/
│           └── datasources.yml
├── postgres_data/ (created by Docker)
└── grafana_data/ (created by Docker)



# Explanation of Each Directory
1. Project Root
   docker-compose.yml: Defines all the Docker services and their configurations.
   prometheus.yml: Configuration file for Prometheus to scrape metrics.
   locustfile.py: Defines performance testing scripts for Locust.
   README.md: Documentation and instructions for setting up and running the project.

2. soc-emulator/
   Dockerfile: Builds the SoC emulator image with necessary installations and configurations.
   run_benchmarks.sh: Script to execute benchmarks inside the emulator.
   automation-scripts/: automate_benchmarks.py: Automates benchmark execution and data collection.
   benchmarks/: Contains benchmark source code files like mem_test.c, cpu_test.c, etc.

3. api-backend/
   Dockerfile: Builds the API backend image.
   requirements.txt: Lists Python dependencies required by the API.
   app.py: Flask application code that handles data storage and retrieval.

4. spark-app/
   Contains Spark application code for data analysis.

5. grafana/
   provisioning/: Contains Grafana provisioning configurations.
   dashboards/: Contains dashboard provisioning configurations and JSON files.
   dashboards.yml: Configuration file that tells Grafana where to find dashboards to load automatically.
   soc_performance_dashboard.json: The JSON file defining the SoC Performance Dashboard.
   datasources/: Contains data source provisioning configurations.
   datasources.yml: Configuration file that defines the Prometheus data source.

6. Docker Volumes (Created by Docker)
   postgres_data/: Stores PostgreSQL data to persist it across container restarts.
   grafana_data/: Stores Grafana data, such as users and dashboards, unless overridden by provisioning.



# File and Directory Descriptions
## docker-compose.yml: Defines all services and their configurations.
## prometheus.yml: Configuration file for Prometheus to scrape metrics.
## locustfile.py: Defines performance testing scripts for Locust.
## README.md: Instructions and documentation for setting up and running the project.
## soc-emulator/: Contains the SoC emulator Dockerfile, benchmark scripts, and source code.
## Dockerfile: Builds the SoC emulator image with all necessary installations.
## run_benchmarks.sh: Script to execute benchmarks inside the emulator.
## benchmarks/: Directory containing benchmark source codes.
## api-backend/: Contains the API backend code and Dockerfile.
## Dockerfile: Builds the API backend image.
## requirements.txt: Lists Python dependencies.
## app.py: Flask application code.
## spark-app/: Contains Spark application code for data analysis.
## Dockerfile: Builds the Spark application image.
## data_analysis.py: Spark job script for processing data.
## automation-scripts/: Contains scripts for automating benchmarks and scheduling.
## automate_benchmarks.py: Automates benchmark execution and data collection.
## schedule_benchmarks.sh: Schedules benchmarks using cron.
## grafana/: Contains Grafana configuration and dashboard JSON files.
## provisioning/dashboards/soc_performance_dashboard.json: Predefined Grafana dashboard.



# Configuring Grafana to Automatically Import the Dashboard
  a. Grafana Provisioning Configuration - grafana/provisioning/dashboards/dashboards.yml
  b. Updating docker-compose.yml (Updated Grafana Service in docker-compose.yml)
     We need to update the docker-compose.yml file to:
     1. Mount the dashboards directory.
     2. Provide the provisioning configuration.
     3. Install the necessary plugins (if any). 

    Explanation:

    GF_PATHS_PROVISIONING: Sets the provisioning configuration directory.
    Volumes:
    ./grafana/provisioning:/etc/grafana/provisioning: Mounts the provisioning configuration.
    ./grafana/dashboards:/var/lib/grafana/dashboards: Mounts the dashboards directory where JSON files are stored.

# Configuring Data Sources via Provisioning
  We can also provision the Prometheus data source so that it's automatically configured when Grafana starts.
  a. Create Data Source Provisioning File
     Create grafana/provisioning/datasources/datasources.yml.

  b. Updating docker-compose.yml for Data Source Provisioning
     Ensure the grafana service in docker-compose.yml includes the data source provisioning directory
     Note: The volumes are already correctly set to include the provisioning directory.


# Spark application code for data analysis
  1. Implementing the spark-app/ Directory
     a. Purpose of spark-app/
        The spark-app/ directory will contain a Spark application written in Python (using PySpark) that performs data analysis on the performance data stored in PostgreSQL. The application will connect to the PostgreSQL database, read the soc_metrics table, process the data, and write the results back to the database or visualize them.

     b. Directory Structure
        soc-simulation-project/
        ├── spark-app/
        │   ├── Dockerfile
        │   ├── data_analysis.py
        │   └── requirements.txt

     c. Contents of spark-app/
        1. Dockerfile - The Dockerfile for building the Spark application image.
        2. data_analysis.py - The Spark application code for data analysis.
        3. requirements.txt - List of Python dependencies for the Spark application.
    
  2. Updating docker-compose.yml
     We need to update the docker-compose.yml file to include the Spark application service.
     Add the service definition for the spark-app

     Explanation:
     spark-app Service:
     build: Points to the spark-app/ directory.
     depends_on: Ensures that the Spark master, worker, and PostgreSQL services are up before starting the Spark application.
     environment: Sets the SPARK_MASTER_URL to connect to the Spark master.
     command: Overrides the default command to submit the Spark job.

  3. Integrating spark-app with the Project
     a. Data Flow
        Data Generation:
        The SoC emulator generates performance data and stores it in the PostgreSQL database via the API backend.

        Data Analysis:
        The spark-app reads the data from PostgreSQL using JDBC and performs data analysis.

        Results:
        The analysis results are printed to the console and can optionally be written back to PostgreSQL or stored in a file.

     b. Interactions with Other Components
        * PostgreSQL: 
          * The Spark application connects to the PostgreSQL database to read data from the soc_metrics table.

        * Spark Master and Worker:
          * The Spark application submits the job to the Spark cluster (master and workers) for distributed processing.

        * Grafana (Optional):
          * If the analysis results are written back to PostgreSQL, 
            Grafana can be configured to visualize these results by querying the soc_analysis_results table.

  4. Running the Spark Application
     a. Prerequisites 
        * if running docker-compose
          * Stop all containers and remove any unused containers, networks, images, and cache:
            docker-compose down
            docker system prune -f
            docker network prune -f

          * Install Docker Buildx:
            docker plugin install docker/buildx-plugin:latest

     b. Building and Starting Services
        From the project root directory, rebuild and start the Docker Compose services:
        * docker-compose up -d --build
        or
        * podman-compose -f docker-compose.yml up -d --build
        or if avoiding usage of BuildKit:
        * DOCKER_BUILDKIT=0 docker-compose up -d --build

        If wanting to scale spark-worker, we use the below command:
        docker-compose up -d --scale spark-worker=3 --build

        Note: The --build flag ensures that any changes to the Dockerfiles are built.

        Or
        * Using podman play kube as an Alternative:
        Since podman-compose often struggles with complex docker-compose configurations, 
         another approach is to convert your docker-compose.yml into Kubernetes YAML, which Podman can handle more effectively:

         * install kompose:
            curl -L https://github.com/kubernetes/kompose/releases/download/v1.34.0/kompose-linux-amd64 -o kompose
            sudo chmod +x /usr/bin/kompose
             sudo mv kompose /usr/local/bin/

         *  Running kompose:
            1. kompose convert  -o kubernetes.yaml
            2. Update kubernetes.yaml to refine it
            3. Convert .env Variables to Kubernetes Secrets or ConfigMaps
               * Load the .env file contents into a Kubernetes Secret or ConfigMap and reference them in your kubernetes.yaml file
                 # Assuming your .env file is named `.env`
                 kubectl create secret generic env-secrets --from-env-file=.env

                 This command will create a Secret named env-secrets with all variables defined in .env.
                 Then, you we updated the kubernetes.yaml file to reference the Secret (section 2.)
            4. This command is specific to Podman and is used to deploy a Kubernetes YAML file in a local environment without a Kubernetes cluster
               podman play kube kubernetes.yaml

         Or
         Deploy to a Kubernetes environment cluster
         * This command is used in a Kubernetes environment:
           kubectl apply -f kubernetes.yaml

     c. Verify Service Status
        docker-compose  ps  

     d. Access Services
        * Grafana: http://localhost:3001
          * Username: admin
          * Password: admin (changed to "password" after first login)
        * Prometheus: http://localhost:9090
        * API Backend: http://localhost:5000
        * PrestoSQL: http://localhost:8080
        

     c. Monitoring the Spark Application
        To view the output of the Spark application, check the logs:
        docker-compose logs -f spark-app

        Note: The -f flag streams the logs in real-time.

        Expected Output:
        spark-app_1         | CPU Usage Statistics:
        spark-app_1         | Average CPU Usage: 45.67
        spark-app_1         | Max CPU Usage: 98.0
        spark-app_1         | Min CPU Usage: 2.5
        spark-app_1         | Memory Usage Statistics:
        spark-app_1         | Average Memory Usage: 1024.0
        spark-app_1         | Max Memory Usage: 2048.0
        spark-app_1         | Min Memory Usage: 512.0

     d. Optional: Writing Results Back to PostgreSQL
        If you uncomment the code section in data_analysis.py that writes results back to PostgreSQL, 
        the Spark application will create a new table soc_analysis_results and store the analysis results there.

        * Uncomment the following code in data_analysis.py:
          # results_df = spark.createDataFrame([
              ("cpu", cpu_usage_stats['avg_cpu_usage'], cpu_usage_stats['max_cpu_usage'], cpu_usage_stats['min_cpu_usage']),
              ("memory", memory_usage_stats['avg_memory_usage'], memory_usage_stats['max_memory_usage'], memory_usage_stats['min_memory_usage'])
          ], ["metric", "average", "maximum", "minimum"])

          results_df.write.jdbc(
              url=jdbc_url,
              table="soc_analysis_results",
              mode="overwrite",
              properties=connection_properties
          )

          Note: Ensure that the database user has permissions to create tables.

     e. Visualizing Results in Grafana
        If you write the results back to PostgreSQL, you can visualize them in Grafana:   
        1. Add PostgreSQL Data Source (if not already added):
          * Navigate to Configuration > Data Sources.
          * Add a new data source and select PostgreSQL.
          * Configure it with the following settings:
            * Host: postgres:5432
            * Database: soc_data
            * User: user
            * Password: pass

        2. Create a New Dashboard:
           * Navigate to Create > Dashboard.
           * Add a new panel.

        3. Configure Panel to Query soc_analysis_results:
           * In the Query section, select the PostgreSQL data source.
           * Enter a query to retrieve analysis results, e.g.:
             SELECT
                metric,
                average,
                maximum,
                minimum
             FROM
                soc_analysis_results

           * Configure the visualization as desired (e.g., table, bar chart).

  5. Detailed Workflow with spark-app Integration
     Workflow 1: Collecting and Analyzing Performance Data

              1. Start the Environment
                 docker-compose up -d --build

              2. Generate Performance Data
                 * The SoC emulator is scheduled to run benchmarks every 30 minutes via cron
                 * You can manually trigger benchmarks:
                   docker exec -it soc-simulation-project_soc-emulator_1 bash
                   ./run_benchmarks.sh

              3. Data Ingestion
                 * The automate_benchmarks.py script collects metrics and sends them to the API backend.
                 * The API backend stores the data in the soc_metrics table in PostgreSQL.

              4. Data Analysis with Spark
                 * The spark-app service automatically runs the data_analysis.py script upon startup.
                 * It reads data from PostgreSQL, performs analysis, and prints results.

              5. Viewing Analysis Results
                 * Check the logs of the spark-app service:
                   docker-compose logs spark-app

                 * If results are written back to PostgreSQL, 
                   you can query the soc_analysis_results table or visualize the results in Grafana.

     Workflow 2: Automating Spark Job Execution 

              By default, the spark-app runs once upon startup. To automate the execution of the Spark job at regular intervals, 
              you can use a scheduler like cron or configure the application to run continuously.

              Option 1: Schedule Spark Job with Cron
               1. Modify the spark-app/Dockerfile to Install Cron
                  # Add cron installation
                  RUN install_packages cron

                  # Copy crontab file
                  COPY crontab /etc/cron.d/spark-cron
                  RUN chmod 0644 /etc/cron.d/spark-cron
                  RUN crontab /etc/cron.d/spark-cron

                  # Start cron and Spark application
                  CMD ["bash", "-c", "service cron start && tail -f /dev/null"]

               2. Create crontab File
                  Create spark-app/crontab with the following content:
                  */30 * * * * root /opt/bitnami/spark/bin/spark-submit --master spark://spark-master:7077 /app/data_analysis.py >> /var/log/spark-app.log 2>&1

                  Note: This schedules the Spark job to run every 30 minutes.

               3. Rebuild and Restart Services
                  docker-compose up -d --build

               4. Check Logs
                  docker exec -it soc-simulation-project_spark-app_1 bash
                  cat /var/log/spark-app.log

              Option 2: Use an External Scheduler
                  * Use tools like Apache Airflow or custom scripts to schedule Spark jobs.

  6. Updating the GitHub Repository
     Add the new spark-app/ directory and update existing files in your Git repository.

     Commands to Update GitHub Repository
     git add spark-app/
     git add docker-compose.yml
     git commit -m "Implemented spark-app for data analysis and updated docker-compose.yml"
     git push origin main

  7. Final Notes
     a. Dependencies
        Ensure that the spark-app has access to the necessary dependencies:
        * PySpark is included in the base image.
        * PostgreSQL JDBC Driver is required to connect to PostgreSQL.
          * Modify the spark-app/Dockerfile to download the JDBC driver:

     b. Adjustments for Compatibility
        * Driver Configuration:
          * Ensure that the org.postgresql.Driver is available in the Spark classpath.
        * Network Settings:
          * Services are connected via the soc-net network defined in docker-compose.yml

     c. Security Considerations
        * Database Credentials:
          * For production environments, secure database credentials using environment variables or secrets management tools.
        * Data Privacy:
          * Ensure compliance with data protection regulations when handling performance data.

# Conclusion
  By implementing the spark-app/ directory and integrating it into the project, 
  we've enhanced the simulation environment to include big data processing capabilities, 
  aligning with the responsibilities of a "Performance Analyst Engineer." 
  The Spark application reads performance data from PostgreSQL, performs analysis, 
  and optionally writes results back to the database for visualization.

  Key Takeaways:

  * Data Analysis Pipeline:
    The project now includes a full pipeline from data generation to analysis and visualization.

  * Integration with Existing Components:
    The Spark application interacts seamlessly with PostgreSQL and the Spark cluster.

  * Automation:
    Spark jobs can be automated to run at regular intervals, providing continuous insights.

 
   


# Misc
  * I prefare running it with podman-compose which is a python package
    * To install it under your python installation: 
      pip install podman-compose  

    * To update it: 
      pip install --upgrade podman-compose  

    * images are being fetched from quay.io or docker.io, to allow getting it automatically from quay.io, login to quay.io:
      podman login quay.io  

    * Restart Podman service if needed (updated /home/nafta/.config/cni/net.d/soc-simulation-project_soc-net.conflist file for example)
      sudo systemctl restart podman
      or
      podman system service -t 0 &


    * Validate JSON Format of /home/nafta/.config/cni/net.d/soc-simulation-project_soc-net.conflist
      cat /home/nafta/.config/cni/net.d/soc-simulation-project_soc-net.conflist | python -m json.tool


    * Stop All Docker Containers: Try stopping all Docker containers to ensure no other service is holding port 3000
      docker stop $(docker ps -q)

    * Restart Docker Service: If the port remains occupied, try restarting the Docker service, 
      which can release any lingering processes attached to that port.

      sudo systemctl restart docker




# List of services
  Based on your docker-compose.yml, the services are:

  - soc-emulator
  - prometheus
  - grafana
  - postgres
  - prestosql
  - spark-master
  - spark-worker
  - spark-app
  - api-backend
  - locust

# Testing Each Service
  1. soc-emulator
     Description: Emulates the SoC hardware using QEMU and runs benchmarks.
     
     Tests:
     a. Verify Container is Running
        docker ps | grep soc-emulator
        - Expected Result: The soc-emulator container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_soc-emulator_1
        - Expected Result: The logs should show that the QEMU emulator started successfully, and benchmarks are being executed.

     c. SSH into Emulated SoC
        ssh -p 5022 pi@localhost
        
        - Password: raspberry
        - Expected Result: You should be able to SSH into the emulated SoC environment.

     d. Verify Benchmarks Execution
        - After SSHing into the SoC:
          ls /home/pi/benchmarks
        - Expected Result: List of benchmark scripts should be present.

          Run a benchmark:
          python3 /home/pi/automate_benchmarks.py
        - Expected Result: Metrics are collected and sent to the API backend.

  2. prometheus
     Description: Monitoring system that scrapes and stores metrics.

     Tests:
     a. Verify Container is Running 
        docker ps | grep prometheus
        - Expected Result: The prometheus container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_prometheus_1
        - Expected Result: No errors; Prometheus is scraping targets as configured.

     c. Access Prometheus Web UI
        - Open a browser and navigate to http://localhost:9090
        - Expected Result: Prometheus UI should load.

     d. Verify Targets
        In the Prometheus UI, go to Status > Targets.
        - Expected Result: The targets (e.g., soc-emulator:9100) should be listed and in the "UP" state.

     e. Query Metrics
        In the Prometheus UI, execute a simple query:
        up
        - Expected Result: You should see metrics indicating that the scrape targets are up.

  3. grafana
     Description: Visualization tool for metrics and data.

     Tests:
     a. Verify Container is Running
        docker ps | grep grafana
        - Expected Result: The grafana container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_grafana_1
        - Expected Result: No errors; Grafana server started successfully.

     c. Access Grafana Web UI
        - Open a browser and navigate to http://localhost:3001.
        - Expected Result: Grafana login page should appear.

     d. Login to Grafana
        - Username: admin
        - Password: As specified in your .env file (e.g., admin)
        - Expected Result: You should be able to log in.

     e. Verify Dashboards
        Go to Dashboards and verify that the soc_performance_dashboard and soc_analysis_results_dashboard are present.
        - Expected Result: Dashboards should load and display data.

  4. postgres
     Description: PostgreSQL database for storing metrics and analysis results.

     Tests:
     a. Verify Container is Running 
        docker ps | grep postgres
        - Expected Result: The postgres container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_postgres_1
        - Expected Result: No errors; PostgreSQL server started successfully.

     c. Connect to PostgreSQL
        Use the psql client and Docker to connect:
        - Expected Result: You should get a psql prompt.

     d. List Tables
        - In the psql prompt, list the tables:
          \dt
        - Expected Result: Tables like soc_metrics and soc_analysis_results should be listed.

     e. Query Data
        - Run a simple query:
          SELECT * FROM soc_metrics LIMIT 5;
        - Expected Result: Should return recent metrics data.

  5. prestosql
     Description: Distributed SQL query engine.

     Tests:
     a. Verify Container is Running
        docker ps | grep prestosql
        - Expected Result: The prestosql container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_prestosql_1
        - Expected Result: No errors; Presto server started successfully.

     c. Access Presto CLI
        - Start a Presto CLI session:
          docker exec -it soc-simulation-project-new_prestosql_1 presto --server localhost:8080 --catalog postgresql --schema public
        - Expected Result: Presto CLI prompt appears.

     d. Run a Query
        - In the Presto CLI, run:
          SELECT * FROM soc_metrics LIMIT 5;
        - Expected Result: Returns data from the soc_metrics table.

  6. spark-master  
     Description: Master node of the Spark cluster.

     Tests:
     a. Verify Container is Running 
        docker ps | grep spark-master
        - Expected Result: The spark-master container should be listed with a status of "Up."

     b. Check Logs
        docker logs soc-simulation-project-new_spark-master_1
        - Expected Result: No errors; Spark Master started successfully.

     c. Access Spark Master Web UI
        - Open a browser and navigate to http://localhost:8081 (or the port you've mapped).
        - Expected Result: Spark Master UI should load, showing worker nodes.

   7. spark-worker
      Description: Worker node of the Spark cluster.

      Tests:
      a. Verify Container is Running
         docker ps | grep spark-worker
         Expected Result: The spark-worker container should be listed with a status of "Up."

      b. Check Logs
         docker logs soc-simulation-project-new_spark-worker_1
         - Expected Result: No errors; Spark Worker started and connected to the Master.

      c. Verify Worker Registration
         In the Spark Master Web UI (http://localhost:8081), check the Workers tab.
         - Expected Result: The worker should be listed and alive.

   8. spark-app
      Description: Spark application container that runs data analysis.

      Tests:
      a. Verify Container is Running
         docker ps | grep spark-app
         - Expected Result: The spark-app container should be listed.

      b. Check Logs
         docker logs soc-simulation-project-new_spark-app_1
         - Expected Result: Output from data_analysis.py, including any print statements and indication that the Spark job completed.

      c. Verify Analysis Results in PostgreSQL
         Connect to PostgreSQL (see Postgres tests) and run:
         SELECT * FROM soc_analysis_results;
         - Expected Result: Should display results of the data analysis.

   9. api-backend
      Description: Flask API backend that receives and stores metrics.

      Tests:
      a. Verify Container is Running
         docker ps | grep api-backend
         - Expected Result: The api-backend container should be listed with a status of "Up."

      b. Check Logs
         docker logs soc-simulation-project-new_api-backend_1
         - Expected Result: No errors; API server started and handling requests.

      c. Test API Endpoint
         - Store Metric:
           curl -X POST -H "Content-Type: application/json" \
           -d '{"cpu_usage":50,"memory_usage":512,"disk_io":1024,"config_name":"test"}' \
           http://localhost:5000/api/store_metric

         - Expected Result: JSON response {"status": "success"} and HTTP status code 200.

         - Get Metrics:
           curl -X GET http://localhost:5000/api/get_metrics
         - Expected Result: JSON array of stored metrics.

   10. locust
       Description: Performance testing tool to simulate user load on the API backend.

       Tests:
       a. Verify Container is Running
          docker ps | grep locust
          - Expected Result: The locust container should be listed with a status of "Up."

       b. Check Logs
          docker logs soc-simulation-project-new_locust_1
          - Expected Result: Logs showing that Locust is ready to receive test parameters.

       c. Access Locust Web Interface
          - Open a browser and navigate to http://localhost:8089.
          - Expected Result: Locust web interface loads.

       d. Run a Load Test
          - Set the number of users and spawn rate.
          - Start the test.
          - Expected Result: The test runs, and the interface shows statistics.  

       e. Monitor API Backend During Load Test
          - Check the logs of api-backend:
            docker logs -f soc-simulation-project-new_api-backend_1
          - Expected Result: Increased number of requests being handled.

# Additional Notes
  - Service Logs: Printing service logs is essential for debugging and verifying that services are running as expected.
  - Container Names: Docker Compose prefixes container names with the project directory and an instance number. Adjust the container names accordingly if your project 
    directory is different.
  - Network Issues: Ensure that all services are on the same Docker network (soc-net) to allow inter-service communication.
  - Port Adjustments: If you have adjusted ports in your docker-compose.yml, make sure to use the correct ports in your tests.















    


   






