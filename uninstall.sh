#!/bin/bash
set -e

# --- Configuration ---
PROJECT_NAME="llama-swap-service"
PLIST_LABEL=$PROJECT_NAME
LLAMA_SWAP_CONFIG_FILE="$HOME/.llama-swap.config.yml"
PLIST_DEST="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"

# --- Colors ---
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_NONE='\033[0m'

echo -e "${C_YELLOW}Uninstalling llama-swap service...${C_NONE}"

# 1. Stop and unload the service
echo "-> Stopping and unloading service at $PLIST_DEST"
launchctl unload "$PLIST_DEST" 2>/dev/null || true

# 2. Remove the service file
if [ -f "$PLIST_DEST" ]; then
    rm "$PLIST_DEST"
    echo "-> Removed service file at $PLIST_DEST"
fi

# 3. Ask to remove config and logs
if [ -f "$LLAMA_SWAP_CONFIG_FILE" ]; then
    read -p "Do you want to remove llama-swap config at $LLAMA_SWAP_CONFIG_FILE? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$LLAMA_SWAP_CONFIG_FILE"
        echo "-> Removed configuration at $LLAMA_SWAP_CONFIG_FILE"
    fi
fi

echo -e "${C_GREEN}Uninstallation complete.${C_NONE}"
