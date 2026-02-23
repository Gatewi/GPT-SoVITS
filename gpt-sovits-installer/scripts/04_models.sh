#!/bin/bash
set -e

# Load Conda and activate env
MINICONDA_DIR="$HOME/miniconda3"
eval "$($MINICONDA_DIR/bin/conda shell.bash hook)"
conda activate GPTSoVits

# Ensure we are in the correct directory (assumes running from root of installer or GPT-SoVITS is in ..)
INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$INSTALLER_ROOT/.."

if [ ! -d "GPT-SoVITS" ]; then
    echo "Error: GPT-SoVITS directory not found. Please run 03_install_core.sh first."
    exit 1
fi

cd GPT-SoVITS

# Ensure huggingface_hub is installed
pip install huggingface_hub

INSTALL_MODE=$1
echo ">>> Installation Mode: ${INSTALL_MODE:-Full}"

echo ">>> Creating Model Directories..."
mkdir -p GPT_SoVITS/pretrained_models
mkdir -p tools/uvr5/uvr5_weights
mkdir -p tools/asr/models

echo ">>> Downloading V3 Models (TTS)..."
wget -q --show-progress -O GPT_SoVITS/pretrained_models/s1v3.ckpt "https://huggingface.co/lj1995/GPT-SoVITS/resolve/main/s1v3.ckpt"
wget -q --show-progress -O GPT_SoVITS/pretrained_models/s2Gv3.pth "https://huggingface.co/lj1995/GPT-SoVITS/resolve/main/s2Gv3.pth"

echo ">>> Downloading V4 Models (TTS)..."
mkdir -p GPT_SoVITS/pretrained_models/gsv-v4-pretrained
wget -q --show-progress -O GPT_SoVITS/pretrained_models/gsv-v4-pretrained/s2Gv4.pth "https://huggingface.co/lj1995/GPT-SoVITS/resolve/main/gsv-v4-pretrained/s2Gv4.pth"

echo ">>> Downloading Vocoder (BigVGAN)..."
huggingface-cli download nvidia/bigvgan_v2_24khz_100band_256x --local-dir GPT_SoVITS/pretrained_models/models--nvidia--bigvgan_v2_24khz_100band_256x

echo ">>> Downloading Base Huberts & Robertas..."
huggingface-cli download lj1995/GPT-SoVITS --include "chinese-roberta-wwm-ext-large/*" --local-dir GPT_SoVITS/pretrained_models
huggingface-cli download lj1995/GPT-SoVITS --include "chinese-hubert-base/*" --local-dir GPT_SoVITS/pretrained_models
huggingface-cli download lj1995/GPT-SoVITS --include "fast_langdetect/*" --local-dir GPT_SoVITS/pretrained_models

if [ "$INSTALL_MODE" == "Full" ]; then
    echo ">>> Downloading Fine-tuning Models (ASR & UVR5)..."
    # UVR5 models for audio separation
    huggingface-cli download Delik/uvr5_weights --include "HP2_all_vocals.pth" --local-dir tools/uvr5/uvr5_weights
    huggingface-cli download Delik/uvr5_weights --include "VR-DeEchoAggressive.pth" --local-dir tools/uvr5/uvr5_weights
    
    # ASR (Faster Whisper Large V3) for auto-labeling
    huggingface-cli download Systran/faster-whisper-large-v3 --local-dir tools/asr/models/faster-whisper-large-v3
else
    echo ">>> Skipping Fine-tuning Models (Lite Mode)."
fi

echo ">>> All Models Downloaded Successfully."
