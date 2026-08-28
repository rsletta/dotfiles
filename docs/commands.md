# Commands Reference

All custom commands, functions, and aliases.

## Context commands

See [contexts.md](contexts.md) for details.

| Command | Description |
|---------|-------------|
| `cch <name>` | Switch context |
| `cenv [env]` | Set env within context |
| `ccd` | cd to CONTEXT_HOME |
| `cman <sub>` | Context management (new/ls/edit/add-tool/rename) |

## Writing and workspaces

| Command | Description |
|---------|-------------|
| `notes daily` | Open today's daily note |
| `notes new <title>` | Create an inbox note |
| `notes search [query]` | Search the active context's vault |
| `til` | Create a TIL entry |
| `til category <list\|new\|sync>` | Manage approved TIL categories |
| `ws <new\|list\|cd\|rename>` | Manage workspaces under `~/ws` |

## Tool commands

| Command | Description |
|---------|-------------|
| `ku [name]` | Set KUBECONFIG from `~/.kube/config.d/`. No arg = unset |
| `awsp [name]` | Set AWS_PROFILE. No arg = unset |
| `awsso` | `aws sso login` |
| `jira` | Context-aware Jira CLI wrapper |
| `lazyj` | Open Jira TUI for the selected project |
| `wtf [engine] <query>` | Search with ddgr and w3m/browser |
| `browse [url]` | Open w3m directly or through ddgr |

## Functions

| Command | Description |
|---------|-------------|
| `tla` | Tmux: list sessions, pick with fzf, attach |
| `tns <name>` | Tmux: create or attach to named session |
| `aali <alias> '<cmd>'` | Add alias to alias file and reload |
| `oc` | Launch opencode with 1Password secrets |

## Aliases — navigation

| Alias | Destination |
|-------|------------|
| `..` `...` `....` `.....` | Up 1-4 levels |
| `dot` | `~/.config/dotfiles` |
| `conf` | `~/.config` |

## Aliases — eza (ls replacement)

| Alias | Flags |
|-------|-------|
| `els` | icons, dirs first |
| `ell` | long, icons, dirs first |
| `ela` | long, all, icons, dirs first |
| `elt` | tree, 2 levels |
| `ellt` | long tree, 2 levels |
| `elsg` | long, all, git status |
| `eldu` | long, dir sizes |
| `elss` | long, sort by size desc |
| `elsd` | long, dirs only |
| `elsp` | long, all, piped to less |

## Aliases — zoxide (cd replacement)

| Alias | Description |
|-------|-------------|
| `zz` | Previous directory |
| `zf` | Fuzzy search visited dirs |
| `zj` | Fuzzy jump |
| `ze` | Fuzzy jump + open in nvim |
| `zl` | Fuzzy search with eza preview |
| `zla` | Fuzzy jump + `eza -la` |

## Aliases — git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `gc` | `git commit` |
| `gd` | `git diff` |
| `lazyg` | `lazygit` |

## Aliases — other

| Alias | Command |
|-------|---------|
| `vim` / `vi` | `nvim` |
| `reload` | `source ~/.zshrc` |
| `tf` | `terraform` |
| `a` | `alvtime` (time tracking) |
| `sd` | `python3 -m http.server` |
| `rec` | `asciinema rec` |
| `lazyd` | `lazydocker` |
