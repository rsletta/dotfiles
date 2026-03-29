# Tool functions that integrate with the context system
# These stay usable independently, but completions are scoped when a context is active

# --- Kubernetes ---

function _set_kube_config() {
    local NAME=$1

    if [[ -z "$NAME" ]]; then
        unset KUBECONFIG
        echo "KUBECONFIG is now <unset>"
        return 0
    fi

    local DIR=~/.kube/config.d
    local TARGET="$DIR/$NAME"

    if [[ ! -e "$TARGET" ]]; then
        echo "Error: $TARGET does not exist" >&2
        return 1
    fi

    export KUBECONFIG="$TARGET"
    echo "KUBECONFIG is now $KUBECONFIG"
    echo "  using context '$(yq .current-context "$KUBECONFIG")'"
}

alias ku=_set_kube_config
compdef _ku ku _set_kube_config

# --- AWS ---

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

# Context-aware completion for awsp
# When a context is active with AWS config: only show profiles from that config
# When no context: show all configured profiles
_awsp_completion() {
    local -a profiles

    if [[ -n "$AWS_CONFIG_FILE" ]] && [[ -f "$AWS_CONFIG_FILE" ]]; then
        profiles=(${(f)"$(grep '^\[profile ' "$AWS_CONFIG_FILE" 2>/dev/null | sed 's/\[profile //' | sed 's/\]//')"})
        # Also include [default] if present
        if grep -q '^\[default\]' "$AWS_CONFIG_FILE" 2>/dev/null; then
            profiles+=(default)
        fi
    else
        profiles=(${(f)"$(aws configure list-profiles 2>/dev/null)"})
    fi

    compadd -- "${profiles[@]}"
}

compdef _awsp_completion awsp _set_aws_profile

alias awsso="aws sso login"
