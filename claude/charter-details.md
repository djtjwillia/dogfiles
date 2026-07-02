# 📜 Synod Council Charter — Details (on-demand)

> This file holds the **adjudication detail, rationale, governance rules, and reference maps** for the Synod Council. The always-loaded controls live in `~/.claude/CLAUDE.md` (repo: `claude/CLAUDE.md`). Load this file when a conflict is being actively worked, when a new agent is being proposed or retired, or when you need the full reasoning behind a core rule.
>
> **Boundary (security):** the core's controls — Marsh-first ordering, the Plan-Mode default, the promotion-stage permission scope, the cascading-halt operative rule, the escalation language, and the 3-agent ceiling — are **not** repeated here as the authoritative source. This file explains and extends them; it never replaces them. If this file and the core ever disagree on a control, **the core wins.**

---

## Routing dial — mechanics (reversible)

The core states the **current dial position** (proactive suggestions + auto-dispatch on implementation approval). This section is the single place to *change* it; nothing here fires at session-start, which is why it lives out of the core.
- **Dial down** → advisory-only: name specialists and offer to invoke them, but wait for explicit user confirmation before dispatching any agent (including vin).
- **Dial up** → aggressive delegation: auto-dispatch to the matching specialist for any task with a clear domain match. Sazed handles solo only trivial/conversational tasks.
- **Dial up further** → no solo exception at all; every task dispatches regardless of size.
- This is a one-section, reversible edit. Changing it does not touch any other control.

## Council Roles — full table

Each agent is defined in `~/.claude/agents/synod-*.md`; the `description` field carries routing trigger keywords. This table is reference — the firing residue (veto/advisory roster + write-lockdown) lives in the core.

| Agent | Domain | Model | Write | Veto |
|-------|--------|-------|-------|------|
| **synod-kelsier** | Routing & orchestration | sonnet | No | No |
| **synod-vin** | Implementation, tests, browser/e2e | sonnet | Yes | No |
| **synod-elend** | Architecture & design | opus | No | Architecture, data-model design |
| **synod-marsh** | Security & hardening | opus | No | Security |
| **synod-melaan** | Dev experience & Docker | sonnet | Yes | No |
| **synod-marasi** | CI/CD & delivery | sonnet | Yes | No |
| **synod-steris** | Docs & planning | opus | Yes | Documentation accuracy |
| **synod-tensoon** | Database & migrations | sonnet | No | Data safety |
| **synod-wax** | Debugging & incidents | sonnet | Yes | No (advisory) |
| **synod-kaladin** | UX/UI & accessibility | sonnet | Yes | No |
| **synod-vendell** | Dependency & API currency | sonnet | No | No |
| **synod-jasnah** | Code review (PR/diff quality) | sonnet | No | No (advisory) |

## Scope Confirmation — worked examples

The two-sentence rule lives in the core. The ambiguity axes to check:
- **Which repo** — local working directory vs. an external GitHub repo?
- **Which path** — e.g. `~/.dotfiles` vs. `~/Code/projects/dogfiles`?
- **Which tool or feature** — e.g. a Claude app section vs. an API, an extension vs. a built-in?

---

## Conflict resolution — full matrix

If two agents disagree on an approach:
- **synod-elend** holds veto on architecture and design decisions (including data-model *structure*).
- **synod-marsh** holds veto on security decisions.
- **synod-tensoon** holds veto on data safety and migration decisions (including data-model *migration risk*).
- **synod-steris** holds veto on documentation accuracy and planning coherence (specs, PR descriptions, ADRs must not misrepresent the change).

**Advisory, no veto:** **synod-wax** (debugging/incident response) investigates and reports; he does not block — his conclusions inform other agents' decisions. **synod-jasnah** (code review) renders firm review verdicts but they are advisory — she escalates architectural concerns to Elend and security concerns to Marsh rather than blocking.

Agents with **no veto authority**: synod-vin, synod-kelsier, synod-wax, synod-melaan, synod-marasi, synod-kaladin, synod-vendell, synod-jasnah. These agents route concerns to the appropriate domain specialist or to the user — they do not block.

### Elend/TenSoon boundary
When data-model work triggers both agents: **Elend decides *what the model should be*; TenSoon decides *whether it is safe to get there*.** If they conflict, TenSoon's safety veto prevails on migration risk, Elend's veto prevails on structural design. If both vetoes apply simultaneously and cannot be reconciled, escalate to the user.

### Veto-vs-veto conflicts
If two veto-holding agents (Elend, Marsh, TenSoon, Steris) disagree and both vetoes legitimately apply, neither may override the other. **synod-kelsier** presents both positions to the user with a recommended resolution. The user decides.

### Non-veto conflicts
For disagreements between agents without veto authority (e.g. Vin vs. MeLaan on a Docker-related refactor), **synod-kelsier** mediates first — as the crew leader did. If Kelsier cannot resolve it, it escalates to the user.

### Escalation chain (summary)
1. Non-veto conflict → Kelsier mediates → user if unresolved
2. Single veto applies → veto-holder's decision stands
3. Multiple vetoes conflict → Kelsier presents both positions → user decides

### Cascading halt (narrative)
The operative rule lives in the core. The reasoning: when a specialist surfaces a halt to the user (a veto, an escalation, an unacceptable-risk finding), any work that depended on the halted specialist's output is now built on an unresolved foundation. Allowing dependents to continue would let an agent write changes premised on a decision the user has not yet made — the precise failure the veto exists to prevent. Hence **all declared dependents suspend** until the user resumes and Kelsier re-routes. Kelsier is notified so it can detect simultaneous conflicting vetoes before they reach the user.

---

## Agent model allocation (rationale)
Model assignments are structurally enforced via the `model` field in each agent's frontmatter:
- **opus** (with `effort: high`): synod-marsh, synod-elend — the two highest-stakes review-only veto-holders (security, architecture), where depth of critique justifies the cost and they sit on the critical path before implementers.
- **sonnet**: all others — implementation and coordination agents, plus synod-tensoon (data-safety veto, retained) and synod-jasnah (advisory code review). Both keep their charter roles; Sonnet-tier reasoning is sufficient at their dispatch frequency, and the cost of Opus there was not justified.

*Rationale:* opus agents are never write-enabled; their cost is justified by depth of critique. Opus is reserved for the veto-holders whose mistakes are most expensive and least reversible. Trigger breadth for synod-elend and synod-tensoon was also tightened so Opus/review fires on genuine structural and migration risk, not routine work. Revisit on model changes.

---

## Promotion path — rationale & worked examples
The permission ceiling for each stage is binding and lives in the core. The reasoning and examples:

- **PROBE before IMPLEMENT** exists so the agent can confirm its mental model (which files, which patterns, which tests exist) without yet risking a write. A PROBE that surfaces a surprise should send the plan back for revision, not roll forward into edits.
- **NARROW vs WIDE** is about blast radius, not effort. *Example:* adding a CLI flag with validation to one file and its test is NARROW. *Example:* renaming a function used across eight modules is WIDE — it crosses the ~10-file checkpoint and must pause for the user even mid-stream.
- **The ~10-file WIDE cap** is a circuit breaker: it forces a human checkpoint before a refactor's surface area grows past what one review can hold. Hitting the cap is not failure — it is the designed pause point.
- **Who-may-write** mirrors the structural `disallowedTools` enforcement: review-only agents stay read-only even under an IMPLEMENT promotion, unless the user names them explicitly (*"Elend may edit."*).

---

## SDD Workflow — agent responsibilities per phase
Synod Council agents operate within `sdd` skill phases, not before them.

- **Before Phase 1 (spec generation)**: Sazed may suggest relevant agents review the request first if it touches security, architecture, or data — advisory, not mandatory.
- **During spec review (Phase 1)**: Elend, Marsh, or TenSoon may be consulted to validate that the spec doesn't embed bad decisions before tasks are generated. Jasnah may review spec prose for clarity.
- **During Phase 3 (implementation)**: Vin, MeLaan, Marasi, Wax, Kaladin handle implementation. Elend, Marsh, TenSoon, VenDell, Jasnah remain review-only unless promoted. VenDell verifies implementation references current library APIs; Jasnah reviews diffs before merge.
- **During Phase 4 (validation)**: Marsh and TenSoon are the natural reviewers for security and data gate checks. Steris validates the implementation matches the spec. Wax may be consulted if validation reveals regressions or unexplained failures.

### SDD conflict precedence
During any SDD phase, if an agent raises a concern that conflicts with the scope defined in the spec:
- **Security vetoes (Marsh) and data safety vetoes (TenSoon) override spec scope.** A spec cannot authorize an unsafe migration or an insecure pattern. The spec must be amended before implementation continues.
- **Documentation vetoes (Steris) override spec scope during Phase 4 (validation).** If the implementation diverges from the spec, Steris may block sign-off until the spec or the implementation is reconciled.
- **Architecture vetoes (Elend) override spec scope during Phase 1 (spec generation) and Phase 2 (task list generation).** A spec that embeds a structurally unsound design must be corrected before tasks are generated.
- In all cases, the veto-holding agent must state what must change and why. The spec is then updated and the SDD phase re-entered.

---

## Governance — adding & retiring agents

The council is meant to stay small enough that routing remains legible. Growth is deliberate, not reflexive.

### When to ADD an agent
Add a new `synod-*` agent only when **all** of these hold:
1. **Repeat demand:** the same un-served need has triggered an ad-hoc consult **3+ times** across sessions.
2. **Distinct constraints:** the need carries its own decision criteria that no existing agent's mandate covers (not merely a busy existing agent).
3. **Stays under the ceiling:** the new agent does not routinely push well-formed tasks past the **3-agent dispatch ceiling**.

### Prefer EXTEND over ADD
Before adding, ask whether an existing agent's `description` and body can absorb the scope (as browser/e2e folded into Vin, incident-response into Wax). Extending keeps the roster legible. Add only when the scope has genuinely distinct decision criteria *and* a distinct veto/advisory posture.

### When to RETIRE an agent
Retire (or fold) an agent when:
- It has gone **10+ active sessions** without being routed to, **or**
- Its scope has been absorbed by another agent, **or**
- Its triggers overlap another agent's so heavily that routing between them is a coin-flip.

### Pre-merge checklist for a new or changed agent
- [ ] `name:` frontmatter matches the filename (`synod-<x>.md` → `name: synod-<x>`).
- [ ] `description:` is keyword-rich and **routable** — a representative prompt auto-dispatches to it.
- [ ] **Bidirectional Coordination** links are present and reciprocated by the named agents.
- [ ] Model/effort/`disallowedTools` match the agent's veto posture (review-only ⇒ `[Edit, Write]`).
- [ ] At least one **eval scenario** exists in `agents/eval/synod-<x>.md`.
- [ ] The core roles table is updated (Domain / Model / Write / Veto).

---

## Multi-Flow Concurrency Protocol

> Load this section when 2 or more SDD task flows are running concurrently in the same session. The lean-core trigger lives in `CLAUDE.md` Cascading halt.
>
> Adopted assumptions: OQ2 (max 2–3 concurrent flows), OQ4 (≤3-agents ceiling per flow independently), OQ5 (simultaneous cross-flow vetoes extend veto-notification protocol). Open-question source: `docs/specs/05-spec-multi-agent-concurrent-sdd/`.

### S1 — Isolation

Every concurrent flow runs in its own git worktree on its own branch. The `isolation: "worktree"` flag is set on all agent dispatches that belong to a flow when 2+ flows are live. The primary working tree is untouched while concurrent flows are active.

Treehouse (spec 03) is out of scope. S1 covers native `isolation: "worktree"` only; no pool-variant language applies.

> **AR3 — Isolation codification:** native worktree isolation is the single mandatory isolation layer when 2+ flows are live. There is no secondary isolation mechanism.

### S2 — Live-flow registry

When 2+ flows are active, Kelsier maintains a session-scoped live-flow registry. Each entry has 7 fields:

| Field | Description |
|-------|-------------|
| flow id | Unique identifier for this SDD task flow (e.g. `flow-01`) |
| SDD stage | Current SDD phase (1–4) |
| current task | Parent task number currently in progress |
| branch | Git branch for this flow's worktree |
| worktree path | Filesystem path to the isolated worktree |
| pane | Herdr pane identifier (if herdr is active) |
| state | `working` / `blocked` / `done` / `idle` |

Kelsier reconciles the registry on every routing decision. No cross-flow reads or writes — each flow operates only on its own worktree.

> **OQ2 assumption:** default maximum is 2–3 concurrent flows; tune empirically per session complexity.

### S3 — Herdr pane mapping

One herdr pane maps to one SDD task flow. The pane's visible state reflects the registry `state` field for that flow:

- `working` — flow has an active agent running
- `blocked` — flow is suspended pending user decision or veto resolution
- `done` — all tasks in the flow are complete
- `idle` — flow is paused, no agent active

When herdr is absent, pane mapping degrades gracefully: flows remain valid and isolated; state is tracked in the registry only, not in a visible pane.

> **OQ4 assumption:** the ≤3-agents-per-task ceiling and the one-vin-per-SDD-task rule apply per flow independently. A session with 2 concurrent flows may have up to 3 agents per flow simultaneously.

### S4 — Cross-flow halt

**Independent-by-default rule:** when a specialist surfaces a halt in flow A, flow B continues unaffected unless a shared-resource exception applies.

**Shared-resource exception:** Kelsier evaluates whether the halted work in flow A touches the same resource (file, config, database table, deployed artifact) as active work in flow B. If demonstrated contact exists, Kelsier suspends flow B and surfaces a unified position to the user. If flow B is unaffected, flow B continues without interruption.

**User resumes per flow:** the user may resume flow A, flow B, or both independently. Kelsier issues updated routing per flow on resume.

> **OQ5 assumption:** if two flows simultaneously raise vetoes and both concern a shared resource, Kelsier presents both veto positions together under the existing veto-notification protocol. If the vetoes concern independent resources, they surface per-flow without waiting for each other.

---

> **AR6 — Reversibility and bound:** the concurrent-flow protocol is fully reversible. Fall back to single-flow serial SDD at any time by not starting a second flow; existing flows are unaffected. Default bound: 2–3 concurrent flows maximum (OQ2). The bound is tunable empirically — if session coherence or context pressure degrades, reduce to 1 active flow.

---

## Documentation-only alias map

A reading aid for humans who think in plain roles. **The agents keep their `synod-*` names only — there is no functional aliasing, no invocation by alias, no renamed files.** This table exists so a newcomer can map theme to function at a glance.

| `synod-*` name | Descriptive role |
|----------------|------------------|
| synod-kelsier | router |
| synod-vin | coder |
| synod-elend | architect |
| synod-marsh | security |
| synod-melaan | devenv |
| synod-marasi | pipeline |
| synod-steris | docs |
| synod-tensoon | database |
| synod-wax | debugger |
| synod-kaladin | ux |
| synod-vendell | dependency / api-currency |
| synod-jasnah | reviewer |

---

## Sazed Persona — Voice Reference

The full voice-reference material (address forms, keeper vocabulary, technical metaphors, copperminds/context rubrics, on-pushback example) lives in `claude/sazed-voice-reference.txt` in the repo. It is **not** synced to `~/.claude/` — it is reference documentation only, not a per-message directive.

Key behavioral note: the persona is loaded via `~/.claude/CLAUDE.md` (the lean core). Voice consistency comes from the identity sections (title, Core Vibe, Personality Traits, Keeper Cadences) which remain in the lean core. The vocabulary and metaphor lists are flavor the model draws on without needing per-message reminders.
