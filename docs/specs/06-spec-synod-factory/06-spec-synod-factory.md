# 06-spec-synod-factory.md

> **Status: PROPOSED — DRAFT for user review.** Implements ADR-005. Defines the `factory` skill, the hook set that makes the promotion ladder a hard gate, four thin factory roles, on-disk flow state, and the model-routing profile. **No Linear integration.** **No `claude -p` requirement for the user.** The machine-initiated entry point (Slack command → skill) is a **later spec (07)** and must reuse this skill unchanged. Nothing in this document authorizes edits.

## Introduction / Overview

The user wants to open Claude Code — bare `claude` in a repo, or the UI — and say *"take on this ticket"* (a pasted Linear ticket body, a ticket ID the conversation can read via the Linear MCP, a spec directory, or a plain sentence), then approve a plan, promote, and receive a PR. Between those two human touches the harness must plan, implement in isolated worktrees (in parallel where the plan allows), verify with real checks, review adversarially, and refuse to declare done while anything is red.

Today the Synod Council can *advise* on all of that; it cannot *manufacture* it, because its controls are prose and its fan-out engine is denied (ADR-005 findings 1–3). This spec closes that gap with the smallest set of new files that makes the existing charter enforceable and executable.

## Problem Statement

1. **No executable unit of work.** "Implement the spec" today means Sazed dispatching vin one task at a time by hand. There is no skill that takes a work order and runs the pipeline.
2. **Soft gates.** A worker that ignores "no edits in PLAN" is not stopped. Unattended fan-out is therefore unsafe.
3. **No isolation by default.** Two implementers in one tree race (spec 05 problem 1).
4. **No budgets.** Nothing bounds turns, attempts, or parallel width; a flaky test could loop indefinitely.
5. **State in context.** Flow registry, approvals, and stage exist only as conversation.
6. **Single-vendor.** No path to run a non-Anthropic model for a role.
7. **Personality tax.** Persona prompts are paid on every worker dispatch.

## Proposed Solution

### S1 — The `factory` skill (`claude/skills/factory/SKILL.md`)

Single skill, user-invoked (`disable-model-invocation: true`), one argument: the work order.

```
/factory <work order>
  work order := ticket ID | pasted ticket text | docs/specs/NN-spec-*/ path | free text
```

Phases (each writes its state to `.claude/factory/flows/<flow-id>.json` before proceeding):

| Phase | Actor | Output | Gate to next |
|---|---|---|---|
| **0 Intake** | Sazed (session) | `flow.json` created: id, source, branch name, stage=PLAN | Scope confirmation (existing charter rule) |
| **1 Plan** | `factory-planner` (Agent, `plan` permission mode) | `tasks.json`: ordered tasks, each with files-touched, acceptance command, risk tags (`security`, `schema`, `structure`) | User approves plan → Sazed writes `stage=NARROW` (or `WIDE`) |
| **2 Gates** | Marsh / Elend / TenSoon **only if** a task carries the matching risk tag | `approvals/<seat>-<flow>.json` | Veto → halt, surface to user |
| **3 Implement** | `factory-implementer` × N via `Workflow.pipeline` (parallel where `tasks.json` marks no file overlap), each `isolation: worktree`, `maxTurns` from tasks.json | Per-task diff + tests in its worktree | `SubagentStop` schema check |
| **4 Verify** | `factory-verifier`, fresh context, sees spec + diff only | `verify.json`: checks run, pass/fail, adversarial findings | Red → back to 3 (attempt counter); cap → surface |
| **5 Review** | `factory-reviewer` (+ `synod-jasnah` if user asks) | Review findings, advisory | — |
| **6 Deliver** | Sazed | Worktrees merged to flow branch, rebased, PR opened with plan + verify report; `flow.json` stage=DONE | Human merges |

The skill is the *only* place phase logic lives. Sazed's `CLAUDE.md` gains one line: *"Work orders route to the `factory` skill."*

**Entry points (this spec):** interactive session — CLI or UI, identical behaviour.
**Entry point (spec 07, later):** `claude -p "/factory <order>"` from a Slack skill. Must require zero changes here; that is a design constraint on S1, not a feature of it.

### S2 — Hooks (`claude/hooks/*.sh`, wired in `claude/settings.json`)

| Hook | Matcher | Script | Behaviour |
|---|---|---|---|
| `PreToolUse` | `Edit\|Write\|MultiEdit\|NotebookEdit` | `stage-gate.sh` | Read `.claude/factory/stage`; if `PLAN`/`PROBE` → exit 2, `additionalContext: "Stage is PLAN. Ask the user to promote."` Missing file ⇒ treat as PLAN (fail closed). |
| `PreToolUse` | `Edit\|Write` | `marsh-gate.sh` | If target path matches the security glob list and no `approvals/marsh-<flow>.json` → exit 2. |
| `PreToolUse` | `Bash` | `bash-guard.sh` | Deny `git push --force`, `rm -rf` outside worktree, `git checkout main` from a flow worktree. Never returns `allow`. |
| `PostToolUse` | `Bash` | `redact.sh` | Regex-redact token shapes (AKIA…, ghp_…, sk-…, JWTs) from output. |
| `SubagentStop` | `factory-*` | `schema-check.sh` | Validate final message against `claude/schemas/<role>.json` (jq). Exit 2 on miss. |
| `Stop` | (session) | `green-gate.sh` | If a flow is active and stage ≥ NARROW: run `task check` (fallback: detected `npm test`/`go test`/`pytest`). Red → exit 2 with tail of output; increment `attempts/<flow>`; at cap (default 5) → exit 0 with `additionalContext: "Attempt cap reached — surface to user."` |
| `SessionStart` | — | `factory-status.sh` | Print live flows from `flows/*.json` so a resumed session (CLI or UI) sees the registry immediately. |

Rules: scripts are POSIX sh + `jq`; each has a `--selftest`; none writes outside `.claude/factory/`; none emits `permissionDecision: allow`.

### S3 — Thin roles (`claude/agents/factory-*.md`)

Four files. Frontmatter carries the control; body is ≤40 lines.

```yaml
# factory-implementer.md
---
name: factory-implementer
description: Factory hot-path coder. Dispatched only by the factory skill with one task from tasks.json. Never routed conversationally.
model: sonnet          # overridden per flow by the gateway profile (S5)
effort: medium
maxTurns: 40
isolation: worktree
skills: [agent-browser]
disallowedTools: [Agent, Workflow]   # workers do not spawn workers
hooks:
  SubagentStop: [claude/hooks/schema-check.sh implementer]
---
🌙 **[ FACTORY — Implementer ]** *pewter, not prose*
<≤3 lines of Vin's voice>
## Contract
Input: one task object. Output: JSON per claude/schemas/implementer.json
(files_changed, tests_added, verification_cmd, rollback, risks, confidence).
## Rules
- Smallest viable change. Touch only files listed in the task.
- Tests are part of the task, not after it.
- Risk tag appears mid-task → stop, emit {"halt": "<tag>"}, do not proceed.
```

`factory-planner` (strong model, `plan` mode, Steris voice), `factory-verifier` (`effort: high`, sees only spec+diff, Wax voice), `factory-reviewer` (Jasnah voice) follow the same shape. Output schemas live in `claude/schemas/`.

**The 12 Synod seats are unchanged** except: vin/steris/wax/jasnah each gain one line — *"When the factory skill is active, your hot-path counterpart is `factory-<role>`; you are invoked for conversation and vetoes."*

### S4 — On-disk state (`.claude/factory/` in the target repo)

```
.claude/factory/
  stage                      # PLAN | PROBE | NARROW | WIDE
  flows/<flow-id>.json       # spec-05 seven fields + source, created_at, tasks_path
  <flow-id>/tasks.json
  <flow-id>/verify.json
  approvals/<seat>-<flow-id>.json
  attempts/<flow-id>
```

Gitignored via a `SessionStart` check that appends `.claude/factory/` to `.gitignore` if absent (the one write allowed before promotion, because it is not source). Kelsier's concurrent-flow mediation (spec 05 S2–S4) reads these files; the protocol text in `charter-details.md` changes only its storage sentence.

### S5 — Model routing profile (`claude/factory-gateway.settings.json`)

- Default: no gateway; `model:` values resolve to Anthropic.
- Opt-in per flow: `/factory --impl-model <alias>` → skill launches implementers with `--settings claude/factory-gateway.settings.json`, which sets `ANTHROPIC_BASE_URL` to the local gateway and maps aliases. Orchestrator, planner, verifier, and veto seats stay on Anthropic unless the user says otherwise.
- Gateway config is a **Marsh-gated artifact**: any change to it triggers `marsh-gate.sh`.
- Fail-closed: gateway unreachable → skill aborts the flow at Phase 3 and surfaces; it never silently falls back to a different model than the user chose.

### S6 — Retirements and re-enablements

- `claude/settings.json`: remove `"Workflow"` from `permissions.deny`; set `skipWorkflowUsageWarning: false`; add `hooks` block.
- `claude/commands/run-evals.md` → `claude/skills/run-evals/SKILL.md`; `summary.md` likewise.
- Package `claude/` as plugin `synod` (`.claude-plugin/plugin.json`) so `claude plugin eval` and `/skill-doctor` apply. Deployment via `task tools:claude` is unchanged; the plugin manifest is additive.
- ADR-003 Part A executed: `effort: high` on steris and vendell; `skills: [agent-browser]` on vin.

## Goals

- G1 One command from either surface (CLI or UI) runs intake → PR.
- G2 An Edit in PLAN stage is **blocked by the harness**, provably (`task factory:selftest`).
- G3 A secrets-path write without Marsh approval is blocked by the harness.
- G4 A red `task check` blocks Stop; the loop is bounded by an attempt cap.
- G5 Two tasks with disjoint files run in parallel in separate worktrees with no race.
- G6 Flow state survives `/compact` and session resume on both surfaces.
- G7 An implementer can run on a non-Anthropic model via the gateway profile with no other change.
- G8 Sazed's voice and the Synod seats are intact; worker prompts are ≤40 lines.

## Non-Goals

- Linear polling, webhooks, or any queue. (User decision.)
- Slack entry point, `claude -p` wrappers, Agent SDK services. (Spec 07.)
- Retiring Synod seats, changing the ≤3-agent conversational ceiling.
- Treehouse adoption (spec 03 unchanged). herdr becomes optional viewing only.
- Experimental agent teams.

## Adoption Requirements

| AR | Requirement |
|---|---|
| AR1 | Hook scripts have `--selftest`; `task factory:selftest` runs all and is green before `task tools:claude` deploys them. |
| AR2 | No hook returns `permissionDecision: allow` (grep-enforced in selftest). |
| AR3 | Every factory role has a JSON schema and `maxTurns`. |
| AR4 | `flow.json` is written before any agent is dispatched in a phase. |
| AR5 | Gateway profile change requires Marsh approval file. |
| AR6 | The `factory` skill accepts a work order from `$ARGUMENTS` only — no interactive prompt inside the skill — so spec 07 can drive it headlessly. |
| AR7 | Behaviour is identical from bare `claude` and from the UI (same `~/.claude/`, same hooks); selftest runs once per surface during validation. |

## Risks

| Risk | Mitigation |
|---|---|
| R1 Hook denies a legitimate write (false positive) | `additionalContext` always names the file/stage; user can promote or add an approval; selftest covers allow-paths too. |
| R2 `Stop` hook slows every session end | Only fires when a flow is active and stage ≥ NARROW. |
| R3 Parallel implementers produce conflicting diffs | Planner marks file overlap; overlapping tasks are serialized; rebase step before PR. |
| R4 Gateway leaks keys | Config in `~/.config/` not repo; Marsh gate; redact hook. |
| R5 Personality regression complaints | Openers retained; Sazed layer untouched; validation includes a "voice check" by steris. |
| R6 `Workflow` cost surprises | Warning re-enabled; per-flow token total written to `flow.json` at DONE. |

## Open Questions (user decision required before SDD-2)

- **OQ1** Attempt cap default — 5? 3?
- **OQ2** Security glob list for `marsh-gate.sh` — start from `**/auth/**, *.env*, **/secrets/**, *.tf, .github/workflows/**, *lock*`?
- **OQ3** Gateway — LiteLLM, or something already in use at Liatrio?
- **OQ4** Does WIDE stage lift the "touch only listed files" rule for implementers, or does the planner re-plan?
- **OQ5** Plugin name: `synod`?

## Relationship to other records

- Implements ADR-005. Executes ADR-003 Part A. Inherits ADR-004's hook/installer posture.
- Supersedes spec 05's *storage* (registry → disk); retains its protocol.
- Demotes spec 04 (herdr) to optional. Leaves spec 03 PROPOSED.
- **Spec 07 (later):** Slack command → skill → `claude -p "/factory …"`; develops a ticket conversationally in Slack. Depends on AR6/AR7 here.
