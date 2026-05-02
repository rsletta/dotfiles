# Jira CLI wrapper with context integration

_jira_require_context() {
  [[ -n "$JIRA_CONFIG_FILE" ]] || {
    echo "jira tool not active. Run: cman add-tool jira, then cch <context>" >&2
    return 1
  }
}

_jira_run() {
  PAGER=less op run -- jira "$@"
}

_jira_tool_dir() {
  dirname "$JIRA_CONFIG_FILE"
}

_jira_active_org() {
  [[ -L "$JIRA_CONFIG_FILE" ]] && basename "$(readlink "$JIRA_CONFIG_FILE")" .yml
}

_jira_projects_file() {
  local org="$(_jira_active_org)"
  [[ -z "$org" ]] && return 1
  echo "$(_jira_tool_dir)/orgs/$org.projects"
}

# Resolve symlink to real path — macOS sed -i won't edit through symlinks
_jira_config_real() {
  local link
  link="$(readlink "$JIRA_CONFIG_FILE")"
  if [[ "$link" = /* ]]; then
    echo "$link"
  else
    echo "$(_jira_tool_dir)/$link"
  fi
}

# --- org management ---

_jira_org_list() {
  local tool_dir="$(_jira_tool_dir)"
  local orgs_dir="$tool_dir/orgs"
  local active="$(_jira_active_org)"

  for f in "$orgs_dir"/*.yml(N); do
    local org="$(basename "$f" .yml)"
    [[ "$org" == "$active" ]] && echo "* $org" || echo "  $org"
  done
}

_jira_org_use() {
  local name="$1"
  local tool_dir="$(_jira_tool_dir)"
  local orgs_dir="$tool_dir/orgs"

  if [[ -z "$name" ]]; then
    name=$(ls "$orgs_dir"/*.yml 2>/dev/null | xargs -I{} basename {} .yml \
      | fzf --prompt="Org: " --layout=reverse --height=10 --query="$(_jira_active_org)") || return 0
    [[ -z "$name" ]] && return 0
  fi

  local org_file="$orgs_dir/$name.yml"
  [[ -f "$org_file" ]] || { echo "Org '$name' not found"; return 1; }

  ln -sf "orgs/$name.yml" "$JIRA_CONFIG_FILE"
  echo "Active org → $name"
}

_jira_org_add() {
  local name="$1"
  local tool_dir="$(_jira_tool_dir)"
  local orgs_dir="$tool_dir/orgs"

  if [[ -z "$name" ]]; then
    echo -n "Org name (short identifier): "
    read -r name
  fi
  [[ -z "$name" ]] && return 1

  mkdir -p "$orgs_dir"

  local org_file="$orgs_dir/$name.yml"
  if [[ -f "$org_file" ]]; then
    echo "Org '$name' already exists"
    return 1
  fi

  cp "$HOME/.config/dotfiles/templates/context/tools/jira/config.yml" "$org_file"

  echo -n "Jira server URL: "
  read -r _server
  [[ -n "$_server" ]] && sed -i '' "s|^server:.*|server: $_server|" "$org_file"

  echo -n "Jira login email: "
  read -r _login
  [[ -n "$_login" ]] && sed -i '' "s|^login:.*|login: $_login|" "$org_file"

  echo "  org '$name' added"
  echo -n "Switch to '$name' now? [Y/n] "
  read -r _reply
  [[ "$_reply" != [nN]* ]] && _jira_org_use "$name"
}

# --- project management ---

_jira_project_add() {
  local projects_file="$(_jira_projects_file)"
  [[ -z "$projects_file" ]] && { echo "No active org"; return 1; }

  local existing=""
  [[ -f "$projects_file" ]] && existing="$(cat "$projects_file")"

  local available raw_output
  raw_output=$(_jira_run project list 2>/dev/null)
  available=$(echo "$raw_output" | awk '$1 ~ /^[A-Z][A-Z0-9]*$/ {print $1, $2}')
  [[ -z "$available" ]] && {
    echo "Could not fetch projects. Check your config:"
    echo "  cat \$JIRA_CONFIG_FILE"
    _jira_run project list
    return 1
  }

  if [[ -n "$existing" ]]; then
    available=$(echo "$available" | awk 'NR==FNR{skip[$1]=1; next} !skip[$1]' <(echo "$existing") -)
  fi

  [[ -z "$available" ]] && { echo "All available projects already in shortlist"; return 0; }

  local selected
  selected=$(echo "$available" \
    | fzf --multi \
          --prompt="Add projects: " \
          --header="TAB to select multiple, ENTER to confirm" \
          --layout=reverse --height=20 \
    | awk '{print $1}')
  [[ -z "$selected" ]] && return 0

  echo "$selected" >> "$projects_file"
  echo "$selected" | while read -r key; do
    echo "  + $key"
  done
}

_jira_project_select() {
  local projects_file="$(_jira_projects_file)"
  [[ -z "$projects_file" ]] && { echo "No active org"; return 1; }

  if [[ ! -f "$projects_file" || ! -s "$projects_file" ]]; then
    echo "No projects in shortlist. Run: jira project add"
    return 1
  fi

  local current
  current=$(grep -m1 'key:' "$JIRA_CONFIG_FILE" 2>/dev/null | awk -F'"' '{print $2}')

  local key
  key=$(cat "$projects_file" \
    | fzf --prompt="Project: " --layout=reverse --height=15 \
          --query="$current") || return 0
  [[ -z "$key" ]] && return 0

  sed -i '' "s/^  key:.*$/  key: \"$key\"/" "$(_jira_config_real)"
  echo "Active project → $key"
}

_jira_project_use() {
  local key="$1"
  sed -i '' "s/^  key:.*$/  key: \"$key\"/" "$(_jira_config_real)"
  echo "Active project → $key"
}

# --- dispatcher ---

lazyj() {
  _jira_require_context || return 1

  case "$1" in
    org)
      shift
      case "$1" in
        list|ls) _jira_org_list ;;
        use)     shift; _jira_org_use "$@" ;;
        add)     shift; _jira_org_add "$@" ;;
        *)       echo "Usage: lazyj org <list|use|add>" >&2; return 1 ;;
      esac
      ;;
    project)
      shift
      case "$1" in
        add)    _jira_project_add ;;
        select) _jira_project_select ;;
        use)    shift; _jira_project_use "$@" ;;
        *)      _jira_run project "$@" ;;
      esac
      ;;
    issue)
      shift
      [[ -z "$1" ]] && set -- list
      _jira_run issue "$@"
      ;;
    board)
      shift
      [[ -z "$1" ]] && set -- list
      _jira_run board "$@"
      ;;
    sprint)
      shift
      [[ -z "$1" ]] && set -- list
      _jira_run sprint "$@"
      ;;
    *) _jira_run "$@" ;;
  esac
}

# --- completion ---

_jira_orgs() {
  local tool_dir orgs_dir
  tool_dir="$(dirname "$JIRA_CONFIG_FILE" 2>/dev/null)"
  orgs_dir="$tool_dir/orgs"
  [[ -d "$orgs_dir" ]] || return
  local -a orgs
  orgs=($(ls "$orgs_dir"/*.yml 2>/dev/null | xargs -I{} basename {} .yml))
  _describe -t orgs 'org' orgs
}

_jira_project_keys() {
  local projects_file
  projects_file="$(_jira_projects_file 2>/dev/null)"
  [[ -f "$projects_file" ]] || return
  local -a keys
  keys=(${(f)"$(<$projects_file)"})
  _describe -t projects 'project' keys
}

_jira() {
  local -a subcmds
  subcmds=(
    'org:Switch Jira org'
    'issue:Manage issues'
    'project:Manage projects'
    'sprint:Manage sprints'
    'board:Manage boards'
    'open:Open issue in browser'
    'me:Show current user'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'jira command' subcmds
    return
  fi

  case "${words[2]}" in
    org)
      if (( CURRENT == 3 )); then
        local -a org_subcmds
        org_subcmds=('list:List orgs' 'use:Switch active org' 'add:Add a new org')
        _describe -t commands 'org command' org_subcmds
      elif (( CURRENT == 4 )) && [[ "${words[3]}" == "use" ]]; then
        _jira_orgs
      fi
      ;;
    project)
      if (( CURRENT == 3 )); then
        local -a project_subcmds
        project_subcmds=('add:Add projects to shortlist' 'select:Pick active project from shortlist' 'use:Set active project directly' 'list:List all projects')
        _describe -t commands 'project command' project_subcmds
      elif (( CURRENT == 4 )) && [[ "${words[3]}" == "use" ]]; then
        _jira_project_keys
      fi
      ;;
    issue)
      if (( CURRENT == 3 )); then
        local -a issue_subcmds
        issue_subcmds=('list:List issues' 'view:View an issue' 'create:Create an issue' 'edit:Edit an issue' 'move:Move issue to status' 'assign:Assign an issue')
        _describe -t commands 'issue command' issue_subcmds
      fi
      ;;
  esac
}

compdef _jira lazyj
