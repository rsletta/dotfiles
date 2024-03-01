#!/usr/bin/env bash

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home='cd ~/'
alias dot='cd ~/.dotfiles'

# ls alias with color-mode
alias lh='ls -lha --color=auto'
alias ls='ls -Fh --color=auto'
alias l.='ls -d .* --color=auto'


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

# Some arch hacks
alias arm="env /usr/bin/arch -arm64 /bin/bash --login"
alias intel="env /usr/bin/arch -x86_64 /bin/bash --login"

if [ $(arch) = "i386" ]; then
    alias brew='/usr/local/bin/brew'
else
    alias brew='/opt/homebrew/bin/brew'
fi
