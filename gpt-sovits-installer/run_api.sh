#!/bin/bash

# Define paths
MINICONDA_DIR="$HOME/miniconda3"
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPT_SOVITS_DIR="$INSTALLER_DIR/GPT-SoVITS"

echo ">>> Starting GPT-SoVITS API..."

# Check if repo exists
if [ ! -d "$GPT_SOVITS_DIR" ]; then
    echo "⚠️  Repo not found ($GPT_SOVITS_DIR). It seems installation was skipped or failed."
    echo ">>> Launching installer (install.sh) now..."
    cd "$INSTALLER_DIR"
    chmod +x install.sh
    ./install.sh
    # Re-check
    if [ ! -d "$GPT_SOVITS_DIR" ]; then
        echo "❌ Critical Error: Installation failed to create directory. Check logs."
        exit 1
    fi
fi

# Determine how to activate Conda
if [ -f "$MINICONDA_DIR/etc/profile.d/conda.sh" ]; then
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    conda activate GPTSoVits
elif [ -f "$MINICONDA_DIR/bin/activate" ]; then
    source "$MINICONDA_DIR/bin/activate" GPTSoVits
else
    echo "❌ Miniconda not found at $MINICONDA_DIR."
    echo ">>> Running installer..."
    cd "$INSTALLER_DIR"
    ./install.sh
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"
    conda activate GPTSoVits
fi

# Navigate and Run
cd "$GPT_SOVITS_DIR"

if [ ! -f "api_v2.py" ]; then
  echo "⚠️  api_v2.py not found. Maybe the clone failed? Pulling again..."
  git pull
fi

echo ">> Running API..."
mkdir -p configs

# Create or overwrite configs/s2.json to ensure correct V3 paths
echo ">>> Generating default configs/s2.json for V3 models..."
cat <<EOF > configs/s2.json
{
  "custom": {
    "device": "cpu",
    "is_half": false,
    "version": "v2",
    "t2s_weights_path": "GPT_SoVITS/pretrained_models/s1v3.ckpt",
    "vits_weights_path": "GPT_SoVITS/pretrained_models/s2Gv3.pth",
    "bert_base_path": "GPT_SoVITS/pretrained_models/chinese-roberta-wwm-ext-large",
    "cnhuhbert_base_path": "GPT_SoVITS/pretrained_models/chinese-hubert-base"
  }
}
EOF

python api_v2.py -a 0.0.0.0 -p 9880 -c configs/s2.json
