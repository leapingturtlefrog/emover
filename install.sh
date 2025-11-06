#!/usr/bin/env bash
set -euo pipefail
REPO="leapingturtlefrog/emover"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$OS-$ARCH" in
    linux-x86_64) BIN="emover-linux-x64";;
    linux-aarch64) BIN="emover-linux-arm64";;
    darwin-x86_64) BIN="emover-macos-x64";;
    darwin-arm64) BIN="emover-macos-arm64";;
    *) echo "Unsupported: $OS-$ARCH"; exit 1;;
esac
[[ "$EUID" -eq 0 ]] && DIR="/usr/local/bin" || DIR="$HOME/.local/bin"
echo "Installing emover to $DIR..."
mkdir -p "$DIR"
URL="https://github.com/$REPO/releases/latest/download/$BIN"
if command -v curl &>/dev/null; then
    curl -fsSL "$URL" -o "$DIR/emover"
elif command -v wget &>/dev/null; then
    wget -q "$URL" -O "$DIR/emover"
else
    echo "Error: curl or wget required"; exit 1
fi
chmod +x "$DIR/emover"
echo "Installed! Run: emover --help"
[[ ":$PATH:" != *":$DIR:"* ]] && echo "Add to PATH: export PATH=\"\$PATH:$DIR\""
