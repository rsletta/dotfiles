#############
## ALIASES ##
#############

# enable the git bash completion commands
source ~/.git-completion.bash
source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home='cd ~/'

# ls alias for color-mode
alias lh='ls -lhaG'
alias ls='ls -GFh'

# refresh shell
alias reload='source ~/.bash_profile'

# enable git unstaged indicators - set to a non-empty value
GIT_PS1_SHOWDIRTYSTATE="."

# enable showing of untracked files - set to a non-empty value
GIT_PS1_SHOWUNTRACKEDFILES="."

# enable stash checking - set to a non-empty value
GIT_PS1_SHOWSTASHSTATE="."

# enable showing of HEAD vs its upstream
GIT_PS1_SHOWUPSTREAM="auto"


# git commamands simplified
alias gst='git status'
alias gco='git checkout'
alias gci='git commit'
alias grb='git rebase'
alias gbr='git branch'
alias gad='git add -A'
alias gpl='git pull'
alias gpu='git push'
alias glg='git log --date-order --all --graph --format="%C(green)%h%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'
alias glg2='git log --date-order --all --graph --name-status --format="%C(green)%H%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'


###############
## SHORTHAND ##
###############

repos() {
	cd ~/repositories/$1
}

?() {
echo "****************************************"
echo "*             Shortcuts                *"
echo "*--------------------------------------*"
echo "* repos -> move to repositories folder *"
echo "* home -> move to user home            *"
echo "* lh -> ls -lhaG                       *"
echo "*--------------------------------------*"
echo "*             Folder nav               *"
echo "*--------------------------------------*"
echo "* .. -> cd ..                          *"
echo "* ... -> cd ../..                      *"
echo "* .... -> cd ../../..                  *"
echo "* ..... -> cd ../../../..              *"
echo "*--------------------------------------*"
echo "*             Git cmd                  *"
echo "*--------------------------------------*"
echo "* gst -> git status                    *"
echo "* gco -> git checkout                  *"
echo "* gci -> git commit                    *"
echo "* gbr -> git branch                    *"
echo "* gad -> git add -A                    *"
echo "* gpl -> git pull                      *"
echo "* gpu -> git push                      *"
echo "* gpu -> git push                      *"
echo "* gpu -> git push                      *"
echo "* grb -> git rebase                    *"
echo "* glg -> git log                       *"
echo "* glg2 -> git log2                     *"
echo "****************************************"
}

#############
## ENV VAR ##
#############
function prompt {
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

  export PS1="\n$RED\u $PURPLE@ $GREEN\w $RESETCOLOR$GREENBOLD\$(git branch 2> /dev/null)\n $BLUE[\#] → $RESETCOLOR"
  export PS2=" | → $RESETCOLOR"
}

prompt
