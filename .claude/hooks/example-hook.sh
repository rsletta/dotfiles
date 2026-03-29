#!/bin/bash
set -e
INPUT=$(cat)

# Only fire once per session
MARKER="$TMPDIR/.claude-greeted-$$"
[ -f "$MARKER" ] && exit 0
touch "$MARKER"

FORTUNES=(
  "May your tests pass on the first try."
  "Remember: git stash is not a backup strategy."
  "A clean diff is a happy diff."
  "Today is a good day to write tests."
  "Refactor not, lest ye be refactored."
)

MSG="${FORTUNES[$((RANDOM % ${#FORTUNES[@]}))]}"

if command -v cowsay &>/dev/null; then
  cowsay "$MSG" >&2
else
  echo "🐮 $MSG" >&2
fi

exit 0
