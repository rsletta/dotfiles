# Workspaces

Organize project work into isolated directories. Each workspace has a standard structure with `src/` and `notes/` subdirectories.

## Commands

| Command | Description |
|---------|-------------|
| `ws new <name>` | Bootstrap a new workspace |
| `ws init <name>` | Alias for `new` |
| `ws list` | List all workspaces (`*` = has a context) |
| `ws ls` | Alias for `list` |
| `ws cd <name>` | Change to workspace directory |

## Workspace structure

All workspaces live under `~/ws/`. Each workspace has:

```
~/ws/<name>/
  src/       # Project source code
  notes/     # Project notes and docs
```

## Relationship to contexts

Workspaces and contexts are **separate systems**:

- **All contexts have a workspace** — typically `~/ws/<context-name>/`
- **Not all workspaces have a context** — some are standalone projects with no tool scoping

You can use them independently:

```zsh
# Switch to workspace only
ws cd alv

# Switch to context (may also suggest ws cd to the same workspace)
cch alv

# Use both together
cch alv && ccd  # Workspace from context + optional cd
```

## Implementation

- `zshrc.d/75-workspace.sh` — ws command and completion
