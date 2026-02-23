#!/bin/bash
set -e

echo ">>> Checking for NVIDIA Hardware..."
if lspci | grep -i nvidia; then
    echo "NVIDIA GPU detected."
else
    echo "Error: No NVIDIA GPU detected on PCIe bus."
    exit 1
fi

echo ">>> Updating Repository..."
sudo apt update

echo ">>> Installing Driver Manager..."
sudo apt install -y ubuntu-drivers-common

echo ">>> Auto-installing Recommended Drivers..."
# This command automatically finds and installs the best driver for the RTX 3060
sudo ubuntu-drivers autoinstall

echo "========================================================"
echo "SUCCESS! Drivers installed."
echo "⚠️  YOU MUST REBOOT YOUR COMPUTER NOW FOR IT TO WORK ⚠️"
echo "Please run: 'sudo reboot' manually."
echo "========================================================"
