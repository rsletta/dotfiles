repos() {
	cd ~/repositories/$1
}


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
