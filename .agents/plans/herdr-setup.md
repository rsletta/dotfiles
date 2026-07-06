# herdr setup

Adopt [herdr](https://herdr.dev) — mouse-first terminal multiplexer (alt to tmux/zellij). Config tracked in repo, symlinked like the rest.

Context: first session in herdr (discovered 2026-07-04). Deferred from the Tokyo Night migration ([[tokyonight-migration]]).

## Theme (resolved)
- The darker tab-bar/sidebar was just herdr's DEFAULT theme (catppuccin). Setting `[theme] name = "tokyo-night"` fixed it — no `panel_bg` override needed. Config already set to tokyo-night.

## Config facts
- File: `~/.config/herdr/config.toml` (TOML) — already exists with `[theme] name = "tokyo-night"`, `[ui] agent_panel_sort = "spaces"`.
- Repo home: `herdr/config.toml`, symlinked manually (no Stow) → `~/.config/herdr/config.toml`.

## Tasks
1. [x] Move existing `~/.config/herdr/config.toml` into repo as `herdr/config.toml` with inline `# Symlink to:` comment.
2. [x] Symlink `~/.config/herdr/config.toml` → repo `herdr/config.toml`; added row to `docs/symlinks.md` + `AGENTS.md` layout. Verified herdr reload-config applied.
3. [ ] Decide tmux fate — keep tmux, run herdr alongside, or replace. (zellij removed — was unused.)
4. [ ] Map keybindings / panes / status to match tmux muscle memory (prefix Ctrl-A, vi nav).
5. [ ] Add `herdr/` to `AGENTS.md` repo-layout section + document in `docs/terminal.md`.
