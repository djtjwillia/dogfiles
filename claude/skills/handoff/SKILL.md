---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save location: if the current workspace has a `docs/handoffs/` directory, save there; otherwise if it has a `docs/` directory, save there; otherwise fall back to the temporary directory of the user's OS. When a handoff directory already contains prior handoffs, match its existing naming convention (numbering, slug style) rather than inventing a new one.

After writing the handoff, check the workspace for a progress or session-log file (e.g. `docs/PROGRESS.md`, `PROGRESS.md`, `CHANGELOG.md`). If one exists, append a single dated entry — timestamp, one-line description of the session, and a link to the new handoff file — matching that file's existing formatting (heading level, bullet style, date format). Do not restructure the file or duplicate the handoff's own content into it.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
