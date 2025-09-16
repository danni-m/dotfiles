#!/usr/bin/env bash

# Exit if a command fails
set -e

# Detect system architecture
ARCH=$(uname -m)

echo "Detected architecture: $ARCH"

# Pick correct tar.gz package
if [[ "$ARCH" == "x86_64" ]]; then
    URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    DIRNAME="nvim-linux-x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
    DIRNAME="nvim-linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download tarball
echo "Downloading Neovim from $URL ..."
curl -LO "$URL"

# Extract filename
FILENAME=$(basename "$URL")

# Remove any existing installation
echo "Removing old Neovim installation..."
sudo rm -rf /opt/"$DIRNAME"

# Extract into /opt
echo "Extracting $FILENAME to /opt..."
sudo tar -C /opt -xzf "$FILENAME"

# Symlink to /usr/local/bin
echo "Linking /opt/$DIRNAME/bin/nvim -> /usr/local/bin/nvim"
sudo ln -sf /opt/"$DIRNAME"/bin/nvim /usr/local/bin/nvim

# Verify installation
echo "Neovim installed successfully!"
nvim --version
