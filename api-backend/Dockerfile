# 
# Dockerfile for API Backend
# 

# Base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Start the application
CMD ["python", "app.py"]
