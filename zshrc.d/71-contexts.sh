export SHELL_CONTEXT=""
export CONTEXT_ENV=""

# Set current context
_set_context() {
  local ctx="$1" shared_dir file

  if [[ -z "$ctx" ]]; then
    echo "Usage: chc <context>" >&2
    return 1
  fi

  shared_dir="$HOME/.config/contexts/$ctx/env/shared"
  if [[ ! -d "$shared_dir" ]]; then
    echo "Unknown context: $ctx" >&2
    return 1
  fi

  export SHELL_CONTEXT="$ctx"
  echo "Setting $SHELL_CONTEXT as context"

  for file in "$shared_dir"/*.sh(N); do
    source "$file"
  done
}

# public command
chc() {
  _set_context "$@"
}

# zsh completion for chc
_chc() {
  local -a contexts
  local dir

  dir="$HOME/.config/contexts"
  [[ -d $dir ]] || return 0

  contexts=("$dir"/*(N:t))
  _describe -t contexts 'context' contexts
}

compdef _chc chc

# Set env inside current context (dev/prod/test/…)
_set_context_env() {
  local env="$1" env_dir file

  if [[ -z "$SHELL_CONTEXT" ]]; then
    echo "Context not set. Run: chc <context>" >&2
    return 1
  fi

  if [[ -z "$env" ]]; then
    unset CONTEXT_ENV
    echo "Context env unset"
    return 0
  fi

  env_dir="$HOME/.config/contexts/$SHELL_CONTEXT/env/$env"
  if [[ ! -d "$env_dir" ]]; then
    echo "Unknown env '$env' for context '$SHELL_CONTEXT'" >&2
    return 1
  fi

  export CONTEXT_ENV="$env"
  echo "Setting context env: $CONTEXT_ENV"

  for file in "$env_dir"/*.sh(N); do
    source "$file"
  done
}

# command you type
cenv() {
  _set_context_env "$@"
}

# zsh completion for cenv
_cenv() {
  local -a envs
  local dir

  # If no context is set, offer no completions
  [[ -n "$SHELL_CONTEXT" ]] || return 0

  dir="$HOME/.config/contexts/$SHELL_CONTEXT/env"
  [[ -d $dir ]] || return 0

  # basenames of children
  envs=(${dir}/*(N:t))
  # drop 'shared'
  envs=(${envs:#shared})

  (( ${#envs} )) || return 0
  compadd -- $envs
}

compdef _cenv cenv

# cd to context home (from shared/variables.sh)
_change_to_context_home() {
  if [[ -z "$CONTEXT_HOME" ]]; then
    echo "CONTEXT_HOME is not set; run chc first" >&2
    return 1
  fi

  cd "$CONTEXT_HOME" || return
}

cdc() {
  _change_to_context_home "$@"
}
