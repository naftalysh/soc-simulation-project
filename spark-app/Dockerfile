# Stage 1: Build dependencies and application code
FROM python:3.9-slim AS builder

# Set working directory
WORKDIR /app

# Install necessary tools and dependencies
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Copy application code and scripts
COPY data_analysis.py test_cpu_usage.py requirements.txt entrypoint.sh /app/

# Set executable permission on entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Download PostgreSQL JDBC driver
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.23.jar -P /app/jars/

# Stage 2: Create the final image
FROM bitnami/spark:latest

# Switch to root user to modify files and permissions
USER root

# Create a new user 'sparkuser' with UID 1001 and home directory /home/sparkuser
RUN useradd -m -u 1001 sparkuser

# Set the HOME environment variable
ENV HOME=/home/sparkuser

# Copy dependencies and application code from the builder stage
COPY --from=builder /app /app
COPY --from=builder /app/jars/postgresql-42.2.23.jar /opt/bitnami/spark/jars/

# Set working directory
WORKDIR /app

# Set Spark master URL
ENV SPARK_MASTER_URL=spark://spark-master:7077

# Change ownership of /app and /home/sparkuser to 'sparkuser'
RUN chown -R sparkuser:sparkuser /app /home/sparkuser

# Switch to non-root user
USER sparkuser

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

