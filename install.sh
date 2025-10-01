#!/bin/bash
set -e # Exit on any error

# --- Configuration ---
PROJECT_NAME="llama-swap-service"
PLIST_LABEL=$PROJECT_NAME
LLAMA_SWAP_CONFIG_FILE="$HOME/.llama-swap.config.yml"
PLIST_DEST="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
LLAMA_SERVER_API_KEY_FILE_PATH="$HOME/.llama_server_api_keys.txt"

# --- Colors for beautiful output ---
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_NONE='\033[0m'

echo -e "${C_YELLOW}Starting llama-swap service installation...${C_NONE}"


find_binary_path() {
    for name in "$@"; do
        if command -v "$name" &>/dev/null; then
            path_check=$(command -v "$name")
            # Ensure it's an absolute path to avoid aliases
            if [[ "$path_check" == /* ]]; then
                echo "$path_check"
            fi
        fi
    done
}


# 1. Find binaries
LLAMA_SWAP_BINARY_PATH=$(find_binary_path llama-swap llama-swap-darwin-arm64)

if [[ -z "$LLAMA_SWAP_BINARY_PATH" ]]; then
    echo -e "${C_RED}Error: 'llama-swap' executable not found in your PATH.${C_NONE}"
    echo "Please install llama-swap and ensure its location is in your PATH."
    exit 1
fi
echo "-> Found binary at: $LLAMA_SWAP_BINARY_PATH"

LLAMA_SERVER_BINARY_PATH=$(find_binary_path llama-server)

if [[ -z "$LLAMA_SERVER_BINARY_PATH" ]]; then
    echo -e "${C_RED}Error: 'llama-server' executable not found in your PATH.${C_NONE}"
    echo "Please install llama-server (llama.cpp) and ensure its location is in your PATH."
    exit 1
fi
echo "-> Found binary at: $LLAMA_SERVER_BINARY_PATH"

# 2. Create default config
if [ ! -f "$LLAMA_SWAP_CONFIG_FILE" ]; then
    echo "-> No existing config found. Creating default at $LLAMA_SWAP_CONFIG_FILE"
	config_template=$(curl -fsSL "https://raw.githubusercontent.com/huajiejin/llama-swap-service-macos/main/templates/llama-swap.config.yml")
	config_content=$(echo "$config_template" | sed \
		-e "s|__LLAMA_SERVER_API_KEY_FILE_PATH__|$LLAMA_SERVER_API_KEY_FILE_PATH|g" \
		-e "s|__LLAMA_SERVER_BINARY_PATH__|$LLAMA_SERVER_BINARY_PATH|g")
	echo "$config_content" > "$LLAMA_SWAP_CONFIG_FILE"
else
    echo "-> Using existing configuration at $LLAMA_SWAP_CONFIG_FILE"
fi

# 3. Create and install the launchd plist
echo "-> Creating and installing launchd service..."

# Fetch the plist template and substitute placeholders
plist_template=$(curl -fsSL "https://raw.githubusercontent.com/huajiejin/llama-swap-service-macos/main/templates/llama-swap-service.plist")
plist_content=$(echo "$plist_template" | sed \
    -e "s|__LLAMA_SWAP_BINARY_PATH__|$LLAMA_SWAP_BINARY_PATH|g" \
    -e "s|__LLAMA_SWAP_CONFIG_PATH__|$LLAMA_SWAP_CONFIG_FILE|g" \
    -e "s|__HOME_PATH__|$HOME|g")

echo "$plist_content" > "$PLIST_DEST"

# Unload any existing version of the service before installing a new one
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo -e "\n${C_GREEN}Success! The llama-swap service is installed and loaded.${C_NONE}"
echo "-> llama-swap should be running on http://127.0.0.1:12345"
echo "-> To check its status, run: launchctl list | grep llama-swap"
echo "-> Logs are available at:"
echo "  $HOME/.llama-swap-service.log"
echo "  $HOME/.llama-swap-service.err"
