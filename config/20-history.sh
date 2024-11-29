# Ignore duplicate commands and commands starting with a space
HISTIGNORE="&:[ ]*"

# Set the history size (number of commands to remember)
HISTSIZE=1000
SAVEHIST=2000

# Append to (don't overwrite) the history file
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
