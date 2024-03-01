export PATH=$PATH:$HOME/.dotfiles/scripts
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/opt/coreutils/libexec/gnubin::/Users/$USER/.dotnet/tools:$PATH
fi
