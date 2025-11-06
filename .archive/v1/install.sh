#!/usr/bin/env bash

# Emover Installation Script

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

GITHUB_RAW_URL="https://raw.githubusercontent.com/leapingturtlefrog/emover/main/emover"

# Determine installation directory
if [[ "$EUID" -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
fi

echo "Emover Installation"
echo ""
echo "Installation directory: $INSTALL_DIR"
echo ""

# Create installation directory if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

echo "Installing emover..."

# Check if we have the script locally (for local installs)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
else
    SCRIPT_DIR=""
fi

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/emover" ]]; then
    # Local installation
    cp "$SCRIPT_DIR/emover" "$INSTALL_DIR/emover"
    echo "Installed from local directory"
else
    # Download from GitHub
    echo "Downloading from GitHub..."
    if command -v curl &> /dev/null; then
        curl -fsSL "$GITHUB_RAW_URL" -o "$INSTALL_DIR/emover"
    elif command -v wget &> /dev/null; then
        wget -q "$GITHUB_RAW_URL" -O "$INSTALL_DIR/emover"
    else
        echo -e "${RED}✗ Neither curl nor wget found. Please install one of them.${NC}"
        exit 1
    fi
fi

if [[ -f "$INSTALL_DIR/emover" ]]; then
    chmod +x "$INSTALL_DIR/emover"
    echo -e "${GREEN}✓ Successfully installed emover to $INSTALL_DIR${NC}"
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠ Warning: $INSTALL_DIR is not in your PATH${NC}"
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
