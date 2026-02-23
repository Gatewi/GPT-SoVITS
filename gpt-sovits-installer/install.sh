#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GPT-SoVITS Automated Installer ===${NC}"
echo -e "${YELLOW}Target: Ubuntu Server (Generic)${NC}"
echo "----------------------------------------"

# Check for command line argument
if [ "$1" == "lite" ]; then
    INSTALL_MODE="Lite"
elif [ "$1" == "full" ]; then
    INSTALL_MODE="Full"
else
    # Interactive selection if no valid argument provided
    echo -e "Choose installation mode:"
    echo -e "  1. ${GREEN}Lite${NC} (TTS API only - Faster, saves ~6GB)"
    echo -e "  2. ${GREEN}Full${NC} (TTS + Fine-tuning for Vietnamese support)"
    read -p "Enter Choice [1 or 2, default 2]: " choice

    if [ "$choice" == "1" ]; then
        INSTALL_MODE="Lite"
    else
        INSTALL_MODE="Full"
    fi
fi

echo -e "${GREEN}Mode selected: $INSTALL_MODE${NC}"
echo "----------------------------------------"

# Function to run scripts
run_script() {
    script_path=$1
    shift
    args=$@
    
    echo -e "\n${GREEN}>> Running: ${script_path} ${args}...${NC}"
    
    chmod +x "$script_path"
    bash "$script_path" $args
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}>> ${script_path} COMPLETED.${NC}"
    else
        echo -e "${RED}>> ${script_path} FAILED!${NC}"
        exit 1
    fi
}

# 1. System Dependencies
run_script "./scripts/01_system_deps.sh"

# Check GPU Driver *after* deps but before heavy install
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${YELLOW}WARNING: NVIDIA Drivers not detected!${NC}"
    echo -e "${YELLOW}If you have an RTX 3060, you MUST install drivers and reboot.${NC}"
    echo -e "${YELLOW}You can run: 'bash scripts/install_gpu_drivers.sh'${NC}"
    echo -e "${YELLOW}The installation will proceed (CPU mode fallback), but inference will be slow.${NC}"
    echo "Waiting 5 seconds..."
    sleep 5
fi

# 2. Conda Environment
run_script "./scripts/02_conda_env.sh"

# 3. Core Installation (Repo + Requirements)
run_script "./scripts/03_install_core.sh"

# 4. Model Downloads
run_script "./scripts/04_models.sh" "$INSTALL_MODE"

echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}   INSTALLATION SUCCESSFUL!  ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "To start the WebUI for Fine-tuning:"
echo -e "  chmod +x run_webui.sh"
echo -e "  ./run_webui.sh"
echo -e ""
echo -e "To start the API:"
echo -e "  chmod +x run_api.sh"
echo -e "  ./run_api.sh"
echo -e "==========================================="
