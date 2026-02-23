#!/bin/bash

# Define paths
MINICONDA_DIR="$HOME/miniconda3"
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPT_SOVITS_DIR="$INSTALLER_DIR/GPT-SoVITS"

echo ">>> Starting GPT-SoVITS WebUI..."

# Check if repo exists
if [ ! -d "$GPT_SOVITS_DIR" ]; then
    echo "⚠️  Repo not found. Auto-running installer..."
    cd "$INSTALLER_DIR"
    chmod +x install.sh
    ./install.sh
    if [ ! -d "$GPT_SOVITS_DIR" ]; then
        echo "❌ Error: Installation failed."
        exit 1
    fi
fi

# Activate Conda
if [ -f "$MINICONDA_DIR/etc/profile.d/conda.sh" ]; then
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    conda activate GPTSoVits
elif [ -f "$MINICONDA_DIR/bin/activate" ]; then
    source "$MINICONDA_DIR/bin/activate" GPTSoVits
else
    echo "❌ Miniconda not found. Running installer..."
    cd "$INSTALLER_DIR"
    ./install.sh
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    conda activate GPTSoVits
fi

# Navigate and Run
cd "$GPT_SOVITS_DIR"
python webui.py
