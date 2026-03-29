# Terminal Setup

## Ghostty (primary)

Config: `ghostty/config`

- Theme: TokyoNight Storm
- Font: Iosevka Nerd Font, 16pt
- Cursor: bar
- Hidden titlebar
- Keybinds: Cmd+Enter fullscreen, Opt+Left/Right unbound (shell handles them)

## tmux

Config: `tmux/tmux.conf`

- Prefix: **Ctrl-A** (not default Ctrl-B)
- Mode: vi keybindings
- Mouse: enabled (but click-to-focus disabled)
- Status bar: bottom, empty (no clutter)
- Windows start at 1, renumber on close
- History: 10,000 lines
- Image passthrough enabled

### Navigation

| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Select pane (vi-style) |
| `Ctrl-H` / `Ctrl-L` | Previous / next window |
| `Ctrl-A Ctrl-A` | Cycle panes |

### Pane/window management

| Key | Action |
|-----|--------|
| `c` | New window (inherits path) |
| `C` | New window (home) |
| Arrow keys | Split in that direction (inherits path) |
| `_` | Split vertical |
| `\|` | Split horizontal |
| `a` | Enter copy mode |
| `r` | Reload config |

### Plugins (via tpm)

- tmux-sensible — sensible defaults
- tmux-gruvbox — Gruvbox dark theme
- tmux-open — open URLs/files from scrollback
- tmux-copycat — regex search in scrollback
- tmux-yank — system clipboard integration

## WezTerm (experimental)

Config: `wezterm/wezterm.lua`

- Theme: Tokyo Night Storm
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

