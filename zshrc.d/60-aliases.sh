#z Utility replacement
alias els='eza --group-directories-first --icons'
alias ell='eza -l --group-directories-first --icons'
alias ela='eza -la --group-directories-first --icons'
alias elt='eza -T --level=2 --group-directories-first --icons'
alias ellt='eza -lT --level=2 --group-directories-first --icons'
alias elsg='eza --git --long --all --icons'
alias eldu='eza -lh --total-size --only-dirs'
alias elsp='eza -la --icons --color=always | less -R'
alias elss='eza -l --sort=size --reverse --icons'
alias elsd='eza -l --only-dirs --icons'

alias zz='z -'      # gå til forrige katalog
alias zf='zoxide query -l | fzf'   # fuzzy jump
alias zj='cd "$(zoxide query -l | fzf)"'  # jump til valgt
alias ze='cd "$(zoxide query -l | fzf)" && nvim .'  # jump + open in Neovim
alias zl='zoxide query -l | fzf --preview "eza -T --level=2 --icons {}"'
alias zla='cd "$(zoxide query -l | fzf)" && eza -la --icons'

# Folder traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias dot='cd ~/.config/dotfiles'

# Git
alias gs='git status'
alias gc='git commit'
alias gd='git diff'

# Serve directory with http
alias sd='python3 -m http.server'

# the great switch
alias vim='nvim'
alias vi='nvim'

# Asciinema
alias rec='asciinema rec'

# refresh shell
alias reload='source ~/.zshrc'

# Some arch hacks to force arm64 or x86_64
# Check if the system is macOS
if [[ $(uname) == Darwin ]]; then
    # Aliases for forcing architecture
    alias arm="env /usr/bin/arch -arm64 /bin/bash --login"
    alias intel="env /usr/bin/arch -x86_64 /bin/bash --login"

    # Set brew alias based on architecture
    if [[ $(arch) == i386 ]]; then
        alias brew='/usr/local/bin/brew'
    else
        alias brew='/opt/homebrew/bin/brew'
    fi
fi

alias conf='cd ~/.config'

alias lazyg='lazygit'

alias tf='terraform'

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

alias lazyd='lazydocker'
