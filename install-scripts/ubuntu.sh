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
                    fzf \
                    jq \
                    figlet \
                    stow

# Fetch Tmux plugin manager tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install linuxbrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Oh My Posh
brew tap jandedobbeleer/oh-my-posh

# Install newer version of Neovim, than the one from apt, and vivid.
brew install neovim \
             vivid \
             oh-my-posh \
             git \
             ripgrep
