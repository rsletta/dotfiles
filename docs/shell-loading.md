# Shell Loading Order

How config files are loaded and what each one does.

## Load sequence

```
~/.zprofile (login shell — once per terminal window)
  zprofile.d/10-path.sh           ~/.local/bin to PATH
  zprofile.d/15-locales.sh        Norwegian locale (nb_NO.UTF-8)
  zprofile.d/50-1-cocoapods.sh    Ruby + CocoaPods paths
  zprofile.d/50-2-flutter.sh      Flutter + FVM paths
  zprofile.d/50-3-dotnet.sh       .NET tools path
  zprofile.d/50-4-rust.sh         Cargo bin path
  zprofile.d/50-5-node.sh         Bun path
  zprofile.d/50-6-lmstudio.sh     LM Studio CLI path
  zprofile.d/50-7-golang.sh       Go path (GOPATH)
  zprofile.d/50-globals.sh        EDITOR, K9S, SOPS config
  Homebrew shellenv
  JetBrains Toolbox PATH

~/.zshrc (every interactive shell)
  zshrc.d/00-shell.sh             Vi keybindings, completion style
  zshrc.d/20-history.sh           History config (5000 lines, shared, dedup)
  zshrc.d/30-prompt.sh            Starship init
  zshrc.d/40-completions.sh       Completion system + 1Password
  zshrc.d/60-aliases.sh           All aliases
  zshrc.d/70-functions.sh         General functions (tmux, notes, claude)
  zshrc.d/71-contexts.sh          Context system core (cch, cenv, ccd)
  zshrc.d/72-context-tools.sh     ku, awsp with scoped completions
  zshrc.d/73-context-manager.sh   cman command
  zshrc.d/80-plugins.sh           zsh-syntax-highlighting, history-substring-search
  fnm env (not cached — per-process multishell paths)
  _cached_init: fzf, zoxide  (see "Init caching" below)
  SDKMAN (lazy-loaded — inits on first use of sdk/java/gradle/kotlin/mvn)
  Docker CLI completions (fpath only, uses compinit from 40-completions.sh)
```

## File numbering convention

Files are numbered to control load order. Gaps allow inserting new files without renaming.

| Range | Purpose |
|-------|---------|
| 00-09 | Shell basics |
| 10-29 | History, input |
| 30-39 | Prompt |
| 40-49 | Completions |
| 50-59 | (unused in zshrc.d, used in zprofile.d for runtimes) |
| 60-69 | Aliases |
| 70-79 | Functions and systems |
| 80-89 | Plugins |

## Global env vars (from zprofile.d/50-globals.sh)

| Variable | Value |
|----------|-------|
| `EDITOR` | nvim |
| `K9S_CONFIG_DIR` | ~/.config/k9s |
| `SOPS_AGE_KEY_FILE` | ~/.config/sops/age/keys.txt |
| `PROMPT_EOL_MARK` | (empty — suppresses % at end of partial lines) |

## Init caching

Several tools need `eval "$(tool init zsh)"` which spawns a subprocess on every shell.
To avoid this, `~/.zshrc` defines `_cached_init` which runs the command once and saves
the output to `~/.cache/zsh/<name>.zsh`. Subsequent shells just source the cached file.

**Daily rotation**: A datestamp file (`~/.cache/zsh/.date`) is checked on startup. The
first shell of each day wipes and rebuilds the cache. Every shell after that is fast.

**Cached tools**: fzf, zoxide, op (op is cached in `40-completions.sh`)

**Not cached**: fnm — its output contains per-process multishell paths that are
unsafe to share across shells. Runs `eval "$(fnm env --use-on-cd)"` directly.

**SDKMAN**: Not cached but lazy-loaded — stub functions for `sdk`, `java`, `gradle`,
`kotlin`, and `mvn` defer `sdkman-init.sh` until first actual use.

**`compinit`**: Uses `-C` (skip security check, reuse dump) unless the dump is older
than 24 hours. Docker Desktop added a duplicate `compinit` at the bottom of `.zshrc`
which was removed — Docker completions work via the fpath entry alone.

To force a full cache rebuild: `rm -rf ~/.cache/zsh`

## Zsh plugins (loaded in 80-plugins.sh)

Installed manually via git clone:
- `zsh-syntax-highlighting` — command-line syntax coloring
- `zsh-history-substring-search` — Ctrl-P/N to search history by substring
- `zsh-autosuggestions` — present but disabled
