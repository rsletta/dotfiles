_INHERITED_CONTEXT="$SHELL_CONTEXT"

export SHELL_CONTEXT=""
export CONTEXT_DIR=""

# Vars exported by the active context, recorded as they are set.
#
# Contexts are individual — each exports whatever IT needs — so a central list
# of "vars a context might set" can never be complete, and the ones it misses
# survive a switch. Recording at export time is exact by construction: whatever
# the context set is exactly what gets unset. Contexts use `cexport` instead of
# `export` in config.sh / tools/setup.sh.
_CONTEXT_EXPORTED_VARS=()

cexport() {
  local assignment
  for assignment in "$@"; do
    _CONTEXT_EXPORTED_VARS+=("${assignment%%=*}")
  done
  export "$@"
}

# Clean up env vars from previous context
_context_cleanup() {
  local var
  for var in "${_CONTEXT_EXPORTED_VARS[@]}"; do
    unset "$var"
  done
  _CONTEXT_EXPORTED_VARS=()
  unset CONTEXT_KUBE_CONFIGS
  export CONTEXT_HOME=""
  [[ -n "$TMUX" ]] && tmux setenv -u SHELL_CONTEXT 2>/dev/null
  return 0
}

# Set current context
_set_context() {
  local ctx="$1"

  if [[ -z "$ctx" ]]; then
    if [[ -n "$SHELL_CONTEXT" ]]; then
      _context_cleanup
      export SHELL_CONTEXT=""
      export CONTEXT_DIR=""
      echo "Context cleared"
    fi
    return 0
  fi

  local ctx_dir="$HOME/.config/contexts/$ctx"
  if [[ ! -f "$ctx_dir/config.sh" ]]; then
    echo "Unknown context: $ctx (no config.sh found)" >&2
    return 1
  fi

  # Leave current context if one is active
  [[ -n "$SHELL_CONTEXT" ]] && _context_cleanup

  # CONTEXT_DIR first — the context's own files reference it.
  export CONTEXT_DIR="$ctx_dir"

  #   config.sh       sets CONTEXT_HOME
  #   tools/setup.sh  exports tool config paths — the whole point of the system
  #   tools/kube.sh   declares kubeconfig names for scoped completions
  #
  # A failure here leaves a HALF-applied context, so bail rather than carry on.
  local f
  for f in "$ctx_dir/config.sh" "$ctx_dir/tools/setup.sh" "$ctx_dir/tools/kube.sh"; do
    [[ -f "$f" ]] || continue
    if ! source "$f"; then
      echo "context: failed sourcing ${f#$ctx_dir/} — context NOT set" >&2
      # The previous context was already torn down above, so leave NO context
      # rather than a stale name with none of its config applied.
      _context_cleanup
      export CONTEXT_DIR=""
      export SHELL_CONTEXT=""
      return 1
    fi
  done

  # Only now is the context real. The prompt and the tmux session env both read
  # SHELL_CONTEXT, so setting it LAST means a visible badge always implies a
  # fully applied config — never a half-sourced one wearing a confident label.
  export SHELL_CONTEXT="$ctx"
  # Sync to the tmux SESSION environment (not the server's) so new windows in
  # this session inherit the context. Deliberately NOT via update-environment:
  # that list is re-applied from the CLIENT on every attach, so attaching from a
  # context-less shell would wipe it. New sessions get it via `new-session -e`.
  [[ -n "$TMUX" ]] && tmux setenv SHELL_CONTEXT "$SHELL_CONTEXT" 2>/dev/null

  # Skillshare drift check (no-op if skillshare not installed in this context)
  typeset -f _context_skillshare_check >/dev/null 2>&1 && _context_skillshare_check

  echo "Context: $SHELL_CONTEXT"
}

# Read a gh oauth token from macOS Keychain by account name.
# Works around cli/cli#12885: gh's own keychain lookup ignores the account
# field, so with multiple gh accounts on github.com it returns an arbitrary
# token. Setup.sh uses this to pin GH_TOKEN for the context's user.
_gh_token_for_user() {
  local user="$1"
  local raw
  raw=$(security find-generic-password -s "gh:github.com" -a "$user" -w 2>/dev/null) || return 1
  printf '%s' "${raw#go-keyring-base64:}" | base64 -d
}

# Return cached GH username for the current context, fetching if needed.
# Cache lives at $CONTEXT_DIR/.cache/gh_user — delete to force refresh.
_gh_user_cached() {
  local cache_file="$CONTEXT_DIR/.cache/gh_user"
  if [[ -f "$cache_file" ]]; then
    cat "$cache_file"
    return
  fi
  local user
  user="$(gh api user --jq .login 2>/dev/null)"
  if [[ -n "$user" ]]; then
    mkdir -p "${cache_file:h}"
    echo "$user" > "$cache_file"
    echo "$user"
  fi
}

# Public command
cch() {
  _set_context "$1"
}

# zsh completion for cch
_cch_contexts() {
  local -a contexts
  local dir="$HOME/.config/contexts"
  [[ -d $dir ]] || return 0

  contexts=("$dir"/*(N:t))
  # Exclude _template and any dotfiles
  contexts=(${contexts:#_*})
  _describe -t contexts 'context' contexts
}

_cch() {
  _cch_contexts
}

compdef _cch cch

# cd to context home
_change_to_context_home() {
  if [[ -z "$CONTEXT_HOME" ]]; then
    echo "CONTEXT_HOME is not set; run cch first" >&2
    return 1
  fi

  cd "$CONTEXT_HOME" || return
}

ccd() {
  _change_to_context_home "$@"
}

# Restore context inherited from the parent shell. Source: the tmux session
# environment that new windows inherit, or an explicit `tmux new-session -e` /
# `new-window -e`. A plain shell inherits none, so nothing happens.
if [[ -n "$_INHERITED_CONTEXT" ]]; then
  cch "$_INHERITED_CONTEXT" > /dev/null
fi
unset _INHERITED_CONTEXT
