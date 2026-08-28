#!/usr/bin/env bash
# Reports divergence in the common core across Claude Code contexts.
#
# Read-only by design: it never copies, edits, or symlinks anything. Contexts stay
# isolated; this only tells you where they have drifted so propagation is a deliberate
# act rather than something you discover months later.
#
# Move this outside the contexts (e.g. into your dotfiles) so no single context owns it.
#
#   check-context-drift.sh

CONTEXTS=(
  "$HOME/.config/contexts/alv/tools/claude"
  "$HOME/.config/contexts/rsletta/tools/claude"
  "$HOME/.config/contexts/spirgroup/tools/claude"
)

# Files expected to be byte-identical everywhere. Deliberate divergences
# (permission mode, plugins, model, git policy) are intentionally absent.
COMMON_FILES=(
  hooks/block-sensitive-files.sh
  hooks/block-askuserquestion.sh
  statusline-command.sh
  test-statusline.sh
)

# Files that share a purpose but are expected to differ per context. Reported for
# awareness only, never as drift. test-hooks.sh belongs here because it must track
# whatever block-vcs-writes.sh does in that context — spirgroup denies git commit,
# so its suite is deliberately larger.
INFORMATIONAL_FILES=(
  hooks/block-vcs-writes.sh
  hooks/test-hooks.sh
  CLAUDE.md
)

# settings.json keys that should agree across contexts.
COMMON_SETTINGS=(
  '.attribution'
  '.autoUpdatesChannel'
)

drift=0
label() { basename "$(dirname "$(dirname "$1")")"; }

echo "== common files (must be identical) =="
for f in "${COMMON_FILES[@]}"; do
  sums=$(for c in "${CONTEXTS[@]}"; do md5 -q "$c/$f" 2>/dev/null || echo MISSING; done | sort -u | wc -l | tr -d ' ')
  if [ "$sums" -eq 1 ]; then
    printf '  ok    %s\n' "$f"
  else
    drift=1
    printf '  DRIFT %s\n' "$f"
    for c in "${CONTEXTS[@]}"; do
      printf '          %-12s %s\n' "$(label "$c")" "$(md5 -q "$c/$f" 2>/dev/null | cut -c1-8 || echo MISSING)"
    done
  fi
done

echo
echo "== common settings keys (must agree) =="
for k in "${COMMON_SETTINGS[@]}"; do
  vals=$(for c in "${CONTEXTS[@]}"; do jq -c "$k // \"unset\"" "$c/settings.json" 2>/dev/null || echo MISSING; done | sort -u | wc -l | tr -d ' ')
  if [ "$vals" -eq 1 ]; then
    printf '  ok    %s\n' "$k"
  else
    drift=1
    printf '  DRIFT %s\n' "$k"
    for c in "${CONTEXTS[@]}"; do
      printf '          %-12s %s\n' "$(label "$c")" "$(jq -c "$k // \"unset\"" "$c/settings.json" 2>/dev/null || echo MISSING)"
    done
  fi
done

echo
echo "== per-context divergence (informational, not drift) =="
for f in "${INFORMATIONAL_FILES[@]}"; do
  printf '  %-28s' "$f"
  for c in "${CONTEXTS[@]}"; do
    printf ' %s=%s' "$(label "$c")" "$(md5 -q "$c/$f" 2>/dev/null | cut -c1-6 || echo ---)"
  done
  echo
done

echo
echo "== test suites =="
for c in "${CONTEXTS[@]}"; do
  printf '  %-12s' "$(label "$c")"
  for suite in hooks/test-hooks.sh test-statusline.sh; do
    if [ -f "$c/$suite" ]; then
      result=$( (cd "$c" && bash "$suite" 2>&1 | tail -1) )
      printf '  %-14s %s' "$(basename "$suite" .sh)" "$result"
      case "$result" in *"failed 0"*) ;; *) drift=1 ;; esac
    else
      printf '  %-14s MISSING' "$(basename "$suite" .sh)"
      drift=1
    fi
  done
  echo
done

echo
[ "$drift" -eq 0 ] && echo "common core in sync" || echo "DRIFT DETECTED — propagate by copying, never by symlinking"
exit "$drift"
