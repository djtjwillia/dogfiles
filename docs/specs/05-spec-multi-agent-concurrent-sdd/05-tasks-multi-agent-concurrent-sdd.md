# 05-tasks-multi-agent-concurrent-sdd.md

> Task list for spec `05-spec-multi-agent-concurrent-sdd.md`.
> Implementation target: charter delta (AR1–AR6). No code — config and documentation only.
> Apply via: `task tools:claude` after all tasks are complete.
> **Scope note:** Treehouse (spec 03) is out of scope. S1 documents native isolation only.

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `claude/CLAUDE.md` | Lean-core charter. Cascading halt section receives the concurrency trigger + pointer (AR1 lean-core half). |
| `claude/charter-details.md` | On-demand charter detail. Receives the full Multi-Flow Concurrency Protocol section: S1–S4, live-flow registry schema, herdr pane mapping, cross-flow halt rule, reversibility/bound (AR1 body, AR3, AR4, AR5, AR6). |
| `claude/agents/synod-kelsier.md` | Kelsier agent definition. Gains the Concurrent-Flow Mediation section: registry maintenance, routing-by-flow-id, S4 halt semantics, per-flow agent ceiling (AR2). |

### Notes

- All edits are in `claude/` (the repo source). Never edit the deployed destinations (`~/.claude/`).
- Deploy with `task tools:claude` after all tasks are complete. `DRY_RUN=true task tools:claude` previews changes safely.
- Treehouse (spec 03) is excluded: S1 documents native isolation only; no pool-variant language.
- Open-question assumptions adopted (OQ2: max 2–3 concurrent flows; OQ4: ≤3-agents ceiling applies per flow; OQ5: cross-flow simultaneous vetoes extend Kelsier's existing veto-notification protocol).

## Tasks

### [x] 1.0 Add concurrency protocol trigger to lean core (CLAUDE.md)

The `claude/CLAUDE.md` cascading-halt section gains a trigger sentence + pointer to `charter-details.md`. Per R6/lean-core discipline, no protocol body goes in the always-loaded core — only the firing condition and the details reference.

#### 1.0 Proof Artifact(s)

- Diff: `claude/CLAUDE.md` shows new trigger sentence in the Cascading halt section referencing the concurrent-flow rule and pointing to `charter-details.md`; the added block is ≤3 sentences
- CLI: `grep -n "concurrent" claude/CLAUDE.md` returns the trigger line with no protocol body in the lean core

#### 1.0 Tasks

- [x] 1.1 Read `claude/CLAUDE.md` and identify the exact location in the **Cascading halt** section where the inter-flow trigger should be appended
- [x] 1.2 Draft the trigger text: one sentence stating "When 2+ flows are live, Kelsier's concurrent-flow registry and cross-flow halt rules also apply — see the Multi-Flow Concurrency Protocol in `charter-details.md`." plus a pointer line; confirm it contains no protocol body
- [x] 1.3 Dispatch synod-vin to insert the trigger text immediately after the existing cascading-halt paragraph in `claude/CLAUDE.md`
- [x] 1.4 Verify: `grep -n "concurrent" claude/CLAUDE.md` returns exactly the new trigger line; no body content leaked into the lean core

---

### [x] 2.0 Write full S1–S4 concurrency protocol into charter-details.md

`claude/charter-details.md` gains a new **Multi-Flow Concurrency Protocol** section containing all four protocol parts, the live-flow registry schema, herdr pane mapping, cross-flow halt rule, and reversibility/bound. Treehouse is excluded; S1 covers native isolation only.

#### 2.0 Proof Artifact(s)

- Diff: `claude/charter-details.md` shows a new `## Multi-Flow Concurrency Protocol` section with subsections for S1–S4; live-flow registry table is present with all 7 fields; AR6 bound and reversibility statement present
- CLI: `grep -c "^### S[1-4]" claude/charter-details.md` returns 4
- CLI: `grep "OQ2\|OQ4\|OQ5" claude/charter-details.md` returns lines documenting the adopted assumptions

#### 2.0 Tasks

- [x] 2.1 Read `claude/charter-details.md` to identify the best insertion point for the new section (after the existing Cascading halt narrative, before any alias map or end-of-file content)
- [x] 2.2 Draft the `## Multi-Flow Concurrency Protocol` section with:
  - **S1 — Isolation:** every concurrent flow runs in its own git worktree on its own branch via `isolation: "worktree"` on agent dispatches; primary working tree is untouched when 2+ flows are live; Treehouse out of scope
  - **S2 — Live-flow registry:** Kelsier maintains the session-scoped registry; include the 7-field table (flow id, SDD stage, current task, branch, worktree path, pane, state)
  - **S3 — Herdr pane mapping:** one pane = one SDD task flow; pane state (blocked/working/done/idle) reflects registry `state`; degrades gracefully when herdr is absent
  - **S4 — Cross-flow halt:** independent-by-default rule; shared-resource exception (Kelsier evaluates, suspends B only on demonstrated contact); user resumes per flow
  - **AR3:** isolation codification sentence (one isolation layer, mandatory when 2+ flows are live)
  - **AR6:** reversibility (fall back to single-flow serial SDD by not starting a second flow) and bound (default max: 2–3 concurrent flows, tunable empirically)
  - **Assumptions:** inline notes for OQ2 (max 2–3), OQ4 (per-flow ceiling), OQ5 (simultaneous cross-flow vetoes extend veto-notification protocol)
- [x] 2.3 Dispatch synod-vin to append the drafted section to `claude/charter-details.md` at the identified insertion point
- [x] 2.4 Verify the 7-field registry table is present and all 4 subsection headings exist: `grep -c "^### S[1-4]" claude/charter-details.md` returns 4

---

### [x] 3.0 Extend synod-kelsier.md with concurrent-flow mediator role

`claude/agents/synod-kelsier.md` gains a **Concurrent-Flow Mediation** section covering registry maintenance, routing-by-flow-id, S4 halt application, per-flow agent ceiling, and cross-flow veto handling.

#### 3.0 Proof Artifact(s)

- Diff: `claude/agents/synod-kelsier.md` shows a new `## Concurrent-Flow Mediation` section
- CLI: `grep -n "flow registry\|flow id\|shared-resource" claude/agents/synod-kelsier.md` returns ≥ 3 distinct lines

#### 3.0 Tasks

- [x] 3.1 Read `claude/agents/synod-kelsier.md` and identify the insertion point (after the existing Veto Notification Protocol section, before "What You Never Do")
- [x] 3.2 Draft the `## Concurrent-Flow Mediation` section with:
  - **Registry:** when 2+ flows are live, Kelsier maintains the session-scoped live-flow registry (7 fields per flow from S2 in `charter-details.md`); reconcile on every routing decision
  - **Routing-by-flow-id:** Sazed routes dispatches into a flow by flow id; Kelsier ensures the dispatch lands in that flow's worktree/branch; never crosses into another flow's worktree
  - **S4 halt application:** on any surface event, record `blocked` in the registry for that flow; check the shared-resource test; if B touches the same resource, suspend B and surface a unified position; if B is unaffected, B continues
  - **Per-flow ceiling:** the ≤3-agents-per-task ceiling and one-vin-per-SDD-task rule apply **per flow independently**
  - **Cross-flow vetoes (OQ5):** if two flows simultaneously raise vetoes, apply the existing veto-notification protocol per flow; if both vetoes concern a shared resource, present both positions together to the user
- [x] 3.3 Dispatch synod-vin to insert the drafted section into `claude/agents/synod-kelsier.md` at the identified location
- [x] 3.4 Verify: `grep -n "flow registry\|flow id\|shared-resource" claude/agents/synod-kelsier.md` returns ≥ 3 distinct lines

---

### [x] 4.0 Deploy and verify all changes via task tools:claude

Run the dry-run to confirm expected changes, then apply and verify each deployed file matches its source.

#### 4.0 Proof Artifact(s)

- CLI: `DRY_RUN=true task tools:claude` output shows `[change]` for `CLAUDE.md`, `charter-details.md`, and `synod-kelsier.md`; `[ok]` for all other files
- CLI: `diff claude/CLAUDE.md ~/.claude/CLAUDE.md` exits 0
- CLI: `diff claude/charter-details.md ~/.claude/charter-details.md` exits 0
- CLI: `diff claude/agents/synod-kelsier.md ~/.claude/agents/synod-kelsier.md` exits 0

#### 4.0 Tasks

- [x] 4.1 Run `DRY_RUN=true task tools:claude` and confirm the three modified files appear as `[change]` with no unexpected changes
- [x] 4.2 Run `task tools:claude` to apply the changes
- [x] 4.3 Run `diff claude/CLAUDE.md ~/.claude/CLAUDE.md && diff claude/charter-details.md ~/.claude/charter-details.md && diff claude/agents/synod-kelsier.md ~/.claude/agents/synod-kelsier.md` — all must exit 0
