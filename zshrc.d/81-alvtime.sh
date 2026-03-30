alias a='alvtime'
eval "$(_ALVTIME_COMPLETE=zsh_source ~/.local/bin/alvtime)"

# Cache alvtime profile for starship prompt (avoids grep on every prompt render)
_cache_alvtime_profile() {
  if [[ -n "$ALVTIME_CONFIG" ]] && [[ -f "$ALVTIME_CONFIG" ]]; then
    export _ALVTIME_PROFILE=$(grep "^profile:" "$ALVTIME_CONFIG" 2>/dev/null | awk '{print $2}')
  elif [[ -f "$HOME/.alvtime.conf" ]]; then
    export _ALVTIME_PROFILE=$(grep "^profile:" "$HOME/.alvtime.conf" 2>/dev/null | awk '{print $2}')
  else
    export _ALVTIME_PROFILE=""
  fi
}
_cache_alvtime_profile
