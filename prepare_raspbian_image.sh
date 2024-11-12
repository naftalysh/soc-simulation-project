#!/bin/bash

# prepare_raspbian_image.sh
# This script automates the download and preparation of the Raspbian Lite image
# for use with the soc-emulator Docker service.

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Constants
IMAGE_URL="https://downloads.raspberrypi.org/raspbian_lite_latest"
IMAGE_ZIP="raspbian_lite_latest.zip"
EXTRACTED_IMG_PREFIX="raspbian-buster-lite"
RENAMED_IMG="raspbian-lite.img"
MOUNT_POINT="/mnt/raspbian"
NBD_DEVICE="/dev/nbd0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Functions
function check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Error: Required command '$1' not found. Aborting."; exit 1; }
}

function download_image() {
    if [ -f "$IMAGE_ZIP" ]; then
        echo "Image zip file already exists: $IMAGE_ZIP"
    else
        echo "Downloading Raspbian Lite image..."
        wget "$IMAGE_URL" -O "$IMAGE_ZIP"
    fi
}

function extract_image() {
    if [ -f "$EXTRACTED_IMG_PREFIX.img" ]; then
        echo "Image already extracted: $EXTRACTED_IMG_PREFIX.img"
    else
        echo "Extracting Raspbian Lite image..."
        unzip "$IMAGE_ZIP"
    fi
}

function rename_image() {
    if [ -f "$RENAMED_IMG" ]; then
        echo "Renamed image already exists: $RENAMED_IMG"
    else
        IMG_FILE=$(ls *.img | grep "$EXTRACTED_IMG_PREFIX")
        if [ -z "$IMG_FILE" ]; then
            echo "Error: Extracted image file not found."
            exit 1
        fi
        echo "Renaming $IMG_FILE to $RENAMED_IMG..."
        mv "$IMG_FILE" "$RENAMED_IMG"
    fi
}

function load_nbd_module() {
    echo "Loading nbd kernel module..."
    sudo modprobe nbd max_part=16
}

function connect_nbd() {
    echo "Connecting $RENAMED_IMG to $NBD_DEVICE..."
    sudo qemu-nbd --connect="$NBD_DEVICE" "$RENAMED_IMG"
}

function disconnect_nbd() {
    echo "Disconnecting $NBD_DEVICE..."
    sudo qemu-nbd --disconnect "$NBD_DEVICE" || echo "Warning: Failed to disconnect $NBD_DEVICE"
}

function mount_image() {
    echo "Mounting partition 2 to $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount "${NBD_DEVICE}p2" "$MOUNT_POINT"
}

function unmount_image() {
    echo "Unmounting $MOUNT_POINT..."
    sudo umount "$MOUNT_POINT" || echo "Warning: Failed to unmount $MOUNT_POINT"
}

function enable_ssh() {
    echo "Enabling SSH access..."
    sudo touch "$MOUNT_POINT/boot/ssh"
}

function copy_benchmarks() {
    echo "Copying benchmark scripts to the image..."
    BENCHMARKS_SRC="$PROJECT_ROOT/soc-emulator/benchmarks"
    BENCHMARKS_DEST="$MOUNT_POINT/home/pi/benchmarks"
    AUTOMATE_SCRIPT_SRC="$PROJECT_ROOT/soc-emulator/automation-scripts/automate_benchmarks.py"
    AUTOMATE_SCRIPT_DEST="$MOUNT_POINT/home/pi/automate_benchmarks.py"
    
    sudo mkdir -p "$BENCHMARKS_DEST"
    sudo cp -r "$BENCHMARKS_SRC/"* "$BENCHMARKS_DEST/"
    sudo cp "$AUTOMATE_SCRIPT_SRC" "$AUTOMATE_SCRIPT_DEST"
}

function set_permissions() {
    echo "Setting executable permissions on scripts..."
    sudo chmod +x "$MOUNT_POINT/home/pi/benchmarks/"*
    sudo chmod +x "$MOUNT_POINT/home/pi/automate_benchmarks.py"
}

function cleanup() {
    echo "Cleaning up..."
    disconnect_nbd
    sudo rm -rf "$MOUNT_POINT"
}

# Main Script Execution
echo "Starting Raspbian Lite image preparation..."

# Check for required commands
REQUIRED_COMMANDS=("wget" "unzip" "qemu-img" "qemu-nbd" "sshpass" "chmod" "cp" "mv" "mkdir" "rm" "modprobe" "mount" "umount")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    check_command "$cmd"
done

# Download the image
download_image

# Extract the image
extract_image

# Rename the image
rename_image

# Load nbd module
load_nbd_module

# Connect nbd
connect_nbd

# Mount the image
mount_image

# Enable SSH
enable_ssh

# Copy benchmark scripts
copy_benchmarks

# Set executable permissions
set_permissions

# Unmount the image and disconnect nbd
cleanup

echo "Raspbian Lite image preparation completed successfully."
