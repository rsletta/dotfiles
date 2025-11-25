tla() {
  # Tmux list and attach to session
  tmux a -t $(tmux ls -F '#S' | fzf --layout=reverse --border --info=inline --margin=8,20)
}

tns() {
  newTmuxSession $1
}

# add new alias to alias file
function aali() {
    if [[ -z $1 || -z $2 || $# -gt 2 ]]; then
        echo usage:
        echo "\t\$$0 <alias> '<command>'"
        echo example:
        echo "\t\$$0 ll 'ls -l'"
    else
        echo "" >> $ALIAS_FILE
        echo "alias $1='$2'" >> $ALIAS_FILE
        echo "alias ADDED to $ALIAS_FILE"
        reload
    fi
}

function _set_kube_config() {
    local NAME=$1

    if [ -z "$NAME" ]; then
        unset KUBECONFIG
        echo "KUBECONFIG is now <unset>"
        return 0
    fi

    local DIR=~/.kube/config.d
    local TARGET=$DIR/$NAME

    if [ ! -e $TARGET ]; then
        echo "Error: $TARGET does not exist" >&2
    fi

    export KUBECONFIG=$TARGET
    echo "KUBECONFIG is now $KUBECONFIG"
    echo "  using context '$(yq .current-context $KUBECONFIG)'"
}
alias ku=_set_kube_config

complete -W "$(ls ~/.kube/config.d)" _set_kube_config


function _start_opencode() {

  export CONTEXT7_API_KEY=op://Personal/Context7/Credentials/api_key

  op run --no-masking -- opencode "$@"
}

alias oc=_start_opencode

function _set_spenn_cli_profile() {
  local PROFILE=$1

  if [ -z "$PROFILE" ]; then
    unset SPENN_CLI_PROFILE
    echo "SPENN_CLI_PROFILE is now <unset>"
    return 0
  fi

  export SPENN_CLI_PROFILE=$PROFILE
  echo "SPENN_CLI_PROFILE is now $SPENN_CLI_PROFILE"
}

alias chsp=_set_spenn_cli_profile
complete -W "$(spenn profile list)" _set_spenn_cli_profile

function _set_aws_profile() {
  local A_TARGET=$1

  if [ -z "$A_TARGET" ]; then
    unset AWS_PROFILE
    echo "AWS_PROFILE is now <unset>"
    return 0
  fi

  export AWS_PROFILE=$A_TARGET
  echo "AWS_PROFILE is now $AWS_PROFILE"
}

alias awsp=_set_aws_profile
complete -W "$(aws configure list-profiles)" _set_aws_profile

alias awsso="aws sso login"
