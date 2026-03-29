# Project Guidelines

## Overview

Personal dotfiles for macOS (Late 2024 reboot). Primary machine is a MacBook Pro.
Focus: shell productivity, context-aware tooling, low-friction writing.

Not using GNU Stow yet — dotfiles are applied via manual sourcing and symlinking.

## How dotfiles are applied

- **Shell config**: `.zshrc` sources all `zshrc.d/*.sh` in numeric order. `.zprofile` sources all `zprofile.d/*.sh` in numeric order.
- **Scripts**: Each script is individually symlinked from `scripts/` into `~/.local/bin/`.
- **Symlinked configs**: `.tmux.conf → tmux/tmux.conf`, `.completions → completions/`
- **Example files**: `zshrc_example` and `zprofile_example` show how to wire up sourcing on a new machine.

## Directory structure

```
zshrc.d/        # Zsh config, sourced in numeric order (00–80)
zprofile.d/     # Zsh profile (PATH, env), sourced in numeric order
scripts/        # Utility scripts — symlink to ~/.local/bin to expose
scripts/lib/    # Shared shell libs (slugify, yyyymmdd)
scripts/templates/  # File templates with __PLACEHOLDER__ vars
templates/      # Bootstrap templates (context/, claude-bootstrap/)
completions/    # Zsh completions (e.g. _ku)
docs/           # Developer docs — see below
tmux/           # tmux config
starship/       # Starship prompt config (replaced oh-my-posh)
ghostty/        # Ghostty terminal config (primary terminal)
nvim/           # Neovim config (current)
nvim-old/       # Legacy neovim config — reference only, do not modify
wezterm/        # WezTerm config — experimental, still in use
zellij/         # Zellij config — experimental, still in use
neofetch/       # Neofetch config
vivid/          # LS_COLORS theme
applications.md # App inventory — update manually when things change
```

## Conventions

- `zshrc.d/` and `zprofile.d/` files are numbered. Mind the load order when adding new files.
- Scripts land on PATH via symlink to `~/.local/bin/` — not by adding `scripts/` to PATH.
- Shell functions and aliases stay in `zshrc.d/` files, not in scripts.
- Custom Claude tooling uses the `klaude-` prefix (not `claude-`).

## Key systems

### Context system (`zshrc.d/71–73`)
Multi-client context switching via `cch <context>`. Contexts live in `~/.config/contexts/<name>/`.
Each context has `config.sh`, `env/`, `tools/`, `hooks/`. Managed with `cman`.
→ See `docs/contexts.md`

### Writing system (`zshrc.d/65-writing.sh`)
`notes` and `til` commands for low-friction writing. **Requires an active context** with writing paths configured (`CONTEXT_VAULT_PATH`, `CONTEXT_TIL_PATH`, `CONTEXT_TIL_TEMPLATE`).
Add writing to a context with `cman add-tool writing`.
→ See `.claude/plans/writing-system-ai-skills.md` for planned AI assistance

### Workspace structure (`zshrc.d/75-workspace.sh`)
Workspaces live at `~/ws/<name>/` with `src/` and `notes/`. Managed with `ws`.
→ See `docs/workspaces.md`

## Docs

`docs/` is actively maintained. Update it when making structural changes.

| File | Covers |
|------|--------|
| `docs/shell-loading.md` | How zshrc.d and zprofile.d are loaded |
| `docs/contexts.md` | Context system in detail |
| `docs/workspaces.md` | Workspace structure |
| `docs/scripts.md` | Scripts and how to add new ones |
| `docs/commands.md` | Key commands reference |
| `docs/terminal.md` | Terminal and prompt setup |
| `docs/neovim.md` | Neovim config notes |
