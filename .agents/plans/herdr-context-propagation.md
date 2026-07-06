# herdr context propagation

Goal: new/split herdr panes inherit the **source pane's current** context (`SHELL_CONTEXT`/`CONTEXT_ENV`) — including after a quick in-session shift — matching tmux's per-session inheritance. No global state, no keystroke hacks, no plugin. See [[herdr-setup]].

## Why possible (probed, v0.7.1)
- Interactive panes export `HERDR_PANE_ID` (e.g. `w1:p1`), `HERDR_WORKSPACE_ID`, `HERDR_SOCKET_PATH`.
- `herdr pane split --current --direction down|right [--env K=V]` carries env into the new pane's shell.
- `[[keys.command]]` receives `HERDR_ACTIVE_PANE_ID` of the source pane (confirm in task 3).

## Design (3 parts)
1. Per-pane state: `cch`/`cenv` write current context to `~/.local/state/herdr-ctx/<HERDR_PANE_ID>` (herdr branch alongside existing tmux branch).
2. Context-carrying split: helper `scripts/herdr-split <down|right>` reads state for `$HERDR_ACTIVE_PANE_ID`, calls `herdr pane split --current --direction <dir>` with `--env SHELL_CONTEXT=… --env CONTEXT_ENV=…`. Bound via `[[keys.command]]` on `prefix+down`/`prefix+right` (replaces native split binds).
3. Generalized restore: un-gate `71-contexts.sh:235` from `$TMUX` — any pane starting with non-empty inherited `SHELL_CONTEXT` re-activates. Safe: plain panes have it blank → no restore.

## Decisions (resolved)
- State dir: `~/.local/state/herdr-ctx/`.
- tmux path unchanged for now; unify onto this mechanism later (optional, task 7).
- Repo convention: manual verify per task (no TDD).

## Tasks
1. [x] Per-pane state write/clear in `_set_context` & `_set_context_env` (`71-contexts.sh`, `_herdr_ctx_persist`), guarded by `HERDR_PANE_ID`.
2. [x] `scripts/herdr-split` helper — reads state, always emits explicit `--env` (empty = neutralize server ambient), calls `herdr pane split`.
3. [x] Bound `prefix+down`/`prefix+right` to `herdr-split` via `[[keys.command]]`; removed native splits; symlinked to `~/.local/bin`. Confirmed `[[keys.command]]` provides `HERDR_ACTIVE_PANE_ID`.
4. [x] Generalized restore (`71-contexts.sh`, dropped `$TMUX` gate; non-empty check retained).
5. [x] E2E verified: split inherits `rsletta`; `cch alv` → split inherits `alv`; cleared → split context-less.
6. [x] Docs: `docs/herdr.md` (mechanism + status). `herdr-split` symlink → add to `docs/symlinks.md` (scripts table).
7. [ ] (optional, later) Unify tmux onto the state-file mechanism; retire `setenv`/`update-environment` coupling.
