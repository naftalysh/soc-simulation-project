# Base image
FROM ubuntu:20.04

# Set non-interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    qemu-system-arm \
    qemu-utils \
    gcc \
    libcurl4-openssl-dev \
    make \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    stress-ng \
    sysbench \
    cron \
    unzip \
    sshpass \
    iputils-ping \
    kmod \  
    sysstat \
    # Ensure modprobe is available
    && rm -rf /var/lib/apt/lists/*
 
# Install Prometheus Node Exporter
RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz && \
    tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz && \
    mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/ && \
    rm -rf node_exporter-1.3.1.linux-amd64*

# Set working directory
WORKDIR /qemu

# Download kernel image for ARM
RUN wget https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.19.50-buster -O kernel-qemu

# Download Raspberry Pi OS Lite image
RUN wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip && \
    unzip raspbian_lite_latest.zip && \
    rm raspbian_lite_latest.zip && \
    IMG_FILE=$(ls *.img) && \
    echo "Extracted image file: $IMG_FILE" && \
    mv "$IMG_FILE" raspbian-lite.img

# Resize the image (optional, for more space)
RUN qemu-img resize -f raw raspbian-lite.img +1G

# Copy benchmark scripts
COPY benchmarks /benchmarks

# Copy setup script
COPY setup_benchmarks.sh /setup_benchmarks.sh
RUN chmod +x /setup_benchmarks.sh

# Copy automation scripts
COPY automation-scripts/automate_benchmarks.py /automate_benchmarks.py
RUN chmod +x /automate_benchmarks.py

# Copy all C benchmark files to the /benchmarks directory in the container
# Currently having only disk_test.c
COPY benchmarks/*.c /benchmarks/

# Compile all C programs in the /benchmarks directory using Optimization Flags
RUN for file in /benchmarks/*.c; do \
        gcc -O2 -o "/benchmarks/$(basename "$file" .c)" "$file"; \
    done

# Install Python dependencies
RUN pip3 install psutil requests

# Copy run_benchmarks.sh
COPY run_benchmarks.sh /run_benchmarks.sh
RUN chmod +x /run_benchmarks.sh

# Copy start.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set up cron job for benchmarks
RUN echo "*/30 * * * * root /run_benchmarks.sh >> /var/log/benchmarks.log 2>&1" > /etc/cron.d/benchmarks
RUN chmod 0644 /etc/cron.d/benchmarks

# Expose Prometheus metrics port
EXPOSE 9100

# Start services
CMD ["/start.sh"]


# Explanation
# ===========
# QEMU Setup:

# Installed qemu-system-arm and qemu-utils for ARM emulation and disk image manipulation.
# Downloaded an ARM kernel and Raspberry Pi OS Lite image for emulation.
# Benchmarks and Scripts:

# Copied benchmark scripts into the image.
# Added a setup_benchmarks.sh script to prepare the emulated environment.
# Python Dependencies:

# Installed required Python packages for metric collection.