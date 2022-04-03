export PATH=$PATH:$HOME/.dotfiles/scripts
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) 

if [[ "$OSTYPE" == "darwin"* ]]; then
  eval $(/bin/brew shellenv)
fi
