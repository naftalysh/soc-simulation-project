#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Run setup_benchmarks.sh to prepare the emulated SoC
/setup_benchmarks.sh

# Start cron service
service cron start

# Start Prometheus Node Exporter
/usr/local/bin/node_exporter
