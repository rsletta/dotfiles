tla() {
  # Tmux list and attach to session
  if [[ -n "$TMUX" ]]; then
    echo "You're already in tmux. Use ctrl+a s like a normal person."
    return 1
  fi
  tmux a -t "$(tmux ls -F '#S' | fzf --layout=reverse --border --info=inline --margin=8,20)"
}

tns() {
  newTmuxSession "$1"
}

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
