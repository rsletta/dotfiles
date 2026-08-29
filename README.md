# macOS dotfiles

Personal dotfiles for a macOS development environment built around zsh,
Ghostty, tmux, Neovim, and Starship.

The repository is applied manually rather than through GNU Stow:

- `~/.zshrc` sources `zshrc.d/*.sh` in numeric order.
- `~/.zprofile` sources `zprofile.d/*.sh` in numeric order.
- Configs and selected scripts are symlinked individually; see
  [`docs/symlinks.md`](docs/symlinks.md) for the authoritative manifest.
- `zshrc_example` and `zprofile_example` are the tracked bootstrap examples.

## Main systems

- Contexts (`cch`, `cman`) isolate client-specific tool configuration.
- Workspaces (`ws`) organize projects under `~/ws/<name>/`.
- Writing commands (`notes`, `til`) use paths supplied by the active context.
- tmux carries active context state into new shells.

## Documentation

Start with [`docs/README.md`](docs/README.md). It links to the context,
workspace, shell loading, command, terminal, script, and Neovim references.

## Theme

Tokyo Night's `night` variant is used across the terminal, prompt, tmux, and
Neovim configuration.

## Influences

- [DJ Adams' dotfiles](https://github.com/qmacro/dotfiles)
- [ThePrimeagen's dotfiles](https://github.com/ThePrimeagen/.dotfiles)
