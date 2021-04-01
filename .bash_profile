# Just import .bashrc
[ -r $HOME/.bashrc ] && source $HOME/.bashrc

# Remove the zsh warning in macOS
export BASH_SILENCE_DEPRECATION_WARNING=1