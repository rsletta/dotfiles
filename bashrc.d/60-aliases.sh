#!/usr/bin/env bash

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home='cd ~/'

# ls alias for color-mode
alias lh='ls -lhaG'
alias ls='ls -GFh'

# load tmux
alias t='tmux'

# open neovim
alias v='nvim'
alias vim='nvim'

## OS SPECIFIC ##
if [[ "$OSTYPE" == "darwin"* ]]; then
    # refresh shell
    alias reload='source ~/.bash_profile'
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # refresh shell
    alias reload='source ~/.bashrc'
fi