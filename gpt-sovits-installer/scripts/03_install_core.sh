#!/bin/bash
set -e

# Load Conda
MINICONDA_DIR="$HOME/miniconda3"
eval "$($MINICONDA_DIR/bin/conda shell.bash hook)"
conda activate GPTSoVits

# Ensure we are in the installer root
INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$INSTALLER_ROOT"

echo ">>> Current Directory: $(pwd)"
echo ">>> Cloning GPT-SoVITS Repository..."

if [ -d "GPT-SoVITS" ]; then
    echo "✅ Directory 'GPT-SoVITS' already exists. Pulling latest changes..."
    cd GPT-SoVITS && git pull && cd ..
else
    echo ">>> Running: git clone https://github.com/RVC-Boss/GPT-SoVITS.git"
    git clone https://github.com/RVC-Boss/GPT-SoVITS.git
fi

# Verify if clone really worked
if [ ! -d "GPT-SoVITS" ]; then
    echo "❌ ERROR: 'git clone' executed but folder 'GPT-SoVITS' is missing!"
    echo "Check if 'git' is installed: $(command -v git)"
    exit 1
fi

echo "✅ Directory verified: $(pwd)/GPT-SoVITS"
cd GPT-SoVITS

echo ">>> Installing Python Requirements..."
# Note: For automated setups, using pip directly is often safer than interactive install scripts.
# We trust the requirements.txt provided by the repo.
pip install -r requirements.txt

# Additional dependencies for Fine-tuning not in requirements.txt (if any)
# Usually requirements.txt covers it, but we add safe guards.
pip install huggingface_hub

echo ">>> Core installation complete."
