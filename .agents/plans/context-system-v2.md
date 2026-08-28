# Context System v2

## Status

Design proposal based on an inspection of the dotfiles repository, the live
contexts under `~/.config/contexts`, and a requirements interview.

This document describes an evolution of the current system. It is not an
implementation plan that requires a big-bang rewrite.

## Problem Statement

The machine is used across several long-lived work identities. The same CLI
tool may require a different account, configuration directory, history, or
credential set depending on the active work context.

Current contexts:

- `rsletta`: private work
- `alv`: employer work
- `spirgroup`: current client assignment

Client contexts may be added or retired, but normally live for months or years.
Context IDs are stable and do not need rename support.

The primary purpose of the system is account and configuration routing. The
workspace structure is related but remains a separate concern.

## Agreed Requirements

### Platform and scope

- macOS and interactive zsh are the only required platform and shell.
- The system is for CLI tools and their child processes.
- GUI environment injection and cross-platform support are non-goals.
- Context definitions and tool state are machine-local. Explicit `rsync` is an
  acceptable migration mechanism.

### Activation

- `cch <context>` must remain the single, fast activation command.
- Activation must not perform network calls or authentication diagnostics.
- After activation, ordinary tool commands must transparently use the correct
  configuration.
- In a plain shell, the context belongs to that shell and its child processes.
- Bare `cch` in a plain shell returns to a neutral context.
- Clearing or switching must remove all state owned by the previous context.

### Multiplexers

The core context engine must not depend on tmux or herdr. Each multiplexer is a
replaceable inheritance adapter.

Tmux is mature and remains supported. Herdr is new and provisional; the design
must not assume it will replace tmux.

Both multiplexers should expose the same behavior:

- A new session/workspace starts neutral.
- The first `cch <context>` establishes its default context.
- New windows/tabs inherit the session/workspace default.
- New splits inherit the source pane, including a pane override.
- A later `cch <other>` changes only the current pane unless explicitly asked
  to change the session/workspace default.
- Bare `cch` in an overridden pane returns to the session/workspace default.
- An explicit command such as `cch --workspace <context>` may retarget the
  session/workspace default.

### Prompt

The existing safety signal should remain:

```text
[ctx:rsletta] [gh:rsletta] [git:rsletta@gmail.com]
```

- `ctx` shows the active shell context.
- `gh` shows the routed GitHub CLI identity.
- `git` remains derived from directory-based Git configuration.

### Context and workspace relationship

- Each context has a canonical `CONTEXT_HOME`, normally `~/ws/<context>`.
- `cch` does not change directory.
- `ccd` remains the explicit navigation command.
- Filesystem workspaces continue to contain `src/` and `notes/`.
- Herdr workspaces may open individual repositories or worktrees while carrying
  the owning context separately.

## Tool Matrix

| Tool | `rsletta` | `alv` | `spirgroup` | Activation model |
|------|-----------|-------|-------------|------------------|
| Claude Code | separate profile | separate profile | separate profile | Context-routed tool home |
| Skillshare | separate Claude target | separate Claude target | separate Claude target | Context-aware, shared skill source |
| Azure CLI | separate profile | separate profile | separate profile | Context-routed tool home |
| GitHub CLI | personal profile | personal profile | Spirgroup profile | Context maps to named GH profile |
| Git author | directory config | directory config | directory config | Outside context activation |
| Jira | none | none | two instances | Named runtime wrappers |
| Kubernetes | scoped shortlist | scoped shortlist as needed | scoped shortlist as needed | Explicit `ku` activation |
| AWS/Garage | global/project-local | none | none | Outside context activation |
| Codex | global personal tool | global personal tool | global personal tool | Outside context activation |
| Writing | context paths | context paths as needed | context paths | Context metadata |

### Claude Code

All three contexts intentionally use separate Claude homes. This isolates:

- account/login state
- session and project history
- configuration
- context-local Skillshare targets

The existing context-level Claude telemetry exports are obsolete because
telemetry is now managed centrally.

Spirgroup Claude requires `SPIR_DEVTOOLS_TOKEN` and `CS_ACCESS_TOKEN`. These are
Claude/MCP launch secrets, not general-purpose shell variables.

### GitHub CLI and Git

`rsletta` and `alv` intentionally share the `rsletta` GitHub identity.
`spirgroup` uses `ronnie-andre-bjorvik-sletta_spgr`.

The live `hosts.yml` files already select the intended users, but `gh auth
status` can still resolve the wrong or invalid Keychain token. The existing
`_gh_token_for_user` helper demonstrates the required account-specific lookup.

Git commit identity is already correctly handled by conditional Git includes
under the workspace directories. Git identity must remain directory-based and
must not be moved into `cch`.

### Jira

Jira is only part of the Spirgroup context. Spirgroup uses two Atlassian
instances in parallel because of internal infrastructure drift.

Stable commands:

```text
jira-i0
jira-iv
```

The installed Jira CLI supports runtime selection through `--config` and
`JIRA_CONFIG_FILE`. Each wrapper should therefore select its config per
invocation rather than mutate a shared `config.yml` symlink.

The two instances probably share an Atlassian login and API token, but the
wrapper design must allow separate 1Password references later without changing
the command interface.

### Kubernetes

The current two-step safety model remains:

1. The active context scopes the kubeconfigs offered by completion.
2. `ku <name>` explicitly sets `KUBECONFIG`.

A context switch must clear a previously selected `KUBECONFIG` so an Alv
cluster cannot silently remain active after switching context.

### AWS and OpenTofu

AWS is not a context dimension today. Metroplex uses the `homelab-garage`
profile explicitly for its S3-compatible OpenTofu backend. That profile remains
global/project-local.

### Codex

Codex is a personal, global tool using its default `~/.codex` home. Contexts do
not route, block, or otherwise manage it. The existing Alv `CODEX_HOME` override
is stale.

### Writing

Writing paths belong to their context and workspace. A context may define vault,
TIL, and post paths beneath its workspace's `notes/` and `src/` trees.

## Design

### Contexts map to tool profiles

A context should not implicitly own one copy of every tool. It maps tools to
named profiles:

```text
context: rsletta
  gh      -> personal
  claude  -> rsletta
  azure   -> rsletta

context: alv
  gh      -> personal
  claude  -> alv
  azure   -> alv

context: spirgroup
  gh      -> spirgroup
  claude  -> spirgroup
  azure   -> spirgroup
  jira    -> spirgroup
```

This makes intentional profile sharing explicit rather than duplicating or
implicitly falling back to global configuration.

### Filesystem layout

```text
~/.config/contexts/
  rsletta/context.zsh
  alv/context.zsh
  spirgroup/context.zsh

~/.local/share/tool-profiles/
  gh/personal/
  gh/spirgroup/
  claude/rsletta/
  claude/alv/
  claude/spirgroup/
  azure/rsletta/
  azure/alv/
  azure/spirgroup/
  jira/spirgroup/{i0,iv}.yml

~/.local/state/contexts/
  tmux/...
  herdr/...
```

Context definitions stay small and inspectable. Mutable tool homes, histories,
caches, and authentication state live under stable profile IDs.

All directories containing tool authentication state should be created with
mode `0700` by default.

### Definition format

Use constrained zsh data because the system is deliberately zsh-only and
should not acquire a parser dependency:

```zsh
CTX_HOME="$HOME/ws/alv"

typeset -A CTX_PROFILES=(
  gh      personal
  claude  alv
  azure   alv
)

CTX_KUBE_CONFIGS=(
  datalvsenteret-talos
  penny
  halvnais-alv-dev
  halvnais-alv-test
)
```

Definitions may assign documented `CTX_*` values only. They must not export
variables, run hooks, define aliases, or contain resolved secrets.

### Central adapters

The context engine owns tool-to-environment mapping in one place:

```text
gh      -> GH_CONFIG_DIR, GH_USER
claude  -> CLAUDE_CONFIG_DIR
azure   -> AZURE_CONFIG_DIR
jira    -> named wrapper config paths
writing -> CONTEXT_VAULT_PATH, CONTEXT_TIL_PATH, templates
```

Inactive speculative adapters should not remain in the registry. Docker,
Google Cloud, Helm, and Terraform/OpenTofu can be added when a real context
requires them.

### Exact environment lifecycle

Every assignment made during activation must go through a single helper such
as `_ctx_set <name> <value>`.

The helper records:

- whether the variable previously existed
- its previous value
- that the variable belongs to the current activation

Cleanup restores the previous value or unsets the variable. This replaces the
fragile `_CONTEXT_TOOL_VARS` allowlist and handles neutral shells correctly.

Explicit tool selections such as `KUBECONFIG` are cleared during context
changes even though they were set by `ku`, because their valid scope is bounded
by the context that offered them.

### GitHub invocation wrapper

Normal `gh` commands should remain transparent. A zsh wrapper resolves the
selected account's token from Keychain for that invocation only:

```zsh
gh() {
  local token
  token="$(_gh_token_for_user "$GH_USER")" || return 1
  GH_TOKEN="$token" command gh "$@"
}
```

The token is inherited by GH extensions launched through that process but is
not exported throughout the interactive shell.

Administrative authentication operations may need an explicit bypass command
that invokes the real `gh` without the wrapper.

### Claude secret wrapper

The Spirgroup context stores only 1Password references. When Claude is launched
under that context, a wrapper resolves those references using `op run` and
passes them only to the Claude process and its MCP children.

Other contexts launch Claude normally with their routed `CLAUDE_CONFIG_DIR`.

### Jira wrappers

`jira-i0` and `jira-iv` should be standalone scripts on `PATH`, not shell-only
functions. This lets human users and agents invoke both instances concurrently.

Each wrapper:

1. selects its fixed config using `--config`
2. supplies a project only when explicitly requested
3. resolves the appropriate Jira token through `op run`
4. never changes a shared symlink or edits another instance's active state

## Multiplexer Adapter Contract

The core engine needs a small adapter surface:

```text
default_context_get
default_context_set
pane_context_get
pane_context_set
pane_context_clear
```

Plain shells use no adapter.

### Default establishment

The first `cch` establishes a default when none exists. This replaces the
current herdr "one tab and one pane" heuristic with a direct state check and
removes calls to `herdr workspace list` and `jq` during activation.

### Herdr

Continue using state files keyed by herdr workspace and pane IDs:

- new tabs read the workspace default
- splits read the source pane state
- pane overrides do not mutate workspace state

Herdr-specific scripts remain outside the core context engine.

### Tmux

Tmux should implement the same semantics using session and pane state. The
current unconditional `tmux setenv` behavior must not allow a pane override to
retarget the session default.

Bindings or wrappers may be required for splits to inherit a source pane
override rather than the tmux session environment.

## Context Management

Keep `cman` as the user-facing administration command.

Expected operations:

- `cman new <context>`
- `cman ls`
- `cman edit [context]`
- `cman add-tool <tool> [context]`
- `cman purge <context>`

`cman add-tool` should update the context's profile mapping and create a tool
profile directory where required. It should no longer append executable exports
to `tools/setup.sh`.

Context rename is removed because context IDs are stable.

### Offboarding

When a client assignment ends, `cman purge` removes everything owned by the
context system:

- context definition
- exclusively owned tool profiles
- context-owned authentication caches and histories
- multiplexer state

Before deleting a tool profile, `cman` must check whether another context still
references it. Shared profiles such as `gh/personal` must survive.

Resources owned outside the context system are reported but not deleted:

- 1Password items
- filesystem workspaces managed by `ws`
- external kubeconfig files
- Git conditional include entries unless explicitly registered as context-owned

Purge must be explicit, preview what will be removed, and require confirmation.

## Confirmed Legacy Surface

The following no longer serves a current requirement:

- `cenv` and `CONTEXT_ENV`
- `env/dev`, `env/test`, and `env/prod`
- context enter/leave hooks
- context-specific aliases
- context-level Claude telemetry exports
- context-managed `CODEX_HOME`
- context rename
- unused Docker, Google Cloud, Helm, and Terraform adapters
- shared mutable Jira `config.yml` symlink

These should be removed only after the replacement behavior is covered by tests.

## Security Findings

At inspection time, `SPIR_DEVTOOLS_TOKEN` and `CS_ACCESS_TOKEN` were stored as
resolved plaintext values in a mode-`0644` context file. They were also absent
from the context cleanup allowlist and could survive a context switch.

Required remediation:

1. Rotate both tokens.
2. Store only 1Password references locally.
3. Resolve them only for the Spirgroup Claude process.
4. Ensure context and tool-profile directories default to mode `0700`.

`JIRA_API_TOKEN` is already represented as a 1Password reference.

## Migration Strategy

The current system mostly works. Migration should be incremental.

### Phase 1: Protect current behavior

- Add focused tests for context activation, switching, clearing, prompt values,
  and variable cleanup.
- Add adapter tests for plain zsh, tmux, and herdr state transitions.
- Document current tool profile paths before moving data.

### Phase 2: Fix current defects

- Rotate and relocate the plaintext Spirgroup secrets.
- Add the invocation-scoped GH token wrapper.
- Add the missing private Azure profile.
- Clear `KUBECONFIG` on context changes.
- Add concurrent `jira-i0` and `jira-iv` scripts.
- Remove the stale Alv `CODEX_HOME` override and telemetry exports.

### Phase 3: Introduce profile mappings

- Add small context definition files alongside the existing layout.
- Implement central adapters and exact environment tracking.
- Initially point profiles at the existing tool-home paths to avoid moving
  gigabytes of data during behavioral migration.
- Migrate one context at a time and compare resulting environments.

### Phase 4: Separate mutable data

- Move tool homes to `~/.local/share/tool-profiles` after profile routing is
  stable.
- Preserve permissions and authentication state.
- Update Skillshare targets for the new Claude paths.

### Phase 5: Unify multiplexer semantics

- Replace the herdr solo-workspace heuristic with default-state existence.
- Implement tmux session-default and pane-override state separately.
- Route new tabs/windows and splits through their adapters.

### Phase 6: Remove legacy code

- Remove `cenv`, hooks, aliases, environment overlay scaffolding, rename support,
  unused adapters, and old Jira switching state.
- Update documentation and templates.
- Add `cman purge` only after ownership metadata is reliable.

## Validation Criteria

The migration is complete when all of the following hold:

- `cch` remains fast and performs no network calls.
- Plain-shell activation and neutral clearing restore environment exactly.
- Tmux and herdr implement identical default/override behavior.
- New tabs/windows use the workspace/session default.
- Splits inherit their source pane override.
- `gh auth status` and normal GH commands use the expected identity after every
  context transition.
- Git author email continues to follow repository directory configuration.
- Claude launches with the correct account, history, skills, and Spirgroup MCP
  secrets.
- Azure never falls back to another context's home.
- `jira-i0` and `jira-iv` can run concurrently.
- Switching context clears an active kubeconfig.
- The prompt continues showing context, GH identity, and Git identity.
- No resolved client token is stored in context definitions.
- Purge cannot delete a tool profile referenced by another context.

## Non-goals

- Cross-platform or non-zsh support
- GUI application identity switching
- Automatic context selection from the current directory
- Authentication diagnostics during `cch`
- Context-controlled Git author identity
- Context-controlled Codex or AWS/Garage configuration
- Context portability or automatic cloud synchronization
