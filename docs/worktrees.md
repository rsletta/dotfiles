# Worktrees

Two pieces, deliberately separate:

- **`wt`** — the worktree system. Pure git/shell. Knows nothing about tmux, and nothing about the context system either: it runs in whatever shell it is given, and the shell already knows how to be in a context.
- **`tmux-wt`** — a thin adapter. Asks `wt` for a path, puts a tmux window there. ~90 lines, no git in it.

If the multiplexer ever changes again, only the adapter is rewritten.

## `wt`

```
wt open [branch] [--base REF] [--path P] [--fetch] [--strict]
wt rm [branch] [--here] [--force]
wt list [--json]
wt path <branch>
wt label [path]
wt layout
```

stdout is machine-readable — a path, nothing else — so `cd "$(wt open foo)"` works. Everything human goes to stderr.

### `open` is idempotent

One verb, whatever the state:

| Situation | Result |
|---|---|
| worktree already exists | prints its path |
| branch exists, no worktree | creates a worktree for it |
| branch exists only on the remote | fetches that one ref, creates a local branch tracking it |
| neither exists | creates both |
| no branch given | generates `worktree/<adjective>-<noun>-<hex>` |

`--strict` restores fail-on-existing for the rare case where you want it.

Fetching is lazy and narrow: `wt` asks the remote about the *one* ref with `ls-remote` and fetches only that. It never runs `fetch --all --prune`, so creating a new branch costs nothing and works offline (an unreachable remote degrades to a plain local branch).

### `rm` keeps the branch

Removes the checkout only. Refuses the main checkout outright, and refuses a worktree with uncommitted changes or unpushed commits unless `--force`.

### Layouts

Both are live in `~/ws` and detection is automatic, based on the repo's **main** worktree — not the current one, so creating a worktree from inside a worktree does not compound suffixes.

| Layout | Example | New checkout |
|---|---|---|
| nested | `iverdi/ivit-monorepo/main` | `iverdi/ivit-monorepo/feature-iv-123-foo` |
| flat | `alv/src/terrarium` | `alv/src/terrarium-feature-iv-123-foo` |

Nested is detected when the main checkout is named `main`/`master`/`trunk`/`develop`, or is named after its own branch, or sits beside a `.bare` dir. Otherwise flat. Override per repo — no env var needed:

```sh
git config wt.layout nested   # or flat
```

`wt layout` prints what was detected and an example path.

## `tmux-wt`

`prefix + G` opens a popup with fzf over the repo's worktrees. Pick one to jump to its window; type a name that matches nothing to create that worktree *and* its window. `prefix + D` removes one.

Removal asks twice: once to confirm the removal, then whether to close that worktree's tmux window. If the window is the **last one in the session** it is never closed and the question is not asked — killing it would destroy the session, and with no other sessions tmux exits and takes every pane down with it.

Window names come from `wt label`, so naming logic lives in one place: `ivit-monorepo/green-stone-6806` when nested, `terrarium-pr-feat-mcp-git-ops` when flat.

Opening is idempotent at the window level too — if a window is already sitting in that path, it switches instead of creating a duplicate.

Context needs no special handling: a new tmux window inherits the session environment, so `SHELL_CONTEXT` comes along by itself. There is no `-e` anywhere in the adapter.
