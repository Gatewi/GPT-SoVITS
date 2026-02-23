#!/bin/bash
set -e

# Define installation directory
MINICONDA_DIR="$HOME/miniconda3"

# 1. Install Miniconda if not present
if [ -d "$MINICONDA_DIR" ]; then
    echo ">>> Miniconda already installed at $MINICONDA_DIR"
else
    echo ">>> Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p "$MINICONDA_DIR"
    rm miniconda.sh
    echo ">>> Miniconda installed."
fi

# 2. Initialize Conda for shell interaction
eval "$($MINICONDA_DIR/bin/conda shell.bash hook)"

# 3. Create Environment
echo ">>> Creating 'GPTSoVits' environment (Python 3.10)..."

# 3.1 Accept Terms of Service (To avoid CondaToSNonInteractiveError)
# We attempt to accept the TOS for the main channels. 
# This command might fail on older conda versions, so we use || true
if command -v conda &> /dev/null; then
    echo ">>> Accepting Anaconda Terms of Service..."
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true
fi

# 3.2 checking if env exists to avoid error
if conda info --envs | grep -q "GPTSoVits"; then
    echo "Environment 'GPTSoVits' already exists."
else
    # We use --yes and -c conda-forge as a secondary option if main fails
    conda create -n GPTSoVits python=3.10 -y
fi

echo ">>> Environment setup complete."
