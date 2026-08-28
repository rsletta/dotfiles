# Terminal Setup

## Ghostty (primary)

Config: `ghostty/config.ghostty`

- Theme: TokyoNight Night
- Font: Iosevka Nerd Font, 16pt
- Cursor: bar
- Hidden titlebar
- Keybinds: Cmd+Enter fullscreen, Opt+Left/Right unbound (shell handles them)

## tmux

Config: `tmux/tmux.conf`

- Prefix: **Ctrl-A** (not default Ctrl-B)
- Mode: vi keybindings
- Mouse: enabled (but click-to-focus disabled)
- Status bar: bottom, Tokyo Night theme
- Windows start at 1, renumber on close
- History: 10,000 lines
- Image passthrough enabled

### Keybindings

Not listed here. Every binding carries its own description via `bind -N`, so the config is the only source of truth:

```
prefix + ?      cheatsheet popup (fzf over `tmux list-keys -N`)
```

That covers the ~79 documented bindings including tmux's own defaults. A table in this file would drift from `tmux.conf` the moment either changed.

Worth knowing, since they are not obvious from the list:

| Binding | Why |
|---------|-----|
| `prefix + G` | Open a worktree as a window — fzf over existing ones; type an unmatched name to create it. See [worktrees.md](worktrees.md). |
| `prefix + D` | Remove a worktree checkout, keeping the branch. |
| Shift + drag | Bypasses tmux's mouse capture for Ghostty's native selection. Plain drag copies to the clipboard on release. |

### Plugins (via tpm)

- tmux-sensible — sensible defaults
- tmux-tokyo-night — Tokyo Night (night) theme
- tmux-open — open URLs/files from scrollback
- tmux-copycat — regex search in scrollback
- tmux-yank — system clipboard integration

## WezTerm (experimental)

Config: `wezterm/wezterm.lua`

- Theme: Tokyo Night (night)
- Font: Iosevka Nerd Font, 14pt
- No tab bar (tmux handles tabs)

## Starship prompt

Config: `starship/starship.toml`

Format: `context directory gh_account alvtime_profile git_branch git_status aws kubernetes`

### Custom segments

| Segment | Shows | When |
|---------|-------|------|
| `context` | SHELL_CONTEXT:CONTEXT_ENV | Context is active |
| `gh_account` | GitHub login | GH_CONFIG_DIR is set |
| `alvtime_profile` | Alvtime profile name | Alvtime config exists |

### Kubernetes

Shows context name with aliases for known EKS clusters.
