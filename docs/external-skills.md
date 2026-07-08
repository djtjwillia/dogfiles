# External skills

Some Claude Code skills are installed straight onto the machine with the
[`vercel-labs/skills`](https://github.com/vercel-labs/skills) CLI
(`npx skills add …`) rather than vendored into `claude/skills/`. They live at
`~/.claude/skills/` (and, for multi-agent skills, `~/.agents/skills/` with a
symlink from `~/.claude/skills/`), tracked machine-locally in
`~/.agents/.skill-lock.json` — not committed to this repo.

This file is the human-readable index of what should be installed and why.
The `Taskfile.yml` target `tools:claude-skills-external` is the source of truth
for the exact install commands.

## Installed skills

| Skill | Source | Agents installed | Purpose |
|---|---|---|---|
| skill-creator | `anthropics/skills` | claude-code | Scaffolds and edits Claude Code skills. |
| improve | `shadcn/improve` | claude-code | Senior-advisor-style read-only codebase audit; produces prioritized implementation plans for other agents. |
| sdd | `liatrio-labs/spec-driven-workflow` | claude-code | Liatrio Spec-Driven Development workflow (explicitly invoked, never auto-triggered). |
| agent-browser | `vercel-labs/agent-browser` | claude-code, cursor, github-copilot, zed | Browser automation CLI for AI agents. |
| frontend-design | `anthropics/claude-code` | claude-code, cursor, github-copilot, zed | Distinctive, production-grade frontend UI generation. |
| web-design-guidelines | `vercel-labs/agent-skills` | claude-code, cursor, github-copilot, zed | Reviews UI code against the Web Interface Guidelines. |
| grill-me | `mattpocock/skills` | claude-code, cursor, devin, github-copilot, windsurf, zed | Interrogates you about a plan or design before building. |
| grill-with-docs | `mattpocock/skills` | claude-code, cursor, devin, github-copilot, windsurf, zed | Same as grill-me, grounded against project docs. |
| grilling | `mattpocock/skills` | claude-code, cursor, devin, github-copilot, windsurf, zed | Interview / stress-test skill (this repo's Skill-tool-listed grill variant). |

## Deliberate exclusions

Two skills are installed on this machine but intentionally left out of the table above:

- **`handoff`** (from `mattpocock/skills`) is installed globally too, but this repo
  vendors its own customized `handoff` skill at `claude/skills/handoff/` — it adds
  `docs/handoffs` save-location logic and progress-log support. That copy is synced
  by the existing `tools:claude-skills` Taskfile target, so it is repo-owned, not an
  external/npx-managed skill.
- **`find-skills`** (from `vercel-labs/skills`) is installed only for Cursor, GitHub
  Copilot, and Zed — it was never wired up for Claude Code — so it is out of scope for
  this Claude-Code-focused list.

## Installing / refreshing

Run `task tools:claude-skills-external` to install or refresh all of the skills in
the table above. See that target in `Taskfile.yml` for the exact `npx skills add`
invocations — this doc is the human-readable index, the Taskfile is the source of
truth for commands.
