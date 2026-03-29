# Load completions from your custom path
fpath=(~/.completions $fpath)

# Load Zsh completions only once — use cached dump unless stale (24h)
autoload -Uz compinit
if [[ -z "$_compinit_done" ]]; then
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
  _compinit_done=1
fi

# Cache op completions (refreshed daily with the rest of ~/.cache/zsh)
if [[ ! -f "$_ZSH_CACHE_DIR/op-completion.zsh" ]]; then
  op completion zsh > "$_ZSH_CACHE_DIR/op-completion.zsh" 2>/dev/null
fi
source "$_ZSH_CACHE_DIR/op-completion.zsh"
compdef _op op
