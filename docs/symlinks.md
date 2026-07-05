# Symlinks & sourcing manifest

Authoritative record of how this repo is applied to the machine. Not using GNU Stow — everything is manual. The repo holds the real files; `$HOME` holds symlinks (or, for shell dirs, sourced paths). Repo root is assumed at `~/.config/dotfiles`.

## Config symlinks

`$HOME` location is a symlink pointing into the repo.

| Repo path | Symlink location |
|-----------|------------------|
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `completions/` (dir) | `~/.completions` |
| `nvim/` (dir) | `~/.config/nvim` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |

## Script symlinks

Select scripts are individually symlinked onto `PATH` at `~/.local/bin/` (link name in bold = command name).

| Repo path | Command (`~/.local/bin/…`) |
|-----------|----------------------------|
| `scripts/create-script` | `create-script` |
| `scripts/ffmpeg/extract_clip` | `extract_clip` |
| `scripts/generate-vivaldi-raycast-commands.sh` | `generate-vivaldi-raycast-commands` |
| `scripts/newTmuxSession` | `newTmuxSession` |
| `scripts/kubernetes-helpers/tail-logs` | `tail-logs` |

## Sourced, not symlinked

Loaded in-place from the repo by the shell — no symlink involved.

- `zshrc.d/*.sh` — sourced in numeric order by `.zshrc` (see `zshrc_example`).
- `zprofile.d/*.sh` — sourced in numeric order by `.zprofile` (see `zprofile_example`).

## Used in place (path reference)

- `templates/` (`context/`, `writing/`) — read by `zshrc.d/65-writing.sh`, `73-context-manager.sh`, `77-jira.sh` via path. Not symlinked.

## In repo, NOT linked

Present in the repo but not applied to the machine (repo is **not** authoritative for these):

- `w3m/` — under trial; live `~/.w3m` is a separate, unlinked copy.
- Scripts under reconsideration, intentionally off `PATH`: `scripts/alvify.sh`, `scripts/createNewPost`, `scripts/fports`, `scripts/til`, `scripts/kubernetes-helpers/kubelog`.
- `scripts/lib/` (`slugify`, `yyyymmdd`) — shared libs sourced by other scripts; not meant for `PATH`.

## Adding a new symlinked config

Manual, e.g. for a hypothetical `foo/config`:

```sh
ln -s "$HOME/.config/dotfiles/foo/config" "$HOME/.config/foo/config"
```

For a script: `ln -s "$HOME/.config/dotfiles/scripts/foo" "$HOME/.local/bin/foo"`. Then add a row to the relevant table above.
