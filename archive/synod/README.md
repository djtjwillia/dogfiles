# Synod Council (archived)

Archived 2026-10-27 in favor of a Sazed-persona-only `claude/CLAUDE.md`.
Last commit containing the full Synod in its live locations: `b5bfd03`.

## What it was

A 12-agent Claude Code council governed by a charter in `CLAUDE.md`.

- **Agents:** synod-vin, -kelsier, -elend, -marsh, -tensoon, -vendell, -jasnah, -wax, -steris, -melaan, -marasi, -kaladin. Each is a `synod-*.md` with frontmatter (description carries routing triggers, `disallowedTools` enforces write-lockdown on review-only agents).
- **Charter:** routing rules, veto-holders (elend, marsh, tensoon, steris), cascading halt, escalation language, 3-agent ceiling.
- **Promotion stages:** PLAN, PROBE, NARROW, WIDE. Permission ceiling per stage; all implementation routed through synod-vin.
- **SDD routing:** agent responsibilities per Spec-Driven Development phase; one synod-vin dispatch per task.
- **Eval harness:** per-agent routing/behavior scenarios (`agents/eval/`) run via the `/run-evals` command, one judging subagent per scenario.

## File map

| Archive path | Original path |
|---|---|
| `agents/synod-*.md` (12) | `claude/agents/synod-*.md` |
| `agents/eval/` | `claude/agents/eval/` |
| `charter-details.md` | `claude/charter-details.md` |
| `commands/run-evals.md` | `claude/commands/run-evals.md` |
| `CLAUDE.full.md` | copy of `claude/CLAUDE.md` at `b5bfd03` (original rewritten) |

## Restore

1. `git mv archive/synod/agents/* claude/agents/` (move `eval/` too; remove `claude/agents/.gitkeep` if desired).
2. `git mv archive/synod/charter-details.md claude/charter-details.md`
3. `git mv archive/synod/commands/run-evals.md claude/commands/run-evals.md`
4. `cp archive/synod/CLAUDE.full.md claude/CLAUDE.md`
5. `task tools:claude`

Alternatively: `git checkout b5bfd03 -- claude/`.

## Deployment notes

- `~/.claude/agents/` is mirrored with `--delete`; archived agents are pruned on the next `task tools:claude`.
- `~/.claude/charter-details.md` and `~/.claude/commands/run-evals.md` are not auto-pruned (commands/ sync is additive); remove them manually.
