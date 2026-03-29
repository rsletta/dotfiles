# Scripts

Utility scripts in `scripts/`. Added to PATH via `~/.local/bin` or called directly.

## Tmux

| Script | Description |
|--------|-------------|
| `newTmuxSession <name>` | Create or attach to named tmux session from current directory |

## Notes and writing

Not actively used, planned for revision.

| Script | Description | Depends on |
|--------|-------------|------------|
| `dailyNote` | Open today's daily note, create from template if missing | WRITING_PATH, lib/yyyymmdd |
| `quickReadNote` | Fuzzy-select and read a daily note with bat | WRITING_PATH, fzf, bat |
| `newNote` | Create new note in Inbox with title | tmux, lib/slugify, lib/yyyymmdd |
| `createNewPost` | Create blog post with frontmatter and tags | BLOG_PATH, lib/slugify, lib/yyyymmdd |

## Utilities

| Script | Description | Depends on |
|--------|-------------|------------|
| `fports "8080,3000" user@host` | SSH port forwarding for comma-separated ports | ssh |
| `create-script` | Scaffold Python CLI script with uv + click | uv (Python) |
| `alvify.sh` | Interactive text transformer for Norwegian text (A/a replacement) | — |
| `generate-vivaldi-raycast-commands.sh` | Generate Raycast commands for Vivaldi browser profiles | jq, Vivaldi |

## Kubernetes helpers

| Script | Description | Depends on |
|--------|-------------|------------|
| `kubernetes-helpers/kubelog` | Interactive log aggregation with stern + lnav + jq | kubectl, stern, jq, lnav |
| `kubernetes-helpers/tail-logs` | Stream pod logs to files (project-specific, hard-coded namespaces) | kubectl, jq |

## Library (scripts/lib/)

| Script | Description |
|--------|-------------|
| `slugify` | Convert string to URL-safe slug |
| `yyyymmdd` | Return today's date as YYYY-MM-DD |

## ffmpeg

| Script | Description |
|--------|-------------|
| `ffmpeg/extract_clip` | Interactive video clip extraction with time range prompts | ffmpeg |
