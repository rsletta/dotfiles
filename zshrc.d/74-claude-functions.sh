CLAUDE_TEMPLATE_DIR="$HOME/.config/dotfiles/templates/claude-bootstrap"

function klaude() {
  if [[ -z "$SHELL_CONTEXT" ]]; then
    echo "klaude: no active context. Run: cch <context>" >&2
    return 1
  fi
  local extra_dirs=()
  for dir in "$@"; do
    extra_dirs+=(--add-dir "$dir")
  done
  claude "${extra_dirs[@]}"
}

compdef '_files -/' klaude

function klaude-init() {
  local target
  target="$(pwd)"

  local MAUVE='\033[38;5;139m'
  local GOLD='\033[38;5;178m'
  local TEAL='\033[38;5;73m'
  local GREEN='\033[38;5;114m'
  local DIM='\033[2m'
  local BOLD='\033[1m'
  local RESET='\033[0m'

  printf "${MAUVE}  █ █ █   █▀█ █ █ █▀▄ █▀▀   ${GOLD}█ █▄ █ █ ▀█▀${RESET}\n"
  printf "${MAUVE}  █▀▄ █   █▀█ █ █ █ █ █▀▀   ${GOLD}█ █ ▀█ █  █${RESET}\n"
  printf "${MAUVE}  ▀ ▀ ▀▀▀ ▀ ▀ ▀▀▀ ▀▀  ▀▀▀   ${GOLD}▀ ▀  ▀ ▀  ▀${RESET}\n"
  echo ""

  printf "  ${DIM}target:${RESET}  ${BOLD}%s${RESET}\n\n" "$target"
  printf "  ${TEAL}├── .claude/${RESET}          project config, hooks, plans, skills\n"
  printf "  ${TEAL}├── CLAUDE.md${RESET}         project guidelines skeleton\n"
  printf "  ${TEAL}└── .gitignore${RESET}        append claude ignores if needed\n"
  echo ""
  printf "  ${BOLD}Continue? [y/N]${RESET} "
  read -r reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "aborted"
    return 0
  fi

  if [ -d .claude ]; then
    printf "  ${GOLD}.claude/${RESET} already exists. ${BOLD}[m]erge / [r]eplace / [s]kip?${RESET} "
    read -r claude_dir_reply
    case "$claude_dir_reply" in
      m|M)
        cp -rn "$CLAUDE_TEMPLATE_DIR/.claude/" .claude/
        printf "  ${DIM}merged template into .claude/ (existing files kept)${RESET}\n"
        ;;
      r|R)
        rm -rf .claude
        cp -r "$CLAUDE_TEMPLATE_DIR/.claude" .
        printf "  ${DIM}replaced .claude/ with template${RESET}\n"
        ;;
      *)
        printf "  ${DIM}skipped .claude/${RESET}\n"
        ;;
    esac
  else
    cp -r "$CLAUDE_TEMPLATE_DIR/.claude" .
  fi

  if [ -f CLAUDE.md ]; then
    printf "  ${GOLD}CLAUDE.md${RESET} already exists. ${BOLD}[a]ppend to template / [r]eplace / [s]kip?${RESET} "
    read -r claude_md_reply
    case "$claude_md_reply" in
      a|A)
        local existing
        existing="$(cat CLAUDE.md)"
        cp "$CLAUDE_TEMPLATE_DIR/CLAUDE.md" .
        printf "\n---\n\n## Existing Content\n\n%s\n" "$existing" >> CLAUDE.md
        printf "  ${DIM}appended existing content to template CLAUDE.md${RESET}\n"
        ;;
      r|R)
        cp "$CLAUDE_TEMPLATE_DIR/CLAUDE.md" .
        printf "  ${DIM}replaced CLAUDE.md with template${RESET}\n"
        ;;
      *)
        printf "  ${DIM}skipped CLAUDE.md${RESET}\n"
        ;;
    esac
  else
    cp "$CLAUDE_TEMPLATE_DIR/CLAUDE.md" .
  fi

  # Claude-specific gitignore entries
  read -r -d '' CLAUDE_IGNORES <<'EOF'
### Claude Code ###
.claude/local/*
!.claude/local/.gitkeep
.claude/plans/local/*
!.claude/plans/local/.gitkeep
.claude/settings.local.json
EOF

  if [ -f .gitignore ]; then
    if ! grep -q "### Claude Code ###" .gitignore; then
      echo "$CLAUDE_IGNORES" >> .gitignore
      printf "  ${DIM}appended claude ignores to .gitignore${RESET}\n"
    else
      printf "  ${DIM}.gitignore already has claude ignores, skipping${RESET}\n"
    fi
  else
    echo "$CLAUDE_IGNORES" > .gitignore
    printf "  ${DIM}created .gitignore with claude ignores${RESET}\n"
  fi

  printf "\n  ${GREEN}✓${RESET} ${BOLD}Ready.${RESET} Edit ${TEAL}CLAUDE.md${RESET} and ${TEAL}.claude/settings.json${RESET} for your project.\n"
}
