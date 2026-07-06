# Functional spec: tmux → zellij

Source: `tmux/tmux.conf`. Captures intent, not syntax. Translation to KDL is a separate pass.

**Guiding principle**: idiomatic zellij. Keep functionality, drop tmux idioms. Where tmux behavior conflicts with zellij defaults, prefer zellij.

## 1. Terminal & shell

1. Default shell: `$SHELL` (zellij default; user already on zsh).
2. Truecolor: zellij handles by default.
3. Extended key sequences (Shift+Enter etc.): rely on `support_kitty_keyboard_protocol` (default on if terminal supports).
4. Terminal passthrough for OSC sequences (allows nested escape codes to reach outer terminal).
5. Env propagation into new panes: `TERM`, `TERM_PROGRAM`, `SHELL_CONTEXT`, `CONTEXT_ENV`. Zellij inherits env at session start; document that mid-session env changes won't propagate.

## 2. Sessions, tabs, panes — model

1. Tab/pane indexes start at 1 (zellij default).
2. Tabs renumber sequentially on close (zellij default).
3. Auto-rename of tabs: **off** (preserve user-set names).
4. Outer terminal title reflects current tab.
5. Scrollback: 10 000 lines (zellij default — leave alone).
6. Session persistence: **on** (zellij default).
7. New panes/tabs inherit cwd from focused pane.

## 3. Mode & input model

- Idiomatic zellij modal model. No prefix simulation.
- Default startup mode: `normal`.
- Tab/pane navigation primarily via `Alt`-modified keys in normal mode (zellij default), or via mode entry (`Ctrl-p`, `Ctrl-t`, etc.).
- Drop tmux-only constructs: prefix-prefix, `bind -r` repeat, `C-z` suspend disable (zellij doesn't suspend).
- Remove zellij's built-in `tmux` mode (`Ctrl-b`). Hard landing — no training wheels.

## 4. Mouse

- Keep zellij defaults: click focuses pane, scroll enters scroll mode, drag selects + copies on release (`copy_on_select=true`).

## 5. Keybind functionality required

The following actions must be reachable. Idiomatic key choices to be settled in the translation pass — listed here as capabilities, not bindings.

### Pane focus
1. Directional focus: left/down/up/right (vim-style preferred where idiomatic).
2. Cycle to next pane.

### Tab focus
1. Previous / next tab.
2. Jump to tab N (1–9).

### Splits & new tabs (cwd-inheriting by default)
1. New tab in cwd (zellij default: `Ctrl-t` → `n`).
2. New pane below / right (zellij defaults: `Ctrl-p` → `d` / `r`).
3. Generic new pane, auto direction (`Ctrl-p` → `n`, or `Alt n` in normal mode).
4. Drop split-up / split-left — rare in practice, `auto_layout` handles direction.

### Copy / scroll
1. Enter scroll/search mode.
2. Vi-style movement in scroll mode (zellij default).
3. Copy selection to system clipboard via `pbcopy` (`copy_command "pbcopy"` on macOS).

### Config
1. Reload config (zellij supports live reload of `config.kdl`; no explicit binding needed).

## 6. Status bar / theming

1. Theme: built-in `gruvbox-dark`. No upfront tuning — tune later if specific issues surface.
2. Status bar: `compact-bar` (single line, bottom). Set via `default_layout "compact"`.
3. Drop directory display in chrome — noise. Shell prompt / pane title cover cwd.
4. Tab labels show name only.
5. Visual identity will differ from `z3z1ma/tmux-gruvbox` (no powerline separators). Accepted; revisit only if it bothers in use.

## 7. Plugins — feature parity map

| tmux plugin | Purpose | Zellij approach |
|---|---|---|
| tpm | Plugin manager | Built-in plugin manager — drop |
| tmux-sensible | Sane defaults | Zellij defaults — drop |
| tmux-gruvbox | Theme + status | Built-in `gruvbox-dark` theme + chosen status bar |
| tmux-open | Open URLs/files from copy-mode | Drop. Rely on Ghostty's URL handling / external tools |
| tmux-copycat | Regex search in scrollback | Zellij search mode (built-in) |
| tmux-yank | Copy to system clipboard | `copy_command "pbcopy"` |

## 8. Local override

- Drop. No `~/.tmux.conf.local` equivalent. Project-specific configuration goes in zellij layout files.

## 9. Resolved decisions

1. Splits: zellij defaults — `Ctrl-p` → `n`/`d`/`r`, `Alt n` in normal mode. Drop split-up/split-left.
2. Status bar: `compact-bar` via `default_layout "compact"`. No directory in chrome.
3. Theme: built-in `gruvbox-dark`, no upfront tuning.
4. Remove zellij's `tmux` mode block (`Ctrl-b`). Hard landing.
