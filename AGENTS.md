# Project Guidelines

## Overview

Personal dotfiles for macOS. Primary machine is a MacBook Pro.
Focus: shell productivity, context-aware tooling, low-friction writing.

Not using GNU Stow. Dotfiles are applied via manual sourcing and symlinking.

## How dotfiles are applied

- Shell config: `.zshrc` sources all `zshrc.d/*.sh` in numeric order. `.zprofile` sources all `zprofile.d/*.sh` in numeric order.
- Configs & scripts are applied by manual symlink (configs → `~/` or `~/.config/`; select scripts → `~/.local/bin/`). See `docs/symlinks.md` for the full, authoritative manifest.
- Example files: `zshrc_example` and `zprofile_example` show how to wire up sourcing on a new machine.

## Directory structure

```text
zshrc.d/              # Zsh config, sourced in numeric order
zprofile.d/           # Zsh profile (PATH, env), sourced in numeric order
scripts/              # Utility scripts — symlink to ~/.local/bin to expose
scripts/lib/          # Shared shell libs
templates/            # Bootstrap templates (context/, writing/)
completions/          # Zsh completions
docs/                 # Developer docs
tmux/                 # tmux config
starship/             # Starship prompt config
ghostty/              # Ghostty terminal config
nvim/                 # Neovim config
wezterm/              # WezTerm config — experimental
w3m/                  # w3m browser config — trial, not linked
applications.md       # App inventory — update manually when things change
```

## Conventions

- `zshrc.d/` and `zprofile.d/` files are numbered. Mind load order.
- Scripts land on PATH via symlink to `~/.local/bin/`, not by adding `scripts/` to PATH.
- Shell functions and aliases stay in `zshrc.d/` files, not in scripts, unless they are clearly standalone utilities.
- Update `docs/` when structural behavior changes.

## Key systems

### Context system (`zshrc.d/71–73`)

Multi-client context switching via `cch <context>`. Contexts live in `~/.config/contexts/<name>/`.
Each context has `config.sh` and `tools/` — `tools/setup.sh` is the payload, a list of `cexport` lines.
Managed with `cman`; `cman show` prints what a context sets, `cman doctor` health-checks them all.
See `docs/contexts.md`.

### Writing system (`zshrc.d/65-writing.sh`)

`notes` and `til` commands for low-friction writing. Requires an active context with writing paths configured (`CONTEXT_VAULT_PATH`, `CONTEXT_TIL_PATH`, `CONTEXT_TIL_TEMPLATE`).
Add writing to a context with `cman add-tool writing`.

### Workspace structure (`zshrc.d/75-workspace.sh`)

Workspaces live at `~/ws/<name>/` with `src/` and `notes/`. Managed with `ws`.
See `docs/workspaces.md`.

## Plans

- Write tracked plans to `.agents/plans/<plan-name>.md`.
- Use `.agents/plans/local/` for scratch or personal plans.

## Docs

| File | Covers |
|------|--------|
| `docs/shell-loading.md` | How zshrc.d and zprofile.d are loaded |
| `docs/symlinks.md` | Symlink & sourcing manifest (what maps where) |
| `docs/contexts.md` | Context system in detail |
| `docs/workspaces.md` | Workspace structure |
| `docs/scripts.md` | Scripts and how to add new ones |
| `docs/commands.md` | Key commands reference |
| `docs/terminal.md` | Terminal and prompt setup |
| `docs/neovim.md` | Neovim config notes |
| `docs/worktrees.md` | `wt` / `tmux-wt` git worktree helpers |
| `docs/agents.md` | Agent status badges in tmux |
