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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
