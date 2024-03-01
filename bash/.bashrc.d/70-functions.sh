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
