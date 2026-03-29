# .claude/

Shared Claude Code configuration for this project.

## Structure

```
.claude/
├── settings.json       # Shared project settings (hooks, etc.)
├── settings.local.json # Personal settings override (gitignored)
├── hooks/              # PreToolUse hook scripts
│   └── example-hook.sh # Example hook — replace with your own
├── skills/             # Project-specific skills
│   └── .gitkeep
├── plans/              # Shared project plans (tracked)
│   ├── .gitkeep
│   └── local/          # Personal/scratch plans (gitignored)
│       └── .gitkeep
└── local/              # Personal scripts and config (gitignored)
    └── .gitkeep
```

## Personal configuration

Use `.claude/local/` for personal scripts and `.claude/settings.local.json` for personal settings overrides. Both are gitignored.

## Plans

Write plans to `.claude/plans/<plan-name>.md` (tracked in git). Use `.claude/plans/local/` for scratch or personal plans (gitignored).
