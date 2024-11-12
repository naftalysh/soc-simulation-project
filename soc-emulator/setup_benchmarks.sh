#!/bin/bash

# Mount the image
mkdir /mnt/raspbian
modprobe nbd max_part=16
qemu-nbd --connect=/dev/nbd0 /qemu/2019-09-26-raspbian-buster-lite.img

# Wait for the device to be available
sleep 5

# Mount the root partition
mount /dev/nbd0p2 /mnt/raspbian

# Copy benchmarks to the image
cp -r /benchmarks /mnt/raspbian/home/pi/benchmarks
cp /automate_benchmarks.py /mnt/raspbian/home/pi/

# Set execute permissions
chmod +x /mnt/raspbian/home/pi/automate_benchmarks.py
chmod +x /mnt/raspbian/home/pi/benchmarks/*

# Unmount and disconnect
umount /mnt/raspbian
qemu-nbd --disconnect /dev/nbd0

# Explanation
# ===========
# Mounting the Image:

# Uses qemu-nbd to connect the image as a network block device.
# Mounts the root partition to access the filesystem.
# Copying Files:

# Copies benchmarks and scripts into the emulated system's filesystem.
# Cleanup:

# Unmounts the image and disconnects the network block device.