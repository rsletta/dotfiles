# One way in and out of tmux, inside or outside a session.
#
#   t          pick a session with fzf (starts one here if none are running)
#   t <name>   go to <name>, creating it at $PWD if it does not exist
#
# tmux's own `new-session -A` covers create-or-attach, but only from OUTSIDE a
# session — inside one it refuses with "sessions should be nested with care".
# Hence the explicit switch-client/attach-session branch. `-e` carries the
# active context into a session at creation; see zshrc.d/71-contexts.sh for why
# that is done here rather than via tmux's update-environment.
t() {
  local name="$1"

  if [[ -z "$name" ]]; then
    local -a sessions
    sessions=(${(f)"$(tmux ls -F '#S' 2>/dev/null)"})
    if (( ${#sessions} == 0 )); then
      name="${${PWD:t}//[^a-zA-Z0-9_-]/-}"   # nothing running — start one here
    else
      name=$(print -l -- $sessions | fzf --layout=reverse --border --info=inline --margin=8,20) || return 0
      [[ -n "$name" ]] || return 0
    fi
  fi

  # An array, not ${VAR:+...}: zsh does not word-split unquoted expansions, so
  # the inline form would pass `-e SHELL_CONTEXT=x` as ONE argument.
  local -a ctx_arg=()
  [[ -n "$SHELL_CONTEXT" ]] && ctx_arg=(-e "SHELL_CONTEXT=$SHELL_CONTEXT")

  tmux has-session -t "$name" 2>/dev/null ||
    tmux new-session -d -s "$name" -c "$PWD" "${ctx_arg[@]}" || return 1

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi
}

_t() {
  local -a sessions
  sessions=(${(f)"$(tmux ls -F '#S' 2>/dev/null)"})
  (( ${#sessions} )) && _describe -t sessions 'tmux session' sessions
}
compdef _t t

# add new alias to alias file
function aali() {
    if [[ -z $1 || -z $2 || $# -gt 2 ]]; then
        echo "aali — add a new alias to $ALIAS_FILE"
        echo ""
        echo "Usage:"
        echo "  aali <name> '<command>'"
        echo ""
        echo "Examples:"
        echo "  aali ll 'ls -la'"
        echo "  aali gs 'git status'"
        echo "  aali k 'kubectl'"
        echo ""
        echo "Note: wrap the command in single quotes. Reload is automatic."
        return 0
    fi
    echo "" >> $ALIAS_FILE
    echo "alias $1='$2'" >> $ALIAS_FILE
    echo "alias '$1' added to $ALIAS_FILE"
    reload
}

function _start_opencode() {

  export CONTEXT7_API_KEY=op://Personal/Context7/Credentials/api_key

  op run --no-masking -- opencode "$@"
}

alias oc=_start_opencode

# Workaround for cli/cli#12885 — gh's keychain lookup ignores the account
# field, so go-gh tools (e.g. gh-dash) get an arbitrary token under multi-account
# setups. Pin GH_TOKEN to the active context's user for this invocation only.
gh-dash() {
  GH_TOKEN="$(_gh_token_for_user "$GH_USER")" command gh dash "$@"
}
alias ghd=gh-dash
