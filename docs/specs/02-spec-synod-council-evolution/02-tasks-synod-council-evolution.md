# Tasks — Synod Council Evolution

> Generated from `02-spec-synod-council-evolution.md`. Parent tasks + sub-tasks (Phase 3 complete).

## Task-slicing note

Parent tasks are sliced by **file ownership**, not by the spec's four conceptual units, to honor the resolved decision *"edit each agent file once."* The spec's Unit 1 (descriptions) and Unit 2 (bodies) both touch every agent file; merging them into a single per-file sweep prevents double-editing. Charter work (Task 1.0) is isolated because it touches only `CLAUDE.md` + `charter-details.md`. `synod-jasnah` is created (Task 2.0) *before* the existing-agent groups so the others' bidirectional Coordination maps can reference her without a second pass. The 11 existing agents are split into **three role-coherent groups** (Tasks 3.0–5.0) so each is small, demoable, and compaction-friendly. Evals (Task 6.0) land last, against the final 12-agent roster.

**Source of truth:** the repo (`claude/CLAUDE.md`); `~/.claude/CLAUDE.md` is a synced copy propagated via the dotfiles workflow (`task tools:claude`).

## Distribution facts (discovered, binding on implementation)

The `tools:claude` task in `Taskfile.yml` currently syncs **only**: `CLAUDE.md`, `settings.json`, `agents/` (rsync `--delete-after`), and `scheduled/`. This has three consequences the sub-tasks address explicitly:

1. **`charter-details.md` is not distributed** until a sync line is added to `tools:claude` (Task 1.0).
2. **`/run-evals` has no home or sync.** Installed slash commands live in `~/.claude/commands/` (the `/SDD-*` pattern). The command is authored at `claude/commands/run-evals.md` and a `commands/` sync line is added to `tools:claude` (Task 6.0).
3. **`agents/eval/*.md` rides the existing `agents/` rsync** into `~/.claude/agents/eval/`. Task 6.0 includes a verification sub-task to confirm these reference files are not loaded by Claude Code as agents (no stray frontmatter that the harness would register).

## Execution cadence (binding on SDD-3)

The repo owner has set these working-rhythm requirements for implementation:

1. **Report after every parent task** completes — state what changed and the proof artifact produced.
2. **Report after every agent group** (Tasks 3.0, 4.0, 5.0) completes — summarize the group.
3. **Prompt the user to `/compact` after each completed task/group** before continuing, to keep context (the "copperminds") functional. Do not silently roll into the next task.

## Relevant Files

- `claude/CLAUDE.md` — the 361-line charter; rewritten into the lean always-loaded core (Task 1.0).
- `claude/charter-details.md` — **new**; on-demand detail (conflict matrix, boundaries, cascading-halt, promotion-stage detail, governance rules, alias map) (Task 1.0).
- `Taskfile.yml` — `tools:claude` task; gains sync lines for `charter-details.md` (Task 1.0) and `commands/` (Task 6.0).
- `claude/agents/synod-jasnah.md` — **new** reviewer agent, Jasnah Kholin persona, opus, review-only (Task 2.0).
- `claude/agents/synod-kelsier.md` — router; description rewrite + body sections + ported keyword→agent decision table (Task 3.0).
- `claude/agents/synod-elend.md` — architect; review-only, `Not in scope:` line (Task 3.0).
- `claude/agents/synod-marsh.md` — security; review-only, `Not in scope:` line, Marsh-first preserved (Task 3.0).
- `claude/agents/synod-tensoon.md` — database; review-only, `Not in scope:` line (Task 3.0).
- `claude/agents/synod-vendell.md` — dependency/API currency; Context7 coordination (Task 3.0).
- `claude/agents/synod-vin.md` — coder; Context7 + browser/e2e folds (Task 4.0).
- `claude/agents/synod-melaan.md` — dev-experience/Docker (Task 4.0).
- `claude/agents/synod-marasi.md` — CI/CD & delivery (Task 4.0).
- `claude/agents/synod-wax.md` — debugger; SEV/IC/post-mortem incident folds (Task 5.0).
- `claude/agents/synod-wayne.md` — UX/UI & accessibility (Task 5.0).
- `claude/agents/synod-steris.md` — docs & planning; docs-accuracy veto preserved (Task 5.0).
- `claude/agents/eval/synod-<agent>.md` — **new** (×12); 4–5 routing/behavior scenarios each (Task 6.0).
- `claude/agents/eval/failures.md` — **new**; structured failure log (Task 6.0).
- `claude/agents/eval/results.md` — **new**; append-only run log (Task 6.0).
- `claude/commands/run-evals.md` — **new** `/run-evals` slash command, subagent-judged, `--changed`, record-and-continue (Task 6.0).

### Notes

- These are markdown-configuration and prose changes; there is no compiler. The eval harness (Task 6.0) is the only automated verification of routing — which is why proof artifacts for Tasks 1.0–5.0 lean on **diffs** and **fresh-session routing transcripts**.
- All new prose (especially `synod-jasnah`) must match the Sazed/Mistborn voice — a hard design constraint from the spec.
- **Security control:** Marsh-first ordering and the Plan-Mode/promotion gates must remain in the lean core (Task 1.0), never externalized to `charter-details.md`. Treat their loss as a regression/blocker.
- After any charter or agent edit, reconcile the repo (source of truth) to the active global copy by running `task tools:claude` — verify with a fresh-session routing transcript before reporting the task done.

## Tasks

### [x] 1.0 Charter restructure — auto-routing, escape hatch, lean-core/details split, governance, alias map

Rewrite `claude/CLAUDE.md` into a lean always-loaded core and externalize detail into a new `claude/charter-details.md`. This delivers the conservative auto-dispatch routing model, the reversible escape hatch, the governance rules, the documentation-only alias map, and a roles table reflecting the 12-agent roster. Preserves Plan-Mode default, the 3-agent ceiling, Marsh-first security ordering, and solo trivial-task handling. (Spec Unit 1 charter portion + Unit 3 charter portion.)

> **Security review (synod-marsh, CONDITIONAL approval, HIGH confidence):** the partition must not sever a control's *trigger* (in core) from its *constraint* (externalized). Four binding conditions, encoded into the sub-tasks below: (1) **promotion-stage permission scope** — stage names + per-stage permission ceiling + who-may-write — stays in LEAN CORE; only verbose rationale/examples move to detail; (2) **cascading-halt operative rule** (the suspension behavior) stays in LEAN CORE as 1–2 imperative sentences; only the narrative moves; (3) Marsh-first must remain an **imperative directive**, not merely a roles-table cell; (4) the roles table keeps its **Write** and **Veto** columns in core.

#### 1.0 Proof Artifact(s)

- Diff: `claude/CLAUDE.md` shows the Prime Directive + Routing rewritten to **conservative auto-dispatch** (multi-discipline OR high-blast-radius), plus a clearly-marked reversible **escape-hatch** block documenting the dial-*up* — demonstrates the routing model changed and is leaner.
- File: `claude/charter-details.md` exists containing the full conflict-resolution matrix, Elend/TenSoon boundary, cascading-halt protocol, SDD agent-responsibility detail, promotion-stage detail, governance rules, and the documentation-only synod↔descriptive alias map — demonstrates load-bearing detail is externalized on-demand.
- Transcript: a fresh session loading **only the lean core** auto-routes a security prompt (`"rotate the auth token"` → Marsh consulted before any implementer) and escalates a vague-perf prompt — demonstrates no routing/escalation drift after the split.
- Diff: the at-a-glance roles table lists all 12 agents including `synod-jasnah` (reviewer) — demonstrates the roster is reflected in the always-loaded core.
- Diff: `Taskfile.yml` `tools:claude` installs `charter-details.md` to `$dest/` — demonstrates the new detail file is distributed.

#### 1.0 Tasks

- [x] 1.1 Inventory the current 361-line `CLAUDE.md`; tag each section as **lean core** (Sazed persona, Copperminds/Context tracking, Prime Directive, at-a-glance roles table *with Write + Veto columns*, auto-routing rules, escalation language, Plan-Mode default + **promotion-stage permission scope** [stage names + per-stage ceiling + who-may-write], output gates, 3-agent ceiling, Marsh-first imperative directive, **cascading-halt operative rule**) vs **detail** (full conflict-resolution matrix, Elend/TenSoon boundary, veto-vs-veto, non-veto conflicts, escalation *chain*, cascading-halt *narrative*, model-allocation rationale, SDD agent-responsibility detail, promotion-stage *rationale/examples*). Per Marsh: a control's trigger and its constraint must live together in core.
- [x] 1.2 Rewrite the **Prime Directive** + **Routing** sections to **conservative auto-dispatch**: auto-dispatch only on **multi-discipline OR high-blast-radius** triggers (prod, auth, secrets, migrations); single-discipline tasks route directly or are handled solo; Kelsier remains the resolver for genuinely ambiguous/multi-discipline tasks (not the only entry path). Preserve the Plan-Mode/no-write default, the 3-agent ceiling, Marsh-first ordering, and solo handling of trivial/conversational tasks.
- [x] 1.3 Add a clearly-marked, reversible **escape-hatch** block documenting the **dial-up** from the conservative default to "auto-route on any single-discipline match," stating the token-cost tradeoff in both directions.
- [x] 1.4 Update the at-a-glance **roles table** to all 12 agents, adding the `synod-jasnah` row (Reviewer / opus / No write / advisory — no veto).
- [x] 1.5 Create `claude/charter-details.md`; move the tagged **detail** sections into it verbatim-where-possible (conflict-resolution matrix, Elend/TenSoon boundary, veto-vs-veto, non-veto conflicts, escalation *chain*, cascading-halt *narrative*, model-allocation rationale, SDD agent-responsibility detail, promotion-stage *rationale/examples*). **Do NOT move** (Marsh, blocking): the promotion-stage permission scope, the cascading-halt operative rule, or the Marsh-first directive — these stay in core. Add a one-line pointer from the lean core to `charter-details.md`.
- [x] 1.6 Add **governance rules** to `charter-details.md`: when-to-add (3+ repeat consults, distinct constraints, stays under the ceiling), when-to-retire (10+ idle sessions, scope absorbed), prefer-extend-over-add, and a pre-merge checklist (name matches filename, description routable, bidirectional coordination links present, eval scenarios exist).
- [x] 1.7 Add the **documentation-only synod↔descriptive alias map** to `charter-details.md` (kelsier=router, vin=coder, elend=architect, marsh=security, melaan=devenv, marasi=pipeline, steris=docs, tensoon=database, wax=debugger, wayne=ux, vendell=dependency/api-currency, jasnah=reviewer). State explicitly: agents keep `synod-*` names only; no functional aliasing.
- [x] 1.8 Audit the lean core against Marsh's four conditions — confirm no load-bearing **security/safety** behavior was externalized: (a) Marsh-first as an imperative directive; (b) Plan-Mode default; (c) the PLAN/PROBE/IMPLEMENT-NARROW/IMPLEMENT-WIDE **permission scope** (per-stage ceiling + who-may-write), not just the stage names; (d) escalation language; (e) the 3-agent ceiling; (f) the **cascading-halt operative rule**; (g) the roles table's Write + Veto columns — all must remain in `CLAUDE.md`.
- [x] 1.9 Add a sync line to `Taskfile.yml` `tools:claude` (and its `DRY_RUN` branch) installing `charter-details.md` to `$dest/charter-details.md`, mirroring the existing `CLAUDE.md` `install -m 0644` line.
- [x] 1.10 Run `task tools:claude` (or `DRY_RUN=true` first) to propagate the lean core + `charter-details.md` to `~/.claude/`, reconciling the synced copy with the repo source of truth.
- [x] 1.11 Fresh-session verification: with only the lean core loaded, confirm `"rotate the auth token"` routes to Marsh before any implementer and a vague-perf prompt escalates — capture the transcript as the proof artifact. **Report + prompt `/compact`.**

### [x] 2.0 Author `synod-jasnah` — the reviewer agent

Create the new `claude/agents/synod-jasnah.md` reviewer agent (Jasnah Kholin persona): opus tier, routable PR/diff/code-quality-review `description`, full self-verifying body (Core Function / Coordination / Self-Check / Confidence / Output with `Not in scope:` line), bidirectional Coordination linking to Elend (architecture), Marsh (security), and Vin (implementation). **Advisory authority, not veto.** Created before Tasks 3.0–5.0 so existing agents can reference Jasnah in their Coordination maps in a single pass. (Spec Unit 3 roster growth.)

#### 2.0 Proof Artifact(s)

- File: `claude/agents/synod-jasnah.md` exists with `name: synod-jasnah`, `model: opus`, `effort: high`, `disallowedTools: [Edit, Write]`, a keyword-rich routable `description`, and a body containing Coordination (bidirectional to Elend/Marsh/Vin), Self-Check, Confidence levels, and a `Not in scope:` output line — demonstrates the reviewer agent is added per the locked decisions.
- Transcript: a PR/diff-review prompt (`"review this diff for code quality before merge"`) auto-routes to `synod-jasnah` with no manual mention — demonstrates the description is routable.
- Self-Check transcript: Jasnah invoked on a sample diff returns review output that passes its own Self-Check and emits a Confidence level, and renders an **advisory** verdict (no veto/block language) — demonstrates self-verification and advisory-only authority.

#### 2.0 Tasks

- [x] 2.1 Create `claude/agents/synod-jasnah.md` frontmatter: `name: synod-jasnah`, `model: opus`, `effort: high`, `disallowedTools: [Edit, Write]`, a distinct unused `color`, and a keyword-rich `description` (PR review, diff review, code quality, readability, maintainability, pre-merge review, code smells, style/consistency) — explicitly distinct from Elend's architecture and Marsh's security. *(Note: all 8 standard agent colors are in use; `purple` chosen deliberately as the opus review-only tier color shared by Elend/TenSoon — also Jasnah's canonical Elsecaller violet. Rationale in proof.)*
- [x] 2.2 Write the **Jasnah Kholin** persona body (exacting, evidence-first, renders firm verdicts without apology) in the Sazed/Mistborn voice; address the user as **Mistborn**/**Seeker**; include the required response-opening identity block used by the other agents.
- [x] 2.3 Add a **Core Function** section scoping Jasnah to code-quality / PR / diff review (correctness-at-the-line, readability, maintainability, test adequacy, consistency) — handing architecture to Elend and security to Marsh.
- [x] 2.4 Add a **bidirectional Coordination** map: Jasnah → Elend (escalate architectural concerns), → Marsh (escalate security concerns), → Vin (hand off fixes); and document which agents route review work *to* her.
- [x] 2.5 Add **Self-Check**, **Confidence levels** (HIGH/MEDIUM/LOW), and an **Output Format** ending in a `Not in scope:` line. Use **advisory** verdict language only — no veto/block phrasing (consistent with Wax).
- [x] 2.6 Verification: confirm `"review this diff for code quality before merge"` auto-routes to Jasnah, and that an invocation on a sample diff passes her Self-Check, emits a Confidence level, and renders an advisory (non-blocking) verdict. **Report + prompt `/compact`.**

### [x] 3.0 Standardize agent Group A — Router & review-only agents (kelsier, elend, marsh, tensoon, vendell)

Single combined per-file pass over the five non-writing agents. Rewrite each `description` into dense proactive-delegation triggers (Spec Unit 1) and add standardized body sections — bidirectional Coordination, Self-Check, Confidence levels — plus the `Not in scope:` output line for the review agents (elend, marsh, tensoon). Port Nate's keyword→agent decision table into `synod-kelsier`. Preserve each agent's opus/sonnet tier, `disallowedTools: [Edit, Write]`, color, and veto status. (Spec Unit 1 + Unit 2, this group.)

#### 3.0 Proof Artifact(s)

- Diff: `synod-kelsier`, `synod-elend`, `synod-marsh`, `synod-tensoon`, `synod-vendell` each show new keyword-rich `description` + Coordination + Self-Check + Confidence sections — demonstrates Group A standardization.
- Diff: `synod-kelsier.md` contains the ported keyword→agent routing decision table (incl. `synod-jasnah`) — demonstrates the routing hub is upgraded.
- Diff: `synod-marsh`, `synod-elend`, `synod-tensoon` include a `Not in scope:` line in their output format — demonstrates the review-agent format upgrade.
- Transcript: a security prompt routes to Marsh first; an ambiguous multi-discipline prompt routes through Kelsier — demonstrates Group A auto-routing.

#### 3.0 Tasks

- [x] 3.1 **synod-kelsier** (single pass): rewrite `description` into proactive routing/orchestration triggers (multi-discipline, ambiguous, high-blast-radius, "which agent"); add bidirectional **Coordination**, **Self-Check**, **Confidence**; **port the keyword→agent decision table** into the body and add the `synod-jasnah` row. Preserve sonnet, `disallowedTools`, color, no-veto.
- [x] 3.2 **synod-elend** (single pass): rewrite `description` (architecture, system design, module boundaries, data-model structure); add Coordination (↔ Vin before implementation, ↔ TenSoon boundary, ↔ Jasnah), Self-Check, Confidence, and a `Not in scope:` output line. Preserve opus/`effort: high`/`disallowedTools`/architecture veto.
- [x] 3.3 **synod-marsh** (single pass): rewrite `description` (keep dense auth/secrets/CVE keywords); add Coordination (↔ Jasnah, ↔ implementers — consulted first), Self-Check, Confidence; confirm/add the `Not in scope:` line in the existing Output Format. **Preserve Marsh-first ordering language and the security veto.**
- [x] 3.4 **synod-tensoon** (single pass): rewrite `description` (database, schema, migrations, queries, indexes, data integrity); add Coordination (↔ Elend boundary, ↔ Vin), Self-Check, Confidence, `Not in scope:` line. Preserve opus/`effort: high`/`disallowedTools`/data-safety veto.
- [x] 3.5 **synod-vendell** (single pass): rewrite `description` (dependency updates, version pinning, deprecation, "is this API current", Context7); add Coordination (↔ Vin for API verification before first proposal), Self-Check, Confidence. Preserve sonnet/`disallowedTools`/no-veto.
- [x] 3.6 Group A verification: produce the diffs above and a routing transcript (security→Marsh-first; ambiguous multi-discipline→Kelsier). **Report the group + prompt `/compact`.**

### [x] 4.0 Standardize agent Group B — Build & delivery implementers (vin, melaan, marasi)

Single combined per-file pass over the three build/delivery implementers. Rewrite each `description` into proactive triggers and add Coordination / Self-Check / Confidence sections. Apply the folds in the same pass: browser/e2e testing scope **and** Context7 doc-lookup into `synod-vin`. Preserve write-enabled status, models, and colors. (Spec Unit 1 + Unit 2 + the Vin folds, this group.)

#### 4.0 Proof Artifact(s)

- Diff: `synod-vin`, `synod-melaan`, `synod-marasi` each show new keyword-rich `description` + Coordination + Self-Check + Confidence sections — demonstrates Group B standardization.
- Diff: `synod-vin.md` includes browser/e2e testing scope **and** Context7 doc-lookup ("verify library APIs before first proposal") — demonstrates the folds are applied.
- Transcript: `"CI is failing on main"` → Marasi alone; `"add a CLI flag with validation"` → Vin; `"the devcontainer won't build"` → MeLaan — demonstrates Group B auto-routing.

#### 4.0 Tasks

- [x] 4.1 **synod-vin** (single pass): rewrite `description` (implementation, feature dev, tests, CLI flags, safe refactors, browser/e2e); add Coordination (↔ Elend before structural work, ↔ Marsh when security in scope, ↔ Jasnah for review, ↔ Vendell/Context7 for APIs), Self-Check, Confidence. **Fold in** Context7 doc-lookup ("verify library APIs before the first proposal") **and** browser/e2e testing scope (pairs with the `agent-browser` skill). Preserve sonnet/write-enabled/color.
- [x] 4.2 **synod-melaan** (single pass): rewrite `description` (Dockerfile, Docker Compose, devcontainers, local setup, onboarding, Makefile/Taskfile, "works on my machine"); add Coordination, Self-Check, Confidence. Preserve sonnet/write-enabled/color.
- [x] 4.3 **synod-marasi** (single pass): rewrite `description` (CI/CD, GitHub Actions, pipelines, deploys, releases, build caching, delivery); add Coordination, Self-Check, Confidence. Preserve sonnet/write-enabled/color.
- [x] 4.4 Group B verification: produce the diffs above (incl. Vin's two folds) and a routing transcript (CI→Marasi, CLI-flag→Vin, devcontainer→MeLaan). **Report the group + prompt `/compact`.**

### [ ] 5.0 Standardize agent Group C — Ops & experience implementers (wax, wayne, steris)

Single combined per-file pass over the three ops/experience implementers. Rewrite each `description` into proactive triggers and add Coordination / Self-Check / Confidence sections. Apply the fold in the same pass: incident-response formats (SEV / Incident Commander / post-mortem) into `synod-wax`. Preserve write-enabled status, models, and colors. (Spec Unit 1 + Unit 2 + the Wax fold, this group.)

#### 5.0 Proof Artifact(s)

- Diff: `synod-wax`, `synod-wayne`, `synod-steris` each show new keyword-rich `description` + Coordination + Self-Check + Confidence sections — demonstrates Group C standardization.
- Diff: `synod-wax.md` includes SEV / Incident Commander / post-mortem output formats — demonstrates the incident-response fold is applied.
- Transcript: `"prod is down, 500s everywhere"` → Wax (incident mode); `"this UI flow is confusing"` → Wayne; `"write the README section"` → Steris — demonstrates Group C auto-routing.

#### 5.0 Tasks

- [ ] 5.1 **synod-wax** (single pass): rewrite `description` (bugs, errors, crashes, stack traces, incidents, outages, regressions, root-cause, log analysis, performance); add Coordination (↔ Marsh for security incidents, ↔ TenSoon for data incidents, ↔ Vin for fixes), Self-Check, Confidence. **Fold in** incident-response output formats: SEV levels, Incident Commander role, post-mortem template. Preserve sonnet/write-enabled/color/no-veto (Wax reports, does not block).
- [ ] 5.2 **synod-wayne** (single pass): rewrite `description` (UI, UX, layout, components, accessibility, user flows, wireframes, frontend review, "is this confusing"); add Coordination, Self-Check, Confidence. Preserve sonnet/write-enabled/color.
- [ ] 5.3 **synod-steris** (single pass): rewrite `description` (README, docs, ADRs, PR descriptions, changelogs, "explain this", planning, checklists); add Coordination, Self-Check, Confidence. **Preserve the documentation-accuracy veto** and its existing output structure.
- [ ] 5.4 Group C verification: produce the diffs above (incl. Wax's incident formats) and a routing transcript (prod-down→Wax, confusing-UI→Wayne, README→Steris). **Report the group + prompt `/compact`.**

### [ ] 6.0 Eval harness + `/run-evals` skill

Create the markdown eval harness and the runner command. Per agent (all 12), author `claude/agents/eval/synod-<agent>.md` with 4–5 scenarios (Input / Expected route / Expected behavior / Red flags), seeded by porting Nate's scenarios via the alias map where an equivalent exists. Add `eval/failures.md` and append-only `eval/results.md`. Add a `/run-evals` command (`claude/commands/run-evals.md`) that spawns one judging subagent per scenario (reports would-be route, judges behavior against Expected + Red flags, self-judges pass/fail), supports a `--changed` flag, operates **record-and-continue** (a failure does not halt the run), logs failures to `failures.md`, appends results to `results.md`, and emits an end-of-run pass/fail/total tally. Add the `commands/` sync to the Taskfile. (Spec Unit 4.)

#### 6.0 Proof Artifact(s)

- Files: `claude/agents/eval/synod-*.md` (one per agent, 4–5 scenarios each), `eval/failures.md`, and `eval/results.md` exist — demonstrates the harness is in place.
- File: `claude/commands/run-evals.md` exists and is invocable as `/run-evals` — demonstrates the runner exists.
- Diff: `Taskfile.yml` `tools:claude` syncs `commands/` to `~/.claude/commands/` — demonstrates the command is distributed.
- CLI/transcript: `/run-evals --changed` after editing a single agent runs only that agent's scenarios, appends a structured row per scenario to `results.md`, logs any failure to `failures.md`, and prints a passed/failed/total summary tally — demonstrates scoped, automated, record-and-continue evaluation.

#### 6.0 Tasks

- [ ] 6.1 Create `claude/agents/eval/`. For each of the 12 agents, author `eval/synod-<agent>.md` with **4–5 scenarios**, each containing **Input**, **Expected route**, **Expected behavior**, and **Red flags**. Seed by porting Nate's eval scenarios via the alias map where an equivalent exists. Use **synthetic inputs only** — no real credentials, tokens, or private repo contents.
- [ ] 6.2 Ensure coverage of the load-bearing controls: at least one **security-ordering** scenario (auth/secret → Marsh consulted before any implementer) and explicit, falsifiable **Red flags** per scenario so the judging subagent has concrete failure criteria.
- [ ] 6.3 Create `claude/agents/eval/failures.md` (structured failure-log template: scenario, expected, observed, timestamp-placeholder) and `claude/agents/eval/results.md` (append-only run-log header + row schema).
- [ ] 6.4 Author `claude/commands/run-evals.md` mirroring the `/SDD-*` command format: for each scenario, **spawn one judging subagent** that reads the Input, reports which agent *would* route, judges behavior against Expected + Red flags, and self-judges pass/fail; append a structured row to `results.md`; log failures to `failures.md`; support `--changed` (only scenarios for agents whose files changed); operate **record-and-continue**; emit an end-of-run **passed/failed/total** tally.
- [ ] 6.5 Add a `commands/` sync to `Taskfile.yml` `tools:claude` (and its `DRY_RUN` branch) installing `claude/commands/` to `~/.claude/commands/`. Then **verify** the eval reference files do not get loaded as agents: confirm `agents/eval/*.md` (which ride the existing `agents/` rsync into `~/.claude/agents/eval/`) carry no agent-registering frontmatter, or relocate/guard them if the harness picks them up.
- [ ] 6.6 Run `task tools:claude` to distribute, then run `/run-evals --changed` after editing one agent: confirm it runs only that agent's scenarios, appends rows to `results.md`, logs any failure to `failures.md`, and prints the tally — capture as the proof artifact. **Report the task + prompt `/compact`.**
