#!/usr/bin/env bash

# Add Github repo for Github cli
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
sudo apt update
sudo apt install -y git \
                    tree \
                    gh \
                    ranger \
                    tmux \
                    neovim \
                    kitty \
                    newsboat \
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

# Fetch Tmux plugin manager tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Fetch Nord dircolors
curl -o ~/.dir_colors https://raw.githubusercontent.com/arcticicestudio/nord-dircolors/develop/src/dir_colors

# Fetch Nord kitty extension
curl -o ~/.config/kitty/nord.conf https://raw.githubusercontent.com/connorholyday/nord-kitty/master/nord.conf

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
