# Context manager: cman new|ls|edit

_CONTEXT_TEMPLATE_DIR="$HOME/.config/dotfiles/templates/context"
_CONTEXT_ROOT="$HOME/.config/contexts"

_cman_new() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "Usage: cman new <name>" >&2
    return 1
  fi

  local target="$_CONTEXT_ROOT/$name"

  if [[ -d "$target" ]]; then
    echo "Context '$name' already exists at $target" >&2
    return 1
  fi

  if [[ ! -d "$_CONTEXT_TEMPLATE_DIR" ]]; then
    echo "Template not found at $_CONTEXT_TEMPLATE_DIR" >&2
    return 1
  fi

  cp -r "$_CONTEXT_TEMPLATE_DIR" "$target"

  # Replace placeholders
  local today
  today=$(date +%Y-%m-%d)

  find "$target" -type f -name '*.sh' -exec sed -i '' \
    -e "s|__NAME__|$name|g" \
    -e "s|__HOME__|$HOME/ws/$name|g" \
    -e "s|__DATE__|$today|g" \
    {} +

  echo "Created context: $name"
  echo "  $target/"
  echo ""
  echo "Next steps:"
  echo "  1. Edit config.sh to set CONTEXT_HOME"
  echo "  2. Configure tools in tools/setup.sh"
  echo "  3. Run: cch $name"
}

_cman_ls() {
  local dir="$_CONTEXT_ROOT"
  [[ -d "$dir" ]] || { echo "No contexts directory" >&2; return 1; }

  local -a contexts
  contexts=("$dir"/*(N:t))
  contexts=(${contexts:#_*})

  if (( ${#contexts} == 0 )); then
    echo "No contexts found"
    return 0
  fi

  local ctx
  for ctx in "${contexts[@]}"; do
    local marker=" "
    [[ "$ctx" == "$SHELL_CONTEXT" ]] && marker="*"
    echo "$marker $ctx"
  done
}

_cman_edit() {
  local name="${1:-$SHELL_CONTEXT}"

  if [[ -z "$name" ]]; then
    echo "Usage: cman edit [name]  (defaults to active context)" >&2
    return 1
  fi

  local target="$_CONTEXT_ROOT/$name"

  if [[ ! -d "$target" ]]; then
    echo "Context '$name' not found" >&2
    return 1
  fi

  ${EDITOR:-vim} "$target"
}

# Known tools and their setup.sh export lines
# Key = tool name, Value = export line template ($CONTEXT_DIR is available at runtime)
typeset -A _CONTEXT_KNOWN_TOOLS
_CONTEXT_KNOWN_TOOLS=(
  gh      'export GH_CONFIG_DIR="$CONTEXT_DIR/tools/gh"'
  aws     'export AWS_CONFIG_FILE="$CONTEXT_DIR/tools/aws/config"\nexport AWS_SHARED_CREDENTIALS_FILE="$CONTEXT_DIR/tools/aws/credentials"'
  docker  'export DOCKER_CONFIG="$CONTEXT_DIR/tools/docker"'
  azure   'export AZURE_CONFIG_DIR="$CONTEXT_DIR/tools/azure"'
  gcloud  'export CLOUDSDK_CONFIG="$CONTEXT_DIR/tools/gcloud"'
  helm    'export HELM_CONFIG_HOME="$CONTEXT_DIR/tools/helm"'
  terraform 'export TF_CLI_CONFIG_FILE="$CONTEXT_DIR/tools/terraform/terraformrc"'
  jira    'export JIRA_CONFIG_FILE="$CONTEXT_DIR/tools/jira/config.yml"'
  writing '__WRITING__'
  skillshare '__SKILLSHARE__'
)

_cman_add_tool() {
  local tool="$1"
  local name="${2:-$SHELL_CONTEXT}"

  if [[ -z "$tool" ]]; then
    echo "Usage: cman add-tool <tool> [context]" >&2
    echo "" >&2
    echo "Known tools: ${(k)_CONTEXT_KNOWN_TOOLS}" >&2
    return 1
  fi

  if [[ -z "$name" ]]; then
    echo "No context specified and none active. Usage: cman add-tool <tool> [context]" >&2
    return 1
  fi

  local ctx_dir="$_CONTEXT_ROOT/$name"
  if [[ ! -d "$ctx_dir" ]]; then
    echo "Context '$name' not found" >&2
    return 1
  fi

  local tool_dir="$ctx_dir/tools/$tool"
  if [[ -d "$tool_dir" ]]; then
    echo "Tool '$tool' already exists in context '$name'" >&2
    return 1
  fi

  # Create tool directory
  mkdir -p "$tool_dir"

  # Wire into setup.sh if it's a known tool
  local setup_file="$ctx_dir/tools/setup.sh"
  if [[ "$tool" == "writing" ]]; then
    local vault_path="$HOME/ws/$name/notes/$name"
    local writing_exports="export CONTEXT_VAULT_PATH=\"$vault_path\"\nexport CONTEXT_TIL_PATH=\"$vault_path/TIL\"\nexport CONTEXT_TIL_TEMPLATE=\"\$HOME/.config/dotfiles/templates/writing/til.md\"\nexport CONTEXT_POST_PATH=\"$vault_path/posts\"\nexport CONTEXT_POST_TEMPLATE=\"\$HOME/.config/dotfiles/templates/writing/post.md\""
    echo "" >> "$setup_file"
    echo -e "$writing_exports" >> "$setup_file"

    local templates_src="$HOME/.config/dotfiles/templates/writing"
    local templates_dst="$vault_path/__templates"
    mkdir -p "$templates_dst"
    cp "$templates_src/Daily Note.md" "$templates_dst/Daily Note.md"

    echo "Added 'writing' to $name — wired into setup.sh"
    echo "  Vault: $vault_path"
    echo "  Copied Daily Note template → $templates_dst/"
  elif [[ "$tool" == "skillshare" ]]; then
    _cman_skillshare_setup "$ctx_dir" "$name" "$tool_dir"
  elif [[ "$tool" == "jira" ]]; then
    echo "" >> "$setup_file"
    echo -e "${_CONTEXT_KNOWN_TOOLS[$tool]}" >> "$setup_file"
    mkdir -p "$tool_dir/orgs"
    echo "Added 'jira' to $name — wired into setup.sh"
    echo "  $tool_dir/"
    _cman_jira_setup "$ctx_dir"
  elif [[ -n "${_CONTEXT_KNOWN_TOOLS[$tool]}" ]]; then
    echo "" >> "$setup_file"
    echo -e "${_CONTEXT_KNOWN_TOOLS[$tool]}" >> "$setup_file"

    local tool_template_dir="$_CONTEXT_TEMPLATE_DIR/tools/$tool"
    if [[ -d "$tool_template_dir" ]]; then
      cp -r "$tool_template_dir/." "$tool_dir/"
    fi

    echo "Added '$tool' to $name — wired into setup.sh"
    echo "  $tool_dir/"
  else
    echo "Added '$tool' to $name — unknown tool, add exports to setup.sh manually"
    echo "  $tool_dir/"
  fi
}

_cman_skillshare_setup() {
  local ctx_dir="$1"
  local name="$2"
  local tool_dir="$3"

  if ! command -v skillshare &>/dev/null; then
    echo "skillshare CLI not found — install it first (brew install runkids/tap/skillshare)" >&2
    rmdir "$tool_dir" 2>/dev/null
    return 1
  fi

  local claude_dir="$ctx_dir/tools/claude"
  if [[ ! -d "$claude_dir" ]]; then
    echo "Context '$name' has no tools/claude/ — add Claude Code support before skillshare" >&2
    rmdir "$tool_dir" 2>/dev/null
    return 1
  fi

  local skills_dir="$claude_dir/skills"
  mkdir -p "$skills_dir"

  local target="$name-claude"
  skillshare target add "$target" "$skills_dir" || {
    rmdir "$tool_dir" 2>/dev/null
    return 1
  }

  printf 'target: %s\nskills: %s\n' "$target" "$skills_dir" > "$tool_dir/installed"

  echo "Added 'skillshare' to $name"
  echo "  Target: $target → $skills_dir"
  echo "  Next: skillshare sync"
}

_context_skillshare_check() {
  local marker="$CONTEXT_DIR/tools/skillshare/installed"
  [[ -f "$marker" ]] || return 0
  command -v skillshare &>/dev/null || return 0
  command -v jq &>/dev/null || return 0

  local target
  target=$(awk -F': ' '/^target:/ {print $2}' "$marker")
  [[ -z "$target" ]] && return 0

  local count
  count=$(skillshare diff "$target" --json 2>/dev/null \
    | jq '[.targets[0].items[]? | select(.is_sync == true)] | length' 2>/dev/null)
  [[ -z "$count" ]] && return 0

  (( count > 0 )) && echo "⚠ skillshare: $count skill(s) need sync — run: skillshare sync"
}

_cman_jira_setup() {
  local ctx_dir="$1"
  local tool_dir="$ctx_dir/tools/jira"

  echo ""
  _cman_jira_add_org "$tool_dir" && echo ""

  # 1Password token (shared across orgs — same Atlassian account)
  if ! command -v op &>/dev/null; then
    echo "  Tip: add JIRA_API_TOKEN to env/shared/variables.sh:"
    echo "    export JIRA_API_TOKEN=\"op://<Vault>/<Item>/<field>\""
    return
  fi

  echo -n "Configure JIRA_API_TOKEN from 1Password? [Y/n] "
  read -r _jira_reply
  [[ "$_jira_reply" == [nN]* ]] && return

  local vault item field
  vault=$(op vault list --format=json 2>/dev/null | jq -r '.[].name' \
    | fzf --prompt="Vault: " --layout=reverse --height=10) || return
  [[ -z "$vault" ]] && echo "  Skipped." && return

  item=$(op item list --vault "$vault" --format=json 2>/dev/null | jq -r '.[].title' \
    | fzf --prompt="Item: " --layout=reverse --height=10) || return
  [[ -z "$item" ]] && echo "  Skipped." && return

  field=$(op item get "$item" --vault "$vault" --format=json 2>/dev/null \
    | jq -r '.fields[] | select(.value != null) | .label' \
    | fzf --prompt="Field: " --layout=reverse --height=10) || return
  [[ -z "$field" ]] && echo "  Skipped." && return

  local op_ref="op://$vault/$item/$field"
  printf '\nexport JIRA_API_TOKEN="%s"\n' "$op_ref" >> "$ctx_dir/env/shared/variables.sh"
  echo "  JIRA_API_TOKEN → $op_ref"
}

_cman_jira_add_org() {
  local tool_dir="$1"
  local orgs_dir="$tool_dir/orgs"

  echo -n "Org name (short identifier, e.g. 'work' or 'oldorg'): "
  read -r _jira_org
  [[ -z "$_jira_org" ]] && _jira_org="default"

  local org_file="$orgs_dir/$_jira_org.yml"
  cp "$_CONTEXT_TEMPLATE_DIR/tools/jira/config.yml" "$org_file"

  echo -n "Jira server URL (e.g. https://yourorg.atlassian.net): "
  read -r _jira_server
  if [[ -n "$_jira_server" ]]; then
    sed -i '' "s|^server:.*|server: $_jira_server|" "$org_file"
  fi

  echo -n "Jira login email: "
  read -r _jira_login
  if [[ -n "$_jira_login" ]]; then
    sed -i '' "s|^login:.*|login: $_jira_login|" "$org_file"
  fi

  ln -sf "orgs/$_jira_org.yml" "$tool_dir/config.yml"
  echo "  org '$_jira_org' → active"
}

_cman_rename() {
  local old="$1"
  local new="$2"

  if [[ -z "$old" || -z "$new" ]]; then
    echo "Usage: cman rename <old> <new>" >&2
    return 1
  fi

  local old_ctx="$_CONTEXT_ROOT/$old"
  local new_ctx="$_CONTEXT_ROOT/$new"

  if [[ ! -d "$old_ctx" ]]; then
    echo "Context '$old' not found" >&2
    return 1
  fi

  if [[ -d "$new_ctx" ]]; then
    echo "Context '$new' already exists" >&2
    return 1
  fi

  if [[ "$SHELL_CONTEXT" == "$old" ]]; then
    echo "Context '$old' is currently active — run 'cch' to clear it first" >&2
    return 1
  fi

  if [[ -L "$old_ctx" ]]; then
    echo "Context dir is a symlink — aborting" >&2
    return 1
  fi

  mv "$old_ctx" "$new_ctx"
  echo "Renamed: contexts/$old → contexts/$new"

  local file updated=0
  while IFS= read -r -d $'\0' file; do
    if grep -q "/ws/$old\|CONTEXT_LABEL=\"$old\"\|Context: $old\|paths for $old" "$file" 2>/dev/null; then
      sed -i '' "s|/ws/$old|/ws/$new|g" "$file"
      sed -i '' "s|CONTEXT_LABEL=\"$old\"|CONTEXT_LABEL=\"$new\"|g" "$file"
      sed -i '' "s|# Context: $old|# Context: $new|g" "$file"
      sed -i '' "s|paths for $old context|paths for $new context|g" "$file"
      echo "  Updated: ${file#$new_ctx/}"
      (( updated++ ))
    fi
  done < <(find "$new_ctx" -name '*.sh' -type f -print0)

  [[ "$updated" -eq 0 ]] && echo "  (no file content needed updating)"
}

cman() {
  local subcmd="$1"
  shift 2>/dev/null

  case "$subcmd" in
    new)      _cman_new "$@" ;;
    ls)       _cman_ls "$@" ;;
    edit)     _cman_edit "$@" ;;
    add-tool) _cman_add_tool "$@" ;;
    rename)   _cman_rename "$@" ;;
    *)
      echo "Usage: cman <new|ls|edit|add-tool|rename>" >&2
      echo "  new <name>             Create context from template"
      echo "  ls                     List contexts (* = active)"
      echo "  edit [name]            Open context in \$EDITOR"
      echo "  add-tool <tool> [ctx]  Add tool to context (default: active)"
      echo "  rename <old> <new>     Rename a context"
      return 1
      ;;
  esac
}

# zsh completion for cman
_cman() {
  local -a subcmds
  subcmds=(
    'new:Create context from template'
    'ls:List contexts'
    'edit:Open context in editor'
    'add-tool:Add tool to context'
    'rename:Rename a context'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'cman command' subcmds
    return
  fi

  case "${words[2]}" in
    edit)
      local -a contexts
      local dir="$_CONTEXT_ROOT"
      [[ -d $dir ]] || return 0
      contexts=("$dir"/*(N:t))
      contexts=(${contexts:#_*})
      _describe -t contexts 'context' contexts
      ;;
    add-tool)
      if (( CURRENT == 3 )); then
        local -a tools
        tools=(${(k)_CONTEXT_KNOWN_TOOLS})
        _describe -t tools 'tool' tools
      elif (( CURRENT == 4 )); then
        local -a contexts
        local dir="$_CONTEXT_ROOT"
        [[ -d $dir ]] || return 0
        contexts=("$dir"/*(N:t))
        contexts=(${contexts:#_*})
        _describe -t contexts 'context' contexts
      fi
      ;;
    new)
      # No completion for new context name
      ;;
    rename)
      local -a contexts
      local dir="$_CONTEXT_ROOT"
      [[ -d $dir ]] || return 0
      contexts=("$dir"/*(N:t))
      contexts=(${contexts:#_*})
      _describe -t contexts 'context' contexts
      ;;
  esac
}

compdef _cman cman
