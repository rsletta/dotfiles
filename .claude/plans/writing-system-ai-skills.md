# Writing System — AI Skill Assistance

Status: backlog / discovery

## The idea

The writing system (notes, til, posts) has context-specific config: paths, templates,
frontmatter schemas. Claude can use this config to actively assist the writing process —
not just scaffold files, but help shape content before it hits the editor.

## What we know

- Each context defines: vault path, TIL path, post path, TIL template, post template
- Templates have placeholders (__TITLE__, __DATE__, etc.)
- Frontmatter schema differs per context (blog needs categories, vault note may need tags, work notes may need something else entirely)
- The user has real friction around writing due to self-awareness and self-criticism

## What might be powerful

- A skill that reads the active context's writing config and knows what frontmatter is expected
- Can help draft/suggest frontmatter values (categories, tags) based on title/content
- Could help with the blank-page problem: given a TIL title, suggest an opening line or structure
- Could validate frontmatter against the context's schema before the file is written
- Longer term: a `notes search` that uses semantic search across the vault, not just fzf

## Discovery questions

1. What does frontmatter look like across all contexts we'll eventually have?
2. Should the template files be the source of truth for schema, or a separate schema file per context?
3. At what point in the flow does AI assist — before opening the editor, inside it, or after?
4. Is the skill a Claude Code skill (terminal), or does it need to hook into Obsidian too?
5. How do we handle the "I learned something small" moment — voice note, quick terminal capture, something else?

## Next steps (when ready)

- [ ] Complete the core writing system (current plan) first
- [ ] Document frontmatter schemas for each context as they are created
- [ ] Sketch the skill interface: what does `klaude til` or `klaude notes` look like?
- [ ] Prototype a frontmatter suggestion skill against the rsletta context
