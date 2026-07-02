# ADR-003: Subagent Frontmatter — Deliberate Effort Tiers and Adoption of Newer Fields

## Status
Proposed

## Date
2026-07-02

## Context

A **mechanical audit** of the Synod Council's Claude Code configuration — `claude/CLAUDE.md`, `claude/charter-details.md`, and the twelve `claude/agents/synod-*.md` subagent definition files — was run this session against current official Anthropic documentation (`code.claude.com/docs`, specifically `code.claude.com/docs/en/subagents.md`). **The existing frontmatter schema is fully compliant.** Every field currently in use (`name`, `description`, `model`, `effort`, `disallowedTools`, `color`) is valid and correctly formed. This ADR does not fix a defect.

Two **design observations** surfaced during that audit. They are opportunities, not bugs. This ADR records the design so a future implementation pass can execute against a considered plan rather than reopening the analysis.

### Observation 1 — `effort` field is applied ad-hoc

The `effort` frontmatter field overrides the session's default effort level for a subagent (accepted values depend on model — `low` / `medium` / `high` / `xhigh` / `max`). Today **6 of 12** agents set it explicitly and **6 inherit** the session default:

| Agent | Model | Current `effort` | Role summary |
|-------|-------|------------------|--------------|
| synod-kelsier | sonnet | `low` | Routing/orchestration — selects specialists, does not implement or review |
| synod-elend | opus | `high` | Architecture & data-model **veto** |
| synod-marsh | opus | `high` | Security **veto**, consulted first |
| synod-jasnah | sonnet | `medium` | Code review (advisory) |
| synod-tensoon | sonnet | `high` | Data-safety & migration **veto** |
| synod-wax | sonnet | `high` | Debugging / incident response (advisory) |
| synod-vin | sonnet | *(inherit)* | General implementation — default coder |
| synod-melaan | sonnet | *(inherit)* | Dev-experience / local environment |
| synod-marasi | sonnet | *(inherit)* | CI/CD & delivery |
| synod-steris | opus | *(inherit)* | Docs & planning **veto** |
| synod-kaladin | sonnet | *(inherit)* | UX / accessibility |
| synod-vendell | sonnet | *(inherit)* | Doc-currency / dependency verification (review-only) |

The pattern looks intentional: judgment-heavy veto and review roles tend to carry explicit `high`; general implementers inherit. But two asymmetries stand out when read against the roster:

- **synod-vendell has no `effort` override**, yet its role — verifying dependency currency and API accuracy against live documentation, holding the line against stale/hallucinated version claims — is analogous in rigor to **synod-marsh's** security verification, which carries `effort: high`. A review-only verification gate inheriting a possibly-low session default is the gap most worth closing.
- **synod-steris is a veto-holder on an `opus` model but inherits `effort`**, while the other three veto-holders (elend, marsh, tensoon) all carry explicit `high`. The one veto role without a declared floor is the documentation-accuracy veto — this record's own author.

The remaining inheritors (vin, melaan, marasi, kaladin) are implementers/designers where inheriting the session effort is defensible and possibly correct — but that should be a **decision on the record**, not an accident of which files happened to get an `effort` line.

### Observation 2 — newer subagent frontmatter fields are unused

Official docs document optional fields that **none** of the twelve agents currently use. Each is a deliberate-deferral candidate; the audit's job is to surface the surface area, not to adopt reflexively.

- **`skills`** (YAML list of skill names) — preloads full skill content into the subagent's context at startup, guaranteeing availability rather than relying on model-driven runtime discovery. Direct candidate: **synod-vin**, whose own description prose says it "pairs with the agent-browser skill" but does not declare `skills: [agent-browser]`. The prose asserts a dependency the frontmatter does not guarantee.
- **`memory`** (string: `user` / `project` / `local`) — enables a persistent memory directory for that specific subagent across invocations. Candidate: the four **veto-holders** (elend, marsh, tensoon, steris) could retain precedent — past review verdicts and rulings — across sessions. **Open tension, flagged explicitly:** the main Sazed session already runs an auto-memory system (`~/.claude/projects/.../memory/`). Per-subagent memory could be *complementary* (subagent-scoped technical precedent vs. session-scoped user/project context) **or** could create confusing, duplicated, or conflicting memory stores. This requires a design decision, not a default-on recommendation.
- **`permissionMode`** (string: `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan`) — a **harness-enforced hard gate**. This contrasts with the Council's current NARROW/WIDE/PROBE/PLAN promotion staging, which is enforced **entirely via prompt instruction** in `claude/CLAUDE.md` — a *soft* gate relying on model compliance, not a technical enforcement mechanism. **This is NOT a clean drop-in replacement:** the charter's promotion model is dynamic and mid-session (the user says "you may implement" mid-conversation to promote an agent), whereas `permissionMode` is *static per-agent-invocation* frontmatter that cannot change once the agent is dispatched. It could still add a defense-in-depth layer on specific agents without replacing the existing model — discussed in the Decision.
- **Other available-but-unused fields** (surface-area acknowledgement only, so a future reader knows they were considered and consciously deferred): `maxTurns`, `isolation: worktree`, `background`, `hooks`, `mcpServers`, `initialPrompt`. No adoption is proposed for these in this ADR.

## Decision

This ADR proposes the following adoption plan. **Nothing here is implemented** — see Consequences on deliberate deferral.

### Part A — Deliberate `effort` tiers across all 12 agents

Assign effort as a reviewed policy, keyed to each role's actual cognitive load, rather than the current ad-hoc split. The proposed policy:

- **Veto-holders and hard verification gates → `high`.** These roles render binding or near-binding judgments; under-thinking them is the expensive failure.
- **Advisory review → `medium`+.** Firm verdicts, but non-blocking.
- **Routing → `low` (unchanged).** Kelsier's job is fast triage and dispatch, not deep reasoning; a low floor is correct and already set.
- **Implementers/designers → explicit `inherit` decision** (i.e. add no `effort` line, but record *why*). These roles scale their thinking to the task the session hands them; a fixed floor would either over-spend on trivial edits or under-serve complex ones. Session-level effort is the right lever.

Proposed per-agent values with reasoning:

| Agent | Current | **Proposed** | Reasoning |
|-------|---------|--------------|-----------|
| synod-kelsier | `low` | **`low`** (keep) | Fast triage/dispatch; deep reasoning is delegated to the specialists it routes to. |
| synod-elend | `high` | **`high`** (keep) | Architecture veto; long-term maintainability calls are high-consequence. |
| synod-marsh | `high` | **`high`** (keep) | Security veto, assume-breach posture; the canonical high-rigor gate. |
| synod-tensoon | `high` | **`high`** (keep) | Data-safety veto; destructive/irreversible operations demand full deliberation. |
| synod-steris | *(inherit)* | **`high`** (add) | **Change.** Documentation-accuracy & planning-coherence veto — a veto-holder on `opus` with no declared effort floor is the odd one out among the four vetoes. Aligns the record-keeper with its peer gates. |
| synod-vendell | *(inherit)* | **`high`** (add) | **Change.** Dependency/doc-currency verification is rigor-analogous to Marsh's security verification; a review-only gate against stale/hallucinated version claims should not inherit a possibly-low session default. This is the single most defensible change in the set. |
| synod-jasnah | `medium` | **`medium`** (keep) | Advisory code review — firm but non-blocking; `medium` matches its escalate-don't-block posture. |
| synod-wax | `high` | **`high`** (keep) | Incident response / root-cause; live incidents reward thoroughness, and it already carries `high`. |
| synod-vin | *(inherit)* | **inherit** (keep, now deliberate) | Default coder; effort should scale to the task the session hands it, not be pinned. Recorded as an intentional inherit. |
| synod-melaan | *(inherit)* | **inherit** (keep, now deliberate) | Dev-ex/local-env work varies widely in depth; session effort is the right lever. |
| synod-marasi | *(inherit)* | **inherit** (keep, now deliberate) | CI/CD delivery; task-scaled effort is appropriate. |
| synod-kaladin | *(inherit)* | **inherit** (keep, now deliberate) | UX/accessibility design scales with the surface under review. |

Net change to files: **two edits** — add `effort: high` to `synod-steris.md` and `synod-vendell.md`. All ten others are unchanged; the six current inheritors that stay inheriting are simply *ratified* as deliberate, not edited.

> **Note on `opus`-model agents (steris, elend, marsh):** the accepted `effort` values are model-dependent. `high` is valid on `opus`. The implementer must confirm against current docs at execution time that the chosen token is accepted for each agent's declared model before writing — deferred verification is called out in the Implementation Order and Verification sections.

### Part B — `skills` field

**Adopt narrowly, for synod-vin only:** add `skills: [agent-browser]` so the browser-automation skill its own description already claims it "pairs with" is *guaranteed* loaded at startup rather than left to runtime discovery. This closes a prose-vs-frontmatter gap. No other agent's description asserts a specific skill dependency, so no other `skills` declaration is proposed.

> Deferred verification: confirm the skill name is exactly `agent-browser` as the harness expects, and confirm preloading a skill does not materially inflate vin's session-start context beyond acceptable cost.

### Part C — `memory` field

**Defer, pending an explicit design decision.** The candidate value is real (veto-holder precedent retention), but the open tension with the existing Sazed session-level auto-memory (`~/.claude/projects/.../memory/`) is unresolved: complementary scoping vs. duplicated/conflicting stores. This ADR **does not** recommend enabling `memory` on any agent. It records the candidate (elend, marsh, tensoon, steris) and the required follow-up: a separate design decision defining scope boundaries (subagent technical precedent vs. session user/project context), conflict-resolution precedence, and storage/retention semantics **before** any `memory:` line is written. Enabling it by default is explicitly rejected here.

### Part D — `permissionMode` field

**Defer as a whole-council replacement; keep it open as a narrow defense-in-depth layer.** `permissionMode` is a static per-invocation hard gate and therefore **cannot replace** the charter's dynamic mid-session promotion model (NARROW/WIDE/PROBE/PLAN granted by user phrase mid-conversation). It could, however, add a harness-enforced backstop on specific agents where the *intent is invariant across all invocations*:

- The six review-only agents (kelsier, elend, marsh, tensoon, vendell, jasnah) already carry `disallowedTools: [Edit, Write, NotebookEdit]`, which is itself a harness-enforced hard gate covering the write-lockdown. `permissionMode: plan` on these would be *belt-and-suspenders* and largely redundant with the existing `disallowedTools` lockdown.
- On implementers (vin, melaan, marasi, steris, kaladin, wax), a static `permissionMode` would **conflict** with the dynamic promotion model — e.g. pinning `permissionMode: plan` would break the user's ability to promote mid-session. **Rejected for implementers.**

**Recommendation:** take no `permissionMode` action in the near term. The existing `disallowedTools` lockdown already provides the hard-gate defense for review-only agents; layering `permissionMode: plan` on top is low-value redundancy, and applying it to implementers is actively harmful to the promotion model. Record it as **considered and consciously deferred**, revisitable if the soft-gate promotion model is ever observed to fail in practice.

### Part E — Other fields

`maxTurns`, `isolation: worktree`, `background`, `hooks`, `mcpServers`, `initialPrompt`: **acknowledged, no adoption proposed.** Recorded here solely so a future reader knows the full surface area was reviewed and these were consciously left out of scope for this ADR.

## Consequences

**Implementation is deliberately deferred.** This ADR is the **design record**, not the trigger to build. Per the user's framing, this is a *future* project; execution is gated on separate, explicit user approval. The Implementation Order below lays out the eventual synod-vin dispatch(es) as unchecked steps for when that approval is granted.

**If adopted as proposed:**
- Two effort floors are added (steris, vendell); the documentation and dependency-verification gates stop inheriting a possibly-low session default. The other ten agents' effort posture is unchanged but now *ratified on the record* rather than accidental.
- synod-vin's browser-testing capability is guaranteed at startup rather than discovered at runtime (one `skills` line).
- `memory`, `permissionMode`, and the six "other" fields remain unused — but now as **documented, deliberate deferrals**, so a future audit does not re-litigate them from scratch.

**What stays the same:**
- The charter's promotion model (NARROW/WIDE/PROBE/PLAN, soft-gated via prompt) is untouched. `permissionMode` is explicitly *not* adopted in a way that would alter it.
- The `disallowedTools` write-lockdown on the six review-only agents is untouched.
- No agent's `description`, `model`, or routing trigger keywords change. This ADR touches only the additive frontmatter fields on `synod-steris.md`, `synod-vendell.md`, and `synod-vin.md` — **three files** if fully adopted.

**Constraints / follow-ups created:**
- A separate **`memory` design decision** is now a named prerequisite before any `memory:` line is written (see Part C).
- The model-dependent validity of `effort: high` on each target agent's model must be confirmed against current docs at implementation time (see Part A note).

**Risk register:**

| Risk | Likelihood | Impact | Mitigation (pre-written) |
|------|-----------|--------|--------------------------|
| Chosen `effort` token invalid for an agent's model | L | M | Verify accepted values per model against `code.claude.com/docs/en/subagents.md` before writing; a fresh session fails loud if the token is rejected, and rollback is a one-line `git checkout`. |
| `skills: [agent-browser]` name mismatch / skill not found | L | L | Confirm exact skill name at implementation time; harness surfaces an unknown-skill error at load, revertible by removing the line. |
| `effort: high` on steris/vendell inflates cost on trivial reviews | M | L | Accepted trade-off — these are gate roles where under-thinking is the costlier failure; revisit if cost is observed to be disproportionate. |
| `permissionMode` later adopted on an implementer breaks promotion | L | H | Explicitly rejected for implementers in Part D; this ADR is the record that prevents that mistake. |
| Editing `claude/agents/*.md` violates the "edit only repo sources" rule | L | H | These *are* repo sources (`claude/agents/`), not deployed destinations (`~/.claude/agents/`). The sync step (`task tools:claude`) is a separate, later, user-gated action — never part of the edit pass. |

**Go / No-go gate:** proceed to implementation only on explicit user approval of this ADR's Decision section. No-go until then.

**Rollback trigger:** if a fresh session after sync shows any target agent failing to load, or any behavioral regression in vin/steris/vendell, revert immediately (see Rollback).

## Implementation Order

*All boxes unchecked — nothing in this ADR is implemented. Execution is gated on separate user approval.*

- [ ] **User reviews and approves this ADR's Decision section** (go/no-go gate). No file edits before this.
- [ ] **Resolve the `memory` design decision** (Part C) — OR explicitly confirm `memory` stays deferred for this pass. This is a prerequisite only if `memory` adoption is desired; if deferred, this box is satisfied by recording "memory deferred, no action."
- [ ] **Verify model-dependent `effort` validity** — confirm `effort: high` is an accepted value for `opus` (steris) and `sonnet` (vendell) against current `code.claude.com/docs/en/subagents.md`.
- [ ] **synod-vin dispatch #1 — add `effort: high` to `claude/agents/synod-steris.md`** frontmatter. Single-file, additive, revertible via `git checkout`.
- [ ] **synod-vin dispatch #2 — add `effort: high` to `claude/agents/synod-vendell.md`** frontmatter. Single-file, additive, revertible.
- [ ] **synod-vin dispatch #3 — add `skills:` list with `agent-browser` to `claude/agents/synod-vin.md`** frontmatter (Part B). Single-file, additive, revertible.
- [ ] **`memory` / `permissionMode` / other fields:** no dispatch — deferred/rejected per Parts C, D, E. Left unchecked intentionally as a record that they were not implemented.
- [ ] **Apply to machine:** run `task tools:claude` to sync `claude/agents/` to `~/.claude/agents/`. **Gated on separate user approval — not part of the edit pass.** (Do not edit `~/.claude/agents/` directly — the repo is the source of truth.)

> **Dispatch note:** each of dispatches #1–#3 is a separate synod-vin dispatch per the charter's one-task-per-dispatch rule, not combined. Wait for each to complete and verify before dispatching the next.

## Verification

- `git diff --stat` shows exactly the intended files changed: `claude/agents/synod-steris.md`, `claude/agents/synod-vendell.md`, `claude/agents/synod-vin.md` (plus this ADR as a new file). No other `synod-*.md`, no `claude/CLAUDE.md`, no `claude/charter-details.md`.
- Grep the three edited files' frontmatter to confirm: `synod-steris.md` and `synod-vendell.md` each now contain an `effort: high` line; `synod-vin.md` contains a `skills:` block listing `agent-browser`.
- Confirm **no** `memory:` or `permissionMode:` line was added to any agent file (these are deferred/rejected).
- Confirm the `description`, `model`, and `disallowedTools` fields of all twelve agents are byte-for-byte unchanged from before this pass.
- Open a fresh Claude Code session and confirm synod-steris, synod-vendell, and synod-vin all load without frontmatter errors, and that synod-vin has the agent-browser skill available at startup.
- Confirm the promotion model still functions: dispatch synod-vin into a NARROW implement stage mid-session and confirm it can still write (proving no `permissionMode` gate was silently introduced).

## Rollback

`git checkout claude/agents/synod-steris.md claude/agents/synod-vendell.md claude/agents/synod-vin.md` reverts all frontmatter edits. `rm docs/adr/ADR-003-subagent-frontmatter-effort-tiers-and-newer-fields.md` removes this ADR. If the machine was already synced, re-run `task tools:claude` after the checkout to restore the deployed copies from the reverted sources. Because every change is additive frontmatter on independent files, a partial rollback (e.g. reverting only vin) is safe and does not affect the others.

## Implementation Prompt

> **For synod-vin — execute the ADR-003 frontmatter adoptions (only after user go/no-go approval).**
>
> Reference: `/Users/taylor/Code/projects/dogfiles/docs/adr/ADR-003-subagent-frontmatter-effort-tiers-and-newer-fields.md`.
>
> **Scope: NARROW IMPLEMENT, three files, additive frontmatter only.** Execute as three separate dispatches, verifying each before the next:
> 1. Add `effort: high` to `claude/agents/synod-steris.md` frontmatter.
> 2. Add `effort: high` to `claude/agents/synod-vendell.md` frontmatter.
> 3. Add a `skills:` list containing `agent-browser` to `claude/agents/synod-vin.md` frontmatter.
>
> **Before writing:** verify `effort: high` is an accepted value for each target agent's declared `model` against current `code.claude.com/docs/en/subagents.md` (route to synod-vendell for the currency check if unsure).
>
> **Do NOT** add any `memory:` or `permissionMode:` line — those are deferred/rejected per this ADR. **Do NOT** touch `claude/CLAUDE.md`, `claude/charter-details.md`, or any other `synod-*.md`. **Do NOT** run `task tools:claude` — surface applying to the machine as a separate, later step gated on user approval.
>
> After editing, run `git diff --stat` and confirm only the three agent files changed, then run the Verification greps above.
