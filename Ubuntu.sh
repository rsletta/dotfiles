#!/usr/bin/env bash

# Bootstrap Ubuntu environment

# Update system
sudo apt update
sudo apt upgrade -y

# Install software
sudo apt install -y neovim \
                    tmux \
                    mosh

# Set tmux config
ln -sf "$PWD"/configs/.tmux.conf ~/.tmux.conf

# Set vim config
ln -sf "$PWD"/configs/.vimrc ~/.vimrc
if [ ! -d ~/.config]; then
 mkdir ~/.config
fi
ln -sf "$PWD"/configs/nvim ~/.config/nvim                    

# Install NVM
echo "Installing NVM"
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

# Reload config
source ~/.bashrc;

# Add SAP NPM registry
npm config set @sap:registry https://npm.sap.com

# Install global nodeJS tools
npm install -g typescript yo eslint @ui5/cli @angular/cli @sap/cds @sap/generator-cds