# dogfiles — Agent Rules

## Scope confirmation (pre-action gate)

- Before exploring, editing, or dispatching an agent, confirm the exact operating target whenever the request could be ambiguous: which repo (this working directory vs an external GitHub repo), which path (the source in `~/Code/projects/dogfiles` vs the deployed destination such as `~/.dotfiles` or `~/.claude`), which task target or tool.
- Sources live in this repo; deployed destinations are managed outputs (see CLAUDE.md). A request that names a deployed path means "change the source here, then apply via the task target" — confirm if unclear.
- If the target is ambiguous, ask ONE clarifying question before proceeding. Never assume and correct afterward.
