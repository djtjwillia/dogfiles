# 02-spec-synod-council-evolution.md

## Introduction/Overview

The **Synod Council** is an 11-agent, Mistborn-themed subagent system distributed via this dotfiles repo as loose files (`claude/CLAUDE.md` holding the Sazed persona + charter, and `claude/agents/synod-*.md` holding the agents). Today the council is **manually consulted** ("if uncertain, consult synod-kelsier first"), the agents are tone-heavy prose without self-verification, the single ~360-line charter loads on every message, and there is no way to measure whether routing actually works.

This spec evolves the council to the structural maturity of Nate Priddy's `plugins/council` — **automatic discipline-based routing, self-verifying agent bodies, a lean always-loaded charter, governance rules, and a measurable eval harness** — **without** adopting plugin packaging and **without** losing the Sazed persona or `synod-*` theming. The primary goal is to make Sazed *auto-dispatch* the correct council member(s) the moment a task touches their discipline, with a documented, reversible token-cost dial.

## Goals

- **Automatic routing:** representative prompts auto-select the correct agent(s) with no manual `@`-mention, while preserving Plan-Mode default, the 3-agent ceiling, Marsh-first security ordering, and solo handling of trivial tasks.
- **Self-verifying agents:** every `synod-*.md` gains a bidirectional Coordination map, a Self-Check, Confidence levels, and (for review agents) a `Not in scope:` line.
- **Lean charter:** split `claude/CLAUDE.md` into an always-loaded core + an on-demand `charter-details.md` without losing load-bearing routing behavior.
- **Governance + roster growth:** add when-to-add/retire/extend rules and a pre-merge checklist; add `synod-jasnah` (reviewer) and fold incident-response + browser-e2e scope into existing agents.
- **Measurability:** a markdown eval harness (`eval/synod-<agent>.md`, `failures.md`, `results.md`) plus a `/run-evals` skill that subagent-judges routing/behavior and appends results.

## User Stories

- **As the repo owner**, I want Sazed to automatically dispatch the right council member when a task clearly touches a discipline (auth → Marsh, CI failure → Marasi), so that I stop having to manually name agents.
- **As the repo owner**, I want a documented dial to widen or narrow auto-routing aggressiveness, so that I can trade token cost against responsiveness without rewriting the charter.
- **As a council agent**, I want a bidirectional handoff map and a self-check, so that I hand work to the correct neighbor and never return malformed or out-of-scope output.
- **As the repo owner**, I want the always-loaded charter to be lean, so that routine messages cost fewer tokens while the full conflict-resolution detail is still retrievable on demand.
- **As the repo owner**, I want a recurring PR/diff-review discipline (`synod-jasnah`) distinct from architecture (Elend) and security (Marsh), so that code-quality review is a routable agent and not only a skill.
- **As the repo owner**, I want to run a routing/behavior eval suite and see pass/fail results recorded, so that I can prove the council routes correctly and catch regressions when I edit an agent.

## Demoable Units of Work

### Unit 1: Automatic discipline-based routing + reversible escape hatch

**Purpose:** Convert the council from manually-consulted to automatically-routed. This is the primary ask. Serves the repo owner directly.

**Functional Requirements:**
- The system shall rewrite every agent `description` frontmatter (all existing agents plus `synod-jasnah`) into dense, keyword-rich, proactive-delegation triggers so the harness auto-selects the agent when a task matches its discipline.
- The system shall rewrite the charter's **Prime Directive** and **Routing** sections so Sazed automatically dispatches the matching council member(s) when a task clearly touches a discipline, removing the "if uncertain, consult kelsier first" hedge as the *only* entry path (Kelsier remains the resolver for genuinely ambiguous or multi-discipline tasks).
- The system shall preserve, in the rewritten charter: Plan-Mode / no-write default, the 3-agent ceiling, security-first ordering (Marsh consulted before any implementer), and solo handling of trivial/conversational tasks.
- The system shall ship the **conservative** routing posture as the default: auto-dispatch only on **multi-discipline OR high-blast-radius** triggers (prod, auth, secrets, migrations); single-discipline tasks route directly or are handled solo.
- The system shall document a clearly-marked, reversible **escape-hatch** charter block describing the **dial-up** from the conservative default to "auto-route on any single-discipline match," stating the token-cost tradeoff in both directions.
- The system shall port Nate's keyword→agent decision table into Kelsier's body and mirror its triggers across each agent `description`.

**Proof Artifacts:**
- Diff: `claude/CLAUDE.md` Prime Directive + Routing sections show auto-dispatch language and the escape-hatch block demonstrates the routing model changed.
- Diff: each `claude/agents/synod-*.md` frontmatter `description` shows keyword-rich proactive triggers demonstrates harness auto-selection is enabled.
- Transcript/manual demo: representative prompts (`"rotate the auth token"` → Marsh first; `"CI is failing on main"` → Marasi alone; `"make it faster"` → escalation; `"fix this typo"` → solo) route correctly with no manual mention, demonstrates conservative auto-routing works. (Formalized as automated scenarios in Unit 4.)

### Unit 2: Agent body standardization (self-verifying agents)

**Purpose:** Upgrade every agent body from tone-heavy prose to a self-verifying structure, adapting Nate's tight sections into the themed voice. Serves every downstream consumer of agent output.

**Functional Requirements:**
- The system shall add a **Coordination** section to each `synod-*.md` containing a *bidirectional* handoff map: who this agent hands work to **and** which agents hand work to it.
- The system shall add a **Self-Check** section to each agent instructing it to verify its own output format and scope before returning.
- The system shall add **Confidence levels** (`HIGH` / `MEDIUM` / `LOW`) to each agent's output format where a judgment is rendered.
- The system shall add a **`Not in scope:`** line to the output format of the review agents (Marsh, Elend, TenSoon, and the new Jasnah).
- The system shall fold **Context7 doc-lookup** into `synod-vin` (in addition to Vendell), instructing Vin to verify library APIs before its first proposal.
- The system shall preserve each agent's existing persona, model, `disallowedTools`, color, and veto status — only adding/structuring body sections.

**Proof Artifacts:**
- Diff: each `synod-*.md` shows new Coordination / Self-Check / Confidence sections demonstrates standardization applied.
- Diff: `synod-vin.md` references Context7 doc-lookup demonstrates the coder verifies APIs first.
- Transcript: one representative agent invoked on a sample prompt returns output that passes its own Self-Check and emits a Confidence level demonstrates the self-verification works end-to-end.

### Unit 3: Charter split + alias map + governance + roster growth

**Purpose:** Reduce always-loaded token cost, formalize how the roster grows/shrinks, and grow the roster per the brief's verdicts. Serves the repo owner (cost + maintainability).

**Functional Requirements:**
- The system shall split `claude/CLAUDE.md` into: (a) a **lean always-loaded core** (persona, Copperminds/Context tracking, Prime Directive, at-a-glance roles table, auto-routing rules, escalation language) and (b) an on-demand **`charter-details.md`** (full conflict-resolution matrix, Elend/TenSoon boundary, cascading-halt protocol, SDD agent-responsibility detail, promotion-stage detail).
- The system shall verify the lean core alone still produces correct auto-routing and escalation (no load-bearing behavior left only in `charter-details.md`).
- The system shall add the **synod↔descriptive alias map** to `charter-details.md` as a **documentation-only** reference table (kelsier=router, vin=coder, elend=architect, marsh=security, melaan=devenv, marasi=pipeline, steris=docs, tensoon=database, wax=debugger, wayne=ux, vendell=dependency/api-currency, jasnah=reviewer). Agents keep their `synod-*` names only; no functional aliasing.
- The system shall add **governance rules** to the charter: when-to-add (3+ repeat consults, distinct constraints, stays under the ceiling), when-to-retire (10+ idle sessions, scope absorbed), prefer-extend-over-add, and a pre-merge checklist (name matches filename, description routable, bidirectional coordination links present, eval scenarios exist).
- The system shall add a new agent **`synod-jasnah`** (descriptive alias `reviewer`): full self-verifying body, routable description for PR/diff/code-quality review, bidirectional Coordination linking to Elend (architecture), Marsh (security), and Vin (implementation). Jasnah holds **advisory authority, not veto** (consistent with Wax). Jasnah's model tier is **opus** (parity with the other review-only agents).
- The system shall **fold incident-response formats** (SEV levels, Incident Commander, post-mortem) into `synod-wax` rather than adding an incident-responder agent.
- The system shall **fold browser/e2e testing** scope into `synod-vin` (note in body + Coordination map, pairing with the `agent-browser` skill) rather than adding `synod-e2e`.
- The system shall **not** add sre, performance, chaos, mcp-builder, compliance, threat-detection, or test-engineer agents (scope folded: performance→Wax, compliance→Marsh, test-strategy→Vin, MCP→Vin/Vendell).

**Proof Artifacts:**
- Diff: `claude/CLAUDE.md` shrinks to the lean core + new `claude/charter-details.md` exists demonstrates the split.
- Fresh-session transcript: a session loading only the lean core still auto-routes (auth→Marsh) and escalates correctly demonstrates no behavior drift.
- File: `claude/agents/synod-jasnah.md` exists with routable description + bidirectional Coordination demonstrates the reviewer agent is added.
- Diff: `synod-wax.md` shows SEV/IC/post-mortem formats and `synod-vin.md` shows e2e scope demonstrates folds applied.
- Section: governance rules + alias map present in charter/charter-details demonstrates governance is documented.

### Unit 4: Eval harness + `/run-evals` skill

**Purpose:** Make routing and agent behavior measurable and regression-testable. Serves the repo owner (proof + safety net when editing agents).

**Functional Requirements:**
- The system shall create `claude/agents/eval/synod-<agent>.md` for each agent (4–5 scenarios each), every scenario containing: **Input**, **Expected route**, **Expected behavior**, **Red flags**. Scenarios shall be seeded by porting Nate's eval scenarios via the alias map where an equivalent exists.
- The system shall create `claude/agents/eval/failures.md` (structured failure log) and `claude/agents/eval/results.md` (append-only run log).
- The system shall add a **`/run-evals` skill** that, for each scenario, **spawns a judging subagent** which reads the scenario Input, reports which agent *would* be routed to, evaluates the actual/intended behavior against Expected, self-judges pass/fail, and appends a structured result row to `eval/results.md`.
- The `/run-evals` skill shall accept a `--changed` flag that runs evals only for agents whose files changed (the default recommended workflow, given full-suite token cost).
- The `/run-evals` skill shall record failures to `eval/failures.md` with enough context (scenario, expected, observed) to act on.
- The `/run-evals` skill shall operate **record-and-continue**: a failed scenario does not halt the run; the skill records the failure and proceeds, then emits a summary tally (passed/failed/total) at the end.

**Proof Artifacts:**
- Files: `eval/synod-*.md`, `eval/failures.md`, `eval/results.md` exist demonstrates the harness is in place.
- Skill file exists and is invocable as `/run-evals` demonstrates the runner exists.
- CLI/transcript: `/run-evals --changed` after editing one agent runs only that agent's scenarios and appends rows to `results.md` demonstrates scoped, automated, recorded evaluation.

## Non-Goals (Out of Scope)

1. **Plugin / marketplace packaging**: the council stays loose-file/dotfiles-distributed. A Claude Code plugin cannot ship a `CLAUDE.md`, which would split the always-loaded Sazed persona from the agents. Deferred (personal use).
2. **Renaming existing agents or removing the Sazed persona**: theming is preserved; only `synod-jasnah` is added.
3. **Functional aliasing**: the descriptive alias map is documentation-only; descriptive names are not invocable agent references.
4. **Restructuring Obsidian memory / session summaries**: `obsidian-summary` already exists and is a separate concern.
5. **Adding agents beyond `synod-jasnah`**: sre/performance/chaos/mcp-builder/compliance/threat-detection/test-engineer/e2e/incident-responder are explicitly folded, not added.

## Design Considerations

No GUI. This is a CLI/markdown-configuration change. The "interface" is agent frontmatter, charter prose, and skill markdown. The Sazed voice and Mistborn metaphors are a hard design constraint — all new prose (including `synod-jasnah`) must match the existing tone. `synod-jasnah` draws its persona from Jasnah Kholin (Stormlight Archive): exacting, evidence-first, renders firm verdicts without apology — a deliberate, acknowledged cross-world naming choice the user requested.

## Repository Standards

- **Spec location/format:** this spec lives at `docs/specs/02-spec-synod-council-evolution/02-spec-synod-council-evolution.md`; follow the structure of `docs/specs/01-spec-ansible-to-task-migration/`.
- **Agent file convention:** lowercase `synod-<name>.md` in `claude/agents/`; YAML frontmatter with `name` (must match filename), `description`, `model`, optional `disallowedTools`, `color`, `effort`. Body sections in themed prose.
- **Model allocation (enforced via frontmatter):** opus + `effort: high` for review-only agents (Elend, Marsh, TenSoon — and decide Jasnah's tier in implementation); sonnet for implementation/coordination agents.
- **Write-restriction enforcement:** review-only agents carry `disallowedTools: [Edit, Write]`.
- **Distribution:** files install to `~/.claude/` via the dotfiles workflow; both `claude/CLAUDE.md` (repo) and `~/.claude/CLAUDE.md` (global) carry the charter and should stay reconciled.
- **Commit conventions:** follow existing repo conventions (conventional-commit style prefixes observed in history).

## Technical Considerations

- **Routing is prompt-driven, not compiled.** Auto-selection depends entirely on the quality of `description` frontmatter keywords + charter directives. There is no type-checker; the eval harness (Unit 4) is the only verification mechanism — which is why Unit 4 is in-scope here rather than deferred.
- **Charter-split drift risk.** Moving conflict-resolution/promotion detail into `charter-details.md` risks the lean core silently dropping load-bearing routing behavior. Unit 3's fresh-session verification is the mitigation; treat any routing regression as a blocker.
- **Two charter homes — repo is source of truth.** `claude/CLAUDE.md` (repo, distributed) is authoritative; `~/.claude/CLAUDE.md` (active global) is a synced copy. The split (lean core + `charter-details.md`) is authored in the repo and propagated to `~/.claude/` via the dotfiles workflow.
- **Eval token cost.** A full `/run-evals` over ~12 agents × 4–5 scenarios, each spawning a judging subagent, is expensive. `--changed` is the default workflow; full runs are deliberate.
- **Subagent self-judging reliability.** A subagent judging routing may be optimistic. Scenarios must include explicit **Red flags** so the judge has falsifiable failure criteria, not just "looks right."
- **Dependency ordering across units:** Unit 1 (descriptions) and Unit 2 (bodies) both edit every agent file. **Decision:** each agent file is edited **once** — its `description` rewrite (Unit 1) and body standardization (Unit 2) are applied in a single combined pass per file to avoid churn. Unit 3 adds Jasnah, who receives the same combined treatment at creation. Unit 4 evals reference the final agent set, so it lands last.

## Security Considerations

- **No secrets or credentials** are introduced by this change; it is configuration/prose only. No API keys, tokens, or sensitive data in agent files, charter, evals, or results logs.
- **Marsh-first ordering is a security control** and must survive the charter rewrite (Unit 1) and the charter split (Unit 3) — security review is consulted before any implementer on in-scope tasks. Treat its loss as a security regression.
- **Eval artifacts must not capture secrets:** `eval/results.md` and `failures.md` record routing decisions and behavior verdicts, not live credentials or private repo contents. Scenarios must use synthetic inputs.
- **Promotion gates preserved:** the Plan-Mode default and explicit-promotion-to-write model (PLAN/PROBE/IMPLEMENT) are a guardrail against unintended edits and must be retained in the lean core, not externalized to `charter-details.md`.

## Success Metrics

1. **Routing accuracy:** ≥ 90% of eval scenarios route to the expected agent(s) on a full `/run-evals`.
2. **Security ordering:** 100% of security-touching scenarios consult Marsh before any implementer (zero tolerance — any miss is a blocker).
3. **Charter leanness:** the always-loaded core is materially smaller than the current ~360 lines (target: roughly halved) with **zero** routing/escalation regressions in the fresh-session test.
4. **Agent standardization:** 100% of `synod-*.md` files contain Coordination + Self-Check sections and pass their own Self-Check on a representative prompt.
5. **Measurability:** `/run-evals --changed` produces an appended, structured `results.md` row for every scenario it runs, with failures logged to `failures.md`.

## Open Questions

No open questions remain. The five forks raised during spec review were resolved by the repo owner on 2026-06-12 and folded into the requirements above:

1. **Jasnah's authority** → **advisory, not veto** (consistent with Wax). "For now no veto."
2. **Jasnah's model tier** → **opus** (parity with other review-only agents).
3. **Charter source-of-truth** → **the repo (`claude/CLAUDE.md`) is authoritative**; `~/.claude/CLAUDE.md` is a synced copy.
4. **Unit 1/Unit 2 sequencing** → **edit each agent file once** (combined description + body pass).
5. **`/run-evals` stringency** → **record-and-continue** with an end-of-run summary tally.
