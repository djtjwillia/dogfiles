# ADR-001: Synod Council Agent Refinements

## Status
Accepted

## Date
2026-06-18

## Context

The Synod Council — our local set of 12 specialized agents (`./claude/agents/synod-*.md`) — had never been benchmarked against an external decomposition. To find blind spots, synod-steris ran a gap analysis comparing our council against a 20-agent reference council (`liatrio/dotfiles-nate-priddy` → `plugins/council/agents/`, fetched via authenticated `gh api`; the repo is private/internal, and the directory contains exactly 20 agents — not the "22" originally cited).

The two councils share a common design ancestry: identical escalation language, per-agent emoji response markers, Self-Check checklists, HIGH/MEDIUM/LOW confidence levels, fenced output templates, and a router-driven 1–3-agent dispatch model. The difference is **decomposition and coverage, not philosophy**. The reference council optimizes for fine-grained single responsibility (it splits domains we merge — three debug/ops agents, three test agents, three security agents — and carries seven domains with no local home). We optimize for richer, self-enforcing agents with low routing-collision cost.

The key tension: **is a given gap better closed by adding a new agent (a "seat") or by adding a line to an existing agent's charter?** This is not a feature question — it is a routing question. The charter caps dispatch at **3 agents per task**, and that ceiling is the binding constraint. Adding agents does not relax the ceiling; it raises competition for it and increases the chance the router picks the wrong 3 from a larger, more overlapping set. synod-elend reviewed every proposed change against a single structural test: **a split (or new seat) is only justified when the resulting agents have disjoint trigger surfaces.** A new seat is the expensive answer and must justify itself against routing cost, not just domain validity.

## Decision

We adopt the four immediate, single-file, additive refinements that synod-elend approved as unconditional GO, in his priority order (impact × safety). Each closes a real gap inside an existing seat at zero routing cost, and each is individually `git checkout`-revertible:

1. **R-MeLaan — chezmoi + destructive-preview into `synod-melaan`.** This is a dotfiles repo, and chezmoi is the clone-to-running path that melaan already claims to own. Add chezmoi/dotfiles materialization (`chezmoi re-add` drift capture) to her Core Function, and add a "preview before apply" operating principle that generalizes to `chezmoi apply`, `terraform apply`, and `ansible-playbook`. Treated as a **scope extension**, not a new agent — adding a chezmoi agent would carve a new seat out of territory melaan already holds.
2. **R-Marsh — disclaim compliance & detection as out-of-scope/unowned in `synod-marsh`.** Add an explicit `Not in scope` line naming compliance-program work (SOC2/ISO/HIPAA control mapping, audit evidence) and detection engineering (Sigma/MITRE/SIEM) as **currently unowned, user-decision-required**. Converts the silent-absorption risk into an explicit deferred decision at zero routing cost.
3. **`disallowedTools` += `NotebookEdit`** on all six review-only agents (kelsier, elend, marsh, tensoon, vendell, jasnah). `NotebookEdit` is an edit-class tool; the existing `[Edit, Write]` lockdown has a hole the charter clearly intends to be complete. Keep our YAML-list format; do **not** block `Bash` (review agents legitimately run read-only inspection).
4. **R-Jasnah + R-Vin — sharpen existing seats, no boundary change.** Wire `synod-jasnah` to the `code-review` and `simplify` skills via a `## Skills to Use` note (stays advisory; skills inform the verdict, grant no write mandate). Add a test-pyramid / mock-at-the-boundary Self-Check line to `synod-vin`, plus a one-line note in jasnah's review scope that test *strategy* (right-layer, boundary-mocking) is a reviewable quality dimension.

Alongside these, we adopt one **council-design rule**: *no new seat ships without a stated, disjoint trigger surface that does not collide with an existing agent's.* This is the structural guardrail that keeps the council routable as it grows.

## Consequences

**What changes:**
- `synod-melaan` becomes accurate for this repo — the DX agent now names the repo's primary materialization tool and carries a generalizable preview-before-apply safety discipline.
- `synod-marsh`'s boundary is honest: compliance and detection are visibly out of scope and unowned, preventing marsh from quietly answering questions it is not equipped for (the exact drift a documentation-accuracy veto exists to catch).
- The write-lockdown on all six review-only agents is complete — `NotebookEdit` can no longer slip past `[Edit, Write]`.
- `synod-jasnah` and `synod-vin` gain sharper review/test-strategy discipline without any change to their boundaries or write mandates.

**What stays the same:**
- The council size remains **12 agents**. No new seats are created.
- The 3-agent routing ceiling is untouched and unpressured by these changes.
- Our richer-per-file agent philosophy, depth, personas, and the deeper coordination/veto/cascading-halt model are all preserved — explicitly *not* sacrificed to chase the reference council's coverage.
- `synod-vendell` (local-only, no reference equivalent) stays as-is — a genuine strength.
- The `color` and `effort` frontmatter fields stay as-is. Kelsier emoji-stacking is neither adopted nor blocked (cosmetic, not architectural).

**New constraints / handoffs introduced:**
- The council-design rule above now gates any future seat addition on a disjoint trigger surface.
- Two CONDITIONAL-GO items (R-Wax reliability lens, `memory: project`) are deferred pending the open questions below; they must **not** be implemented in the same pass as items 1–4.

## Deferred / Not Adopted

**CONDITIONAL-GO — deferred (design approved, action gated):**
- **R-Wax (SRE/reliability lens) — fold now, split later on demonstrated need.** Elend's verdict: fold a proactive reliability lens (RELIABILITY REVIEW template + error-budget line) into wax now, with a charter note that proactive reliability is a *candidate split*. The principled future split is **2-into-2** (wax keeps RCA+incident; a new seat takes SRE) — *not* 1-into-3, because debugger and incident-responder share nearly their entire trigger surface and splitting them manufactures routing ambiguity for no coverage gain. Promote to a standalone seat only when real SLO/error-budget/runbook work appears. Reason: a standalone SRE agent in a repo with no SLOs is an idle seat, and idle seats dilute routing.
- **`memory: project` for wax and tensoon only — gated on harness verification.** Concept is architecturally sound for these two (incident history and migration history compound in value across sessions), but Elend cannot confirm this Claude Code version honors the field. Reason: writing an unsupported frontmatter key is at best inert and at worst a parse risk. Do not blanket-apply to 8 agents as the reference does.
- **Pre-approve the *designs* of G1 (mcp-builder) and G2 (performance)** as the two likeliest first additions — create as live seats only when an MCP-authoring or load-testing task actually arrives, and only with disjoint triggers (G2 must fire on "budget/load-test/capacity," never bare "performance," which must stay routable to wax). Reason: design boundary is sound; an agent with no work to route to is pure overhead.

**NO-GO — not adopted:**
- **G3 — compliance agent.** Reason: a dedicated compliance seat in a personal dotfiles/skills repo has no plausible work; an idle seat is negative value. Remedy is R-Marsh (make the gap visible). Revisit only on a certification mandate.
- **G4 — chaos agent.** Reason: chaos engineering presumes a running distributed system with resilience worth validating; this repo has no production surface to inject faults into. Clearest NO-GO of the set.
- **G5 — threat-detection agent.** Reason: detection engineering is SOC work needing telemetry and a security-operations function. Furthest of all five from this repo's reality. Remedy is R-Marsh.
- **The full 1-into-3 splits of wax, vin, and marsh.** Reason: splitting debugger from incident-responder (and coder from test-engineer) produces seats with colliding trigger surfaces and no coverage gain — manufactured routing ambiguity. This is one of Elend's two named veto triggers.
- **A standalone test-strategy agent.** Reason: test strategy is a *review* concern, routed to advisory reviewers (jasnah) or encoded as Self-Check discipline — not a new implementer seat. Closed inside existing seats by R-Vin/R-Jasnah.

## Implementation Order

Items 1–4 are immediate, single-file, additive, and individually revertible. Items 5–6 are gated on the open questions. Item 7 is deferred-by-design.

- [ ] **1. R-MeLaan** — add chezmoi/dotfiles materialization + destructive-preview discipline to `claude/agents/synod-melaan.md`. *(SCOPE EXTENSION — GO)*
- [ ] **2. R-Marsh** — add `Not in scope` disclaimer for compliance & detection (currently unowned, user-decision-required) to `claude/agents/synod-marsh.md`. *(GO)*
- [ ] **3. `disallowedTools` += `NotebookEdit`** on all six review-only agents (kelsier, elend, marsh, tensoon, vendell, jasnah); keep YAML-list format; do not touch Bash. *(GO)*
- [ ] **4. R-Jasnah + R-Vin** — wire jasnah to `code-review` + `simplify` skills; add test-pyramid/mock-at-boundary Self-Check line to vin + a one-line test-strategy note in jasnah's review scope. *(GO)*
- [ ] **5. R-Wax** — fold a proactive reliability/SRE lens into `synod-wax` (RELIABILITY REVIEW template + error-budget line) with a candidate-split charter note. *(CONDITIONAL-GO — fold now, split on demonstrated need; gated — see Open Questions)*
- [ ] **6. `memory: project`** for wax and tensoon only, **after** verifying the harness honors the field. *(CONDITIONAL-GO — gated on harness check)*
- [ ] **7. Pre-approve designs of G1 (mcp-builder) and G2 (performance)** — create as live seats only when triggering work arrives, with disjoint trigger surfaces. *(CONDITIONAL-GO — design approved, creation deferred)*

## Open Questions

Two handoffs flagged by synod-elend must be resolved before items 5–6 proceed:

1. **`memory: project` — harness capability check.** Does this Claude Code version honor the `memory: project` frontmatter field? This is a platform-support question, not an architecture decision — route to a harness check (claude-code-guide, or a one-agent test) before writing the key into wax or tensoon. Separately, Elend noted that if `memory: project` introduces cross-session *state* semantics, that persistence boundary is **synod-tensoon's** to assess, not his.
2. **R-Wax reliability scope — tensoon boundary confirmation.** The reliability/SRE fold (and any later 2-into-2 split) should be confirmed against synod-tensoon's data-safety boundary if it touches accumulated cross-session state (e.g., incident history persisted via `memory: project`). Confirm tensoon's sign-off on any state-bearing aspect before the reliability lens lands with persistence attached.

---

## Summary

We compared our 12-agent Synod Council against a 20-agent reference council to surface coverage blind spots. The two share a common design philosophy; the difference is decomposition — the reference splits domains we deliberately merge and carries seven domains with no local home. synod-steris's gap analysis found that most "gaps" are deliberate scope decisions, not defects, and that our per-agent depth is a strength to preserve, not sacrifice. synod-elend then reviewed every proposed change against the binding constraint — a 3-agent-per-task routing ceiling — using a single test: a new seat or split is only justified when its trigger surface is disjoint from existing agents. We approved four immediate, additive, single-file refinements that close real gaps inside existing agents at zero routing cost (chezmoi/preview for melaan, a compliance/detection out-of-scope disclaimer for marsh, a `NotebookEdit` lockdown fix for the six review-only agents, and skill-wiring/test-strategy sharpening for jasnah and vin), plus a council-design rule requiring disjoint triggers for any future seat. The deferred items — a reliability lens and `memory: project` for wax/tensoon — are CONDITIONAL-GO, gated on a harness capability check and a tensoon boundary confirmation. The NO-GO items (compliance, chaos, threat-detection agents, and the full 1-into-3 splits) were deferred because they would create idle seats with no work to route to, or seats with colliding triggers that manufacture routing ambiguity rather than add coverage — in a personal dotfiles/skills repo, an idle agent is negative value.

## Implementation Prompt

> **For synod-vin — execute the four approved refinements from ADR-001.**
>
> Reference: `/Users/taylor/Code/projects/dogfiles/docs/adr/ADR-001-synod-council-agent-refinements.md` (read the Decision and Implementation Order sections first).
>
> **Scope: NARROW IMPLEMENT only.** Make small, localized, additive edits — one file at a time. Do not rename, restructure, or remove anything. Each change must be individually `git checkout`-revertible. After each edit, stop and verify before moving to the next file.
>
> **Approved changes (items 1–4):**
>
> 1. **`/Users/taylor/Code/projects/dogfiles/claude/agents/synod-melaan.md`** — Add to Core Function: "chezmoi/dotfiles materialization and drift capture (`chezmoi re-add`)." Add to Operating Principles: "**Preview before apply.** Diff/preview any `chezmoi apply` (or `terraform apply`, `ansible-playbook`) before running it. Never apply blind."
>    - *Verify:* the two additions are present, melaan's existing Core Function/Operating Principles structure is intact, and nothing else changed.
>
> 2. **`/Users/taylor/Code/projects/dogfiles/claude/agents/synod-marsh.md`** — Add a `Not in scope` line explicitly disclaiming compliance-program work (control mapping, audit evidence) and detection engineering (Sigma/MITRE/SIEM), stating they are currently *unowned* and require a user decision on whether to add an agent.
>    - *Verify:* the disclaimer names both compliance and detection, and frames them as unowned/user-decision-required (not silently absorbed).
>
> 3. **All six review-only agent files** — `synod-kelsier.md`, `synod-elend.md`, `synod-marsh.md`, `synod-tensoon.md`, `synod-vendell.md`, `synod-jasnah.md`. In each frontmatter `disallowedTools` list, add `NotebookEdit` so the list reads `[Edit, Write, NotebookEdit]`. Keep the YAML-list format. Do **not** add `Bash`.
>    - *Verify:* each of the six files now lists `NotebookEdit` in `disallowedTools`; no other agent's frontmatter was touched; `Bash` was not added anywhere.
>
> 4. **`/Users/taylor/Code/projects/dogfiles/claude/agents/synod-jasnah.md`** — Add a short `## Skills to Use` section referencing the `code-review` skill (diff inspection) and `simplify` skill (reuse/efficiency cleanups); note these inform the verdict and grant no write mandate. Add a one-line note to jasnah's review scope that test *strategy* (right-layer testing, boundary-mocking) is a reviewable quality dimension. **`/Users/taylor/Code/projects/dogfiles/claude/agents/synod-vin.md`** — Add a Self-Check line: "Did I assess the test *pyramid* — am I testing at the right layer, mocking at boundaries not internals?"
>    - *Verify:* jasnah has a `## Skills to Use` section + the test-strategy review note and remains advisory (no write mandate added); vin has the new Self-Check line.
>
> **Global verification after all four:** run `git diff --stat` — expect exactly these files changed: synod-melaan, synod-marsh, synod-kelsier, synod-elend, synod-tensoon, synod-vendell, synod-jasnah, synod-vin (marsh appears in both items 2 and 3). Confirm no file outside this set was modified. Spot-check that no existing content was deleted — every change is additive.
>
> **Do NOT proceed with items 5–6** (R-Wax reliability lens and `memory: project`) until the Open Questions in the ADR are resolved: the `memory: project` harness capability check and the synod-tensoon boundary confirmation. These are out of scope for this pass.
