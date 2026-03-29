# ── Writing System ─────────────────────────────────────────────────────────
# All writing commands require an active context with writing paths configured.
# Set a context first: cch <context>
#
# Context vars:
#   CONTEXT_VAULT_PATH      — Obsidian vault root
#   CONTEXT_TIL_PATH        — where TIL files live (blog dir or vault folder)
#   CONTEXT_TIL_TEMPLATE    — path to TIL frontmatter template
#   CONTEXT_POST_PATH       — where blog posts/articles live
#   CONTEXT_POST_TEMPLATE   — path to post frontmatter template

_WRITING_SCRIPTS="$HOME/.config/dotfiles/scripts"

# ── Internal helpers ────────────────────────────────────────────────────────

_writing_die() { echo "writing: $1" >&2; return 1; }

_writing_require_vault() {
  [[ -n "$CONTEXT_VAULT_PATH" ]] || _writing_die "CONTEXT_VAULT_PATH not set. Run: cch <context>"
}

_writing_date() { date +%Y-%m-%d; }

_writing_slugify() {
  local str="${1//[![:alnum:] ]/}"
  str="${str,,}"
  str="${str% }"
  str="${str// /-}"
  echo "${str:?Cannot generate slug}"
}

_ensure_obsidian() {
  pgrep -x Obsidian > /dev/null 2>&1 || open -a Obsidian
}

# ── notes ───────────────────────────────────────────────────────────────────

_notes_daily() {
  _writing_require_vault || return 1

  local date filepath
  date=$(_writing_date)
  filepath="$CONTEXT_VAULT_PATH/Daily Notes/$date.md"

  if [[ ! -f "$filepath" ]]; then
    cat > "$filepath" << EOF
---
tags:
  - 📝
---
# Daily Note: $(date "+%A %-d. %B %Y")

## Goals
-

## Tasks
- [ ]

## Reflections
-

## Accomplishments
-

## Miscellaneous
EOF
  fi

  ${EDITOR:-nvim} "$filepath"
}

_notes_new() {
  _writing_require_vault || return 1

  local title="$1"
  [[ -n "$title" ]] || { _writing_die "Usage: notes <title>"; return 1; }

  local date slug filepath
  date=$(_writing_date)
  slug=$(_writing_slugify "$title")
  filepath="$CONTEXT_VAULT_PATH/Inbox/$date-$slug.md"

  if [[ ! -f "$filepath" ]]; then
    cat > "$filepath" << EOF
# $title
Date: $date
EOF
  fi

  ${EDITOR:-nvim} "$filepath"
}

_notes_search() {
  _writing_require_vault || return 1

  local strict=0
  [[ "$1" == "-s" ]] && { strict=1; shift; }

  local query="$1"
  local selected file line
  local case_flag="--ignore-case"
  [[ $strict -eq 1 ]] && case_flag=""

  if [[ -n "$query" ]]; then
    selected=$(
      rg --line-number --with-filename --color=always \
         --glob="*.md" \
         --iglob="!.obsidian" \
         --iglob="!__templates" \
         $case_flag \
         "$query" "$CONTEXT_VAULT_PATH" \
        | fzf --ansi --delimiter=: \
              --preview "bat --color=always --highlight-line={2} {1}" \
              --preview-window=right:60%
    )
    [[ -z "$selected" ]] && return 0
    file=$(echo "$selected" | cut -d: -f1)
    line=$(echo "$selected" | cut -d: -f2)
    ${EDITOR:-nvim} "+$line" "$file"
  else
    selected=$(
      find "$CONTEXT_VAULT_PATH" -name "*.md" \
        -not -path "*/.obsidian/*" \
        -not -path "*/__templates/*" \
        | fzf --preview "bat --color=always {}" \
              --preview-window=right:60%
    )
    [[ -z "$selected" ]] && return 0
    ${EDITOR:-nvim} "$selected"
  fi
}

notes() {
  local cmd="$1"

  case "$cmd" in
    daily)  _notes_daily ;;
    new)    shift; _notes_new "$@" ;;
    search) shift; _notes_search "$@" ;;
    *)
      echo "Usage: notes <command>"
      echo ""
      echo "Commands:"
      echo "  daily          Open today's daily note"
      echo "  new <title>    Create new inbox note"
      echo "  search [q]     Search vault"
      ;;
  esac
}

_notes() {
  local -a subcommands
  subcommands=(
    'daily:Open today'\''s daily note'
    'new:Create new inbox note'
    'search:Search vault'
  )
  _describe -t subcommands 'notes command' subcommands
}

compdef _notes notes

# ── til ─────────────────────────────────────────────────────────────────────

til() {
  "$_WRITING_SCRIPTS/til" "$@"
}
