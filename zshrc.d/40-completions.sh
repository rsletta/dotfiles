# Load completions from your custom path
fpath=(~/.completions $fpath)

# Load Zsh completions only once
autoload -Uz compinit bashcompinit
if [[ -z "$_compinit_done" ]]; then
  compinit
  bashcompinit
  _compinit_done=1
fi
