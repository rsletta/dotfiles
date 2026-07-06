# Agent-Agnostic Migration

1. [ ] Define target
   - `AGENTS.md` = repo rules
   - `.agents/` = shared agent artifacts
   - `.agents/plans/` = tracked plans
   - Claude = optional tool only

2. [ ] Keep / convert / delete
   - Keep: repo facts + conventions from `CLAUDE.md`
   - Convert: tracked/local plan pattern, reusable plan docs
   - Delete: `.claude/` scaffolds, `klaude`, `klaude-init`, Claude hook sample
   - Refactor: context skill path assumptions, session tooling, docs

3. [ ] Decide replacements
   - No wrapper replacement unless real multi-agent need exists
   - No bootstrap replacement unless generic bootstrap earns its keep
   - Skill sync target should be neutral
   - Session inspection should be explicit about tool scope

4. [ ] Implement passes
   - Pass 1: add `AGENTS.md`, `.agents/`, ignore rules
   - Pass 2: migrate useful guidance + plans
   - Pass 3: remove Claude bootstrap/functions/templates
   - Pass 4: neutralize context + skillshare integration
   - Pass 5: clean docs, references, leftovers

5. [ ] Validate
   - No repo guidance depends on Claude naming
   - No shell path requires `.claude/` unless tool-specific
   - Docs match real structure
   - Ignore rules clean

Unresolved questions:
1. Should skillshare sync into `.agents/skills/`, or stay context-level and only this repo becomes neutral?
2. Should `klaude-sessions` be deleted, or renamed as explicit Claude session tooling?
3. Do you want a generic repo bootstrap command later, or should this repo stop generating agent scaffolding for now?
