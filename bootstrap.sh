#!/usr/bin/env bash

# Print figlet of section headers
heading () {
  figlet $@
}

# Symlink dotfiles
heading symbolic links
ln -sf "$PWD"/bash_profile ~/.bash_profile
ln -sf "$PWD"/bashrc ~/.bashrc

echo Symlinking done