# ADR-002: Lean-Core Context Trim

## Status
Accepted

## Date
2026-07-02

## Context

`claude/CLAUDE.md` (the "lean core") is synced to `~/.claude/CLAUDE.md` and loaded into **every** Claude Code session's context window at session-start. Its cost is paid on every turn of every session, so every line it carries that does not need to fire at session-start is a standing tax on context. `claude/charter-details.md` is the on-demand companion — loaded only when a conflict is being worked — and pays no session-start cost.

The user asked to minimize session-start context, under two hard constraints: (1) keep the Sazed/Keeper persona voice (shortened is fine), and (2) keep the Routing control fully functional in the core — it is the single most important control to the user. Beyond those, trim aggressively but defensibly.

This was a **multi-agent review**:
- **synod-elend** (architecture veto) ruled on what is a firing control vs. reference: KEEP-FULL for Prime Directive, Scope Confirmation rule sentences, Routing (veto against any cut), Output gates, Cascading halt, Escalation language, and the Promotion-path approval-relay/who-may-write/~10-file lines; **MOVE to details** the escape-hatch dial mechanics and the full 12-row Council Roles table (reference, and unbounded growth as agents are added — the exact cost to avoid); **COMPRESS** the four promotion-stage descriptions to one line each.
- **synod-marsh** (security veto) conditionally approved with six binding verbatim-retention conditions on the security-adjacent controls (Marsh-first keyword list, escalation string, cascading-halt "do not independently surface," promotion phrases + edit ceilings + ~10-file cap + "Sazed does not manufacture approvals," and both write-authority boundary lines).
- **synod-steris** (documentation-accuracy veto) synthesized the draft and verified it against source.

**Staleness discovery during review:** the SDD Workflow section documented `/SDD-1-generate-spec` … `/SDD-4-validate-spec-implementation` slash commands that **no longer exist**. They were retired to `.bak` and replaced by a single `sdd` skill (`~/.claude/skills/sdd/SKILL.md`) that self-detects its phase from workspace state and explicitly instructs against referring users to slash-style phase invocations. The section was therefore not merely verbose — it was **factually wrong**, documenting dead commands. This falls squarely in Steris's veto domain, and the same staleness was also present in `charter-details.md`'s SDD agent-responsibility and conflict-precedence sections, corrected in the same pass.

A second staleness item surfaced: the core's write-lockdown residue said `disallowedTools: [Edit, Write]`, but ADR-001 item 3 added `NotebookEdit`. The correct value is `[Edit, Write, NotebookEdit]`.

## Decision

Rewrite `claude/CLAUDE.md` to a lean core of ~102 lines (down from ~174, ≈41% reduction), and move the displaced reference into `claude/charter-details.md`, as follows:

1. **Persona block** compressed from ~50 lines to ~14, preserving the identity (title), Core Vibe tone, a Keeper-cadence example, and the on-pushback behavioral line verbatim. Voice preserved; flavor duplication removed.
2. **Routing** kept fully functional. Only the header-restating sentence is deleted and the escape-hatch dial *mechanics* move to details; the current dial *position* is stated once in the core. Every routing trigger — proactive surfacing, vin-only implementation, Marsh-first, Elend-before-Vin, 3-agent ceiling, Explore-for-surveys, SDD-planning→steris — stays in the core.
3. **Council Roles table** moved to details; a firing residue stays in the core: where agents are defined + that triggers live in `description` frontmatter, and a veto/advisory/non-blocking roster plus the write-lockdown statement (which the cascading-halt and escalation logic key off).
4. **Promotion path** stage descriptions compressed to one line each (phrase + edit ceiling), with the approval-relay paragraph, who-may-write mapping, ~10-file cap, and "Sazed does not manufacture approvals" kept verbatim per Marsh.
5. **Scope Confirmation** reduced to its two rule sentences + one inline ambiguity cue; the three worked examples move to details.
6. **SDD Workflow** rewritten to be **correct and minimal**: it now describes the `sdd` skill (self-detecting phases, user-invoked) instead of the dead slash commands, and preserves Sazed's load-bearing firing trigger — recognizing the spec/task/implementation/validation moment and naming synod-steris for spec/planning work. The "each numbered task is a separate synod-vin dispatch" rule is retained as one line, reworded from "never batched" to "never combined into one dispatch" to avoid verbal collision with the `sdd` skill's user-facing "Batch Mode" checkpoint option (they are different axes: council dispatch mechanics vs. approval cadence). The same command→phase rename is applied to `charter-details.md`'s SDD agent-responsibility and conflict-precedence sections.
7. **Write-lockdown residue corrected** to `[Edit, Write, NotebookEdit]`, aligning the core with ADR-001 item 3.

KEEP-FULL, unchanged: Charter header note, Prime Directive, Output gates, Cascading halt, Escalation language, Context discipline.

## Consequences

**What changes:**
- Session-start context drops ~41% (~72 lines), paid back on every turn of every session.
- The SDD section becomes factually correct in both files — no more pointing at retired commands.
- The write-lockdown residue matches ADR-001.
- The Council Roles table stops taxing session-start and stops growing the core as agents are added.

**What stays the same:**
- Both hard-requirement controls (persona voice, full Routing) are intact.
- All four vetoes, the escalation string, cascading-halt semantics, and the full promotion permission-ceiling model are byte-for-byte preserved where Marsh required it.
- `charter-details.md` remains the authoritative-on-demand companion; the "core wins on conflict" boundary is unchanged.

**New constraints / follow-ups:**
- Any future agent addition updates the roles table in `charter-details.md`, not the core.

## Implementation Order

1. [x] **User reviewed and approved the final draft directly (2026-07-02).** Elend and Marsh's initial reviews both conditioned approval on a re-review of the final draft before an implementer wrote it; the user opted to give final sign-off directly instead, superseding that condition.
2. [x] **synod-vin — replace `claude/CLAUDE.md`** with the approved draft. Single-file, revertible via `git checkout`.
3. [x] **synod-vin — insert the three moved blocks + fix the stale SDD references in `claude/charter-details.md`.** Single-file, revertible.
4. [ ] **Apply to machine:** run `task tools:claude` to sync both files to `~/.claude/`. (Do not edit `~/.claude/` directly — the repo is the source of truth.) **Gated on separate user approval — not part of this pass.**

**Verification:** `git diff --stat` shows exactly `claude/CLAUDE.md` and `claude/charter-details.md` changed (plus this ADR and the glossary as new files). Grep the new core for each Marsh-verbatim string (Marsh-first keyword list, escalation string, "Sazed does not manufacture approvals", "~10 files", "do not independently surface") and confirm each is present unchanged. Confirm the new core no longer contains `/SDD-1` or `/SDD-4`, and neither does `charter-details.md`. Confirm `disallowedTools` residue reads `[Edit, Write, NotebookEdit]`. Open a fresh session and confirm the persona voice and Routing behavior are unchanged.

**Rollback:** `git checkout claude/CLAUDE.md claude/charter-details.md` and `rm docs/adr/ADR-002-lean-core-context-trim.md docs/glossary-synod-council.md`.

## Implementation Prompt

> **For synod-vin — execute the ADR-002 lean-core trim.**
>
> Reference: `/Users/taylor/Code/projects/dogfiles/docs/adr/ADR-002-lean-core-context-trim.md`.
>
> **Scope: NARROW IMPLEMENT, four files.** (1) Replace `claude/CLAUDE.md`. (2) Edit `claude/charter-details.md` (insert three blocks + fix stale SDD references). (3) Create this ADR. (4) Create `docs/glossary-synod-council.md`. After editing, run `git diff --stat` and confirm only these files changed, then run the verification greps above.
>
> **Do NOT** run `task tools:claude` — surface applying to the machine as a separate, later step gated on user approval.
