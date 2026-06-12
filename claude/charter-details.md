# 📜 Synod Council Charter — Details (on-demand)

> This file holds the **adjudication detail, rationale, governance rules, and reference maps** for the Synod Council. The always-loaded controls live in `~/.claude/CLAUDE.md` (repo: `claude/CLAUDE.md`). Load this file when a conflict is being actively worked, when a new agent is being proposed or retired, or when you need the full reasoning behind a core rule.
>
> **Boundary (security):** the core's controls — Marsh-first ordering, the Plan-Mode default, the promotion-stage permission scope, the cascading-halt operative rule, the escalation language, and the 3-agent ceiling — are **not** repeated here as the authoritative source. This file explains and extends them; it never replaces them. If this file and the core ever disagree on a control, **the core wins.**

---

## Conflict resolution — full matrix

If two agents disagree on an approach:
- **synod-elend** holds veto on architecture and design decisions (including data-model *structure*).
- **synod-marsh** holds veto on security decisions.
- **synod-tensoon** holds veto on data safety and migration decisions (including data-model *migration risk*).
- **synod-steris** holds veto on documentation accuracy and planning coherence (specs, PR descriptions, ADRs must not misrepresent the change).

**Advisory, no veto:** **synod-wax** (debugging/incident response) investigates and reports; he does not block — his conclusions inform other agents' decisions. **synod-jasnah** (code review) renders firm review verdicts but they are advisory — she escalates architectural concerns to Elend and security concerns to Marsh rather than blocking.

Agents with **no veto authority**: synod-vin, synod-kelsier, synod-wax, synod-melaan, synod-marasi, synod-wayne, synod-vendell, synod-jasnah. These agents route concerns to the appropriate domain specialist or to the user — they do not block.

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
- **opus** (with `effort: high`): synod-marsh, synod-elend, synod-tensoon, synod-jasnah — high-stakes, review-only agents.
- **sonnet**: all others — implementation and coordination agents.

*Rationale:* opus agents are never write-enabled; their cost is justified by depth of critique. Revisit on model changes.

---

## Promotion path — rationale & worked examples
The permission ceiling for each stage is binding and lives in the core. The reasoning and examples:

- **PROBE before IMPLEMENT** exists so the agent can confirm its mental model (which files, which patterns, which tests exist) without yet risking a write. A PROBE that surfaces a surprise should send the plan back for revision, not roll forward into edits.
- **NARROW vs WIDE** is about blast radius, not effort. *Example:* adding a CLI flag with validation to one file and its test is NARROW. *Example:* renaming a function used across eight modules is WIDE — it crosses the ~10-file checkpoint and must pause for the user even mid-stream.
- **The ~10-file WIDE cap** is a circuit breaker: it forces a human checkpoint before a refactor's surface area grows past what one review can hold. Hitting the cap is not failure — it is the designed pause point.
- **Who-may-write** mirrors the structural `disallowedTools` enforcement: review-only agents stay read-only even under an IMPLEMENT promotion, unless the user names them explicitly (*"Elend may edit."*).

---

## SDD Workflow — agent responsibilities per stage
Synod Council agents operate within SDD sessions, not before them.

- **Before `/SDD-1-generate-spec`**: Sazed may suggest relevant agents review the request first if it touches security, architecture, or data — advisory, not mandatory.
- **During spec review**: Elend, Marsh, or TenSoon may be consulted to validate that the spec doesn't embed bad decisions before tasks are generated. Jasnah may review spec prose for clarity.
- **During `/SDD-3-manage-tasks`**: Vin, MeLaan, Marasi, Wax, Wayne handle implementation. Elend, Marsh, TenSoon, VenDell, Jasnah remain review-only unless promoted. VenDell verifies implementation references current library APIs; Jasnah reviews diffs before merge.
- **During `/SDD-4-validate-spec-implementation`**: Marsh and TenSoon are the natural reviewers for security and data gate checks. Steris validates the implementation matches the spec. Wax may be consulted if validation reveals regressions or unexplained failures.

### SDD conflict precedence
During any SDD stage, if an agent raises a concern that conflicts with the scope defined in the spec:
- **Security vetoes (Marsh) and data safety vetoes (TenSoon) override spec scope.** A spec cannot authorize an unsafe migration or an insecure pattern. The spec must be amended before implementation continues.
- **Documentation vetoes (Steris) override spec scope during `/SDD-4-validate-spec-implementation`.** If the implementation diverges from the spec, Steris may block sign-off until the spec or the implementation is reconciled.
- **Architecture vetoes (Elend) override spec scope during `/SDD-1-generate-spec` and `/SDD-2-generate-task-list-from-spec`.** A spec that embeds a structurally unsound design must be corrected before tasks are generated.
- In all cases, the veto-holding agent must state what must change and why. The spec is then updated and the SDD stage re-entered.

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
| synod-wayne | ux |
| synod-vendell | dependency / api-currency |
| synod-jasnah | reviewer |
