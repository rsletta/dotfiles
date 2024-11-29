#!/usr/bin/env bash

repos() {
	cd ~/repositories/$1
}


tla() {
  # Tmux list and attach to session
  tmux a -t $(tmux ls -F '#S' | fzf --layout=reverse --border --info=inline --margin=8,20)
}

tns() {
  newTmuxSession $1
}

# add new alias to alias file
function aali() {
    if [[ -z $1 || -z $2 || $# -gt 2 ]]; then
        echo usage:
        echo "\t\$$0 <alias> '<command>'"
        echo example:
        echo "\t\$$0 ll 'ls -l'"
    else
        echo "alias $1='$2'" >> $ALIASFILE
        echo "alias ADDED to $ALIASFILE"
    fi
}
