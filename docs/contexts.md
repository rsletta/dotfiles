# Context System

Switch between work contexts (clients, personal) on the same machine. Each context scopes tool configs, env vars, and shell completions.

## Commands

| Command | Description |
|---------|-------------|
| `cch <name>` | Switch context. No arg = clear |
| `ccd` | cd to CONTEXT_HOME |
| `cman new <name>` | Create context from template |
| `cman ls` | List contexts (* = active) |
| `cman edit [name]` | Open context in $EDITOR |
| `cman add-tool <tool> [ctx]` | Add tool config to context |
| `cman show [name]` | What a context sets: files sourced, every export, tool dirs |
| `cman doctor` | Health-check every context |

## Seeing what a context does

`cch` works by sourcing files you never see. That is the point, and it is also the failure mode — things get set up, forgotten, and drift apart. Two commands exist so the state is always one command away instead of something you have to remember to go looking for.

`cman show` lists every variable the context set, what each one points at, and which tool directories exist. Values are classified rather than dumped: a `op://` reference is labelled as such, a path is shown relative to the context (and marked `MISSING` if it does not exist), and anything whose name looks like a credential is reported as `PLAINTEXT SECRET (N chars)` — never printed. Run against a context you are not currently in, it sources that context in a throwaway subshell, so nothing leaks into your shell.

`cman doctor` runs the same inspection across every context and reports only problems: plaintext secrets that should be `op://` references, exports pointing at missing paths, empty tool directories, `kube.sh` declaring no kubeconfigs (which silently leaves `ku` completion unscoped), and skillshare markers that disagree with `skillshare target list`. Exits non-zero when anything is found.

## Context directory layout

Each context lives in `~/.config/contexts/<name>/`:

```
config.sh             # Required: CONTEXT_HOME
tools/
  setup.sh            # Exports tool config env vars — the whole payload
  kube.sh             # Lists kubeconfig names for scoped completions
  gh/  aws/  ...      # Tool-specific config directories
```

Template for new contexts: `dotfiles/templates/context/`.

## Safety model

Context activation is always conscious in plain shells. Multiplexer-created shells inherit it:

- tmux windows and panes inherit the session environment, which `cch` sets.
- `cch` in one pane changes that pane only; the session default is untouched, so a pane can run a different context from the rest of the session.
- `SHELL_CONTEXT` is deliberately **not** in tmux's `update-environment`: that list is re-applied from the client on every attach, and attaching from a context-less shell would wipe the session's context. The `t` function passes `-e` instead, so new sessions inherit without the attach hazard.

Set the context once when the session starts and everything opened afterwards inherits it.

**Auto-set (safe):** `tools/setup.sh` sets config *paths* — tells tools where to find config files. No profiles or clusters are activated.

**Explicit (dangerous):** You must manually run:
- `ku <name>` to set KUBECONFIG
- `awsp <name>` to set AWS_PROFILE

Completions for both are scoped to the active context.

## What `cch` does

1. Cleans up all tool env vars from old context
2. Sources `config.sh` (CONTEXT_HOME)
3. Sources `tools/setup.sh` and `tools/kube.sh`
4. Runs skillshare drift check (only if skillshare was added to this context)
5. Writes `SHELL_CONTEXT` into the tmux session environment

## Known tools for `cman add-tool`

| Tool | Env var(s) |
|------|-----------|
| gh | `GH_CONFIG_DIR` |
| aws | `AWS_CONFIG_FILE`, `AWS_SHARED_CREDENTIALS_FILE` |
| docker | `DOCKER_CONFIG` |
| azure | `AZURE_CONFIG_DIR` |
| gcloud | `CLOUDSDK_CONFIG` |
| helm | `HELM_CONFIG_HOME` |
| terraform | `TF_CLI_CONFIG_FILE` |
| codex | `CODEX_HOME` |
| jira | `JIRA_CONFIG_FILE` — token via `JIRA_API_TOKEN` (1Password, see below) |
| skillshare | — registers a per-context skillshare target and stores local sync metadata. See below. |

**Kubeconfig exception:** Kubeconfigs stay in `~/.kube/config.d/` (cloud tools write there). Context declares which ones belong to it in `tools/kube.sh`.

## Secrets

Use `op://` references in `tools/setup.sh` for 1Password secrets. Resolve with `op run --no-masking -- <command>`. A plaintext token in `setup.sh` is exported into every shell in the context — prefer a reference.

### Jira setup

```sh
# 1. Add the tool (creates tools/jira/config.yml, wires JIRA_CONFIG_FILE)
cman add-tool jira

# 2. Edit tools/jira/config.yml — fill in server URL, login, project key

# 3. Add token to tools/setup.sh
export JIRA_API_TOKEN="op://<Vault>/<Item>/token"

# 4. Activate context
cch <context>

# 5. Use — wrapper resolves token via op run
lazyj issue list
```

### Skillshare setup

Skills live in a single global source (`~/.config/skillshare/skills/`, git-tracked). Per-context registration fans them out into a context-local skill directory via symlinks. Local skills in a context coexist with synced skills (merge mode).

Prereqs: `skillshare` CLI (`brew install runkids/tap/skillshare`) and `jq`.

```sh
# Per context
cman add-tool skillshare [ctx]   # registers target, drops tools/skillshare/installed marker
skillshare sync                  # populates symlinks; pre-existing local duplicates stay local (delete first if you want them linked)
```

Drift detection runs on every `cch`. If source has skills the target doesn't, `cch` prints `⚠ skillshare: N skill(s) need sync — run: skillshare sync`. Silent when clean.

Project-mode skills (`.skillshare/` committed in a repo) work independently of contexts.

## Prompt

Starship shows the active context (e.g. `alv`). GH identity shows when `GH_CONFIG_DIR` is set.

## Implementation files

- `zshrc.d/71-contexts.sh` — core engine (cch, ccd)
- `zshrc.d/72-context-tools.sh` — ku, awsp with scoped completions
- `zshrc.d/73-context-manager.sh` — cman command
- `completions/_ku` — context-aware kubeconfig completion
