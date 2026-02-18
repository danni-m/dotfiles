#!/bin/bash

sudo apt-get update && sudo apt-get install -yy zsh git python3

RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

./install_nvim.sh

RAW_ARCH=$(uname -m)

echo "Detected architecture: $RAW_ARCH"

# Pick correct tar.gz package
if [[ "$RAW_ARCH" == "x86_64" ]]; then
    ARCH="x86_64"
    GOARCH="amd64"
elif [[ "$RAW_ARCH" == "aarch64" ]]; then
    ARCH="arm64"
    GOARCH="arm64"
else
    echo "Unsupported architecture: $RAW_ARCH"
    exit 1
fi

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'].lstrip('v'))")
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install node
npm install -g tree-sitter-cli

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
git -C "$DOTFILES_DIR" submodule init
git -C "$DOTFILES_DIR" submodule update

sudo mkdir -p ~/.config
sudo chown "$(id -u):$(id -g)" ~/.config
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim

sudo apt-get update && sudo apt-get install -y python3-venv fd-find
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Install Go
GO_VERSION=$(curl -s https://go.dev/dl/?mode=json | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['version'].lstrip('go'))")
if [[ -z "$GO_VERSION" ]]; then
    echo "Failed to determine Go version"
    exit 1
fi
curl -Lo go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz
# Add Go to PATH for all shells
echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' >> ~/.zshrc

cat xterm-ghostty.terminfo | sudo tic -x -
