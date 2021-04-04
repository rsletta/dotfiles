export PATH=$PATH:$HOME/.dotfiles/scripts
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH
fi
