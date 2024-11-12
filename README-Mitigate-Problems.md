# Mitigate problems

1. Port Conflicts: The error messages indicate that the specified ports (e.g., 5432, 9090, 8081) are already in use by other services or containers on your system.
   ( after - DOCKER_BUILDKIT=0 docker-compose -f docker-compose-new.yml up -d --build )

   ERROR: for prometheus  Cannot start service prometheus: driver failed programming external connectivity on endpoint soc-simulation-project-new_prometheus_1 (...): Bind for 0.0.0.0:9090 failed: port is already allocated
   ERROR: for postgres  Cannot start service postgres: driver failed programming external connectivity on endpoint soc-simulation-project-new_postgres_1 (...): Bind for 0.0.0.0:5432 failed: port is already allocated

   Possible Causes:
   - Another instance of the same Docker containers is running.
   - Other applications are using these ports (e.g., a local PostgreSQL server on port 5432).
   - Previous Docker containers were not stopped or removed properly.

   Commands:
   - For Linux/macOS
     - sudo lsof -i :5432
     - sudo lsof -i :9090
     - sudo lsof -i :8081
  
    sudo lsof -i :5432                                                                                                                     
    [sudo] password for nafta: 
    COMMAND       PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
    docker-pr 1024464 root    4u  IPv4 18681365      0t0  TCP *:postgresql (LISTEN)
    docker-pr 1024471 root    4u  IPv6 18694854      0t0  TCP *:postgresql (LISTEN)

    sudo lsof -i :9090                                                                                                                     
    COMMAND       PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
    docker-pr 1024530 root    4u  IPv4 18703713      0t0  TCP *:9090 (LISTEN)
    docker-pr 1024538 root    4u  IPv6 18691841      0t0  TCP *:9090 (LISTEN)

    sudo lsof -i :8081                                                                                                                     
    COMMAND       PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
    docker-pr 1024417 root    4u  IPv4 18708650      0t0  TCP *:tproxy (LISTEN)
    docker-pr 1024423 root    4u  IPv6 18684057      0t0  TCP *:tproxy (LISTEN)

 2. Stop Conflicting Processes
    - If another service is using the port (e.g., local PostgreSQL server), you can stop it:
      sudo service postgresql stop
    - If a Docker container is using the port, list running containers:
      docker ps
    - Then stop and remove the conflicting containers:
      docker stop <container_id>
      docker rm <container_id>
    - Or stop all running containers:
      docker stop $(docker ps -aq)

 3. Remove Stopped Containers and Unused Networks
    Sometimes, old Docker containers or networks can cause conflicts.

   Commands:
    - Remove all stopped containers:
      docker container prune -f

    - Remove all unused networks:
      docker network prune -f

    - Remove all dangling images:
      docker image prune -f

    - Remove all unused volumes:
      docker volume prune -f

 4. Restart Docker Desktop or Docker Service
    If the issue persists, try restarting Docker:

   - On Linux:
     sudo systemctl restart docker

 5. Rebuild and Start the Docker Compose Services
    docker-compose -f docker-compose-new.yml up -d --build


    

