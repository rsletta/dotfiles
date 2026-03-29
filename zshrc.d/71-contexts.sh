_INHERITED_CONTEXT="$SHELL_CONTEXT"
_INHERITED_CONTEXT_ENV="$CONTEXT_ENV"

export SHELL_CONTEXT=""
export CONTEXT_ENV=""
export CONTEXT_DIR=""

# Tool env vars managed by context system — cleaned up on context switch
_CONTEXT_TOOL_VARS=(
  GH_CONFIG_DIR
  AWS_CONFIG_FILE
  AWS_SHARED_CREDENTIALS_FILE
  DOCKER_CONFIG
  AZURE_CONFIG_DIR
  CLOUDSDK_CONFIG
  HELM_CONFIG_HOME
  TF_CLI_CONFIG_FILE
  GH_USER
  CONTEXT_VAULT_PATH
  CONTEXT_TIL_PATH
  CONTEXT_TIL_TEMPLATE
  CONTEXT_POST_PATH
  CONTEXT_POST_TEMPLATE
)

# Clean up env vars from previous context
_context_cleanup() {
  for var in "${_CONTEXT_TOOL_VARS[@]}"; do
    unset "$var"
  done
  unset CONTEXT_KUBE_CONFIGS
  export CONTEXT_HOME=""
  export CONTEXT_LABEL=""
  export CONTEXT_ENV=""
}

# Set current context
_set_context() {
  local ctx="$1"

  if [[ -z "$ctx" ]]; then
    if [[ -n "$SHELL_CONTEXT" ]]; then
      local old_dir="$HOME/.config/contexts/$SHELL_CONTEXT"
      if [[ -f "$old_dir/hooks/on-leave.sh" ]]; then
        source "$old_dir/hooks/on-leave.sh"
      fi
      _context_cleanup
      export SHELL_CONTEXT=""
      export CONTEXT_DIR=""
      echo "Context cleared"
      return 0
    fi
    return 0
  fi

  local ctx_dir="$HOME/.config/contexts/$ctx"
  if [[ ! -f "$ctx_dir/config.sh" ]]; then
    echo "Unknown context: $ctx (no config.sh found)" >&2
    return 1
  fi

  # Leave current context if one is active
  if [[ -n "$SHELL_CONTEXT" ]]; then
    local old_dir="$HOME/.config/contexts/$SHELL_CONTEXT"
    if [[ -f "$old_dir/hooks/on-leave.sh" ]]; then
      source "$old_dir/hooks/on-leave.sh"
    fi
    _context_cleanup
  fi

  # Set context identity
  export CONTEXT_DIR="$ctx_dir"
  export SHELL_CONTEXT="$ctx"

  # Source config (sets CONTEXT_HOME, CONTEXT_LABEL)
  source "$ctx_dir/config.sh"

  # Source shared env
  local file
  for file in "$ctx_dir"/env/shared/*.sh(N); do
    source "$file"
  done

  # Source tool setup
  if [[ -f "$ctx_dir/tools/setup.sh" ]]; then
    source "$ctx_dir/tools/setup.sh"
  fi

  # Source kube declarations (for scoped completions)
  if [[ -f "$ctx_dir/tools/kube.sh" ]]; then
    source "$ctx_dir/tools/kube.sh"
  fi

  # Run on-enter hook
  if [[ -f "$ctx_dir/hooks/on-enter.sh" ]]; then
    source "$ctx_dir/hooks/on-enter.sh"
  fi

  echo "Context: $SHELL_CONTEXT"
}

# Public command
cch() {
  _set_context "$@"
}

# zsh completion for cch
_cch() {
  local -a contexts
  local dir="$HOME/.config/contexts"
  [[ -d $dir ]] || return 0

  contexts=("$dir"/*(N:t))
  # Exclude _template and any dotfiles
  contexts=(${contexts:#_*})
  _describe -t contexts 'context' contexts
}

compdef _cch cch

# Set env inside current context (dev/prod/test/...)
_set_context_env() {
  local env="$1"

  if [[ -z "$SHELL_CONTEXT" ]]; then
    echo "Context not set. Run: cch <context>" >&2
    return 1
  fi

  if [[ -z "$env" ]]; then
    export CONTEXT_ENV=""
    echo "Context env unset (env-specific exports persist until next cch)"
    return 0
  fi

  local env_dir="$CONTEXT_DIR/env/$env"
  if [[ ! -d "$env_dir" ]]; then
    echo "Unknown env '$env' for context '$SHELL_CONTEXT'" >&2
    return 1
  fi

  export CONTEXT_ENV="$env"
  echo "Context env: $CONTEXT_ENV"

  local file
  for file in "$env_dir"/*.sh(N); do
    source "$file"
  done
}

cenv() {
  _set_context_env "$@"
}

# zsh completion for cenv
_cenv() {
  local -a envs
  [[ -n "$SHELL_CONTEXT" ]] || return 0

  local dir="$CONTEXT_DIR/env"
  [[ -d $dir ]] || return 0

  envs=(${dir}/*(N:t))
  envs=(${envs:#shared})

  (( ${#envs} )) || return 0
  compadd -- $envs
}

compdef _cenv cenv

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

# Restore context in new tmux panes (inherited from parent shell)
if [[ -n "$TMUX" && -n "$_INHERITED_CONTEXT" ]]; then
  cch "$_INHERITED_CONTEXT" > /dev/null
  [[ -n "$_INHERITED_CONTEXT_ENV" ]] && cenv "$_INHERITED_CONTEXT_ENV" > /dev/null
fi
unset _INHERITED_CONTEXT _INHERITED_CONTEXT_ENV
