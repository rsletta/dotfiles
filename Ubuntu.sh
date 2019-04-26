#!/usr/bin/env bash

# Bootstrap Ubuntu environment

# Update system
sudo apt update
sudo apt upgrade

# Install software
sudo apt install -y neovim \
                    tmux \
                    mosh