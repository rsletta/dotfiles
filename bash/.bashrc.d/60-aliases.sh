#!/usr/bin/env bash

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias '~'='cd ~/'
alias dot='cd ~/.dotfiles'
alias vault='cd ~/vault'

# Notes
alias dn='dailyNote'
alias qrn='quickReadNote'

# Serve directory with http
alias sd='python3 -m http.server'

# ls alias with color-mode
alias lh='ls -lha --color=auto'
alias ls='ls -Fh --color=auto'
alias l.='ls -d .* --color=auto'


# load tmux
alias t='tmux'

# open neovim
alias v='nvim'
alias vim='nvim'

# Asciinema
alias rec='asciinema rec'

## OS SPECIFIC ##
if [[ "$OSTYPE" == "darwin"* ]]; then
    # refresh shell
    alias reload='source ~/.bash_profile'
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # refresh shell
    alias reload='source ~/.bashrc'
fi
