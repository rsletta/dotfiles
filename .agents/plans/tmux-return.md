# tmux return

Move daily driver back to tmux. herdr trial concluded: most of what I valued is replicable, and tmux is stronger where it counts (context inheritance, scrollback search, maturity, agent-neutrality).

Architecture: three independent systems + thin tmux adapters. Adapters are the only disposable part.

```
context system   (cch/cenv)          ─┐
worktree system  (git/shell)          ├─ thin tmux adapters
agent status     (agent hooks)       ─┘
```

Not a port of the herdr scripts. Those were built around herdr's constraints. Build what I want now; expect churn as I use it.

## Ground rules

- Agile. Each slice usable alone. Stop and reassess after each.
- herdr stays installed until slice 6. Fallback while settling in.
- Context system is out of scope. Only its tmux adapter changes.
- Don't build ahead of demonstrated need. Popup dashboard, multi-agent adapters, persistence stay parked until use proves them.

## Slice 1 — back in tmux [reversible, no deletions]

1. [x] Verify `tmux.conf` as-is: extended-keys + passthrough already correct (matches Anthropic's documented Claude Code fix, plus `csi-u`).
2. [x] Add `MouseDragEnd1Pane` → `pbcopy` (drag currently selects but never copies — likely the friction I remembered).
3. [x] Confirm Shift+drag (Ghostty config sets no `mouse-shift-capture`, so it is at the default `false` — native selection available with no change) gives native Ghostty selection (`mouse-shift-capture` defaults false — no config needed).
4. [ ] Work a day. Note what bites.

Verified end-to-end with the real zshrc: neutral start -> `cch spirgroup` -> new window inherits `spirgroup` + `CONTEXT_HOME` -> `cch rsletta` in that window is pane-local, original pane still `spirgroup`. 3442 bytes of herdr machinery removed; no `herdr` references left in `71-contexts.sh`.

**Left for slice 6:** `~/.local/state/herdr-ctx/` still holds ~180 stale files (oldest 7 Jul) + `workspaces/`. Nothing writes them now; `herdr-split`/`herdr-tab` still read them, so herdr context carrying runs on frozen data until teardown.

## Slice 2 — context adapter

1. [x] Revert `71-contexts.sh` to `setenv`/`setenv -u` glue.
2. [x] Delete `_herdr_ctx_persist`, `_herdr_ctx_workspace_persist`, `_herdr_ctx_workspace_is_solo`, `_herdr_ctx_should_update_*`, `_herdr_ctx_scope_suffix`, `cch --workspace`, `~/.local/state/herdr-ctx/`.
3. [x] Verify: session = context, `cch` once at session start, all windows/panes inherit. `cch` in a pane still overrides locally (rsletta-inside-alv case).

Verified working: `tmux new-window -e SHELL_CONTEXT=rsletta` fully re-activates via existing shell restore. Session env is session-global; explicit `-e` overrides.

## Slice 3 — worktree tool (`wt`)

Fresh spec. `herdr-worktree` is inspiration, not a template — most of it is herdr compensation.

**Principles**

- Pure git/shell. Knows nothing about tmux. Knows nothing about contexts either — it runs in whatever shell it is given, and the shell already knows how to be in a context.
- stdout = machine-readable (the path, nothing else). stderr = human. Makes `cd "$(wt open foo)"` work.
- Subcommand CLI per `cman`/`ws`.

**Commands**

1. [x] `wt open [branch] [--base ref] [--path p] [--fetch] [--strict]` — **idempotent**. Reads right either way: opening a worktree is opening it whether it already existed or had to be created. Worktree exists → print path. Branch exists, no worktree → create one for it. Neither → create both. `--strict` restores fail-on-existing.
2. [x] `wt rm [branch|--here] [--force]` — remove linked checkout, keep branch.
3. [x] `wt list [--json]` — branch, path, dirty, ahead/behind.
4. [x] `wt path <branch>` — print path or exit 1.
5. [x] `wt layout` — print detected layout + main root. Debug.

**Better than what I have, with reasons**

1. [x] Drop the `zsh -ic` context re-entry. Verified unnecessary: tmux `run-shell` inherits session env, and an interactive shell restores context on its own.
2. [x] Drop herdr calls, JSON parsing, the `jq` dependency, and the `--interactive` pause-on-exit hack (tmux popups stay open on their own).
3. [x] Idempotent instead of `fail "branch already exists"`. Hard-failing is hostile when I just want back to a branch. I hit this repeatedly, always mid-other-work, so I defer the fix and move to the worktree by hand instead.
4. [x] Fetch becomes lazy/opt-in. Current fetches `--all --prune` on every create — slow, network-dependent, hard-fails offline. Only fetch when a remote ref is actually needed and missing locally.
5. [x] Removal safety. Current passes `--force` to herdr blindly. Refuse dirty checkouts or unpushed commits unless `--force` is explicit.
6. [x] Layout override via `git config wt.layout` instead of `HERDR_WORKTREE_LAYOUT`. Repo-local, persists, nothing to export.
7. [x] `wt list` surfaces dirty/ahead-behind — otherwise I have to open a worktree to find out.

**Keep — genuinely good already**

- Layout detection from the **main** worktree, not the current one. Prevents compounding suffixes (`monorepo-feature-x-hotfix-y`).
- Slugify, remote-ref resolution (`feature/x` vs `origin/feature/x`), generated `adjective-noun-hex` names, `--dry-run`.
- Both layouts stay live: spirgroup nested, alv flat, and `chromer`/`janitor` are plain repos with no worktrees at all.

## Slice 4 — tmux adapter for worktrees

1. [x] Binding: `prefix+G` runs `tmux-wt open` in a `display-popup` (fzf over existing worktrees; typing an unmatched name creates it). `prefix+D` removes. Window reuse is idempotent — reopening switches instead of duplicating.
2. [x] Window naming from `wt label`: nested -> `<repo>/<branch-slug>` (`ivit-monorepo/green-stone-6806`), flat -> the dir name (`terrarium-pr-feat-mcp-git-ops`). Layout knowledge stays in `wt`.
3. [ ] `tmux-wt rm` interactive path is untested headless (needs a TTY for fzf + confirm). Exercise it in real use.

## Slice 5 — agent status

One agent, one surface. Expand only if insufficient.

1. [x] `tmux-agent-status` writes pane state; hook JSON documented in `docs/agents.md` (per-context Claude settings — not installed by me) write `tmux set -p @agent_status <state>`.
2. [x] Window badge reads `@agent_win` (roll-up), pane border reads `@agent_status`. Zero extra rows. Badge config sits after tpm because tmux-tokyo-night overwrites `window-status-format` on load `#{@agent_status}`. Zero extra rows.
3. [x] Cleared on `pane-focus-in` — preserves herdr's `done`-but-unseen semantics.
4. [x] Codex wired via `~/.codex/hooks.json` (5 events). Needs `/hooks` trust approval in Codex before it fires.
5. [ ] Live with it before adding a popup dashboard.

Authoritative (hook-driven) beats herdr's screen-scraping fallback.

## Slice 6 — cheatsheet + teardown

**Teardown done** (29 Aug). The `herdr` binary itself is left installed and a server was still running at the time; only the repo's config, wrappers, symlinks, docs and state were removed.

1. [x] `bind -N` added for the three new bindings; 79 documented prefix bindings total.
2. [x] `prefix+?` opens the cheatsheet popup.
3. [x] `docs/terminal.md` keybinding tables **removed**, not regenerated — a generated copy would drift just the same. Points at `prefix+?` instead; the rest of the file (Ghostty, plugins, WezTerm, Starship) stays. Added `docs/worktrees.md` for `wt`/`tmux-wt`.
4. [x] Removed `herdr/config.toml` (+ the `herdr/` dir), `scripts/herdr-{split,tab,worktree,worktree-rm}`, all five symlinks, `docs/herdr.md`, and `~/.local/state/herdr-ctx/` (241 files, 964K).
5. [x] Updated `docs/symlinks.md`, `docs/scripts.md`, `AGENTS.md`, `README.md`, `ghostty/config.ghostty`.
6. [ ] Left alone deliberately: the brew-installed `herdr` binary, its runtime dir `~/.config/herdr/` (live sockets/logs), the `.agents/plans/herdr-*.md` history, the skillshare `herdr` skill, and the comparative rationale in `docs/agents.md`.

## Parked

- Session persistence (resurrect/continuum). Lived without it for years. Someday.
- Remote image paste — scoped below, not built.

## Image paste (scoped, not built)

The pattern already exists in `ve` as `abx paste`: `pngpaste` writes the clipboard image to `~/.cache/agent-sandbox/clipboard/<ts>.png`, that dir is mounted into the VM **at the same path** (paths-mirror-host), and the path goes back onto the clipboard for pasting into the agent's TUI. Hammerspoon binds it to `Cmd+Shift+V`. Contract: it writes the path to stdout, nothing else.

That is the same architecture herdr uses for its remote bridge, and it generalizes to three targets:

| Target | Transfer | Path handed to the agent |
|---|---|---|
| local | none | the local temp path |
| sandbox VM | existing RO mount | same path (mirrored) |
| remote host | `scp`/`rsync` to a mirrored cache dir | the remote path |

**tmux makes it better than the clipboard round-trip.** With a target pane known, `tmux send-keys` types the path straight into the agent prompt — no `Cmd+V` step at all. `abx paste` cannot do that because it has no pane concept.

Shape, if built, following the same split as everything else:

- `imgpaste` — pure: clipboard -> file -> print path. Optional `--to <host>` for scp. No tmux.
- `tmux-imgpaste` — adapter: run `imgpaste`, `send-keys` the path into the target pane.

### Platform agnosticism changes the design

Two assumptions in `abx paste` do **not** survive contact with a Linux target:

1. **paths-mirror-host is Lima-specific.** Lima can mount the host's `/Users/rsletta/...` at the same path inside the VM, so no translation is needed. A remote Linux box has no `/Users`; `$HOME` is `/home/rsletta`. The destination path must therefore be **resolved on the remote** (`ssh host 'mkdir -p ~/.cache/agent-clipboard && printf %s "$HOME"'`), never computed locally and assumed to match.
2. **`pngpaste` is macOS-only.** Capture needs a platform shim if the tool is ever run from Linux: `pngpaste` (macOS), `wl-paste` (Wayland), `xclip -selection clipboard -t image/png -o` (X11).

So the tool has three layers, and only the middle one is portable as-is:

| Layer | Portability |
|---|---|
| capture (clipboard -> local file) | per-OS shim; today only macOS matters, since the clipboard is always on the laptop |
| transfer (`scp`/`rsync`) | portable |
| destination path | must be resolved **on the target**, per-target — this is what breaks the mirror trick |

The sandbox case already crosses macOS -> Linux, but gets away with it because Lima mirrors paths. That is a property of Lima, not a general solution, and the remote case cannot reuse it.

### The clipper model dissolves most of this

Inspiration: [wincent/clipper](https://github.com/wincent/clipper) (Greg Hurrell). Clipper is a daemon on the **local** machine that owns the clipboard; `RemoteForward` makes its socket reachable from the remote; the remote just pipes to `nc localhost 8377`. The remote needs to know nothing about the local machine.

```
# ssh_config
Host host.example.org
  RemoteForward /home/me/.clipper.sock /Users/me/.clipper.sock
```

Image paste is the same plumbing with the data flowing the other way — an **inverse clipper**. The daemon *serves* the clipboard image instead of receiving text:

1. local daemon, on connect, runs the platform's clipboard-read (`pngpaste -`) and writes PNG bytes to the socket
2. `RemoteForward` exposes that socket on the remote
3. on the remote, `imgpaste` reads the socket, writes the bytes to a file **on its own filesystem**, prints that path
4. the tmux adapter `send-keys` the path into the agent's pane

This answers all three open questions rather than deciding them:

- **Remote-pane detection: not needed.** The command already runs on the remote, inside the pane. Nothing has to guess.
- **Path resolution: not needed.** The remote writes wherever it likes and knows its own path. The mirror problem disappears.
- **Platform agnosticism: falls out.** Only the daemon touches a clipboard, and it always runs on the machine that owns one. The remote side is plain bytes to a file — identical on Linux and macOS.

It also unifies local and remote: the *same* `imgpaste` works both ways, because locally it talks to the real socket and remotely to the forwarded one. Same property that makes clipper work.

Note clipper itself cannot be reused directly — it *sets* the clipboard from received text, one-way. This needs the read direction and binary-safe transfer.

Rough size: small daemon (a socket listener shelling out to `pngpaste -`), one `ssh_config` block, a client script, a two-line tmux binding. Not large — but cleanly separable, so: **deferred to its own session.**
- Pi status adapter. No known hook surface; parked.

## Notes

- `docs/herdr.md` claims ivit-monorepo and ivit-webclient are flat. Stale — both nested now. Fix as detection logic moves.
- herdr core has no scrollback regex search (third-party plugin only). Open question in `docs/herdr.md` — answered, and it's a regression from tmux-copycat.
- tmux 3.7c: floating panes, OSC 133, pane scrollbars. Actively developed; 3.8 accumulating.

## Unresolved

1. Window naming for worktrees — `repo/branch`, bare branch slug, or something else? Decide in slice 4 from use.
2. ~~Does `wt` belong in `scripts/`?~~ Yes — `scripts/wt`, symlinked to `~/.local/bin/wt`, per existing convention.
3. Worktree window in the repo's context session, or its own session when it gets busy? Defer — expand/contract workflow may make it moot.
