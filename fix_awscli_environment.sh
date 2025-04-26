#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# 1. Install pipx if not already installed
# pipx is recommended for safe Python CLI tool installation
if ! command -v pipx &> /dev/null; then
    echo "[INFO] pipx not found. Installing pipx using apt."
    sudo apt update
    sudo apt install -y pipx
    pipx ensurepath
else
    echo "[INFO] pipx is already installed."
fi

# 2. Ensure pipx path is properly added to PATH environment variable
# This is critical for CLI tools like awscli to be discoverable by the shell
pipx ensurepath

# 3. Dynamically check if ~/.local/bin is in PATH, if not, add it
# This mitigates Snap confinement issues or misconfigured shells
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "[INFO] Adding ~/.local/bin to PATH temporarily."
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "[INFO] ~/.local/bin permanently added to ~/.bashrc."
else
    echo "[INFO] ~/.local/bin already present in PATH."
fi

# 4. Check if awscli is installed through pipx
# This avoids redundant installations
if ! pipx list | grep -q 'awscli'; then
    echo "[INFO] awscli not found in pipx. Installing awscli."
    pipx install awscli
else
    echo "[INFO] awscli already installed via pipx."
fi

# 5. Validate that 'aws' command is available
# 'awscli' package provides 'aws' binary, not 'awscli'
if command -v aws &> /dev/null; then
    echo "[SUCCESS] AWS CLI found."
    aws --version
else
    echo "[ERROR] AWS CLI binary not found in PATH."
    echo "Please restart your shell manually or source your ~/.bashrc file:"
    echo "    source ~/.bashrc"
    exit 1
fi

echo "[DONE] AWS CLI environment setup completed successfully."