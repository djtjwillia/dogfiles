# Synod Council — Gap Analysis vs. Reference Council

**Date:** 2026-06-18
**Author:** synod-steris (Docs & Planning)
**Confidence:** MEDIUM — the comparison is complete and verified against both sources, but the reference agents were read via a structured digest (one subagent pass), not line-by-line in full. Frontmatter and domain claims are quoted from that digest; deep behavioral nuance in a few reference files may be under-sampled. Flagged inline where it matters.

---

## Executive Summary

Our local council (`./claude/agents/synod-*.md`, 12 agents) was compared against the reference council at `liatrio/dotfiles-nate-priddy` → `plugins/council/agents/` (20 agents).

> **Scope note (accuracy):** The task framing cited a *public* GitHub URL. The actual repo is **private/internal** (`visibility: internal`) and was reachable only via authenticated `gh api`. The reference directory contains exactly **20** files (the task said "22" — a miscount, confirmed against the directory listing).

The two councils share a common ancestor in design: identical escalation language (`"This requires your decision. Reason: [one sentence]."`), per-agent emoji response markers, Self-Check checklists, HIGH/MEDIUM/LOW confidence levels, fenced output-format templates, and a router-driven 1–3-agent dispatch model. The differences are **decomposition and coverage**, not philosophy.

**The headline findings:**

1. **The reference council splits domains we merge.** It runs three debugging/ops agents where we run one (`synod-wax`); three test agents where we fold everything into `synod-vin`; and three security/compliance/detection agents where we run one (`synod-marsh`).
2. **Seven reference domains have no local equivalent at all:** chaos engineering, pre-prod performance, compliance/audit, MCP-server building, detection engineering, dedicated incident command, and test strategy.
3. **Our agents are materially richer per-file** (7–10 KB vs. their 2–6 KB), with deeper coordination sections, dual/triple output templates, and explicit veto-notification protocols. **This is our strength and should not be sacrificed to chase coverage.**
4. **One frontmatter field is worth adopting** (`memory: project`) and **one tooling convention is worth evaluating** (finer-grained `disallowedTools` including `Bash`/`NotebookEdit`).

Recommendation: treat coverage gaps as **deliberate scope decisions**, not defects. Adopt selectively (see Refinement Recommendations). Do not import their naming scheme or their leaner prose — our depth is the point of this council.

---

## Role Map (local ↔ reference)

| Local agent | Reference equivalent(s) | Relationship |
|---|---|---|
| `synod-kelsier` (routing) | `router.md` | 1:1 |
| `synod-vin` (impl + tests + e2e) | `coder.md` + `test-engineer.md` + `e2e.md` | **1:3** — we merge; they split |
| `synod-elend` (architecture) | `architect.md` | 1:1 |
| `synod-marsh` (security) | `security.md` + (program) `compliance.md` + (detection) `threat-detection.md` | **1:3** — we merge |
| `synod-melaan` (dev experience) | `devenv.md` | 1:1 |
| `synod-marasi` (CI/CD) | `pipeline.md` | 1:1 |
| `synod-steris` (docs + planning) | `docs.md` | 1:1 |
| `synod-tensoon` (database) | `database.md` | 1:1 |
| `synod-wax` (debug + incident) | `debugger.md` + `incident-responder.md` + (reliability) `sre.md` | **1:3** — we merge |
| `synod-wayne` (UX/UI/a11y) | `ux.md` | 1:1 |
| `synod-vendell` (dependency currency) | *(no equivalent)* | **local-only** |
| `synod-jasnah` (code review) | `reviewer.md` | 1:1 |
| *(no equivalent)* | `chaos.md` | **reference-only** |
| *(no equivalent)* | `performance.md` | **reference-only** |
| *(no equivalent)* | `mcp-builder.md` | **reference-only** |

---

## Gap Analysis — Missing Agents & Capabilities

These are domains the reference council covers that ours does not. Ordered by how clearly the gap maps to plausible work in this repo and its ecosystem.

### A. Net-new domains with NO local home

| # | Reference agent | Domain | Why it might matter here | Severity |
|---|---|---|---|---|
| G1 | `mcp-builder.md` | Building MCP servers — tool/resource/prompt schemas, Zod/Pydantic validation, transports | This environment is MCP-heavy (Slack, Granola, Context7, etc.). If we ever *author* an MCP server, no agent owns it. `synod-vin` would default to it without specialized guidance. | **Medium** |
| G2 | `performance.md` | Pre-production performance — k6 load tests, perf budgets (p50/p95/p99), CI perf gates | No agent owns load testing or performance budgets. `synod-marasi` (CI) and `synod-wax` (incident perf-degradation) touch the edges but neither owns *pre-prod capacity validation*. | **Medium** |
| G3 | `compliance.md` | Compliance program — SOC2/ISO 27001/HIPAA/PCI-DSS gap assessment, control mapping, audit readiness | Distinct from security. `synod-marsh` does threat/hardening, not framework control-mapping or evidence strategy. A real gap if this org pursues certification. | **Low–Medium** (context-dependent) |
| G4 | `chaos.md` | Chaos engineering — fault injection, blast-radius, resilience experiments | No resilience-validation owner. Adjacent to `synod-wax` but Wax investigates *actual* failures; chaos *induces controlled* ones. | **Low** |
| G5 | `threat-detection.md` | Detection engineering — Sigma rules, MITRE ATT&CK mapping, SIEM, detection CI/CD | SOC/detection-as-code. Furthest from a dotfiles/skills repo's likely work. | **Low** |

### B. Domains we MERGE that they SPLIT (capability dilution risk)

These are not missing — but our merged agents carry several specialist mandates each, and may under-serve the deeper end of any one of them.

- **`synod-wax` carries three reference roles** — `debugger` (RCA), `incident-responder` (live incident command, IC/Comms/Scribe roles, P0–P3 matrix), and `sre` (SLOs, error budgets, runbooks, toil). Our Wax *does* cover debugging + incident command well (it has dedicated INCIDENT and POST-MORTEM templates). **The genuine gap is the SRE/reliability-contract layer**: SLO/SLI definition, error-budget accounting, runbook-as-deliverable, and proactive reliability review. Wax is reactive ("a bug is a crime scene"); nothing in our council owns *proactive* reliability.
- **`synod-vin` carries three reference roles** — `coder`, `test-engineer` (test *strategy*: pyramid design, mocking boundaries, testability review), and `e2e` (Playwright planning/healing with named Scout/Inscribe/Mend modes). Vin authors tests well but there is **no owner of test *strategy* as a reviewable discipline** — coverage-gap-by-behavior, mocking-boundary review, testability assessment before code is written.
- **`synod-marsh` carries three reference roles** — `security`, `compliance` (G3 above), and `threat-detection` (G5 above). The pure-security overlap is strong; the program/detection layers are the gaps already listed.

### C. Capability gaps within shared roles

- **`devenv.md` explicitly owns `chezmoi`/dotfiles materialization** ("Destructive previews: diff/preview before any `chezmoi apply`"). **This repo is a dotfiles repo.** Our `synod-melaan` covers Docker/Compose/devcontainers/Make/Taskfile but **does not mention chezmoi or the destructive-preview discipline** — a concrete, repo-relevant gap. *(See Refinement R-MeLaan.)*
- **`ux.md` owns i18n/l10n** (RTL, locale formatting, pluralization, string externalization). Our `synod-wayne` does not mention internationalization.
- **`reviewer.md` has a `## Skills to Use` section** referencing `/review`, `/caveman-review`, `simplify`, `superpowers:*`. Our `synod-jasnah` references no skills — yet this environment exposes a `code-review` skill and a `simplify` skill that Jasnah could be wired to invoke.

---

## Refinement Recommendations (per existing agent)

Each is scoped to a single file, additive, and reversible. None require renaming or restructuring the council.

### R-Wax — add a reliability/SRE dimension *(highest-value refinement)*
`synod-wax.md` is purely reactive. Add an **SRE/reliability lens** so the council can answer "are we *prone* to this incident?" before it happens:
- New responsibility: SLO/SLI/error-budget review; runbook authorship as a first-class deliverable.
- New output template: `RELIABILITY REVIEW` with an `Error budget status: HEALTHY / BURNING / EXHAUSTED / UNKNOWN` line (borrowed from `sre.md`).
- Alternative (cleaner, more work): split a new `synod-*` reliability agent. **Tradeoff:** a new agent raises the council from 12→13 and competes for the 3-agent routing ceiling. Folding into Wax keeps the count but stretches an already-broad agent. *This is an architecture decision — route to `synod-elend` before acting.*

### R-Vin — add a test-strategy reviewer hook
`synod-vin.md` authors tests but does not *review test strategy*. Either:
- Add a Self-Check line: "Did I assess the test *pyramid* — am I testing at the right layer, mocking at boundaries not internals?" (borrow `test-engineer.md`'s "mock at the boundary, not inside it"), **or**
- Note in Coordination that test-*strategy* questions (testability, coverage-by-behavior) are a distinct review Vin can request — candidate future agent. Low-effort version: the Self-Check line only.

### R-MeLaan — add chezmoi / dotfiles + destructive-preview *(most repo-relevant)*
`synod-melaan.md` should explicitly cover **chezmoi/dotfiles materialization** given this *is* a dotfiles repo, and adopt `devenv.md`'s **destructive-preview discipline**:
- Add to Core Function: "chezmoi/dotfiles materialization and drift capture (`chezmoi re-add`)."
- Add to Operating Principles: "**Preview before apply.** Diff/preview any `chezmoi apply` (or `terraform apply`, `ansible-playbook`) before running it. Never apply blind."
- This is a genuine accuracy gap: an agent owning local DX in a dotfiles repo that does not mention the repo's primary materialization tool.

### R-Wayne — add internationalization to accessibility scope
`synod-wayne.md` treats accessibility as baseline but omits i18n/l10n. Add to Core Function and Self-Check: RTL layouts, locale-aware formatting, pluralization, string externalization. One line in each.

### R-Jasnah — wire to available review skills
`synod-jasnah.md` should reference the skills this harness exposes. Add a short `## Skills to Use` note: the `code-review` skill for diff inspection and `simplify` for reuse/efficiency cleanups. Mirrors `reviewer.md`'s `## Skills to Use` section. Keeps Jasnah advisory — the skills inform the verdict; they do not grant a write mandate.

### R-Marsh — note compliance & detection as out-of-scope, with a named owner
`synod-marsh.md`'s `Not in scope` line should explicitly disclaim **compliance-program work** (control mapping, audit evidence) and **detection engineering** (Sigma/MITRE/SIEM) — stating that if those arise, they are currently *unowned* and require user decision on whether to add an agent. This makes the gap visible rather than silently absorbed into a security review. *(Steris accuracy note: an agent that silently absorbs out-of-scope work misrepresents what was reviewed — exactly the kind of drift my veto exists to prevent.)*

### R-Steris (self) — already aligned
`synod-steris.md` maps cleanly to `docs.md` and is the *richer* of the two (dual IMPLEMENTATION-PLAN / DOCUMENTATION-REVIEW templates, explicit SDD-4 veto, risk register with pre-written mitigations). No capability gap. The only reference idea not present locally: `docs.md` runs on `model: haiku` (cost optimization for a high-volume agent) — we run Steris on `opus`. **That is a deliberate, defensible choice** (planning coherence and accuracy veto warrant the stronger model); recorded here only so the divergence is on the record, not papered over.

### No refinement needed
`synod-kelsier` (↔ router), `synod-elend` (↔ architect), `synod-marasi` (↔ pipeline), `synod-tensoon` (↔ database) map cleanly and are at parity or richer. `synod-vendell` is **local-only and a genuine strength** (see below) — keep as-is.

---

## Strengths — What We Do That They Don't

1. **`synod-vendell` has no reference equivalent.** A dedicated dependency/API-currency reviewer that verifies references against Context7 *before* and *after* implementation is a capability the reference council folds informally into `coder`/`debugger`. Making it a first-class review-only agent is a real advantage — stale references are a silent, recurring failure class, and we have a standing guard against it.
2. **Deeper coordination model.** Our agents carry explicit bidirectional Coordination sections ("the work flows both ways"), a formal **Veto Notification Protocol** routed through Kelsier, a **Cascading Halt** safety control, and named veto-vs-veto handling. The reference set has coordination notes but no comparable orchestration protocol surfaced in the digest.
3. **Richer output templates.** `synod-wax` ships *three* templates (INVESTIGATION / INCIDENT / POST-MORTEM); `synod-steris` ships two; `synod-jasnah` and `synod-marsh` carry explicit `Not in scope` lines that force honest boundary-naming. Reference agents largely carry one template each.
4. **Explicit SDD-workflow integration.** Our council is wired into the SDD stage commands (`/SDD-1` … `/SDD-4`) with Steris holding an SDD-4 reconciliation veto. The reference `docs.md` references SDD but the council-wide integration is ours.
5. **Per-agent persona depth.** Each agent's voice is distinct and load-bearing (Marsh's "assume breach," TenSoon's "a schema is a contract," Jasnah's "a judgment without evidence is an opinion wearing a robe"). This is not decoration — it makes each agent's *operating discipline* memorable and self-enforcing. The reference set is comparatively terse.

---

## Structural / Frontmatter Conventions Worth Adopting

| Convention | Reference usage | Our usage | Recommendation |
|---|---|---|---|
| **`memory: project`** | On 8 ops/detection agents (chaos, compliance, incident-responder, mcp-builder, performance, sre, test-engineer, threat-detection) | **Absent** | **Evaluate adopting** for agents that benefit from cross-session project memory — strongest candidate is `synod-wax` (incident history) and `synod-tensoon` (migration history). Verify the field is supported by our harness before adding. *(MEDIUM confidence — I did not confirm `memory: project` is honored by this Claude Code version; verify before writing it into any agent.)* |
| **Finer-grained `disallowedTools`** | Comma-separated string incl. `Bash`, `NotebookEdit` granularity; two tiers (full lockdown vs. Bash-allowed for read-only investigation) | We use a YAML list `[Edit, Write]` only | **Consider** adding `NotebookEdit` to review-only agents' `disallowedTools` for completeness (it is an edit-class tool). Note: our format is a YAML list; theirs is a string — **keep our list format** (cleaner, equivalent). Do *not* blanket-block `Bash` on review agents — several of ours legitimately run read-only inspection. |
| **`color` field** | **Absent** in reference | Present on all our agents | **Keep ours.** Harmless, aids UX in agent pickers. No action. |
| **`effort` field** | **Absent** in reference (they tune via `model` choice) | Present on several (`effort: high/medium/low`) | **Keep ours** if the harness honors it; it is a finer dial than model choice alone. |
| **Emoji response marker** | Present; router *stacks* emojis to show dispatch chain | Present (single marker per agent) | **Consider** adopting Kelsier emoji-stacking to visualize multi-agent routing chains. Cosmetic but improves traceability. |
| **`## Skills to Use` section** | On `reviewer.md` | Absent | Adopt for `synod-jasnah` (see R-Jasnah) and consider for `synod-vin` (`code-review`, `simplify`, `verify`). |
| **Named operating modes** | `e2e.md` defines Scout / Inscribe / Mend modes, each with its own template | Absent | **Consider** if e2e testing becomes a first-class need; for now `synod-vin` covers it adequately. |

---

## Recommended Next Steps (prioritized, with go/no-go)

1. **R-MeLaan (chezmoi + destructive-preview)** — highest repo-relevance, lowest risk, additive. **Go.**
2. **R-Jasnah (wire to review skills)** and **R-Wayne (i18n)** — small additive edits. **Go.**
3. **R-Marsh (disclaim compliance/detection scope)** — one `Not in scope` line; makes a silent gap visible. **Go.**
4. **R-Wax (SRE/reliability lens)** — higher value but touches council structure (fold-vs-split decision). **Route to `synod-elend` first** — this is an architecture call (agent-count ceiling, routing pressure), not a docs edit.
5. **`memory: project` adoption** — **No-go until verified** the field is honored by this harness version. Verification step: check Claude Code agent frontmatter docs or test with one agent before rolling out.
6. **New agents for G1–G5 (mcp-builder, performance, compliance, chaos, threat-detection)** — **No-go without user decision.** Each raises the council size and competes for the 3-agent ceiling. These are scope decisions for the user, not refinements. Surface as: *adopt on demonstrated need*, mcp-builder and performance being the likeliest first additions given this environment.

> **Rollback note:** Every "Go" item above is a single-file additive edit. Reverting any one is a `git checkout` of that one file. No cross-file coupling is introduced by the recommended refinements.

---

## Sources

- **Local:** `/Users/taylor/Code/projects/dogfiles/claude/agents/synod-{kelsier,vin,elend,marsh,melaan,marasi,steris,tensoon,wax,wayne,vendell,jasnah}.md` (12 files, read in full).
- **Reference:** `liatrio/dotfiles-nate-priddy` @ `main` → `plugins/council/agents/` (20 files: architect, chaos, coder, compliance, database, debugger, devenv, docs, e2e, incident-responder, mcp-builder, performance, pipeline, reviewer, router, security, sre, test-engineer, threat-detection, ux). Private/internal repo; fetched via authenticated `gh api`, summarized via structured digest.

---

## Synod-Elend Architectural Review

**Date:** 2026-06-18
**Reviewer:** synod-elend (Architecture & Design)
**Confidence:** HIGH on the structural verdicts (the constraints — a 3-agent routing ceiling, a 12-seat council, the merge-vs-split tradeoff — are fully in view and priced). MEDIUM only on `memory: project`, which depends on a harness capability I cannot verify from here and have routed accordingly.

> **Framing.** The council is not a feature list; it is a *routing surface*. Every agent added is not just a file — it is one more entry the router must disambiguate against, one more boundary that can be crossed, one more seat competing for the 3-agent dispatch ceiling. The reference council's 20 agents are not 8 capabilities we lack; they are a *different decomposition philosophy*. They optimized for fine-grained single responsibility. We optimized for rich, self-enforcing agents with low routing-collision cost. Neither is wrong. But you cannot adopt their decomposition piecemeal without paying their disambiguation tax, and a 12→17 council blows straight through our ceiling. The governing question for every verdict below is therefore not "is this domain real?" — most are — but **"is this gap better closed by a new seat or by a line in an existing charter?"** A new seat is the expensive answer and must justify itself against routing cost, not just domain validity.

---

### The 3-agent ceiling is the binding constraint — read this first

The charter caps dispatch at 3 agents per task. That ceiling interacts with council *size* in a way the gap analysis touches but does not fully price:

- **Adding agents does not relax the ceiling — it raises competition for it.** With 12 agents, the router picks ≤3 from 12. With 17, it picks ≤3 from 17. Every added seat increases the probability that the *right* 3 for a task are not the 3 chosen, because the router must disambiguate across more overlapping descriptions.
- **Split agents share trigger keywords.** A debugger, an incident-responder, and an SRE all match "production is slow." Three seats that collide on the same triggers do not add coverage — they add a *routing coin-flip*. This is the single strongest argument against the splits, and it is structural, not stylistic.
- **Therefore: a split is only justified when the resulting agents have *disjoint* trigger surfaces.** If splitting produces agents that fire on the same words, you have manufactured ambiguity, not specialization.

I apply that test to every split below.

---

### Part 1 — New agents (G1–G5)

| Gap | Agent | Verdict |
|---|---|---|
| G1 | `mcp-builder` | **CONDITIONAL-GO** |
| G2 | `performance` | **CONDITIONAL-GO** |
| G3 | `compliance` | **NO-GO** (for now) |
| G4 | `chaos` | **NO-GO** |
| G5 | `threat-detection` | **NO-GO** |

**G1 — mcp-builder: CONDITIONAL-GO.** This is the strongest of the five and the only one whose trigger surface is genuinely *disjoint* from every existing agent. "Author an MCP server — tool/resource/prompt schemas, transport, Zod/Pydantic validation" collides with nobody: it is a build task with no existing owner, so synod-vin would default to it without specialized discipline. That is a clean boundary. **The condition is demonstrated need:** this environment *consumes* many MCP servers but the repo does not yet *author* one. An agent with no work to route to is pure overhead — a seat that dilutes the router and ages out of date. Approve the *design* now (the boundary is sound); create the file the moment the first MCP-authoring task appears. Until then it is a documented, pre-approved addition, not a live seat.

**G2 — performance: CONDITIONAL-GO.** Pre-prod performance (k6, perf budgets, p50/p95/p99 CI gates) is a real boundary, and the analysis correctly notes it falls *between* marasi (CI) and wax (incident-time degradation) without either owning it. The reason this is CONDITIONAL and not GO: its trigger surface *partially* overlaps both neighbors ("slow," "performance," "load"), so adding it raises the routing-collision risk I flagged above. The mitigating factor is that pre-prod capacity validation is a *proactive, planned* activity, not a reactive one — "establish a perf budget" or "add a load-test gate" is unambiguous and will not be confused with "production is on fire" (wax) or "the build is slow" (marasi). **Condition:** create it only when a load-testing or perf-budget task actually arrives, and when created, write its description to fire on *budgets/load-tests/capacity-planning*, never on bare "performance" — that word must stay routable to wax for incidents. Of the five, G1 and G2 are the likeliest first additions, exactly as Steris predicted.

**G3 — compliance: NO-GO (revisit on a certification mandate).** Compliance-program work (SOC2/ISO/HIPAA control mapping, audit evidence) is genuinely distinct from security — Steris is right that marsh does hardening, not framework control-mapping. But a dedicated compliance *agent* in a personal dotfiles/skills repo is a seat with no plausible work for the foreseeable future, and an idle seat is negative value: it dilutes routing and rots. The correct structural move is **R-Marsh** — make the gap *visible* in marsh's `Not in scope` line with a named "currently unowned, requires user decision" disclaimer. That converts a silent absorption risk into an explicit, deferred decision at zero routing cost. Revisit only if this org commits to a certification.

**G4 — chaos: NO-GO.** Chaos engineering (fault injection, blast-radius experiments) presumes a running distributed system with resilience worth validating. This repo is dotfiles, skills, and agent definitions — there is no production surface to inject faults into. The boundary is real *in general* but has no referent *here*. Adding it would be architecture-as-cargo-cult: importing a seat because the reference has one, not because the work exists. The analysis rated this "Low" severity and I concur — it is the clearest NO-GO of the set.

**G5 — threat-detection: NO-GO.** Detection engineering (Sigma rules, MITRE ATT&CK, SIEM, detection CI/CD) is SOC work for an org with a security-operations function and telemetry to write detections against. It is the furthest of all five from this repo's reality. Same remedy as G3: name it as out-of-scope and unowned in marsh's charter (R-Marsh) so the gap is on the record, and add the seat only if a SOC/detection mandate ever materializes.

---

### Part 2 — The split questions

**synod-wax split (debugger + incident-responder + SRE): CONDITIONAL-GO — and the condition is "split off SRE only, do not split debugger from incident-responder."**

This requires comparing two valid approaches, because the analysis poses it as fold-vs-split and the honest answer is *neither extreme*.

- *Option A — keep wax fully merged, add an SRE lens via R-Wax (a RELIABILITY REVIEW template + error-budget line).* Optimizes for: council size (stays 12), zero new routing collision. Costs: stretches an already-broad agent across reactive *and* proactive reliability, and — more seriously — **mixes two genuinely different operating postures in one persona.** Wax's whole identity is "a bug is a crime scene" — reactive, post-hoc. SRE is proactive: "are we *prone* to this incident before it happens?" These are different *mindsets*, and folding them risks the proactive work never actually getting done because the agent's reflexes are reactive.
- *Option B — split into three: debugger, incident-responder, SRE.* Optimizes for: textbook single responsibility. Costs: **debugger and incident-responder share nearly their entire trigger surface** — "it's broken," "error rate is up," "production is down" route to both. That is exactly the manufactured-ambiguity failure mode. Splitting these two produces a routing coin-flip with no coverage gain, because our wax *already* handles both well (it ships INVESTIGATION, INCIDENT, and POST-MORTEM templates). This is the wrong cut.

The third path, which I prefer: **split off reliability/SRE as its own seat, leave debugger+incident-responder merged in wax.** The cut is justified by the disjoint-trigger test — SRE fires on *proactive, planned* triggers ("define an SLO," "what's our error budget," "write a runbook," "is this prone to failure") that do **not** collide with wax's reactive "it's broken." Debugger and incident-responder fire on the *same* reactive triggers and must stay together. So the principled split is 2-into-2 (wax keeps RCA+incident; new agent takes proactive reliability), not 1-into-3.

**However — this is a CONDITIONAL-GO, and the condition is demonstrated need, identical to G1/G2.** A standalone SRE agent in a repo with no SLOs, no error budgets, and no production reliability contract is another idle seat. So: the *low-cost* version (R-Wax: a reliability lens folded into wax) is approved now as the immediate step, with an explicit note in wax's charter that proactive reliability is a *candidate split* the moment real SLO/error-budget/runbook work appears. When that work arrives, promote it to its own seat using the 2-into-2 cut above — not before. This gives you the discipline now and the clean boundary later, without paying for an empty chair today.

**synod-vin split (coder + test-engineer + e2e): NO-GO on the split. CONDITIONAL-GO on a test-strategy *review hook* (R-Vin).**

- *Why not split test-engineer out:* test *authoring* and code *authoring* are the same act in practice — you write the code and its tests in one motion, against the same files, in the same context. Splitting them forces a context handoff (coder writes, hands to test-engineer who must re-load everything) that adds latency and dropped-context risk for near-zero gain. The trigger surfaces are also heavily overlapping ("implement X" implies "test X"). This is a textbook case where the reference's fine-grained decomposition costs more than it returns *for our merged-agent philosophy*.
- *Why not split e2e out:* e2e/Playwright is a *mode* of testing, not a separate discipline with a disjoint trigger surface. The reference encodes it as named modes (Scout/Inscribe/Mend) *within* an agent — which is itself an argument that it is a mode, not a seat. Our vin pairs with the agent-browser skill and covers it adequately.
- *Where the analysis is right:* there is a genuine gap in test *strategy as a reviewable discipline* — pyramid design, mocking-at-the-boundary, testability assessment *before* code is written. But that is a **review** concern, and review concerns in our council route to advisory reviewers (jasnah) or get encoded as Self-Check discipline — not to a new implementer seat. **CONDITIONAL-GO on R-Vin's low-effort form:** add the test-pyramid/mock-at-the-boundary Self-Check line to vin, and add a one-line note to jasnah's review scope that test *strategy* (right-layer, boundary-mocking) is a reviewable quality dimension. That closes the gap inside existing seats at zero routing cost. The standalone test-strategy agent is a NO-GO until proven otherwise.

**synod-marsh split (security + compliance + threat-detection): NO-GO on the split.**

This is the same answer as G3 and G5 viewed from the other side. The pure-security overlap between our marsh and the reference `security.md` is strong — that role is at parity and needs no change. The compliance and detection layers are the G3/G5 gaps, and I have already ruled those as deferred-until-mandate. Splitting marsh now would create two idle seats (compliance, detection) and strip nothing useful from the one live seat. The correct structural move is **R-Marsh**: marsh's `Not in scope` line explicitly disclaims compliance-program and detection-engineering work and names them as *currently unowned, user-decision-required*. This is the highest-leverage security-architecture change available because it prevents the *silent absorption* failure mode — an agent quietly answering compliance questions it is not equipped for, misrepresenting what was actually reviewed. That is precisely the drift a veto exists to catch, and Steris flagged it correctly.

---

### Part 3 — Frontmatter & convention changes

**`memory: project`: CONDITIONAL-GO — gated on harness verification (route to a harness check, not to me).** The *concept* is architecturally sound for exactly the two agents Steris named: wax (incident/RCA history compounds in value across sessions) and tensoon (migration history is a genuine cross-session asset). Those are the right candidates — both deal in *accumulated state* where prior sessions inform current judgment. But I cannot verify this Claude Code version honors the field, and writing an unsupported frontmatter key is at best inert and at worst a parse risk. **Condition:** verify support against the harness (a claude-code-guide check or a one-agent test) *before* writing it anywhere. This is not an architecture decision once the design intent is settled — it is a capability check. Approved in principle for wax and tensoon only; do not blanket-apply to 8 agents as the reference does.

**Finer-grained `disallowedTools` (add `NotebookEdit`): GO.** This is a pure correctness fix with no structural cost. `NotebookEdit` is an edit-class tool; our six review-only agents (kelsier, elend, marsh, tensoon, vendell, jasnah) carry `disallowedTools: [Edit, Write]` but not `NotebookEdit`, which is a gap in the write-lockdown that the charter's "structural enforcement" clause clearly *intends* to be complete. Adding it closes a hole. **Keep our YAML-list format** — it is equivalent to and cleaner than the reference's comma-string. **Do NOT blanket-block `Bash`** on review agents: several legitimately run read-only inspection (this very review ran `cat`/`gh api`-class commands), and blocking Bash would break their investigation capability. The reference's two-tier Bash handling is more granularity than we need; our model already distinguishes via the promotion ladder.

**`color` / `effort` fields: GO (keep as-is).** No action. Both are harmless local enrichments. The analysis is correct.

**Kelsier emoji-stacking: NO-GO (cosmetic, not architectural — out of my scope to approve, and not worth a structural verdict).** It is a traceability nicety, not a boundary or coupling decision. If desired, it is a trivial kelsier-file edit with no structural implication. I neither approve nor block; it simply is not an architecture question.

**`## Skills to Use` for jasnah (R-Jasnah): GO.** Wiring jasnah to the `code-review` and `simplify` skills sharpens an existing seat without altering its boundary — it stays advisory, the skills inform the verdict and grant no write mandate. No new coupling, no routing change. Clean additive refinement.

---

### Part 4 — The open question: chezmoi/dotfiles in synod-melaan

**Verdict: SCOPE EXTENSION, not a new agent. GO on R-MeLaan.**

I read melaan's charter in full to settle this. Her Core Function already claims *"local environment reproducibility across operating systems and machines"* and *"onboarding experience — from clone to running."* In a dotfiles repo, **chezmoi *is* the clone-to-running path.** The omission is not a missing domain — it is a missing *line* in a charter that already owns the domain. Adding a new agent for chezmoi would be the textbook error of solving a documentation gap with a structural change: it would carve a new seat out of the exact territory melaan already holds, creating an overlap-collision (every "set up my dotfiles" task would fire both) for zero boundary gain. Compare the two paths explicitly:

- *Option A — new chezmoi agent.* Optimizes for: nominal single-responsibility purity. Costs: a 12→13 council, a direct trigger collision with melaan's existing "clone-to-running" mandate, and a seat whose work is a strict subset of an existing seat's. This is coupling masquerading as separation.
- *Option B — extend melaan (R-MeLaan).* Optimizes for: boundary integrity (the agent who owns local materialization owns *the* local materialization tool), council size, and accuracy (closing a real gap where the DX agent in a dotfiles repo doesn't name the repo's primary tool). Costs: melaan's charter grows by two lines. Negligible.

Option B is correct without qualification. The destructive-preview discipline (*"diff/preview before any `chezmoi apply`"*) is doubly right to add — it is a *safety* principle that generalizes to `terraform apply` and `ansible-playbook`, and it belongs in the charter of the agent who runs those commands. This is the single most repo-relevant change in the entire analysis and carries the lowest risk. **GO, unconditionally.**

---

### 10x consideration (what breaks as the council scales)

The failure mode at scale is **not** too few agents — it is *router entropy*. At 12 agents with disjoint-enough triggers, the ≤3 dispatch is tractable. Every split that shares triggers (debugger/incident-responder, coder/test-engineer) degrades routing accuracy faster than it adds coverage, because the router's job is disambiguation and overlapping seats are anti-disambiguation. If this council ever does grow toward 17–20, the binding investment is **not** more agent files — it is a sharper router and a *trigger-keyword disjointness audit* so that added seats fire on distinct words. The discipline to enforce now, before any growth: **no new seat ships without a stated, disjoint trigger surface that does not collide with an existing agent's.** Encode that as a council-design rule and the 10x version stays routable. Skip it and the council becomes a pile of agents the router can no longer tell apart — coverage on paper, coin-flips in practice.

---

### Veto register

I exercise **no hard veto** — none of Steris's recommendations propose an irreversible or structurally damaging change; she correctly deferred the structural calls to me rather than acting. I record two **veto triggers** that would fire if overridden:

1. **Splitting debugger from incident-responder** (the 1-into-3 wax split, or the analogous fine-grained vin split) — I would veto on *manufactured routing ambiguity*: it creates seats with colliding trigger surfaces and no coverage gain. The 2-into-2 wax cut (SRE-only, on demonstrated need) is the approved alternative.
2. **Creating any of G1–G5, the SRE agent, or a test-strategy agent as a *live seat* before its triggering work exists** — I would veto on *idle-seat routing dilution*: an agent with no work to route to is negative value. Pre-approved designs, yes; pre-created files, no.

---

### Approved for implementation — prioritized (impact × safety)

In order. Items 1–4 are immediate, single-file, additive, and individually `git checkout`-revertible. Items 5–6 are gated. Items 7+ are deferred-by-design.

1. **R-MeLaan — chezmoi + destructive-preview into melaan.** Highest repo-relevance, lowest risk, closes a real accuracy gap in the agent who already owns the domain. *(SCOPE EXTENSION — GO)*
2. **R-Marsh — disclaim compliance & detection as out-of-scope/unowned in marsh's `Not in scope`.** Prevents silent absorption of work marsh is not equipped for; converts G3/G5 into explicit deferred decisions at zero routing cost. *(GO)*
3. **`disallowedTools` += `NotebookEdit`** on all six review-only agents (kelsier, elend, marsh, tensoon, vendell, jasnah). Closes a write-lockdown hole; keep YAML-list format; do not touch Bash. *(GO)*
4. **R-Jasnah (wire to `code-review` + `simplify` skills)** and **R-Vin (test-pyramid/mock-at-boundary Self-Check line + a one-line test-strategy note in jasnah's review scope).** Sharpen existing seats, no boundary change. *(GO)*
5. **R-Wax — fold a proactive reliability/SRE lens into wax** (RELIABILITY REVIEW template + error-budget line), with an explicit charter note that proactive reliability is a *candidate split* (2-into-2: wax keeps RCA+incident, new seat takes SRE) to be promoted only when real SLO/error-budget/runbook work appears. *(CONDITIONAL-GO — fold now, split on demonstrated need)*
6. **`memory: project` for wax and tensoon only** — *after* verifying the harness honors the field. *(CONDITIONAL-GO — gated on harness check; route to claude-code-guide or a one-agent test, not to me)*
7. **Pre-approve the *designs* of G1 (mcp-builder) and G2 (performance)** as the two likeliest first additions, to be created as live seats only when an MCP-authoring or load-testing task actually arrives — and only with disjoint trigger surfaces (G2 must fire on "budget/load-test/capacity," never bare "performance"). *(CONDITIONAL-GO — design approved, creation deferred)*
8. **G3 (compliance), G4 (chaos), G5 (threat-detection), the standalone test-strategy agent, and the full 1-into-3 wax/vin/marsh splits** — *(NO-GO until a concrete triggering mandate exists; covered as deferred decisions by item 2 and the R-Wax note.)*

**Council-design rule to adopt alongside the above:** *no new seat ships without a stated, disjoint trigger surface that does not collide with an existing agent's.* This is the structural guardrail that keeps the council routable as it grows.

---

**Not in scope of this review:**
- **Migration safety / persistence** — there is no data layer here; if `memory: project` introduces cross-session state semantics, that boundary is **synod-tensoon's** to assess, not mine.
- **Security adequacy of marsh's actual coverage** — I ruled on marsh's *structural boundaries* (what it owns vs. defers), not on whether its security discipline is sufficient; that is **synod-marsh's** own review.
- **Harness capability verification** for `memory: project`, `effort`, and skill-wiring — these are platform-support questions, not architecture; route to a harness check.
- **Line-level prose quality** of any resulting edits — **synod-jasnah's** boundary.
- **Documentation accuracy of this analysis's reference claims** — **synod-steris** authored and owns that; my MEDIUM-confidence inheritance of her digest-based reference reading is noted.

*A structure that cannot be changed is a structure that will eventually be abandoned. These changes keep the council able to grow — and, just as importantly, keep it from growing into something the router can no longer steer.*
