# Scripts

Utilities under `scripts/`. Selected scripts are symlinked to `~/.local/bin`;
the authoritative list is in [symlinks.md](symlinks.md).

## Active commands

| Script | Command/use | Description |
|--------|-------------|-------------|
| `create-script` | `create-script <path>` | Scaffold a Python CLI using uv and Click |
| `ffmpeg/extract_clip` | `extract_clip` | Interactively extract a video segment |
| `newTmuxSession` | `newTmuxSession <name>` / `tns <name>` | Create or attach to a tmux session |
| `wt` | `wt open\|rm\|list\|path\|layout` | Git worktree helper. Pure git/shell — no multiplexer, no context knowledge |
| `tmux-wt` | tmux key binding (`prefix+G` / `prefix+D`) | Open or remove a worktree as a tmux window, via fzf popup |
| `tmux-agent-status` | agent lifecycle hooks | Record agent state on its pane; roll up to the window |
| `kubernetes-helpers/tail-logs` | `tail-logs` | Stream logs for its project-specific namespaces |
| `til` | `til` zsh function | Create and categorize TIL entries for the active writing context |

`install-nvim-lsps` is run directly from the repository when bootstrapping
the language servers configured by Neovim.

## Parked scripts

These are intentionally not on `PATH` and remain for evaluation or migration:

- `alvify.sh`
- `createNewPost`
- `fports`
- `kubernetes-helpers/kubelog`

## Libraries

`scripts/lib/yyyymmdd`, `slugify`, and `til-categories` support the writing
scripts and are not standalone commands.
