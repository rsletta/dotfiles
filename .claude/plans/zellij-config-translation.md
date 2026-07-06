# Zellij config translation

Concrete edits to `zellij/config.kdl` implementing `zellij-from-tmux.md`.
Single-file change. Existing config is zellij's stock default scaffold.

## Edits

### Top-level settings
1. [ ] `theme "tokyo-night-storm"` → `theme "gruvbox-dark"` (line 321).
2. [ ] Uncomment + set `default_layout "compact"` (line ~327).
3. [ ] Uncomment + set `copy_command "pbcopy"` (line ~361).

### Keybinds (disable tmux-emulation mode)
4. [ ] Change `keybinds {` → `keybinds clear-defaults=true {` (line 2).
   File already mirrors full default scaffold — flag flips it to authoritative.
5. [ ] Delete `tmux { ... }` block (lines 146–168).
6. [ ] Delete `shared_except "tmux" "locked" { ... }` block (lines 206–208).

### Manual verification
7. [ ] Launch fresh zellij session; gruvbox palette visible.
8. [ ] Single-line compact-bar at bottom; no top tab-bar.
9. [ ] `Ctrl-b` does nothing (tmux mode gone).
10. [ ] `Ctrl-p` → `d`/`r`/`n` splits; new pane inherits cwd.
11. [ ] `Ctrl-t` → `n` new tab in cwd; `1`–`9` jumps.
12. [ ] Mouse drag-select; `pbpaste` returns selection.
13. [ ] `Ctrl-s` enters scroll mode; `s` searches.

## Scope

- `tmux/` config untouched. This is an experiment; tmux remains usable.

## Unresolved questions

(none)
