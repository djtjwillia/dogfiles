# 05-spec-multi-agent-concurrent-sdd.md

> **Status: PROPOSED — not yet started.** This spec defines a routing and isolation **protocol** for running 2+ concurrent SDD task flows in one repo. It is intentionally lean: it specifies the protocol and the minimal charter changes, not implementation detail. It **feeds a charter update** that becomes actionable once herdr (spec 04) and, optionally, Treehouse (spec 03) are in place. No charter edits are authorized by this document.

## Introduction/Overview

The user wants to run **two or more active SDD-style task flows in this single repo simultaneously** — e.g. SDD-3 execution on feature A while SDD-1 spec drafting proceeds on feature B. The Synod Charter today has the *capability* primitive (`isolation: "worktree"` on Agent calls) but **no protocol** governing concurrent flows: nothing tracks which task flows are live, nothing prevents two flows from racing on the same working tree, nothing maps terminal panes to flows, and nothing defines what happens to flow B when an agent in flow A halts.

This spec defines that protocol. It builds on three prior pieces of the record:
- The completed Kelsier redesign (commit `d345887`): Kelsier is now a **narrowed mediator/router**, no longer a do-everything orchestrator — which gives the concurrency protocol a place to live.
- The deferred memory draft `project_worktree_parallel_issues.md`, which sketched per-task worktree isolation but was **blocked on the Kelsier rework** (now done — this spec unblocks it).
- Specs 03 (Treehouse, optional pool) and 04 (herdr, the multiplexer the flows would run inside).

## Problem Statement

With concurrent SDD flows and no protocol:

1. **Working-tree race.** Two `synod-vin` dispatches in the same repo without isolation write to the same tree — edits, builds, and tests collide. (This is the original driver from the memory draft.)
2. **No live-flow registry.** Sazed/Kelsier have no record of which flows are active, which task within each flow is in progress, or which branch/worktree each owns. Routing is blind to concurrency.
3. **Unmapped panes.** If flows run in herdr panes (spec 04), nothing defines the pane↔flow mapping — which pane is which task, what state each is in (herdr tracks blocked/working/done/idle, but only if something assigns panes to flows).
4. **Undefined halt semantics across flows.** The charter's **cascading halt** suspends *declared dependents within a routing plan*. It does not define behavior across **independent concurrent flows**: if an agent in flow A surfaces to the user, what happens to flow B — which never depended on A?
5. **Unclaimed pool leasing.** If Treehouse is adopted (spec 03), nothing maps its leased worktrees to active flows.

The cost of not solving this is **correctness** (race in problem 1) and **coordination failure** (problems 2–5) — not merely latency. Problem 1 alone is a reason the protocol must exist before concurrent `vin` dispatches are allowed.

## Proposed Solution

A protocol with four parts. Each part is a rule, not a build.

### S1 — One flow, one worktree, one branch (isolation)

Every concurrent SDD task flow runs in its **own git worktree on its own branch**. When 2+ flows are live in the same repo, no flow operates on the shared primary working tree. Worktrees come from one of two sources, decided by spec 03's outcome:
- **Default (Treehouse NOT adopted):** Claude Code native `isolation: "worktree"` per agent dispatch within the flow.
- **If Treehouse adopted:** a leased worktree from the pool, one lease per flow, returned on flow completion.
- **Exactly one isolation layer per flow** — never both (mirrors spec 03 AR5/R4; the layering decision is shared between the two specs).

### S2 — Kelsier owns the live-flow registry (routing)

When 2+ flows are live, **synod-kelsier is the active mediator** (this is the role the redesign narrowed Kelsier to). Kelsier maintains a lightweight **flow registry** for the session:

| Field | Meaning |
| --- | --- |
| flow id | stable handle for the task flow (e.g. the SDD spec dir it serves) |
| SDD stage | which stage (1–4) the flow is in |
| current task | the in-progress task within the flow (for SDD-3, the single task being executed) |
| branch | the branch the flow owns |
| worktree path | the isolated worktree (native or leased) |
| pane | the herdr pane bound to the flow (spec 04), if running in herdr |
| state | working / blocked / done / idle (aligns with herdr's semantic states) |

**Routing rule:** Sazed routes a dispatch *into a flow* by flow id; Kelsier ensures the dispatch lands in that flow's worktree/branch and never crosses into another flow's. The charter's **≤3 agents per task** ceiling and **one-vin-dispatch-per-SDD-task** rule (no batching) still hold **within each flow independently**.

### S3 — One pane, one flow (herdr mapping)

When flows run inside herdr (spec 04): **one herdr pane = one SDD task flow.** The pane's herdr semantic state (blocked/working/done/idle) reflects the flow's registry `state`. Kelsier's registry `pane` field is the binding. This makes the herd legible: each pane is a flow, its state is visible, and Kelsier routes by flow id which resolves to a pane. herdr provides the panes and state tracking; **this protocol provides the meaning of the mapping** — that division is the same one spec 04 draws (herdr runs correctly; routing meaning lives here).

### S4 — Cross-flow halt semantics (the new rule)

The existing charter cascading halt covers **intra-flow dependents**. This spec adds the **inter-flow** rule:

- **Concurrent flows are independent by default.** If an agent in flow A surfaces to the user (halts), the charter cascading halt suspends A's *declared dependents within A's routing plan* — as today. **Flow B is NOT automatically suspended**, because B never declared a dependency on A.
- **Kelsier is notified on any surface** (existing rule) and **records the halt against the flow** in the registry (flow A → blocked).
- **Exception — shared-resource halt:** if the reason flow A surfaced is a **shared resource** (the repo's primary branch, a shared migration, a credential rotation, a Treehouse pool exhaustion), Kelsier evaluates whether flow B touches the same resource. If it does, **Kelsier suspends flow B as well** and surfaces a unified position to the user (consistent with Kelsier's simultaneous-conflicting-veto duty). If B is unaffected, B continues.
- **The user resumes per flow.** Resuming flow A does not auto-resume B and vice versa; Kelsier issues updated routing per flow on resume.

This keeps independent work independent while making genuinely shared-resource contention safe.

## Goals

- **No working-tree races** between concurrent flows (S1).
- **A legible live-flow registry** Kelsier maintains so routing is concurrency-aware (S2).
- **A defined pane↔flow mapping** when running in herdr (S3).
- **Defined cross-flow halt semantics** — independent flows stay independent; shared-resource contention is caught (S4).
- **Minimal, reversible charter delta** — the smallest set of charter/Kelsier additions that make the protocol real (§Charter Changes).
- **Composes with specs 03 and 04** without requiring either: works on native isolation alone, and works without herdr (panes optional).

## Non-Goals

- **Implementing herdr or Treehouse.** Those are specs 04 and 03. This spec assumes at most their *interfaces*, not their adoption.
- **Cross-machine or cross-repo concurrency.** Single repo, single machine, this session.
- **Unlimited parallelism.** This is not an autoscaler; concurrent-flow count is bounded (Open Question 2).
- **Changing the SDD stage commands or the per-task no-batching rule.** Those hold unchanged, per flow.
- **A new orchestration engine.** Kelsier mediates with a registry; this is coordination, not a scheduler.

## Adoption Requirements

If approved (and once specs 04/03 land as needed):

| ID | Requirement |
| --- | --- |
| AR1 | **Charter: concurrency protocol section.** Add S1–S4 to the charter (or `charter-details.md`) as the multi-flow protocol, with the live-flow registry schema (S2 table). |
| AR2 | **Kelsier definition: mediator-of-concurrent-flows.** Extend `synod-kelsier`'s agent definition so it maintains the flow registry, routes dispatches by flow id into the correct worktree/branch, and applies S4 halt semantics. |
| AR3 | **Isolation rule.** Codify "one flow = one worktree = one branch" and the single-isolation-layer rule (shared with spec 03 AR5). State the default (native isolation) and the Treehouse-adopted variant. |
| AR4 | **herdr pane mapping (conditional on spec 04).** Document one-pane-one-flow and the registry `pane`/`state` binding. Gracefully degrade when herdr is absent (panes optional). |
| AR5 | **Cross-flow halt rule.** Add S4 to the charter's cascading-halt section as the inter-flow companion to the existing intra-flow rule. |
| AR6 | **Reversibility + bound.** Document how to disable concurrent flows (fall back to single-flow serial SDD) and the max concurrent-flow count (Open Question 2). |

## Risks

| ID | Risk | Likelihood | Impact | Mitigation (pre-written) |
| --- | --- | --- | --- | --- |
| R1 | **Working-tree race despite protocol** (a dispatch escapes isolation and writes the primary tree). | M | H | S1/AR3 make isolation mandatory for concurrent flows; Kelsier refuses to route a write-capable dispatch into a flow lacking a worktree+branch. Verify in a two-flow dry run. |
| R2 | **Registry drift** — Kelsier's registry disagrees with reality (a flow finished but still shows working; a pane closed but still bound). | M | M | Registry is session-scoped and cheap; Kelsier reconciles on every routing decision. herdr's live state (if present) is the source of truth for `state`. |
| R3 | **Cross-flow halt over- or under-suspends** — B suspended when independent, or B continues when it shares a resource. | M | H | S4's explicit shared-resource test; default is independence, suspension only on demonstrated shared-resource contact. User is the resume authority per flow. |
| R4 | **Layering conflict with native + Treehouse isolation** (double-wrapped worktrees across flows). | M | H | Shared with spec 03 R4/AR5: exactly one isolation layer, decided once, documented in both specs. |
| R5 | **Pane exhaustion / pool starvation** — more live flows than panes or pool leases. | L | M | AR6 bounds concurrent-flow count; on exhaustion Kelsier queues the new flow rather than racing (flow stays idle until a slot frees). |
| R6 | **Charter bloat** — protocol added verbosely to the always-loaded lean core. | M | M | Put the full protocol in `charter-details.md`; keep only the trigger ("2+ live flows → Kelsier mediates, see details") in the lean core. Honors the charter's own "never externalize a control's constraint while leaving its trigger" rule by keeping trigger + pointer together. |

## Success Criteria

The protocol **succeeds** if **all** hold:

1. **Two flows, no race:** a two-flow dry run (e.g. SDD-3 on A, SDD-1 on B) completes with each flow confined to its own worktree/branch; the primary tree is untouched by either.
2. **Registry is accurate:** at any point during the two-flow run, Kelsier's registry correctly reports each flow's stage, branch, worktree, (pane), and state.
3. **Independent halt isolates correctly:** an agent surfacing in flow A suspends A's intra-flow dependents and leaves an unrelated flow B running; the user resumes A without touching B.
4. **Shared-resource halt catches correctly:** a halt rooted in a shared resource that B also touches suspends B and surfaces a unified position.
5. **Degrades gracefully:** the protocol works with native isolation and no herdr (panes optional), and with Treehouse adopted — exactly one isolation layer in each case.
6. **Lean-core discipline preserved:** the always-loaded charter grows only by a trigger + pointer; the body lives in `charter-details.md`.

The protocol **fails** (revise) if concurrent flows cannot be made race-free (R1), or if cross-flow halt semantics cannot be made both safe and non-over-suspending (R3).

## Open Questions

1. **Does the live-flow registry persist, or is it session-only?** Session-only is simpler and matches current practice (Sazed routes within a session). Cross-session flow resumption (herdr's persistent sessions, spec 04) may argue for persistence — defer until herdr's session model is confirmed (spec 04 vendell gate).
2. **What is the max concurrent-flow count?** Bounded by panes, by pool size (if Treehouse), and by cognitive/coordination load. Propose a conservative default (2–3) at approval; tune empirically.
3. **Single isolation layer: native or Treehouse?** Shared with spec 03 (R4/AR5). This spec inherits whatever spec 03's go/no-go decides; until then, default = native isolation.
4. **Does the ≤3-agents-per-task ceiling apply per flow or across all live flows?** Proposed: **per flow** (each flow is its own task context). Confirm with the user — across-all would tightly cap concurrency.
5. **How does Kelsier surface a unified position across flows** when two flows independently raise vetoes at once? Builds on Kelsier's existing simultaneous-conflicting-veto duty; confirm the multi-flow extension at AR2.

## Dependencies & Sequencing

- **Hard dependency on the Kelsier redesign:** done (commit `d345887`). This spec is now unblocked (it was the memory-draft blocker).
- **Soft dependency on spec 04 (herdr):** S3 (pane mapping) is conditional — the protocol works without herdr, but the pane↔flow mapping only applies if herdr is adopted. AR4 is gated on spec 04 landing.
- **Soft dependency on spec 03 (Treehouse):** S1's pool variant and the single-layer decision (R4/AR5) are shared; until spec 03's gate clears, default = native isolation.
- **Feeds:** the eventual charter update (AR1–AR5). That charter edit is **separate, later, and goes through synod-vin** like any charter change — not authorized here.

## Escalation / Routing Notes

- **synod-kelsier** — owns this protocol's core: the flow registry (S2), routing-by-flow-id, and cross-flow halt semantics (S4, AR2, AR5). This spec extends Kelsier's narrowed-mediator role into concurrency mediation.
- **synod-elend** — architecture review: the registry schema and the cross-flow halt model are a structural/coordination design decision. Elend should review S2/S4 before the charter delta is implemented (Elend-before-Vin on structure).
- **synod-steris** — documentation-accuracy veto: the charter delta (AR1–AR5) must match the protocol as approved, and the lean-core trigger+pointer must not orphan its constraint (R6). I hold this line at the charter edit.
- **synod-marsh** — consult on S4's shared-resource case where the shared resource is a **credential rotation or secret** (the charter already routes credential-rotation contingencies to Marsh). Confirm the halt rule defers to Marsh on security-rooted cross-flow halts.
- **synod-vin** — implements the eventual charter/Kelsier-definition edits (separate authorization), one change at a time, with the charter's own output gates.

---

**Next step:** This spec remains **PROPOSED**. It is approvable now (the Kelsier-redesign blocker is cleared), but its herdr- and Treehouse-conditional parts (S3, S1-pool, AR4) activate only as specs 04 and 03 land. Recommended order: approve this protocol → resolve spec 04 (herdr) and spec 03 (Treehouse gate) → then `/SDD-2-generate-task-list-from-spec` against this file for the charter delta. The decision to proceed is the user's.
