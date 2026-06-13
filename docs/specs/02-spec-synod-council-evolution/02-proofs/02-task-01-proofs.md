# Proof Artifacts — Task 1.0: Charter restructure

> Spec: `02-spec-synod-council-evolution` · Task: **1.0** (charter lean-core/details split, conservative auto-routing, escape hatch, governance, alias map)
> Security gate: **synod-marsh** reviewed the partition before implementation (CONDITIONAL approval, HIGH confidence) — all four conditions encoded into sub-tasks 1.1/1.5/1.8 and satisfied in the rewrite.

## Summary of changes

| File | Change |
|------|--------|
| `claude/CLAUDE.md` | Charter section rewritten into **lean core**; 168 lines changed (66 insertions, 105 deletions) — net leaner. Persona (lines 1–190) preserved verbatim. |
| `claude/charter-details.md` | **New** — externalized adjudication detail, model rationale, SDD agent-responsibility matrix + conflict precedence, promotion rationale, **governance rules**, **documentation-only alias map**. |
| `Taskfile.yml` | `tools:claude` gains a `charter-details.md` install line in both the real branch and the `DRY_RUN` mirror (3 insertions). |

## CLI Output — distribution (sub-tasks 1.9, 1.10)

Dry-run confirms `charter-details.md` entered the sync plan:

```
$ task tools:claude DRY_RUN=true
[dry-run] Would mkdir -p /Users/taylor/.claude
[dry-run] Would install -m 0644 claude/CLAUDE.md /Users/taylor/.claude/CLAUDE.md
[dry-run] Would install -m 0644 claude/charter-details.md /Users/taylor/.claude/charter-details.md
[dry-run] Would install -m 0644 claude/settings.json /Users/taylor/.claude/settings.json
[dry-run] Would rsync --dry-run --delete-after claude/agents/ /Users/taylor/.claude/agents/
[dry-run] Would rsync claude/scheduled/ /Users/taylor/Claude/Scheduled/
```

Real sync reconciled the global copy to the repo source of truth:

```
$ task tools:claude
[claude] Installed CLAUDE.md to /Users/taylor/.claude
[claude] Installed charter-details.md to /Users/taylor/.claude
[claude] Installed settings.json to /Users/taylor/.claude
[claude] Synced agents/ to /Users/taylor/.claude/agents/
[claude] Synced scheduled/ to /Users/taylor/Claude/Scheduled

$ ls -la /Users/taylor/.claude/CLAUDE.md /Users/taylor/.claude/charter-details.md
-rw-r--r--@ 1 taylor staff  9696 Jun 12 15:01 /Users/taylor/.claude/charter-details.md
-rw-r--r--@ 1 taylor staff 18441 Jun 12 15:01 /Users/taylor/.claude/CLAUDE.md
```

## Diff highlights (sub-tasks 1.2–1.4)

- **Prime Directive + Routing** rewritten to **conservative auto-dispatch**: auto-dispatch only on *multi-discipline OR high-blast-radius (prod, auth, secrets, migrations)*; single-discipline routes direct; trivial handled solo.
- **Routing escape hatch** block added — documents the reversible **dial-up** ("auto-route on any single-discipline match") and dial-down, with the token-cost tradeoff stated in both directions.
- **Roles table** now lists all **12 agents** incl. `synod-jasnah` (Reviewer / opus / No write / No veto — advisory), with **Write** and **Veto** columns retained in core (Marsh condition 4).
- `charter-details.md` carries the conflict-resolution matrix, Elend/TenSoon boundary, veto-vs-veto, escalation chain, cascading-halt narrative, model rationale, SDD detail, promotion rationale, **governance rules** (sub-task 1.6), and **alias map** (sub-task 1.7).

## Security audit (sub-task 1.8) — Marsh's four conditions

| Condition | Result | Where it lives |
|-----------|--------|----------------|
| 1. Promotion-stage **permission scope** (stage names + per-stage ceiling + who-may-write) | ✅ in core | `CLAUDE.md` § Promotion path |
| 2. **Cascading-halt operative rule** (suspension behavior) | ✅ in core | `CLAUDE.md` § Cascading halt |
| 3. **Marsh-first** as an imperative directive (not just a table cell) | ✅ in core | `CLAUDE.md` § Routing (non-negotiable line) |
| 4. Roles table keeps **Write + Veto** columns | ✅ in core | `CLAUDE.md` § Council Roles |

`charter-details.md` opens with an explicit boundary: *"If this file and the core ever disagree on a control, the core wins."*

## Verification — fresh-session routing transcript (sub-task 1.11)

A subagent constrained to read **only** `/Users/taylor/.claude/CLAUDE.md` (NOT `charter-details.md`) was given two prompts. Result: **PASS on all four checks** — the lean core alone was sufficient.

| Check | Governing core quote | Result |
|-------|----------------------|--------|
| Prompt A: "rotate the auth token in production" → **Marsh before any implementer** | *"Marsh-first (security control — non-negotiable): … synod-marsh must be consulted before any implementer."* | **PASS** |
| Prompt B: "the app feels slow lately, not sure why" → **ambiguity escalation** | *"This requires your decision, Mistborn. Reason: [one sentence]." … It must not proceed or guess.* | **PASS** |
| Max agents per task | *"Ceiling: at most 3 agents per task."* | **PASS** |
| Promotion-phrase write scopes | NARROW = *"small, localized edits in the specific files discussed"*; WIDE = *"Max ~10 files per session; checkpoint with the user"* | **PASS** |

**Conclusion:** the externalization dropped no load-bearing control. Every control whose trigger is needed for these scenarios kept its constraint in the loaded core, satisfying the core's own guard rail and Marsh's conditions. No secrets or credentials appear in any artifact — the test prompt "auth token" is synthetic.
