#!/usr/bin/env bash

# Git stuff
export GIT_PS1_SHOWCOLORHINTS='y'
export GIT_PS1_SHOWDIRTYSTATE='y'
export GIT_PS1_SHOWUNTRACKEDFILES='y'
export GIT_PS1_SHOWSTASHSTATE="y"
export GIT_PS1_DESCRIBE_STYLE='describe'
export GIT_PS1_SHOWUPSTREAM='auto'
export GIT_PS1_STATESEPARATOR='|'

. "$HOME/.dotfiles/git/git-prompt.sh"

### Prompt ###
export LC_ALL=
export CLICOLOR=1
# Set colors with vivid
export LS_COLORS=$(vivid generate gruvbox-dark)

__prompt_command() {
  local BLACK="\[\033[0;30m\]"
  local BLACKBOLD="\[\033[1;30m\]"
  local RED="\[\033[0;31m\]"
  local REDBOLD="\[\033[1;31m\]"
  local GREEN="\[\033[0;32m\]"
  local GREENBOLD="\[\033[1;32m\]"
  local YELLOW="\[\033[0;33m\]"
  local YELLOWBOLD="\[\033[1;33m\]"
  local BLUE="\[\033[0;34m\]"
  local BLUEBOLD="\[\033[1;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local PURPLEBOLD="\[\033[1;35m\]"
  local CYAN="\[\033[0;36m\]"
  local CYANBOLD="\[\033[1;36m\]"
  local WHITE="\[\033[0;37m\]"
  local WHITEBOLD="\[\033[1;37m\]"
  local RESETCOLOR="\[\e[00m\]"

  export PS1="$YELLOW[\#]$RESETCOLOR $BLUE\u$PURPLE@$CYAN\h: $GREEN\w$RESETCOLOR$(__git_ps1 "(%s)")\n$GREEN → $RESETCOLOR"

  export PS2=" | → $RESETCOLOR"
}

PROMPT_COMMAND=__prompt_command
