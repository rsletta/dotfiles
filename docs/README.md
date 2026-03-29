# Dotfiles Documentation

macOS-focused shell environment. Ghostty + tmux + zsh + neovim.

## Quick Start

New terminal session flow:
1. Shell loads zprofile.d/ (PATH, env) then zshrc.d/ (shell config, aliases, functions)
2. Run `cch <context>` to set your work context
3. Run `cenv <env>` if needed (dev/test/prod)
4. Run `ku`/`awsp` to explicitly activate cluster/cloud profile

## Docs

| File | What it covers |
|------|---------------|
| [contexts.md](contexts.md) | Context system (cch, cenv, ccd, cman) |
| [workspaces.md](workspaces.md) | Workspace organization (ws command) |
| [commands.md](commands.md) | All custom commands, functions, aliases |
| [shell-loading.md](shell-loading.md) | How config files load and what each does |
| [neovim.md](neovim.md) | Neovim setup, plugins, keybindings |
| [scripts.md](scripts.md) | Utility scripts in scripts/ |
| [terminal.md](terminal.md) | Terminal emulator and tmux config |
| [../applications.md](../applications.md) | Full application inventory with install sources |

## Key Tools

| Tool | Purpose |
|------|---------|
| Ghostty | Terminal emulator (primary) |
| tmux | Terminal multiplexer (Ctrl-A prefix) |
| starship | Shell prompt |
| neovim | Editor |
| eza | ls replacement |
| zoxide | cd replacement |
| fzf | Fuzzy finder |
| lazygit | Git TUI |
| 1Password CLI | Secrets via `op://` |
