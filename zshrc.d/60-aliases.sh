# Utility replacement
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons'
alias la='eza -la --group-directories-first --icons'
alias lt='eza -T --level=2 --group-directories-first --icons'
alias llt='eza -lT --level=2 --group-directories-first --icons'
alias lsg='eza --git --long --all --icons'
alias ldu='eza -lh --total-size --only-dirs'
alias lsp='eza -la --icons --color=always | less -R'
alias lss='eza -l --sort=size --reverse --icons'
alias lsd='eza -l --only-dirs --icons'

alias cd='z'        # gjør `cd` smart
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
alias '~'='cd ~/'
alias dot='cd ~/.config/dotfiles'
alias vault='cd ~/vault'

# Git
alias gs='git status'
alias gc='git commit'
alias gd='git diff'

# Notes
alias dn='dailyNote'
alias qrn='quickReadNote'
alias nn='newNote'

# Serve directory with http
alias sd='python3 -m http.server'

# ls alias with color-mode
#alias lh='ls -lha --color=auto'
#alias ls='ls -Fh --color=auto'
#alias l.='ls -d .* --color=auto'

# the great switch
alias vim='nvim'
alias vi='nvim'
alias cat='bat'

# Asciinema
alias rec='asciinema rec'

# refresh shell
alias reload='source ~/.zshrc'

# Some arch hacks to force arm64 or x86_64
# Check if the system is macOS
if [ "$(uname)" = "Darwin" ]; then
    # Aliases for forcing architecture
    alias arm="env /usr/bin/arch -arm64 /bin/bash --login"
    alias intel="env /usr/bin/arch -x86_64 /bin/bash --login"

    # Set brew alias based on architecture
    if [ "$(arch)" = "i386" ]; then
        alias brew='/usr/local/bin/brew'
    else
        alias brew='/opt/homebrew/bin/brew'
    fi
fi

alias conf='/Users/rsletta/.config'

alias conf='cd ~/.config'

alias lg='lazygit'

alias w='watson'

alias tf='terraform'

alias jts='java --add-exports=java.desktop/com.apple.eawt=ALL-UNNAMED -jar /Users/rsletta/.local/bin/search.jar'
