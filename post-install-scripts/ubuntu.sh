#!/usr/bin/env bash

sudo apt update
sudo apt install -y git \
                    tree \
                    ranger \
                    tmux \
                    neovim \
                    fzf \
                    jq \
                    figlet

# Symlink Neovim config
if [ ! -d $HOME/.config ]; then
  echo Creating .config directory
  mkdir $HOME/.config
fi
echo Adding new Neovim config directory symlink
ln -s -f -F -h "$dotfiles/nvim" "$HOME/.config/nvim"

# Install nvm using git
git clone https://github.com/nvm-sh/nvm.git ~/.nvm
cd ~/.nvm
LATEST_NVM=$(curl --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
git checkout $LATEST_NVM
. ./nvm.sh

# Add nvm path to .extrasrc
echo 'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.extrasrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> ~/.extrasrc

# Return to HOME
cd $HOME
