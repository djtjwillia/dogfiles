# Proof Artifacts — Task 3.0: Standardize agent Group A (router & review-only agents)

> Spec: `02-spec-synod-council-evolution` · Task: **3.0** (single combined per-file pass over kelsier, elend, marsh, tensoon, vendell)
> One edit per file (description + body in the same sweep), per the locked "edit each agent file once" decision.

## Summary of changes

| File | Tier (preserved) | Changes |
|------|------------------|---------|
| `claude/agents/synod-kelsier.md` | sonnet / no-veto | Denser proactive `description`; prose decision-tree **promoted to a keyword→agent table** (with the new `synod-jasnah` row); added `🤝 Coordination` (bidirectional), `🔬 Self-Check`, `🎯 Confidence Levels`. |
| `claude/agents/synod-elend.md` | opus / architecture+data-model-design veto | Denser `description`; added `🤝 Coordination` (↔ Vin, ↔ TenSoon, ↔ Jasnah, → Marsh, ← Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`; `Not in scope:` line in Output Format. |
| `claude/agents/synod-marsh.md` | opus / security veto | Denser `description` (keeps auth/secrets/CVE keywords); added `🤝 Coordination` (→ implementers consulted **first**, ↔ Jasnah, ↔ Elend, ← VenDell/Wax/Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`; `Not in scope:` line. **Marsh-first ordering + security veto preserved verbatim.** |
| `claude/agents/synod-tensoon.md` | opus / data-safety veto | Denser `description`; Coordination map extended (↔ Elend boundary, → Vin, → Marsh, → Marasi, ← VenDell/Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`; `Not in scope:` line. |
| `claude/agents/synod-vendell.md` | sonnet / no-veto | Denser `description` (keeps Context7 cue); added `🔬 Self-Check`, `🎯 Confidence Levels`; existing rich Coordination map + inbound dispatch line. No `Not in scope:` line (no veto / not a verdict-output review agent). |

No charter edit required — the 12-agent roster and veto columns were set in Task 1.0.

## CLI Output — distribution

```
$ task tools:claude
[claude] Installed CLAUDE.md to /Users/taylor/.claude
[claude] Installed charter-details.md to /Users/taylor/.claude
[claude] Installed settings.json to /Users/taylor/.claude
[claude] Synced agents/ to /Users/taylor/.claude/agents/
[claude] Synced scheduled/ to /Users/taylor/Claude/Scheduled
```

All five files ride the existing `agents/` rsync — no Taskfile change needed. Installed copies confirmed byte-identical to repo source (`diff -q` clean for all five).

## Diffstat

```
 claude/agents/synod-elend.md   | 47 +++++++++++++++++++--
 claude/agents/synod-kelsier.md | 93 ++++++++++++++++++++++++++----------------
 claude/agents/synod-marsh.md   | 47 +++++++++++++++++++--
 claude/agents/synod-tensoon.md | 45 +++++++++++++++++---
 claude/agents/synod-vendell.md | 35 ++++++++++++++--
 5 files changed, 214 insertions(+), 53 deletions(-)
```

## Invariant check (frontmatter preserved)

| Agent | model | color | `disallowedTools: [Edit, Write]` | veto |
|-------|-------|-------|----------------------------------|------|
| kelsier | sonnet | orange | yes | none |
| elend | opus | purple | yes | architecture + data-model design |
| marsh | opus | red | yes | security |
| tensoon | opus | purple | yes | data safety |
| vendell | sonnet | cyan | yes | none |

All tiers, colors, write-blocks, and veto status unchanged from pre-Task-3.0 state.

## Ported keyword→agent decision table (synod-kelsier)

The prose "Routing Decision Tree" was promoted to a markdown table scanned top-to-bottom (multi-match → multi-agent, up to the ceiling of 3). All 11 routable specialists are rows, including the new reviewer:

```
| PR review, diff review, code quality, readability, maintainability,
  "is this ready to merge", code smells | synod-jasnah |
  Advisory — escalates architecture to Elend, security to Marsh |
```

The security row is annotated **"Always — and first, before any implementer is proposed"**, and the `synod-vin` row is annotated **"Default when no specialist domain is triggered."**

## Verification — fresh-session routing transcript (sub-task 3.6)

A subagent constrained to read **only** the installed lean core (`~/.claude/CLAUDE.md`) and the five Group A agent files (skimming sibling `description:` lines solely to judge routing ambiguity) ran five checks. **Result: PASS on all five.**

| Check | Result | Governing evidence |
|-------|--------|--------------------|
| **A — Security routes Marsh-first** | **PASS** | Prompt `"rotate the auth token and update the secret in vault"` → charter "synod-marsh must be consulted before any implementer"; Kelsier table security row "Always — and first"; Marsh body "consulted **before** they build … Marsh-first … non-negotiable." |
| **B — Ambiguous multi-discipline → Kelsier** | **PASS** | `"redesign how the service talks to the database and ship it through CI"` → charter "if the routing itself is ambiguous, route through synod-kelsier"; ceiling-of-3; table yields a sane `elend → tensoon → marasi` crew with elend-before-vin honored. |
| **C — Keyword→agent table incl. jasnah** | **PASS** | Kelsier contains an explicit markdown table (not prose) with the quoted `synod-jasnah` code-review row. |
| **D — Standardized body sections** | **PASS (all 5)** | Self-Check + Confidence Levels + bidirectional Coordination present in kelsier, elend, marsh, tensoon, vendell. |
| **E — `Not in scope:` + veto preservation** | **PASS** | elend/marsh/tensoon each end Output Format with `Not in scope:`; vetoes intact (architecture/data-model, security, data-safety); kelsier & vendell confirmed **no veto**. |

### Accepted stylistic variance (no failure)

The verifier noted VenDell's `🤝 Coordination` uses partner-by-partner prose rather than the `→/↔/←` arrow notation adopted by the other four. It is functionally bidirectional (it names both what VenDell surfaces and what each partner decides) and was the file's pre-existing established form. Accepted as documented variance rather than introduce churn; flagged here for the record.

## Security & secrets check

No secrets, tokens, or credentials appear in any edited file or in this artifact. The Marsh-first security control and the security veto were preserved verbatim and re-verified (Check A). All inputs in this proof are synthetic prompt strings.

**Conclusion:** Group A (router + review-only agents) is standardized — dense proactive descriptions, bidirectional Coordination, Self-Check, and Confidence Levels across all five; `Not in scope:` on the three veto-review agents; the keyword→agent table ported into Kelsier with the `synod-jasnah` row; and every tier, color, write-block, and veto preserved. Fresh-session routing PASS×5.
