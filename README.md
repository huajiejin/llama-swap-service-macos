# llama-swap Service for macOS

A simple installer to run `llama-swap` as a reliable, auto-starting background service on macOS.

This script configures `launchd` to automatically start `llama-swap` on system boot or user login.

### Installation

Run the following command in your terminal. It will download and execute the installation script.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/huajiejin/llama-swap-service-macos/main/install.sh)"
```

### Prerequisites

- **`llama-swap` & `llama-server`:** The `llama-swap` (or `llama-swap-darwin-arm64`) and `llama-server` executables must be installed and available in your shell's `PATH`. If you don't have them, you can install them using the script in the [ggml-tools-installer repository](https://github.com/huajiejin/ggml-tools-installer).

### What the Installer Does

1. **Creates Config:** Places a default configuration file at `~/.llama-swap.config.yml` if one doesn't already exist.
2. **Sets up Service:** Creates and loads a `launchd` service file at `~/Library/LaunchAgents/llama-swap-service.plist`.

### Managing the Service

- **Check Status:**
    ```bash
    launchctl list | grep llama-swap
    ```
- **Start/Stop Manually:**
    ```bash
    # Stop the service
    launchctl unload ~/Library/LaunchAgents/llama-swap-service.plist

    # Start the service
    launchctl load ~/Library/LaunchAgents/llama-swap-service.plist
    ```
- **View logs:**
	```bash
	tail -f ~/.llama-swap-service.*
	```

### Uninstallation

To remove the service and associated files, you can run the uninstaller script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/huajiejin/llama-swap-service-macos/main/uninstall.sh)"
```
