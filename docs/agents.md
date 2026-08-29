# Agent status in tmux

Surfaces what each coding agent is doing without spending screen space on it. Replaces herdr's sidebar: the badge rides the status line and pane border that tmux already draws, so it costs **zero extra rows**.

## Why hooks rather than screen-scraping

herdr infers agent state by matching patterns against the pane's visible output, which is why it has an `unknown` state and why its docs describe blocked-detection as deliberately conservative. An agent's own lifecycle hooks are authoritative: the agent says what it is doing, nothing has to guess.

This also keeps it agent-agnostic. Claude Code, Codex and Pi each report through whatever mechanism they provide; all of them end up calling one command.

## The command

```sh
tmux-agent-status working|blocked|done|idle|clear [pane]
tmux-agent-status rollup [window]      # recompute a window badge, touching no pane
```

Sets `@agent_status` on the pane (defaults to `$TMUX_PANE`), then rolls the window up to the most urgent state among its panes as `@agent_win`.

Outside tmux it exits 0 and does nothing, so hooks are safe to leave configured everywhere.

### Two option names, deliberately

`@agent_status` is pane-scoped; `@agent_win` is window-scoped. They must differ. tmux resolves `#{@foo}` by walking pane → window → session, so a shared name breaks in two ways:

- the window badge renders whichever pane is *active* instead of the roll-up
- a pane whose value is cleared inherits the window's, so the roll-up reads its own output back and latches permanently

For the same reason the roll-up reads each pane with `show-options -pv` rather than `list-panes -F '#{@agent_status}'`, which would inherit.

## Badges

| State | Badge | Meaning |
|---|---|---|
| `working` | yellow ● | busy |
| `blocked` | red ▲ | wants you — permission, question |
| `done` | green ✓ | finished **and not yet looked at** |
| unset | — | nothing running |

Window badges come from `@agent_win` (the roll-up), pane-border badges from `@agent_status`. Urgency order is blocked > done > working, so a blocked agent is never masked by a busy sibling in the same window.

A pane dying takes its own state with it, but the window roll-up would keep showing it. `set-hook -g pane-exited` calls `tmux-agent-status rollup #{window_id}` so the badge is recomputed from the panes that remain.

`done` clears itself when you focus the pane (`pane-focus-in` hook in `tmux.conf`), which is what makes it mean "finished but unseen" rather than just "finished".

## Wiring Claude Code

Add to the context's Claude settings (`$CLAUDE_CONFIG_DIR/settings.json`). Each context has its own Claude home, so this is per-context.

```json
{
  "hooks": {
    "SessionStart":     [{ "hooks": [{ "type": "command", "command": "tmux-agent-status working" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "tmux-agent-status working" }] }],
    "Notification":     [{ "hooks": [{ "type": "command", "command": "tmux-agent-status blocked" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "tmux-agent-status done"    }] }],
    "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "tmux-agent-status clear"   }] }]
  }
}
```

`tmux-agent-status` must be on the hook's `PATH` (`~/.local/bin`). Use the absolute path if a hook runs with a reduced environment.

## Wiring Codex

Codex has a real hooks system (0.144.1), separate from `notify`. Events line up almost exactly with Claude Code's, and `PermissionRequest` is a cleaner "blocked" signal than Claude's generic `Notification`.

Written to `~/.codex/hooks.json`:

```json
{
  "hooks": {
    "SessionStart":     [{ "hooks": [{ "type": "command", "command": "tmux-agent-status working" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "tmux-agent-status working" }] }],
    "PermissionRequest":[{ "hooks": [{ "type": "command", "command": "tmux-agent-status blocked", "statusMessage": "tmux badge: blocked" }] }],
    "Stop":             [{ "hooks": [{ "type": "command", "command": "tmux-agent-status done"    }] }],
    "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "tmux-agent-status clear"   }] }]
  }
}
```

Deliberately a **separate file** rather than an inline `[hooks]` table in `config.toml`: that file already sets `notify` to Codex Computer Use's client, and `notify` takes a single program — wiring the badge there would have replaced it. Hooks and `notify` are independent, so both work.

**Codex requires you to trust a hook before it runs.** Run `/hooks` inside Codex, review the definitions, approve. Until then the file is inert. Full event list: `SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`, `PermissionRequest`, `UserPromptSubmit`, `PreCompact`, `PostCompact`, `SubagentStart`, `SubagentStop`, `Stop`.

## Wiring other agents

- **Pi** — no known hook surface yet. Parked. If it has none, a plugin is buildable, or fall back to a pane-content heuristic for that agent alone.

The design assumes nothing agent-specific: anything that can run a command on a state change is supported.

## Known gap

Nothing writes `working` when an agent is started outside a hook-capable path, and nothing detects a crashed agent — a killed pane simply stops reporting. The pane option dies with the pane, so this self-cleans, but a wedged agent will sit on a stale badge.
