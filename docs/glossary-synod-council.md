# Synod Council — Glossary

Crisp definitions for the terms a newcomer to the charter needs. For the controls themselves, see `claude/CLAUDE.md` (lean core) and `claude/charter-details.md` (details).

**Lean core** — `claude/CLAUDE.md`, synced to `~/.claude/CLAUDE.md` and loaded into every Claude Code session at start. It holds only the controls that must be in context to *fire* — the Sazed persona plus the always-on Synod Council controls. Its cost is paid on every turn, so it is kept as small as the firing controls allow.

**charter-details** — `claude/charter-details.md`, the on-demand companion to the lean core. It holds adjudication detail, rationale, governance rules, and reference maps (the full roles table, worked examples, the conflict matrix). It is loaded only when a conflict is actively being worked or full reasoning is needed, and it pays no session-start cost. On any disagreement about a control, **the lean core wins** — details explains and extends, never overrides.

**Control (trigger vs. constraint)** — a charter rule has two halves: the **trigger** (the condition that makes it fire — e.g. "security is in scope") and the **constraint** (what it then requires — e.g. "consult Marsh first"). The governing rule: never move a constraint to details while leaving its trigger in the core, because a control whose constraint is not loaded cannot actually fire.

**Veto** — blocking authority held by exactly four agents in their domains: synod-elend (architecture & data-model structure), synod-marsh (security), synod-tensoon (data safety), synod-steris (documentation accuracy). A veto can halt sign-off or implementation until the concern is resolved. Distinct from **advisory** agents (synod-wax, synod-jasnah), who report firmly but cannot block, and **non-blocking** agents, who route concerns rather than stopping work.

**Marsh-first** — a non-negotiable security control: whenever security is in scope (auth, tokens, secrets, OIDC/OAuth/SSO, credentials, encryption, CVEs, supply chain), synod-marsh must be consulted **before any implementer** touches the work. Security review gates implementation, not the reverse.

**Elend-before-Vin** — the architecture analogue of Marsh-first: on structural or architecture decisions, synod-elend is consulted before synod-vin implements. Design soundness is judged before code is written.

**Promotion stage (PLAN / PROBE / NARROW / WIDE)** — the four-level permission ceiling that governs how much an agent may write. **PLAN** (default): propose only, no edits. **PROBE** (*"You may probe."*): read-only inspection, no edits. **NARROW** (*"You may implement."*): small, localized edits in the discussed files. **WIDE** (*"Proceed with wide changes."*): cross-module refactors, capped at ~10 files per session with a user checkpoint. A promotion is granted by the user (explicitly or implicitly) and, once granted, applies session-wide.

**Cascading halt** — the safety rule that when any specialist surfaces a halt to the user (a veto, escalation, or unacceptable-risk finding), synod-kelsier is notified and every specialist declared as a dependent in the current routing plan is suspended — they do not continue and do not independently surface to the user until the user resumes and Kelsier re-routes. Prevents an agent from building on a decision the user has not yet made.

**`sdd` skill (phase model)** — the Spec-Driven Development workflow, delivered as a single user-invoked skill (`~/.claude/skills/sdd/`) that self-detects its lifecycle phase from workspace state (via a bundled assessor script) and loads the one matching phase reference. **Phase 1 — Spec Generation** (no complete spec yet), **Phase 2 — Task List + Audit** (spec complete, no task list / no passing audit), **Phase 3 — Implementation** (spec + tasks + passing audit, open tasks remain), **Phase 4 — Validation** (implementation looks complete, needs pass/fail sign-off). It replaced the retired `/SDD-1..4` slash commands; users continue the workflow in natural language, not by naming phase commands.
