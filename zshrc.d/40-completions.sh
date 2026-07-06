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

# Cache abx completion; refresh when the binary is newer than the cache
if command -v abx >/dev/null 2>&1; then
  _abx_bin=$(command -v abx)
  if [[ ! -f "$_ZSH_CACHE_DIR/abx-completion.zsh" || "$_abx_bin" -nt "$_ZSH_CACHE_DIR/abx-completion.zsh" ]]; then
    abx completion zsh > "$_ZSH_CACHE_DIR/abx-completion.zsh" 2>/dev/null
  fi
  source "$_ZSH_CACHE_DIR/abx-completion.zsh"
  compdef _abx abx
  unset _abx_bin
fi
