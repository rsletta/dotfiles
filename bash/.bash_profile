# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/bash_profile.pre.bash"
# Just import .bashrc
[ -r $HOME/.bashrc ] && source $HOME/.bashrc

# Remove the zsh warning in macOS
export BASH_SILENCE_DEPRECATION_WARNING=1

# Fig post block. Keep at the bottom of this file.
. "$HOME/.fig/shell/bash_profile.post.bash"
