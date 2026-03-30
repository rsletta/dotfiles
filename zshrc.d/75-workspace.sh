# Workspace management commands

ws() {
  local cmd="$1"
  [[ -z "$cmd" ]] && { _ws_help; return 0; }
  shift

  case "$cmd" in
    new|init)
      _ws_new "$@"
      ;;
    list|ls)
      _ws_list "$@"
      ;;
    cd)
      _ws_cd "$@"
      ;;
    rename)
      _ws_rename "$@"
      ;;
    *)
      echo "Unknown workspace command: $cmd" >&2
      _ws_help
      return 1
      ;;
  esac
}

_ws_new() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "usage: ws new <name>" >&2
    return 1
  fi

  local ws_home="$HOME/ws/$name"

  if [[ -d "$ws_home" ]]; then
    echo "Workspace already exists: $ws_home" >&2
    return 1
  fi

  mkdir -p "$ws_home"/{src,notes}
  echo "Created workspace: $ws_home"
}

_ws_list() {
  local ws_dir="$HOME/ws"
  local ctx_dir="$HOME/.config/contexts"

  if [[ ! -d "$ws_dir" ]]; then
    echo "Workspace directory does not exist: $ws_dir" >&2
    return 1
  fi

  echo "Workspaces:"
  for ws in "$ws_dir"/*(N/); do
    local name="${ws:t}"
    if [[ -d "$ctx_dir/$name" ]]; then
      echo "  $name *"
    else
      echo "  $name"
    fi
  done
}

_ws_rename() {
  local old="$1"
  local new="$2"

  if [[ -z "$old" || -z "$new" ]]; then
    echo "Usage: ws rename <old> <new>" >&2
    return 1
  fi

  local old_ws="$HOME/ws/$old"
  local new_ws="$HOME/ws/$new"

  if [[ ! -d "$old_ws" ]]; then
    echo "Workspace '$old' not found" >&2
    return 1
  fi

  if [[ -d "$new_ws" ]]; then
    echo "Workspace '$new' already exists" >&2
    return 1
  fi

  if [[ -L "$old_ws" ]]; then
    echo "Workspace dir is a symlink — aborting" >&2
    return 1
  fi

  mv "$old_ws" "$new_ws"
  echo "Renamed: ws/$old → ws/$new"
}

_ws_cd() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "usage: ws cd <name>" >&2
    return 1
  fi

  local ws_home="$HOME/ws/$name"

  if [[ ! -d "$ws_home" ]]; then
    echo "Workspace not found: $ws_home" >&2
    return 1
  fi

  cd "$ws_home"
}

# Completion for ws command
_ws() {
  local -a subcmds
  subcmds=(new init list ls cd rename)

  if (( CURRENT == 2 )); then
    _describe -t subcmds 'subcommand' subcmds
  elif (( CURRENT == 3 )); then
    case "${words[2]}" in
      cd|init|new|rename)
        local -a workspaces
        if [[ -d "$HOME/ws" ]]; then
          workspaces=($(ls -d "$HOME/ws"/*/ 2>/dev/null | xargs -I {} basename {}))
          compadd -- "$workspaces"
        fi
        ;;
    esac
  fi
}

compdef _ws ws

_ws_help() {
  cat << 'EOF'
Workspace management

Usage:
  ws new <name>         Bootstrap a new workspace
  ws init <name>        Alias for 'new'
  ws list               List all workspaces
  ws ls                 Alias for 'list'
  ws cd <name>          Change to workspace directory
  ws rename <old> <new> Rename a workspace
EOF
}
