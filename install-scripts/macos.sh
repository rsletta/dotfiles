#!/usr/bin/env bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval $(/bin/brew shellenv)

brew tap jandedobbeleer/oh-my-posh

# Install applications
brew install bash \
             coreutils \
             git \
             tree \
             gh \
             ranger \
             tmux \
             neovim \
             fzf \
             jq \
             figlet \
             vivid \
             oh-my-posh

# Fetch Tmux plugin manager tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
