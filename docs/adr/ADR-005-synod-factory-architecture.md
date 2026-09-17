# ADR-005: Synod Factory — Harness-Enforced Governance, Thin Roles, and Interactive-First Orchestration

## Status
Proposed (Draft — for user review; nothing implemented)

## Date
2026-09-14

## Context

The Synod Council (ADR-001 → ADR-004, specs 01–05) was designed in mid-2026 around the Claude Code primitives available then: subagent frontmatter, a lean-core `CLAUDE.md`, and prompt-enforced promotion staging (PLAN / PROBE / NARROW / WIDE). It has served well as a **consulting topology** — a user talks to Sazed, Sazed routes to ≤3 specialists, specialists report back.

The user now wants a **software factory**: hand the harness a unit of work (a ticket pasted into chat, a spec directory, a Slack command via a later skill) and have it plan, implement in isolation, verify deterministically, review adversarially, and open a PR — with the human touching it once, at merge. The current setup cannot do this without change, for reasons an audit against the September 2026 Claude Code docs makes concrete:

| # | Finding | Evidence | Severity |
|---|---------|----------|----------|
| 1 | **Every governance control is a soft gate.** PLAN/PROBE/NARROW/WIDE, Marsh-first, Elend-before-Vin, output gates, cascading halt — all enforced by prompt text in `claude/CLAUDE.md`. Zero hooks exist in `claude/`. The only harness-enforced control is `disallowedTools` on review agents. ADR-003 flagged this and deferred it. | `grep -r hooks claude/` → none | **HIGH** — unattended runs cannot rely on model compliance |
| 2 | **The fleet primitive is denied.** `claude/settings.json` → `"permissions": { "deny": ["Artifact", "Workflow"] }` (commit `d7b2baf`). `Workflow` is the harness's native fan-out: `agent()/parallel()/pipeline()/phase()`, 16 concurrent, 1,000 per run, schema-typed results, resumable. Specs 04/05 then hand-build the same capability out of herdr panes and a Kelsier-maintained registry. | `claude/settings.json` L20 | **HIGH** — the factory's main engine is switched off |
| 3 | **Orchestration state lives in an LLM's context.** Spec 05's seven-field flow registry is "maintained by synod-kelsier" (a `sonnet`/`effort: low` agent). Context compaction erases it. Nothing on disk records which flows are live. | `charter-details.md` §S2 | **HIGH** — correctness under concurrency |
| 4 | **Twelve personas is a consulting topology, not a manufacturing one.** Each `synod-*.md` carries ~1.5–2k tokens of voice, coordination prose, and checklists — paid on every dispatch. The ≤3-agent ceiling (ADR-001) is right for routing a conversation, wrong for a fleet of N identical implementers over a task list. | 12 × `claude/agents/synod-*.md` | **MEDIUM** — cost and routing contention at scale |
| 5 | **Legacy slash commands.** `claude/commands/{run-evals,summary}.md` predate skills. Only skills participate in `/skill-doctor` usage stats and `claude plugin eval`. | `claude/commands/` | **LOW** |
| 6 | **Hand-rolled evals.** `run-evals` spawns judge subagents and appends to `results.md`. `claude plugin eval` now provides isolated runs, A/B with/without, HTML + JSON reports natively — but only for content packaged as a plugin. | `claude/commands/run-evals.md` | **LOW** |
| 7 | **Unused frontmatter that now matters for unattended work.** No agent sets `maxTurns` (budget cap), `memory` (cross-session precedent), `skills` (guaranteed preload — vin's prose claims `agent-browser`, its frontmatter does not), `isolation`, `background`, or per-agent `hooks`. | ADR-003 Observation 2 | **MEDIUM** |
| 8 | **No model-routing story.** `model:` values are `sonnet`/`opus`; there is no path for non-Anthropic models, which the user explicitly wants available inside the same harness. | all agents | **MEDIUM** |

### User constraints recorded for this decision

- **Claude Code is the harness.** Not Cowork, not a bespoke SDK service, not a Python orchestrator. Best practices for that harness apply.
- **Claude-first, not Claude-only.** Other vendors' models must be usable for specific roles without leaving the harness.
- **Personality stays.** Sazed's voice and the Synod names are a feature of the *conversation layer*. They are not to be stripped — only moved off the hot path.
- **No `claude -p` requirement for the user.** The user mixes a bare `claude` in a repo with the Claude Code UI. Both must drive the factory. Headless mode is reserved for machine-initiated triggers (a later Slack-skill spec).
- **No Linear integration in the orchestrator.** A ticket is *handed* to the factory ("take on LIN-123", a pasted body, a spec dir). Nothing polls Linear. The Linear MCP remains available to the *conversation* for reading a ticket the user names; it is not a queue.
- **ADR-004's lesson stands:** no hook ever returns `permissionDecision: "allow"` blindly, no vendor installer writes into a managed destination.

## Decision

Adopt the **Synod Factory** architecture in five parts. Spec 06 turns this into tasks; this ADR records *why*.

### D1 — Governance moves from prompt to hooks (hard gates)

The promotion ladder stays — it is good UX — but its **enforcement** moves to `settings.json` hooks reading a stage file on disk:

| Control (today: prose) | Hook | Mechanism |
|---|---|---|
| "Sazed never writes; nobody writes in PLAN/PROBE" | `PreToolUse` on `Edit\|Write\|NotebookEdit\|MultiEdit` | Reads `.claude/factory/stage` (`PLAN\|PROBE\|NARROW\|WIDE`); exits 2 with `additionalContext` naming the stage if not promoted. The user promotes by saying so; Sazed writes the file (a `Bash` write to one path is the *only* write Sazed is allowed). |
| Marsh-first | `PreToolUse` on `Edit\|Write` with path match (`**/auth/**`, `*.env*`, `**/secrets/**`, `*.tf` touching IAM, lockfiles, CI workflow files) | Exits 2 unless `.claude/factory/approvals/marsh-<flow>.json` exists for the current flow. |
| Output gates (Verification / Rollback / Risks / Scope) | `SubagentStop` | Validates the returned JSON against the role schema; exit 2 → agent must complete the block. |
| "Done means green" | `Stop` | Runs the repo's canonical check (`task check` → test + lint + typecheck); exit 2 with failing output as `additionalContext`. Iteration counter in `.claude/factory/<flow>/attempts`; hard-stops at N (default 5) and surfaces to the user instead of looping forever. |
| Secrets hygiene (herdr `pane_history` lesson) | `PostToolUse` on `Bash` | Redacts known token shapes from tool output before it enters context. |
| Cascading halt | `Notification` (`agent_completed`, `idle_prompt`) + registry | Records flow state on disk; halt is a file write, not a memory. |

**Rule:** a hook may *deny* or *ask*; it never returns `allow` for anything the harness would otherwise prompt on. Permission widening happens only through explicit `permissions.allow` entries the user reviews in this repo.

### D2 — Council stays; hot path gets thin roles

The **12 Synod seats remain** as the conversational and review layer (routing, vetoes, personality — everything ADR-001 defended). The **factory hot path** adds four thin *role* definitions instantiated N times:

| Role (file) | Purpose | Model default | Personality budget |
|---|---|---|---|
| `factory-planner` | Ticket/spec → ordered JSON task list with acceptance checks | strongest available (Fable/Opus tier) | 3-line opener in Steris's voice |
| `factory-implementer` | One task → diff in its own worktree, tests included | mid tier (Sonnet) or non-Anthropic via gateway | 3-line opener in Vin's voice |
| `factory-verifier` | Fresh context; sees only spec + diff; runs checks; adversarial | mid tier, `effort: high` | 3-line opener in Wax's voice |
| `factory-reviewer` | Code review against role schema; advisory | mid tier | 3-line opener in Jasnah's voice |

Personality is preserved as a **fixed ≤3-line opener** per role (the existing "Response Opening" convention) plus Sazed's full voice at the orchestrator layer where the user actually reads. Monologues, coordination prose, and self-check lists move to `charter-details.md` and role schemas. Net: personality where a human reads it, schemas where a hook reads it.

Marsh / Elend / TenSoon / Steris keep their veto seats and are invoked by the factory *as gates*, not as workers.

### D3 — Orchestration is interactive-first; `Workflow` re-enabled

- The **interactive Claude Code session is the orchestrator** — whether launched as bare `claude` in a repo or from the UI. Both read the same `~/.claude/` (deployed from this repo), so the factory is identical in either surface.
- Remove `"Workflow"` from `permissions.deny`. The `factory` skill uses `Workflow` (`pipeline(tasks, implement, verify)`) for fan-out *within* a session, and the `Agent` tool with `isolation: worktree` + `background: true` for long single tasks. `skipWorkflowUsageWarning` returns to `false` so cost is visible.
- `claude -p` / Agent SDK is **not** part of this decision. It is reserved for the machine-initiated tier (Slack command → later spec), which will *invoke the same `factory` skill* headlessly. One skill, two entry points.
- herdr (spec 04) is demoted to an optional viewing surface. Treehouse (spec 03) remains PROPOSED; its benchmark, if run, compares against native `isolation: worktree` — the default.

### D4 — State lives on disk

`.claude/factory/` in the target repo (gitignored) holds: `stage`, `flows/<id>.json` (the spec-05 seven fields, now a file), `approvals/`, `attempts/`. Kelsier *reads and reconciles* the registry; he does not *remember* it. Spec 05's protocol S1–S4 is retained verbatim in meaning; only its storage changes.

### D5 — Model routing: Claude-first, gateway for the rest

Claude Code resolves `model:` per subagent. Non-Anthropic models enter through an OpenAI/Anthropic-compatible gateway (LiteLLM or equivalent) set via `ANTHROPIC_BASE_URL` **scoped to a factory profile**, never globally:

| Option | How | Tradeoff |
|---|---|---|
| **A — Anthropic only** | `model: sonnet/opus/fable` | Simplest; no gateway; hooks and caching behave as documented. Fails the "not Claude-only" constraint. |
| **B — Gateway per role (recommended)** | LiteLLM config maps `model: factory-impl-alt` → vendor model; `factory` skill launches implementers with a `--settings factory-gateway.json` profile | Any vendor for implementers; Claude keeps orchestrator/verifier/veto seats where tool-use fidelity matters most. Adds a local process and a secrets surface (gateway keys) — Marsh reviews the gateway config as a first-class artifact. Prompt caching semantics differ per vendor. |
| **C — Bedrock/Vertex** | `CLAUDE_CODE_USE_BEDROCK=1` etc. | Enterprise credentials, still Claude models; orthogonal to B. Useful for client engagements, not for vendor diversity. |

Decision: **B**, with A as the default profile when the gateway is not running (fail-closed to Anthropic, never fail-open to an unconfigured endpoint).

## Consequences

**What changes**
- Governance becomes verifiable: `task factory:selftest` can prove that an Edit in PLAN stage is blocked, that a secrets-path write without Marsh approval is blocked, and that a red test blocks Stop.
- Unattended fan-out becomes safe enough to run: budgets (`maxTurns`, attempt caps) bound every loop; state survives compaction.
- Token cost per implementer drops (thin role vs. persona) and rises in aggregate (N workers). Cost becomes a visible, per-flow number.
- `claude/commands/` is retired in favour of `claude/skills/`; the council ships as a plugin, unlocking `claude plugin eval` and `/skill-doctor`.

**What stays**
- 12 seats, vetoes, Marsh-first, Elend-before-Vin, the promotion ladder, SDD, the repo-as-source discipline, Sazed's voice, ADR-001's disjoint-trigger rule.
- The user's workflow: open `claude` (CLI or UI), say "take on this ticket," approve the plan, promote, merge the PR.

**New constraints**
- Every hook script lives in `claude/hooks/` and is deployed by `task tools:claude`; none may be installed by a vendor tool (ADR-004).
- No hook returns `permissionDecision: "allow"`.
- Gateway configuration is a Marsh-gated artifact.
- The ≤3-agent ceiling applies to the *council conversation*; the factory hot path is bounded by `parallel()` width and `maxTurns`, recorded per flow.

## What would break at 10x

| Failure | Mitigation in this design |
|---|---|
| Persona overhead × N | D2 thin roles; personas off the hot path |
| Permission prompts stall unattended runs | D1 hooks + reviewed `permissions.allow`; never `bypassPermissions` |
| Flaky tests → infinite green-loop | Stop-hook attempt cap → surface to user |
| Worktree/merge storms | One task per worktree; rebase step before PR; planner keeps tasks small |
| Registry lost on compaction | D4 on-disk state |
| Gateway outage | Fail-closed to Anthropic profile |
| Secrets in tool output | `PostToolUse` redaction; `pane_history` off |

## Deferred / Not Adopted

- **Agent SDK orchestrator service** — not adopted; contradicts "Claude Code is the harness." Revisit only if the Slack tier (later spec) proves `claude -p` insufficient.
- **Linear polling / queue** — not adopted by user decision. Linear MCP stays available to the conversation for *reading* a named ticket.
- **Experimental agent teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) — evaluate after spec 06 lands; `Workflow` covers current needs without an experimental flag.
- **Retiring any Synod seat** — no. ADR-001's council-design rule stands.
- **Treehouse adoption** — unchanged (PROPOSED; benchmark-first per spec 03 status).

## References
- ADR-001 (council design rule), ADR-003 (frontmatter audit — this ADR executes its deferred items), ADR-004 (hook/installer safety posture)
- Specs 03, 04, 05 (superseded in storage, retained in protocol meaning)
- Claude Code docs: hooks, sub-agents, workflows, skills, headless, scheduled-tasks (`code.claude.com/docs/en/`)
