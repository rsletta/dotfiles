# herdr

Trial notes for [herdr](https://herdr.dev) (terminal workspace manager, client/server, persistent). tmux stays as-is; herdr runs alongside under evaluation. Config: `herdr/config.toml` → symlinked to `~/.config/herdr/config.toml`. Reload with `herdr server reload-config`.

## Mental model (why not everything ports)

herdr is **workspace → tab → pane**, **agent-first**, **sidebar-first**. tmux is **session → window → pane** with a status line. So tmux's status bar, window auto-rename, mouse hacks, and tpm plugins aren't missing knobs — they're concepts herdr replaces with its sidebar + agent UI. Port the *bindings/behaviors*, not the *scaffolding*.

## Porting checklist (from current tmux.conf)

Legend: ✅ already herdr default · ⚙️ set in config · 🔀 re-express herdr-native · ⛔ skip (n/a) · ⚠️ verify first

| tmux setting | herdr | Action | Decision |
|---|---|---|---|
| `prefix C-a` | `[keys] prefix = "ctrl+a"` | ⚙️ **done** (zsh vi-mode → no line-start conflict; nvim `ctrl+a` increment is the only residual) | [x] |
| vi pane nav `h/j/k/l` | `focus_pane_*` = `prefix+h/j/k/l` | ✅ default, confirmed | [x] |
| new pane inherits cwd | `[terminal] new_cwd = "follow"` | ✅ default | [ ] |
| `bind r` reload | `reload_config = prefix+shift+r` | ✅ default | [ ] |
| `bind a` copy-mode | `copy_mode = prefix+[` | ✅ default | [ ] |
| `bind c` new window | `new_tab = prefix+c` | ✅ default | [ ] |
| `default-shell /bin/zsh` | `[terminal] default_shell` (empty = `$SHELL`) | ✅ default (zsh already) | [ ] |
| splits (arrow setup, 99% down/right) | `split_horizontal="prefix+down"` (stack), `split_vertical="prefix+right"` (side-by-side) | ⚙️ **done** (up/left left unbound; herdr has no directional placement) | [x] |
| worktree fallback root | `[worktrees] directory = "~/ws/worktrees"` | ⚙️ **done** (native herdr menu fallback; preferred flow is `herdr-worktree`) | [x] |
| new worktree | `prefix+shift+g` | ⚙️ **done** via `herdr-worktree --interactive` wrapper | [x] |
| remove worktree | `prefix+shift+d` | ⚙️ **done** via `herdr-worktree-rm` wrapper; removes linked checkout, keeps branch | [x] |
| prev/next window `C-h`/`C-l` | tabs `prefix+p` / `prefix+n` | 🔀 or bind `ctrl+h/l` direct | [ ] |
| `history-limit 10000` (lines) | `[advanced] scrollback_limit_bytes` (~10MB default) | 🔀 default likely fine | [ ] |
| mouse hacks (no click-focus, drag-copy, wheel) | `mouse_capture`, `right_click_passthrough_modifier`, `mouse_scroll_lines` | ⛔ evaluate herdr's mouse model natively | [ ] |
| `terminal-overrides` / `extended-keys` / `terminal-features` / `allow-passthrough` | (internal to herdr) | ⛔ not expressible, not needed | [ ] |
| status bar / titles / `automatic-rename off` | sidebar (no status line) | ⛔ n/a | [ ] |
| tpm plugins: tokyo-night | `[theme] name = "tokyo-night"` | ✅ done | [x] |
| tpm plugins: yank / open / copycat | native clipboard / URL / copy-mode | ⛔/⚠️ no plugin system — see verify | [ ] |

## Context propagation (solved)

herdr does **not** forward context env out of the box (no `tmux setenv`/`update-environment` equivalent). Implemented instead as, all multiplexer-agnostic:

1. `cch`/`cenv` persist the active context per pane to `~/.local/state/herdr-ctx/$HERDR_PANE_ID` (`71-contexts.sh`, `_herdr_ctx_persist`).
2. In a solo workspace (one tab, one pane), `cch` also promotes the context to the workspace default at `~/.local/state/herdr-ctx/workspaces/$HERDR_WORKSPACE_ID`. In a populated workspace, `cch` is pane-local unless run as `cch --workspace <context>`.
3. `prefix+c` runs `scripts/herdr-tab`, which reads the workspace default and calls `herdr tab create --env SHELL_CONTEXT=… --env CONTEXT_ENV=…`.
4. `prefix+↓`/`prefix+→` run `scripts/herdr-split`, which reads the source pane's state (via `HERDR_ACTIVE_PANE_ID`) and calls `herdr pane split --env SHELL_CONTEXT=… --env CONTEXT_ENV=…`.
5. Shell startup re-activates any inherited context (`71-contexts.sh` restore, no longer `$TMUX`-gated).

Verified: split inherits the source pane's *current* context (incl. after an in-session `cch`); a cleared pane splits context-less. Detail: `.agents/plans/herdr-context-propagation.md`.

## Worktrees

Native herdr worktree creation is still useful. It treats worktrees as disposable, agent-friendly checkouts: the checkout lives under a managed root, herdr opens it as a separate workspace, and removing the herdr worktree removes the checkout while leaving the Git branch intact.

The managed root is configured under `~/ws` instead of herdr's default `~/.herdr` location:

```toml
[worktrees]
directory = "~/ws/worktrees"
```

That keeps herdr's native flow intact while placing unmanaged/default checkouts somewhere visible in the normal workspace tree.

Preferred human-driven creation is `herdr-worktree`, which computes a path dynamically:

- Detects the current repo from the active herdr pane or `$PWD`
- Re-enters the source context before fetching, so context-scoped Git credentials are available
- Fetches remotes before resolving branch names
- Accepts remote branches as either `feature/name` (default remote) or `origin/feature/name`, creating local branch `feature/name` from the fetched remote ref
- Generates `worktree/<adjective>-<noun>-<hex>` when no branch is supplied
- Places the checkout as a sibling of the main checkout, named per the repo's layout (below)
- Calls `herdr worktree create --cwd <repo> --branch <branch> --path <path>`
- Carries the source context into the new workspace by parsing the created root pane and running `cch --workspace <context>` there. Herdr's `worktree create` has no documented `--env` option, so this is post-create activation rather than launch-time env injection.

### Checkout layouts

Two repo layouts are supported. Worktrees are siblings of the main checkout in both, and the branch slug is identical in both (`feature/iv-123-foo` → `feature-iv-123-foo`); only the directory prefix differs.

| Layout | Repo | New worktree | herdr label |
| --- | --- | --- | --- |
| nested | `iverdi/ivit-localdev/main` | `iverdi/ivit-localdev/feature-iv-123-foo` | `ivit-localdev/feature-iv-123-foo` |
| flat | `iverdi/ivit-monorepo` | `iverdi/ivit-monorepo-feature-iv-123-foo` | `ivit-monorepo-feature-iv-123-foo` |

Nested is the preferred layout: a container dir named after the repo, one child dir per checkout named after its branch. The prefix is redundant there because the container already carries the repo name. Flat is the older convention that `ivit-monorepo` and `ivit-webclient` still use; moving such a repo into a container is a pure directory move, with no config change needed.

Detection is automatic, based on the repo's **main** worktree (not the current one, so creating a worktree from inside a worktree no longer compounds the suffix into `ivit-monorepo-feature-x-hotfix-y`). It reports nested when any of these holds:

- the main checkout's dir name is `main`, `master`, `trunk`, or `develop`
- the main checkout's dir name equals the slug of its own branch — e.g. dir `release-2024` on branch `release/2024`
- the checkout sits next to a `.bare` dir, or the repo *is* a `<repo>/.bare` bare clone with checkouts alongside it

Otherwise flat. Override with `HERDR_WORKTREE_LAYOUT=nested|flat|auto` (default `auto`; anything else is a hard error). An explicit `--path` still wins over both. `--dry-run` prints the detected `layout:` and the resolved main checkout, so a misdetection is visible without creating anything.

`prefix+shift+g` runs `herdr-worktree --interactive` in a temporary pane. It prompts for branch, base, and checkout path with generated defaults, then opens the new checkout as a herdr workspace. The header shows the resolved repo and detected layout.

`prefix+shift+d` runs `herdr-worktree-rm --interactive` in a temporary pane. It only removes linked worktree checkouts, refuses source checkouts, closes the herdr workspace through `herdr worktree remove`, and leaves the Git branch intact.

`--interactive` only controls pause-on-exit: on failure it prints `press enter to close...` so the message survives long enough to read. Without it a `type = "pane"` binding closes the pane the instant the script exits, and every error path is invisible. Run without the flag from a normal shell.

## Troubleshooting: stale server

Both wrapper families talk to herdr over the socket API, so a **client/server protocol mismatch takes all of them down at once** — splits, tabs, and worktree create/remove. It happens when the `herdr` binary is upgraded (e.g. by brew) while an old server keeps running:

```
{"error":{"code":"protocol_mismatch","message":
  "client protocol 19 is newer than server protocol 16; ..."}}
```

Every socket call then exits 1. Fix by restarting the server — note this exits pane processes:

```sh
HERDR_SOCKET_PATH="$HOME/.config/herdr/herdr.sock" herdr server stop
```

Then relaunch `herdr`. Because native `split_horizontal`/`new_tab`/`new_worktree` are deliberately unbound in favor of the wrappers, there is no fallback while the server is stale — the keys simply do nothing.

## ⚠️ Still to verify

- **Scrollback search** — currently tmux-copycat (regex search in scrollback). Confirm herdr copy-mode has a search equivalent before assuming parity.

## Config surface reference (v0.7.1)

Full default: `herdr --default-config`. Sections:

- `[keys]` — `prefix` + ~40 named actions (tabs/panes/workspaces/worktrees), `[[keys.command]]` custom binds (run e.g. lazygit in a pane/detached), separate navigate-mode keys.
- `[terminal]` — `default_shell`, `shell_mode` (auto/login/non_login), `new_cwd` (follow/home/current/path).
- `[ui]` — `sidebar_width`, `mouse_capture`, `mouse_scroll_lines`, `pane_borders`, `pane_gaps`, `confirm_close`, `prompt_new_tab_name`, `agent_panel_sort` (spaces/priority), `accent`.
- `[theme]` / `[theme.custom]` — built-in themes + per-token color overrides.
- `[ui.toast]` / `[ui.sound]` — in-app/terminal/system toasts, per-agent sounds.
- `[session]` — `resume_agents_on_restore` (native agent session resume).
- `[worktrees]` — git-worktree root dir. `[remote]` — SSH bridge keepalive.
- `[advanced]` — `scrollback_limit_bytes`. `[experimental]` — `pane_history`, kitty graphics, CJK IME handling.

## Status

Trial. Config tracked + symlinked + themed. Prefix (`ctrl+a`), splits (`↓`/`→`), vim pane nav, and context propagation all live. tmux unchanged. Open: scrollback search parity.
