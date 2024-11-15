#!/bin/bash

set -e

# Mount the image
mkdir -p /mnt/raspbian_root
mkdir -p /mnt/raspbian_boot
modprobe nbd max_part=16

# Connect the image using the --raw flag
qemu-nbd --connect=/dev/nbd0 --format=raw /qemu/raspbian-lite.img

# Wait for the device to be available
sleep 5

# Inform the kernel of the partition table
partprobe /dev/nbd0

# Mount the partitions
mount /dev/nbd0p2 /mnt/raspbian_root
mount /dev/nbd0p1 /mnt/raspbian_boot

# Enable SSH by creating an empty 'ssh' file in the boot partition
touch /mnt/raspbian_boot/ssh

# Copy benchmarks to the image
cp -r /benchmarks /mnt/raspbian_root/home/pi/benchmarks
cp /automate_benchmarks.py /mnt/raspbian_root/home/pi/

# Set execute permissions
chmod +x /mnt/raspbian_root/home/pi/automate_benchmarks.py
chmod +x /mnt/raspbian_root/home/pi/benchmarks/*

# Unmount and disconnect
umount /mnt/raspbian_boot
umount /mnt/raspbian_root
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