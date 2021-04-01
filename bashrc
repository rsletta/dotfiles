#!/usr/bin/env bash

case $- in
  *i*) ;;
  *) return ;;
esac

# Check for post install config profile
if [ -f ~/.extrasrc ]; then
  source ~/.extrasrc
fi

# Load configs
for rcfile in "$HOME"/.bashrc.d/*.sh; do
  source "$rcfile"
done