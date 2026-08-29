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

# Known tools and their setup.sh cexport lines
# Key = tool name, Value = cexport line template ($CONTEXT_DIR is available at runtime)
typeset -A _CONTEXT_KNOWN_TOOLS
_CONTEXT_KNOWN_TOOLS=(
  gh      'cexport GH_CONFIG_DIR="$CONTEXT_DIR/tools/gh"'
  aws     'cexport AWS_CONFIG_FILE="$CONTEXT_DIR/tools/aws/config"\ncexport AWS_SHARED_CREDENTIALS_FILE="$CONTEXT_DIR/tools/aws/credentials"'
  docker  'cexport DOCKER_CONFIG="$CONTEXT_DIR/tools/docker"'
  azure   'cexport AZURE_CONFIG_DIR="$CONTEXT_DIR/tools/azure"'
  gcloud  'cexport CLOUDSDK_CONFIG="$CONTEXT_DIR/tools/gcloud"'
  helm    'cexport HELM_CONFIG_HOME="$CONTEXT_DIR/tools/helm"'
  terraform 'cexport TF_CLI_CONFIG_FILE="$CONTEXT_DIR/tools/terraform/terraformrc"'
  jira    'cexport JIRA_CONFIG_FILE="$CONTEXT_DIR/tools/jira/config.yml"'
  codex   'cexport CODEX_HOME="$CONTEXT_DIR/tools/codex"'
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
    local writing_exports="cexport CONTEXT_VAULT_PATH=\"$vault_path\"\ncexport CONTEXT_TIL_PATH=\"$vault_path/TIL\"\ncexport CONTEXT_TIL_TEMPLATE=\"\$HOME/.config/dotfiles/templates/writing/til.md\"\ncexport CONTEXT_POST_PATH=\"$vault_path/posts\"\ncexport CONTEXT_POST_TEMPLATE=\"\$HOME/.config/dotfiles/templates/writing/post.md\""
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

  local skills_dir="$tool_dir/skills"
  mkdir -p "$skills_dir"

  local target="$name-skills"
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
    echo "  Tip: add JIRA_API_TOKEN to tools/setup.sh:"
    echo "    cexport JIRA_API_TOKEN=\"op://<Vault>/<Item>/<field>\""
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
  printf '\ncexport JIRA_API_TOKEN="%s"\n' "$op_ref" >> "$ctx_dir/tools/setup.sh"
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

# --- inspection -------------------------------------------------------------
#
# The context system works by sourcing files you never see. That is the point,
# and it is also the failure mode: things get set up, forgotten, and drift.
# `cman show` and `cman doctor` exist so the state is always one command away
# rather than something you have to remember to go looking for.

# Describe a value WITHOUT ever printing a secret.
_cman_describe_value() {
  local name="$1" val="$2" dir="$3" shown

  [[ -z "$val" ]] && { print -r -- "(empty)"; return }
  [[ "$val" == op://* ]] && { print -r -- "1password ref"; return }

  case "${name:u}" in
    *TOKEN*|*SECRET*|*PASSWORD*|*CREDENTIAL*|*API_KEY*|*APIKEY*)
      print -r -- "PLAINTEXT SECRET (${#val} chars)"; return ;;
  esac

  if [[ "$val" == /* ]]; then
    if [[ -n "$dir" && "$val" == "$dir"/* ]]; then shown="${val#$dir/}"
    else                                           shown="${val/#$HOME/~}"; fi
    [[ -e "$val" ]] && print -r -- "-> $shown" || print -r -- "-> $shown  (MISSING)"
    return
  fi

  print -r -- "$val"
}

# name=value for every var a context exports. Live shell if it is the active
# context, otherwise a throwaway subshell so nothing leaks into this one.
_cman_context_vars() {
  local ctx="$1" dir="$_CONTEXT_ROOT/$1" v

  if [[ "$ctx" == "$SHELL_CONTEXT" ]]; then
    for v in ${(o)_CONTEXT_EXPORTED_VARS}; do print -r -- "$v=${(P)v}"; done
    return
  fi

  CONTEXT_DIR="$dir" zsh -f -c '
    typeset -ga _V=()
    cexport() { local a; for a in "$@"; do _V+=("${a%%=*}"); done; export "$@" }
    # read the cache rather than hitting the network for another context
    _gh_user_cached() { [[ -f "$CONTEXT_DIR/.cache/gh_user" ]] && cat "$CONTEXT_DIR/.cache/gh_user" }
    source "$1/config.sh"
    [[ -f "$1/tools/setup.sh" ]] && source "$1/tools/setup.sh"
    [[ -f "$1/tools/kube.sh" ]]  && source "$1/tools/kube.sh"
    local v; for v in ${(o)_V}; do print -r -- "$v=${(P)v}"; done
  ' zsh "$dir" 2>/dev/null
}

_cman_show() {
  local ctx="${1:-$SHELL_CONTEXT}"
  if [[ -z "$ctx" ]]; then
    echo "No context active. Usage: cman show [name]" >&2
    return 1
  fi

  local dir="$_CONTEXT_ROOT/$ctx"
  [[ -d "$dir" ]] || { echo "Context '$ctx' not found" >&2; return 1 }

  local live="" ; [[ "$ctx" == "$SHELL_CONTEXT" ]] && live="  (active in this shell)"
  print -r -- "context: $ctx$live"
  print -r -- "  dir:   ${dir/#$HOME/~}"

  print -r -- ""
  print -r -- "  sourced on cch:"
  local f n
  for f in config.sh tools/setup.sh tools/kube.sh; do
    [[ -f "$dir/$f" ]] || continue
    n=$(grep -cE '^[[:space:]]*cexport ' "$dir/$f" 2>/dev/null)
    print -r -- "    $f ($n exports)"
  done

  print -r -- ""
  local -a lines; lines=(${(f)"$(_cman_context_vars "$ctx")"})
  print -r -- "  exports (${#lines}):"
  local l name val
  for l in $lines; do
    name="${l%%=*}"; val="${l#*=}"
    printf '    %-42s %s\n' "$name" "$(_cman_describe_value "$name" "$val" "$dir")"
  done

  print -r -- ""
  print -r -- "  tool dirs:"
  local t cnt
  for t in "$dir"/tools/*(N/); do
    cnt=$(ls -A "$t" 2>/dev/null | wc -l | tr -d ' ')
    printf '    %-14s %s\n' "${t:t}" "$cnt entries$( (( cnt == 0 )) && print -n '   <- empty')"
  done
}

_cman_doctor() {
  local -a contexts; contexts=("$_CONTEXT_ROOT"/*(N:t)); contexts=(${contexts:#_*})
  # All locals declared ONCE: re-running `local x` in the same scope makes zsh
  # print x's current value, which would spray the report with debug lines.
  local issues=0 ctx dir l name val t marker ss_target ss_dir
  local -a found

  for ctx in $contexts; do
    dir="$_CONTEXT_ROOT/$ctx"
    found=()

    while IFS= read -r l; do
      [[ -n "$l" ]] || continue
      name="${l%%=*}"; val="${l#*=}"
      case "${name:u}" in
        *TOKEN*|*SECRET*|*PASSWORD*|*CREDENTIAL*|*API_KEY*|*APIKEY*)
          [[ "$val" == op://* || -z "$val" ]] || found+=("plaintext secret: $name (use an op:// ref)") ;;
      esac
      [[ "$val" == /* && ! -e "$val" ]] && found+=("$name points at a missing path")
    done < <(_cman_context_vars "$ctx")

    for t in "$dir"/tools/*(N/); do
      [[ -z "$(ls -A "$t" 2>/dev/null)" ]] && found+=("tools/${t:t}/ is empty")
    done

    [[ -f "$dir/tools/kube.sh" ]] && ! grep -qE '^[[:space:]]*CONTEXT_KUBE_CONFIGS=\([^)]' "$dir/tools/kube.sh" \
      && found+=("kube.sh declares no kubeconfigs — ku completion is unscoped here")

    marker="$dir/tools/skillshare/installed"
    if [[ -f "$marker" ]] && command -v skillshare &>/dev/null; then
      # NB: never `local path` in zsh — it is tied to $PATH and clobbers it.
      ss_target=$(awk -F': ' '/^target:/ {print $2}' "$marker")
      ss_dir=$(awk -F': ' '/^skills:/ {print $2}' "$marker")
      if [[ -n "$ss_target" ]]; then
        skillshare target list 2>/dev/null | grep -qF -- "$ss_target" \
          || found+=("skillshare target '$ss_target' is in the marker but not registered")
      fi
      [[ -n "$ss_dir" && ! -d "$ss_dir" ]] && found+=("skillshare skills dir missing: ${ss_dir/#$HOME/~}")
    fi

    if (( ${#found} )); then
      issues=1
      print -r -- "$ctx:"
      printf '  - %s\n' $found
    else
      print -r -- "$ctx: ok"
    fi
  done

  print -r -- ""
  (( issues )) && print -r -- "issues found" || print -r -- "all contexts healthy"
  return $issues
}

cman() {
  local subcmd="$1"
  shift 2>/dev/null

  case "$subcmd" in
    new)      _cman_new "$@" ;;
    ls)       _cman_ls "$@" ;;
    edit)     _cman_edit "$@" ;;
    add-tool) _cman_add_tool "$@" ;;
    show)     _cman_show "$@" ;;
    doctor)   _cman_doctor "$@" ;;
    *)
      echo "Usage: cman <new|ls|edit|add-tool|show|doctor>" >&2
      echo "  new <name>             Create context from template"
      echo "  ls                     List contexts (* = active)"
      echo "  edit [name]            Open context in \$EDITOR"
      echo "  add-tool <tool> [ctx]  Add tool to context (default: active)"
      echo "  show [name]            What a context sets (default: active)"
      echo "  doctor                 Health-check every context"
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
    'show:Show what a context sets'
    'doctor:Health-check every context'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'cman command' subcmds
    return
  fi

  case "${words[2]}" in
    show|edit)
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
  esac
}

compdef _cman cman
