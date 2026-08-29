# context simplification

Strip the context system to the part that carries value — per-context tool config — and delete the extension points that were never filled. 726 → ~400 lines.

## Verdict

Value = tool config isolation. `tools/setup.sh` (12–16 real lines per context, plain exports) is the whole payload and the right shape.

Two things are part of that value, not QoL on top:

- **tmux propagation** — without it the config applies only in the pane where `cch` ran, so isolation becomes a ritual instead of a default.
- **prompt indicator** (`starship.toml:118`) — isolation you cannot see is isolation you cannot trust.

Everything else is dead or convenience.

## Measured (2026-08-29)

| thing | real lines behind it |
|---|---|
| `tools/setup.sh` × 3 | 43 |
| `env/shared/*.sh` × 3 | 4 |
| `env/{dev,prod,test}` (alv) | 0 |
| `hooks/on-enter.sh` + `on-leave.sh` × 3 | 0 |
| `CONTEXT_LABEL` consumers | 0 (prompt reads `SHELL_CONTEXT`) |

## Phase 1 — cut dead surface

1. [x] Remove `cenv` — `_set_context_env`, `cenv`, `_cenv`, `compdef` (`71-contexts.sh:172–223`).
2. [x] Remove `CONTEXT_ENV` threading — `71-contexts.sh:2,5,46,47`, `_INHERITED_CONTEXT_ENV` at `245,247`, `CONTEXT_ENV` from `_CONTEXT_TOOL_VARS`.
3. [x] Remove `tmux.conf:115` (`update-environment CONTEXT_ENV`).
4. [x] Simplify `starship.toml:118` to `echo "$SHELL_CONTEXT"`.
5. [x] Delete `env/{dev,prod,test}` from `~/.config/contexts/alv/`.
6. [x] Remove hooks — `71-contexts.sh:56–59`, `77–80` (duplicate block), `107–110`; delete 6 empty files; drop `templates/context/hooks/`.
7. [x] Remove `CONTEXT_LABEL` — `71-contexts.sh:45`, `templates/context/config.sh:5`, each context's `config.sh`.
8. [x] Remove `_cman_rename` + its `rename` dispatch/completion arms (`73-context-manager.sh:285–333` and refs). Yearly op; carries the ws-coupling bug.
9. [x] Delete `env/shared/aliases.sh` (empty in all 3) + template.
10. [x] Update `docs/contexts.md`, `docs/commands.md`, `docs/README.md`, `docs/shell-loading.md`, `docs/terminal.md`.

## Phase 2 — propagation, correctly

Measured trade-off. `update-environment SHELL_CONTEXT` gives new-session inheritance but **any attach from a context-less shell wipes the session's context** (client env wins; unset → `-SHELL_CONTEXT`, empty → blank). `tla` runs from exactly such a shell.

Explicit `-e` on `new-session` gives inheritance *and* survives attach. Verified both.

11. [x] Remove `tmux.conf:114` (`update-environment SHELL_CONTEXT`).
12. [x] Context carried explicitly at session creation via `-e`. Superseded by the `t` consolidation below — `scripts/newTmuxSession` is gone.
13. [x] Verified on an isolated socket: fresh session → `cch` → new window inherits → attach from a context-less shell → context survives → later window still inherits.

## Phase 3 — robustness

14. [x] `cexport() { export "$@"; _CONTEXT_EXPORTED_VARS+=("${1%%=*}"); }`; `_context_cleanup` unsets that array, then empties it.
15. [x] Convert each context's `setup.sh` / `env/shared/variables.sh` to `cexport`. Fixes `CS_ACCESS_TOKEN` + `SPIR_DEVTOOLS_TOKEN` surviving a switch.
16. [x] Delete `_CONTEXT_TOOL_VARS`; strip export-line templates from `_CONTEXT_KNOWN_TOOLS` (keep names for `add-tool` dir creation).
17. [x] `|| { echo "context: failed sourcing X" >&2; return 1; }` on every `source` in `_set_context` (was 8, fewer after phase 1).
18. [x] **Make the indicator honest.** `_set_context:86` exports `SHELL_CONTEXT` *before* sourcing anything, so a mid-file failure leaves a half-applied context with a confident prompt, a `Context: alv` message, and `tmux setenv` (`:116`) propagating the lie to new panes. Reorder: source into locals → on success export `SHELL_CONTEXT` + `tmux setenv` → then print. Badge showing ⇒ config fully applied.

## Phase 3b — tmux entry points consolidated

`tla` + `tns` + `scripts/newTmuxSession` → one `t` function (`zshrc.d/70-functions.sh`). Native `new-session -A` covers create-or-attach but **refuses inside a session** ("sessions should be nested with care", rc=1), so the switch-client branch is the part worth keeping. `-e` is honoured on create and ignored on re-attach — verified.

19. [x] `t` / `t <name>`, works inside and outside tmux; fzf pick with no arg; names a new session after `$PWD` when nothing is running; `_t` completion.
20. [x] `scripts/newTmuxSession` deleted, `~/.local/bin` symlink removed, `docs/symlinks.md` / `scripts.md` / `commands.md` / `contexts.md` / `tmux.conf` updated.
21. [x] Two bugs found by testing and fixed: zsh does not word-split `${VAR:+...}` (the `-e` pair arrived as one argument — now an array), and `$PWD`-derived names now sanitize every non-alphanumeric, not just `.` and `:`.

## Phase 4 — standing bugs

22. [x] `65-writing.sh:26` — `${str,,}` → `${(L)str}` (bash-ism; `notes new` errors in zsh). Or delete `notes` and keep `til`.
23. [x] `75-workspace.sh:130` — `compadd -- "$workspaces"` → `compadd -- $workspaces` (quoted array = one joined candidate).
24. [x] `tmux.conf:15` — `bind-key C-a send-prefix` is dead, overridden at `:101`. Drop it or move the pane-cycle key.
25. [x] `tmux-agent-status` — add `set-hook -g pane-exited` to re-roll `@agent_win`; badge latches when a `working` pane dies.
26. [x] `tmux-wt:56` parses `wt list`'s human table with `awk '{b=$1;p=$NF}'` — breaks on paths with spaces, feeds `(detached)` to `wt rm`. Give `wt list` a tab-separated `--porcelain` and consume that; drop unused `--json`.
27. [x] `wt:280,313` — `cmd_list`/`cmd_path` call `resolve_layout` (3 git calls) without using layout.
28. [x] `completions/_ku` — guards on array *non-empty*, so contexts declaring `CONTEXT_KUBE_CONFIGS=()` silently fall back to the global list. Guard on *set* instead.
29. [x] `docs/commands.md` — `jira` row describes a command that doesn't exist; `lazyj` is not a TUI; `browse` is `open`, not w3m. `wt`/`tmux-wt`/`ghd` missing.
30. [x] Delete `tmux/tmux.conf.bak`; move `zshrc.d/zshrcd-improvements.md` out of the sourced dir.

## Unresolved

1. `cman` keeps 137 lines of jira/skillshare wizards for once-per-org setup. Shrink to `cp -r template` + documented snippet, or keep?
2. `notes` — fix the one-liner (`daily`/`search` already work) or delete that half of `65-writing.sh`?
3. `env/shared/variables.sh` holds 4 real lines total. Fold into `tools/setup.sh` and drop `env/` entirely, or keep the split?
4. `scripts/lib/til-categories` is mutable state in a git-tracked repo — move to context or `~/.local/state`?
