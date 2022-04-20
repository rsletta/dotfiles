#!/usr/bin/env bash

export LC_ALL=
export CLICOLOR=1
# Set colors with vivid
export LS_COLORS=$(vivid generate ~/.config/vivid/themes/gruvbox-dark-custom.yaml)

eval "$(oh-my-posh prompt init bash --config "~/.ohmygruvbox.omp.json")"
