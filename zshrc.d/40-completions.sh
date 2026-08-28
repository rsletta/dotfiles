# Load completions from your custom path
fpath=(~/.completions $fpath)

# Keep this module safe when sourced outside the standard ~/.zshrc bootstrap.
: ${_ZSH_CACHE_DIR:="$HOME/.cache/zsh"}
mkdir -p "$_ZSH_CACHE_DIR"

# Docker CLI completions (Colima/Docker Desktop drops them here)
[[ -d ~/.docker/completions ]] && fpath=(~/.docker/completions $fpath)

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

# Cache op completions (refreshed daily with the rest of ~/.cache/zsh).
if command -v op >/dev/null 2>&1; then
  if [[ ! -s "$_ZSH_CACHE_DIR/op-completion.zsh" ]]; then
    op completion zsh > "$_ZSH_CACHE_DIR/op-completion.zsh" 2>/dev/null
  fi
  [[ -s "$_ZSH_CACHE_DIR/op-completion.zsh" ]] && source "$_ZSH_CACHE_DIR/op-completion.zsh"
  compdef _op op
fi
