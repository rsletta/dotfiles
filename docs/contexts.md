# Context System

Switch between work contexts (clients, personal) on the same machine. Each context scopes tool configs, env vars, and shell completions.

## Commands

| Command | Description |
|---------|-------------|
| `cch <name>` | Switch context |
| `cenv [env]` | Set env within context (dev/test/prod). No arg = unset |
| `ccd` | cd to CONTEXT_HOME |
| `cman new <name>` | Create context from template |
| `cman ls` | List contexts (* = active) |
| `cman edit [name]` | Open context in $EDITOR |
| `cman add-tool <tool> [ctx]` | Add tool config to context |

## Context directory layout

Each context lives in `~/.config/contexts/<name>/`:

```
config.sh             # Required: CONTEXT_HOME, CONTEXT_LABEL
env/
  shared/             # Sourced on cch (always)
  dev/ test/ prod/    # Sourced on cenv <env>
tools/
  setup.sh            # Exports tool config env vars
  kube.sh             # Lists kubeconfig names for scoped completions
  gh/  aws/  ...      # Tool-specific config directories
hooks/
  on-enter.sh         # Runs after entering context
  on-leave.sh         # Runs before leaving context
```

Template for new contexts: `dotfiles/templates/context/`.

## Safety model

Context activation is always conscious — no context is inherited from parent sessions.

**Auto-set (safe):** `tools/setup.sh` sets config *paths* — tells tools where to find config files. No profiles or clusters are activated.

**Explicit (dangerous):** You must manually run:
- `ku <name>` to set KUBECONFIG
- `awsp <name>` to set AWS_PROFILE

Completions for both are scoped to the active context.

## What `cch` does

1. Runs `hooks/on-leave.sh` from old context (if any)
2. Cleans up all tool env vars from old context
3. Sources `config.sh` (CONTEXT_HOME, CONTEXT_LABEL)
4. Sources `env/shared/*.sh`
5. Sources `tools/setup.sh` and `tools/kube.sh`
6. Runs `hooks/on-enter.sh`
7. Runs skillshare drift check (only if skillshare was added to this context)

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
| jira | `JIRA_CONFIG_FILE` — token via `JIRA_API_TOKEN` (1Password, see below) |
| skillshare | — registers `<ctx>-claude` target in global skillshare config; fans out global skills to context's Claude dir. See below. |

**Kubeconfig exception:** Kubeconfigs stay in `~/.kube/config.d/` (cloud tools write there). Context declares which ones belong to it in `tools/kube.sh`.

## Secrets

Use `op://` references in env files for 1Password secrets. Resolve with `op run --no-masking -- <command>`.

### Jira setup

```sh
# 1. Add the tool (creates tools/jira/config.yml, wires JIRA_CONFIG_FILE)
cman add-tool jira

# 2. Edit tools/jira/config.yml — fill in server URL, login, project key

# 3. Add token to env/shared/variables.sh
export JIRA_API_TOKEN="op://<Vault>/<Item>/token"

# 4. Activate context
cch <context>

# 5. Use — wrapper resolves token via op run
jira issue list
```

### Skillshare setup

Skills live in a single global source (`~/.config/skillshare/skills/`, git-tracked). Per-context registration fans them out into each context's Claude config dir via symlinks. Local skills in a context coexist with synced skills (merge mode).

Prereqs: `skillshare` CLI (`brew install runkids/tap/skillshare`) and `jq`. Context must already have `tools/claude/`.

```sh
# Per context
cman add-tool skillshare [ctx]   # registers <ctx>-claude target, drops tools/skillshare/installed marker
skillshare sync                  # populates symlinks; pre-existing local duplicates stay local (delete first if you want them linked)
```

Drift detection runs on every `cch`. If source has skills the target doesn't, `cch` prints `⚠ skillshare: N skill(s) need sync — run: skillshare sync`. Silent when clean.

Project-mode skills (`.skillshare/` committed in a repo) sync to the repo's local `.claude/skills` and work independently of contexts.

## Prompt

Starship shows the active context and env (e.g. `alv` or `alv:dev`). GH identity shows when `GH_CONFIG_DIR` is set.

## Implementation files

- `zshrc.d/71-contexts.sh` — core engine (cch, cenv, ccd)
- `zshrc.d/72-context-tools.sh` — ku, awsp with scoped completions
- `zshrc.d/73-context-manager.sh` — cman command
- `completions/_ku` — context-aware kubeconfig completion
