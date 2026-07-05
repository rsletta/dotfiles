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
2. `prefix+↓`/`prefix+→` run `scripts/herdr-split`, which reads the source pane's state (via `HERDR_ACTIVE_PANE_ID`) and calls `herdr pane split --env SHELL_CONTEXT=… --env CONTEXT_ENV=…`.
3. Shell startup re-activates any inherited context (`71-contexts.sh` restore, no longer `$TMUX`-gated).

Verified: split inherits the source pane's *current* context (incl. after an in-session `cch`); a cleared pane splits context-less. Detail: `.agents/plans/herdr-context-propagation.md`.

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
