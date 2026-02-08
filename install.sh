#!/bin/bash

sudo apt-get update && sudo apt-get install -yy zsh git

RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

./install_nvim.sh

RAW_ARCH=$(uname -m)

echo "Detected architecture: $ARCH"

# Pick correct tar.gz package
if [[ "$RAW_ARCH" == "x86_64" ]]; then
    ARCH="x86_64"
elif [[ "$RAW_ARCH" == "aarch64" ]]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.zshrc
nvm install node
npm install -g tree-sitter-cli

mkdir -p ~/.config
pushd ~/.config
git clone https://github.com/danni-m/nvim.git
popd

sudo apt-get update && sudo apt-get install -y python3-venv fd-find
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

cat xterm-ghostty.terminfo | sudo tic -x -
