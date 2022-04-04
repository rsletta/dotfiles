#!/usr/bin/env bash

# Git stuff
export GIT_PS1_SHOWCOLORHINTS='y'
export GIT_PS1_SHOWDIRTYSTATE='y'
export GIT_PS1_SHOWUNTRACKEDFILES='y'
export GIT_PS1_SHOWSTASHSTATE="y"
export GIT_PS1_DESCRIBE_STYLE='describe'
export GIT_PS1_SHOWUPSTREAM='auto'
export GIT_PS1_STATESEPARATOR='|'

. "$HOME/.git-completion/git-prompt.sh"

### Prompt ###
export LC_ALL=
export CLICOLOR=1
# Set colors with vivid
export LS_COLORS=$(vivid generate gruvbox-dark)

eval "$(oh-my-posh prompt init bash --config "~/.ohmynord.omp.json")" && clear