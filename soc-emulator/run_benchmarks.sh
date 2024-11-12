#!/bin/bash

# Start QEMU in the background
qemu-system-arm \
    -kernel /qemu/kernel-qemu \
    -cpu arm1176 \
    -m 256 \
    -M versatilepb \
    -no-reboot \
    -serial stdio \
    -append "root=/dev/sda2 rootfstype=ext4 rw" \
    -hda /qemu/2019-09-26-raspbian-buster-lite.img \
    -net user,hostfwd=tcp::5022-:22 -net nic \
    -display none &

# Wait for the system to boot
echo "Waiting for the emulated SoC to boot..."
sleep 60  # Adjust as necessary

# Run benchmarks via SSH
echo "Running benchmarks inside the emulated SoC..."

# Install SSH client if not already installed
apt-get update && apt-get install -y sshpass

# Define SSH parameters
SSH_USER=pi
SSH_PASS=raspberry
SSH_HOST=localhost
SSH_PORT=5022

# Copy automate_benchmarks.py to the emulated system (already copied via setup)
# Run benchmarks inside the emulated system
sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -p $SSH_PORT $SSH_USER@$SSH_HOST "python3 /home/pi/automate_benchmarks.py"

# Collect results (if any output files are generated)
# scp -P $SSH_PORT $SSH_USER@$SSH_HOST:/path/to/results /path/to/local/destination

# Shutdown the emulated system
sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -p $SSH_PORT $SSH_USER@$SSH_HOST "sudo shutdown -h now"

# Wait for QEMU to exit
wait


# Explanation
# ===========
# Starting QEMU:

# Boots the emulated SoC with the prepared image.
# Sets up port forwarding from host port 5022 to guest port 22 for SSH access.
# Waiting for Boot:

# Waits for the system to boot before attempting to connect via SSH.
# Running Benchmarks:

# Uses sshpass to automate SSH login.
# Runs automate_benchmarks.py inside the emulated system.
# Collecting Results:

# (Optional) Use scp to copy any result files from the emulated system.
# Shutting Down:

# Sends a shutdown command to the emulated system.
# Waits for QEMU to exit.