#!/bin/bash
set -e

echo ">>> Installing System Dependencies..."
# Update package list
sudo apt-get update

# Install required packages
# ffmpeg: Audio processing
# libsox-dev: Audio library
# build-essential: Compilers (gcc, etc.)
# git, curl, wget: Utilities
sudo apt-get install -y ffmpeg libsox-dev build-essential git curl wget

echo ">>> Checking NVIDIA Drivers..."
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA Drivers detected:"
    nvidia-smi
else
    echo "WARNING: 'nvidia-smi' not found. GPU functionality might not work."
    echo "If you have an NVIDIA GPU, please install drivers:"
    echo "  sudo apt install ubuntu-drivers-common"
    echo "  sudo ubuntu-drivers autoinstall"
fi
