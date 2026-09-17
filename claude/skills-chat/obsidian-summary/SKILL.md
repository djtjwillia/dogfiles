---
name: obsidian-summary
description: Produce a structured Obsidian-flavoured summary note of the current conversation, ready to download and drop into your vault. Use when asked to save, log, or summarise this conversation for Obsidian, when writing a doc or reference note, or when capturing a decision or ADR.
---

## Purpose

Produce a well-structured Obsidian note from the current conversation. The output must be useful out of context — readable weeks later by someone (including you) who wasn't in this chat.

All output uses Obsidian-flavoured markdown: YAML frontmatter with Dataview-compatible properties, `[[wikilinks]]` for internal vault links, `> [!type]` callouts for highlighted information, and Mermaid diagrams where structure warrants it.

> [!note] Chat runtime, not Claude Code
> This variant runs in claude.ai / Claude Desktop, which has no access to your Mac's filesystem, no git, and no session log to read back. It cannot write directly to your vault or infer a project from a git branch. Instead it produces a downloadable `.md` file and tells you exactly where to file it.

---

## Step 1 — Infer the note type

Determine what kind of note this conversation calls for. Show the inferred type and confirm before proceeding.

| Type | When to use | Default location |
|------|-------------|-----------------|
| `session` | General work summary, progress, task completion | `50-notes/AI Sessions/<project>/<label>/` |
| `document` | Standalone reference meant to be read on its own (how-to, explainer, overview) | `50-notes/Docs/<project>/` |
| `decision` | A specific decision with context and rationale (ADR) | `50-notes/Decisions/<project>/` |
| `investigation` | Exploration or research without implementation — findings and open questions | `50-notes/Investigations/<project>/` |

Infer the type from what was asked ("write a doc", "save what we decided", "summarise this") and the nature of the conversation.

Show the inferred type as:
> `→ Note type: <type>` — <one sentence explaining why>
> Type a different type to override, or confirm to continue.

---

## Step 2 — Derive project, label, and filename

There is no git branch or repo to read here, so ask instead of inferring:

- **Project:** the subject/product/client this conversation is about. If it's obvious from context, propose it and let the user correct it; otherwise ask one question.
- **Label:** a short slug for this specific conversation or topic (e.g. `pricing-page-copy`, `q3-roadmap`). Derive from the conversation subject; ask only if genuinely unclear.
- **Engagement (optional):** if you know this maps to a named client/engagement, note the slug for the `engagement:` frontmatter property; omit otherwise — don't guess.

**Filename:**
- `session` → `<YYYY-MM-DD>-session.md`
- `document` → `<slugified-title>.md`
- `decision` → `<YYYY-MM-DD>-<slugified-title>.md`
- `investigation` → `<YYYY-MM-DD>-<slugified-subject>.md`

Ask at most one question, combining project + label into a single ask when both are unclear:
> `→ Proposed: project=<project>, label=<label>` — correct if wrong, or confirm.

---

## Step 3 — Generate the note

Use the template for the inferred type. Apply Obsidian-flavoured markdown throughout:

- Use `[[wikilinks]]` when referencing other notes that likely exist in the vault (specs by number, previous sessions by label)
- Use `> [!type]` callouts for decisions, risks, warnings, and tips — choose the type that fits: `note`, `tip`, `warning`, `important`, `danger`, `question`
- Use Dataview-compatible frontmatter properties (typed: dates as `YYYY-MM-DD`, arrays as YAML lists)
- Use `%%hidden comments%%` for internal notes not meant for reading view
- Use `- [x]` / `- [ ]` task syntax for status tracking

There is no Synod Council agent roster in this chat runtime — there is no `agents:` frontmatter field and no "Agent Findings" section in any template below.

---

### Template: session

```markdown
---
type: session
project: <project>
label: <label>
date: <YYYY-MM-DD>
engagement: <slug, if known — omit otherwise>
tags:
  - claude-chat
  - <project>
status: complete
---

# <label> — <YYYY-MM-DD>

## What We Were Doing
One or two sentences. The task or problem, framed for someone reading cold.

## Decisions Made

> [!important] Key Decisions
> Brief one-line summary of the most important decision(s).

| Decision | Reasoning | Alternatives Considered |
|----------|-----------|------------------------|
| | | |

%%Omit this section if no explicit decisions were made%%

## Task Status
- [x] Completed task
- [~] In-progress task
- [ ] Not started

## Open Questions
%%Only include unresolved questions — things that came up but weren't answered%%
- [ ] Question

> [!question] Needs Decision
> Use for anything that explicitly requires the user's input before work can continue.

## Next Steps
%%Only concrete actions identified in this conversation — not aspirational%%
- [ ] Step

## Diagrams
%%Include only if the conversation involved non-obvious flows, state machines, or cross-component interactions%%
%%See diagram guidance below%%
```

---

### Template: document

```markdown
---
type: document
project: <project>
date: <YYYY-MM-DD>
engagement: <slug, if applicable — omit otherwise>
tags:
  - claude-chat
  - <project>
  - reference
aliases:
  - <alternative title if useful>
status: draft
---

# <Title>

> [!note] About This Document
> One sentence on what this is and who it's for.

## Overview
<Purpose and scope>

## <Section>
<Content — use wikilinks to related notes, callouts for important asides>

## Related
- [[<related note>]]
```

---

### Template: decision

```markdown
---
type: decision
project: <project>
date: <YYYY-MM-DD>
engagement: <slug, if applicable — omit otherwise>
tags:
  - claude-chat
  - <project>
  - adr
status: accepted
---

# Decision: <Title>

## Context
What situation or problem prompted this decision.

## Decision
What was decided, stated plainly.

> [!important] Summary
> One-sentence version of the decision for scanning.

## Reasoning
Why this option over alternatives.

## Alternatives Considered

| Option | Why Rejected |
|--------|-------------|

## Consequences
What this decision makes easier, harder, or precludes.

> [!warning] Trade-offs
> Anything worth flagging as a known downside.

## Related
- [[<related note>]]
```

---

### Template: investigation

```markdown
---
type: investigation
project: <project>
date: <YYYY-MM-DD>
engagement: <slug, if applicable — omit otherwise>
tags:
  - claude-chat
  - <project>
  - investigation
subject: <what was investigated>
outcome: <inconclusive | findings | abandoned>
---

# Investigation: <Subject>

## What We Were Looking At
One or two sentences on the question or area being explored.

## Findings

> [!tip] Key Finding
> The most important thing learned.

<Findings in prose or bullets — be specific>

## What We Didn't Explore
Things that were adjacent but out of scope for this conversation.

## Open Questions
- [ ] Question

## Next Steps
- [ ] Step, or "None — investigation complete" if finished
```

---

## Diagram guidance

Generate a Mermaid diagram if the conversation involved something with structure that prose can't convey cleanly. Place under `## Diagrams` (session/investigation) or inline where relevant (document/decision).

**Use a diagram when the conversation involved:**
- A multi-step flow across components → `sequenceDiagram` or `flowchart`
- State or status transitions → `stateDiagram-v2`
- Decision branching logic → `flowchart TD`
- Data model or entity relationships → `erDiagram`
- Pipeline or dependency ordering → `flowchart LR`

**Skip a diagram when:**
- The conversation was a linear Q&A with no branching
- The decisions table already shows the structure clearly
- You would be inventing structure not present in the conversation

Format:
````markdown
```mermaid
<diagram>
```
> <One sentence: what this shows and why it's worth having.>
````

One well-chosen diagram is better than three redundant ones.

---

## Step 4 — Confirm before writing

Show the full generated note and ask:
> **Ready to save?** (`y` to confirm, `e` to edit first, `n` to cancel)

Do not produce the file until confirmed.

---

## Step 5 — Write the file and offer for download

Write the markdown to `/mnt/user-data/outputs/<filename>` (the filename derived in Step 2) and offer it to the user as a download.

If `/mnt/user-data/outputs/` is not writable in this environment, fall back to printing the complete markdown in a fenced code block so the user can copy it manually — do not truncate or summarise it.

---

## Step 6 — Tell the user where it goes

Report the destination folder for this note type so the user can drop the downloaded file into the right place in their vault:

| Type | Destination in vault |
|------|----------------------|
| `session` | `50-notes/AI Sessions/<project>/<label>/` |
| `document` | `50-notes/Docs/<project>/` |
| `decision` | `50-notes/Decisions/<project>/` |
| `investigation` | `50-notes/Investigations/<project>/` |

> ✓ Note ready: `<filename>`. Drop it into `50-notes/<subfolder>/<project>[/<label>]/` in your vault.

If this conversation is a continuation of previous work that likely has a note in the vault already, suggest the wikilink:
> 💡 You may want to add `[[<previous session label>]]` to link this note to that one.
