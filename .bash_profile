# enable the git bash completion commands
source ~/.git-completion.bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Source NVM path if installed
if [ -d ~/.nvm  ]; then
  source ~/.nvm_path
fi

# Add Visual Studio Code to path, if present
#if [ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
 #export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin";
#fi


export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

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
