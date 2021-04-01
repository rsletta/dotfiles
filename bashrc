#!/usr/bin/env bash

case $- in
  *i*) ;;
  *) return ;;
esac

# Check for post install config profile
if [ -f ~/.profile ]; then
  source ~/.profile
fi

# Load configs
for rcfile in "$HOME"/.bashrc.d/*.sh; do
  source "$rcfile"
done