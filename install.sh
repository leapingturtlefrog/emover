#!/usr/bin/env bash

# Emover Installation Script

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine installation directory
if [[ "$EUID" -eq 0 ]]; then
    # Running as root, install system-wide
    INSTALL_DIR="/usr/local/bin"
else
    # Not root, install to user directory
    INSTALL_DIR="$HOME/.local/bin"
fi

echo "🧹 Emover Installation"
echo ""
echo "Installation directory: $INSTALL_DIR"
echo ""

# Create installation directory if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if emover script exists
if [[ ! -f "$SCRIPT_DIR/emover" ]]; then
    echo -e "${RED}✗ Error: emover script not found in $SCRIPT_DIR${NC}"
    exit 1
fi

echo "Installing emover..."

# Copy the script
if cp "$SCRIPT_DIR/emover" "$INSTALL_DIR/emover"; then
    chmod +x "$INSTALL_DIR/emover"
    echo -e "${GREEN}✓ Successfully installed emover to $INSTALL_DIR${NC}"
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Warning: $INSTALL_DIR is not in your PATH${NC}"
    echo ""
    echo "Add it to your PATH by adding this line to your shell config:"
    echo ""
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
    echo ""

    # Detect shell and suggest appropriate config file
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "For Bash, add it to ~/.bashrc or ~/.bash_profile"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "For Zsh, add it to ~/.zshrc"
    fi
else
    echo ""
    echo "You can now run: emover --help"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
