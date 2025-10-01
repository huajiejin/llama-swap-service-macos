#!/bin/bash
set -e

# --- Configuration ---
PROJECT_NAME="llama-swap-service"
PLIST_LABEL=$PROJECT_NAME
CONFIG_FILE="$HOME/.llama-swap.config.yml"
PLIST_DEST="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"

# --- Colors ---
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'
C_NONE='\033[0m'

echo -e "${C_YELLOW}Uninstalling llama-swap service...${C_NONE}"

# 1. Stop and unload the service
echo "-> Stopping and unloading service..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true

# 2. Remove the service file
if [ -f "$PLIST_DEST" ]; then
    rm "$PLIST_DEST"
    echo "-> Removed service file."
fi

# 3. Ask to remove config and logs
if [ -f "$CONFIG_FILE" ]; then
    read -p "Do you want to remove llama-swap config? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$CONFIG_FILE"
        echo "-> Removed configuration."
    fi
fi

echo -e "${C_RED}Uninstallation complete.${C_NONE}"
