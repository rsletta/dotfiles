#!/usr/bin/env bash

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias '~'='cd ~/'
alias dot='cd ~/.config/dotfiles'
alias vault='cd ~/vault'

# Git
alias gs='git status'
alias gc='git commit'
alias gd='git diff'

# Notes
alias dn='dailyNote'
alias qrn='quickReadNote'
alias nn='newNote'

# Serve directory with http
alias sd='python3 -m http.server'

# ls alias with color-mode
alias lh='ls -lha --color=auto'
alias ls='ls -Fh --color=auto'
alias l.='ls -d .* --color=auto'

# the great switch
alias vim='nvim'
alias vi='nvim'
alias cat='bat'

# Asciinema
alias rec='asciinema rec'

# refresh shell
alias reload='source ~/.zshrc'

# Some arch hacks to force arm64 or x86_64
# Check if the system is macOS
if [ "$(uname)" = "Darwin" ]; then
    # Aliases for forcing architecture
    alias arm="env /usr/bin/arch -arm64 /bin/bash --login"
    alias intel="env /usr/bin/arch -x86_64 /bin/bash --login"

    # Set brew alias based on architecture
    if [ "$(arch)" = "i386" ]; then
        alias brew='/usr/local/bin/brew'
    else
        alias brew='/opt/homebrew/bin/brew'
    fi
fi

# All below are added via 'aali' function
alias jts='java -jar $HOME/tooling/search.jar'
