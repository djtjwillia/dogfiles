# Proof Artifacts — Task 5.0: Standardize agent Group C (ops & experience implementers)

> Spec: `02-spec-synod-council-evolution` · Task: **5.0** (single combined per-file pass over wax, wayne, steris)
> One edit per file (description + body in the same sweep), per the locked "edit each agent file once" decision.

## Summary of changes

| File | Tier (preserved) | Changes |
|------|------------------|---------|
| `claude/agents/synod-wax.md` | sonnet / orange / **write-enabled** / no-veto (advisory) | Denser proactive `description` (adds regressions, log/observability, performance, SEV/outage cues); **incident-response fold applied** — Core gains an incident-command line; Output Formats gains a live-**INCIDENT** template (SEV1/2/3 + Incident Commander + status lifecycle) and a blameless **POST-MORTEM** template alongside the existing INVESTIGATION REPORT; existing prose Coordination **upgraded to →/↔/← notation** and extended (↔ Vin, → Marsh security-incident, → TenSoon data-incident, → Marasi delivery-incident, → Wayne, → Steris, ← Kelsier); added `🔬 Self-Check`, `🎯 Confidence Levels`. Advisory-only authority preserved. |
| `claude/agents/synod-wayne.md` | sonnet / pink / **write-enabled** / no-veto | Denser proactive `description` (adds design systems, WCAG/keyboard/screen-reader); existing prose Coordination **upgraded to →/↔/← notation** and extended (↔ Vin, → Elend, → Marsh, → TenSoon, → Steris, → Wax, ← Kelsier); added `🔬 Self-Check`, `🎯 Confidence Levels`. |
| `claude/agents/synod-steris.md` | sonnet / yellow / **write-enabled** / **documentation-accuracy veto** | Denser proactive `description` (adds commit-message standards, release notes, runbooks; keeps veto sentence); **new** `🤝 Coordination` section (→ Elend, → Marsh, → TenSoon, → MeLaan, ← Wax, ← Wayne/Marasi/Vin, ← Kelsier); added `🔬 Self-Check`, `🎯 Confidence Levels`. **Veto Authority section and BOTH output formats (IMPLEMENTATION PLAN + DOCUMENTATION REVIEW/OUTPUT) preserved verbatim.** |

### Deliberate scope decision: no `Not in scope:` line in Group C

In Task 3.0, the `Not in scope:` output line was added only to the **review-only** veto agents (elend/marsh/tensoon). The Group C mandate (Task 5.x) asks only for Coordination / Self-Check / Confidence, plus preservation of Steris's veto and output structure — it does **not** direct adding a `Not in scope:` line. All three Group C agents are **write-enabled implementers**, matching Group B's treatment (no `Not in scope:` line). Steris holds a veto but is an implementer, not a review-only verdict agent; its accuracy boundary is already expressed in its Veto Authority section. Following the task mandate literally (smallest viable change), no `Not in scope:` line was added. Recorded here so the choice is on the record and trivially reversible if the user wants it.

## CLI Output — distribution

```
$ task tools:claude
[claude] Installed CLAUDE.md to /Users/taylor/.claude
[claude] Installed charter-details.md to /Users/taylor/.claude
[claude] Installed settings.json to /Users/taylor/.claude
[claude] Synced agents/ to /Users/taylor/.claude/agents/
[claude] Synced scheduled/ to /Users/taylor/Claude/Scheduled
```

All three files ride the existing `agents/` rsync — no Taskfile change needed. Installed copies confirmed byte-identical to repo source (`diff -q` clean for all three).

## Diffstat

```
 claude/agents/synod-steris.md | 47 ++++++++++++++++++++++---
 claude/agents/synod-wax.md    | 81 ++++++++++++++++++++++++++++++++++++++-----
 claude/agents/synod-wayne.md  | 44 +++++++++++++++++++----
 3 files changed, 152 insertions(+), 20 deletions(-)
```

## Invariant check (frontmatter + preservation)

| Agent | model | color | `disallowedTools` (must be ABSENT) | veto | Coordination | Self-Check | Confidence |
|-------|-------|-------|-----------------------------------|------|--------------|------------|------------|
| wax | sonnet | orange | absent ✓ | none (advisory) | yes | yes | yes |
| wayne | sonnet | pink | absent ✓ | none | yes | yes | yes |
| steris | sonnet | yellow | absent ✓ | **documentation accuracy (preserved)** | yes | yes | yes |

All tiers, colors, and write-enabled status unchanged. No write-block introduced (these agents must apply edits in IMPLEMENT stages).

**Steris veto + output-format preservation (scripted):**
```
veto section: present          (## ⚖️ Veto Authority)
veto language: present         ("veto on documentation accuracy")
both output formats: present   (IMPLEMENTATION PLAN + DOCUMENTATION REVIEW / OUTPUT)
```

**Wax incident-response fold (scripted):**
```
'INCIDENT': present
'POST-MORTEM': present
'Incident Commander': present
'Severity:': present
```

## Verification — fresh-session routing transcript (sub-task 5.4)

A subagent constrained to read **only** the installed lean core (`~/.claude/CLAUDE.md`) and the three Group C agent files (skimming sibling `description:` lines solely to judge routing) ran six checks. The verifier was briefed explicitly on the charter's single-discipline-direct routing rule (a single-discipline task routes directly to its matching specialist; "default to Vin" applies only when no specialist domain is triggered) to prevent the interpretation error seen in the Task 4.0 verification. **Result: PASS on all six.**

| Check | Result | Governing evidence |
|-------|--------|--------------------|
| **A — "prod is down, 500s everywhere" → Wax (incident mode)** | **PASS** | synod-wax `description` triggers on outage/SEV; body contains the live-INCIDENT format (SEV1/2/3 + Incident Commander + status lifecycle) and a POST-MORTEM template. |
| **B — "checkout UI flow is confusing" → Wayne** | **PASS** | synod-wayne `description` lists "why is this confusing" + user flows; single-discipline → Wayne. |
| **C — "write the README section" → Steris** | **PASS** | synod-steris `description` lists README/docs/"explain this"; single-discipline → Steris. |
| **D — Steris veto + dual formats intact** | **PASS** | Veto Authority section + veto language present; both IMPLEMENTATION PLAN and DOCUMENTATION REVIEW/OUTPUT formats retained. |
| **E — Standardized sections; write-enabled** | **PASS (all 3)** | Coordination (→/↔/←) + Self-Check + Confidence in all three; none carry `disallowedTools`. |
| **F — Wax remains advisory (no veto)** | **PASS** | synod-wax body: "You do not hold veto power. You investigate and report." Charter lists Wax under "No veto." |

## Security & secrets check

No secrets, tokens, or credentials appear in any edited file or in this artifact. All routing-transcript inputs are synthetic prompt strings. No security control was touched: Wax routes a discovered vulnerability or exposed credential **to Marsh first** ("a security incident is his before it is anyone else's"); Wayne routes auth/sensitive-data flows to Marsh; Steris routes credential-rotation contingencies to Marsh before writing them as procedure. The Marsh-first control is reinforced across all three Coordination maps.

**Conclusion:** Group C (ops & experience implementers) is standardized — dense proactive descriptions, bidirectional Coordination, Self-Check, and Confidence Levels across all three; the Wax incident-response fold (SEV / Incident Commander / post-mortem) applied; Steris's documentation-accuracy veto and both output formats preserved verbatim; every tier, color, and write-enabled status intact with no write-block introduced. Fresh-session routing PASS×6. **With Group C complete, all 11 existing agents (Groups A–C) plus the new synod-jasnah are standardized — the 12-agent roster is uniform ahead of the Task 6.0 eval harness.**
