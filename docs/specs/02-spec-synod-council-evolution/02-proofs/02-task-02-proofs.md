# Proof Artifacts — Task 2.0: Author `synod-jasnah` (the reviewer agent)

> Spec: `02-spec-synod-council-evolution` · Task: **2.0** (create the 12th agent — Jasnah Kholin, code-review, opus, review-only, advisory-not-veto)
> Created **before** Groups A–C (Tasks 3.0–5.0) so the existing agents' Coordination maps can reference Jasnah in their single per-file pass.

## Summary of changes

| File | Change |
|------|--------|
| `claude/agents/synod-jasnah.md` | **New** (9320 bytes). Jasnah Kholin persona; `model: opus`, `effort: high`, `disallowedTools: [Edit, Write]`, `color: purple`. Full enriched body: Core Function, Operating Principles, What You Never Do, **Coordination** (bidirectional), **Self-Check**, **Confidence Levels**, Escalation Triggers, Response Opening, Tone, Output Format ending in **`Not in scope:`**. |

No charter edit was required — the `synod-jasnah` row was already added to the core roles table in Task 1.0 (`Code review (PR/diff quality) | opus | No | No (advisory)`).

## Frontmatter (sub-task 2.1)

```yaml
name: synod-jasnah
description: >
  Code review agent for pull-request and diff quality. Use when the task involves
  reviewing a PR or diff before merge, code quality, readability, maintainability,
  test adequacy, naming, style and consistency, code smells, dead code, or
  "is this ready to merge?" questions. Renders firm review verdicts, but they are
  advisory — escalates architecture concerns to synod-elend and security concerns
  to synod-marsh. Review-only — does not write code.
model: opus
effort: high
disallowedTools:
  - Edit
  - Write
color: purple
```

### Color decision (sub-task 2.1)

The task called for a "distinct unused color." **All eight standard Claude Code agent colors are already in use:**

```
synod-elend    purple      synod-melaan   green
synod-kelsier  orange      synod-steris   yellow
synod-marasi   cyan        synod-tensoon  purple
synod-marsh    red         synod-vendell  cyan
synod-vin      blue        synod-wax      orange
synod-wayne    pink
```

A genuinely unused color is therefore unavailable. The palette already encodes a pattern of **shared colors by tier/role**: `purple` = the **opus review-only adjudicators** (Elend/architecture, TenSoon/data). Jasnah is the third agent of exactly that tier (opus, review-only, code quality), so she joins `purple` by design — and violet is Jasnah Kholin's canonical Elsecaller association. The choice is deliberate and documented, not a collision.

## CLI Output — distribution (sub-task implied by execution cadence)

```
$ task tools:claude
[claude] Installed CLAUDE.md to /Users/taylor/.claude
[claude] Installed charter-details.md to /Users/taylor/.claude
[claude] Installed settings.json to /Users/taylor/.claude
[claude] Synced agents/ to /Users/taylor/.claude/agents/
[claude] Synced scheduled/ to /Users/taylor/Claude/Scheduled

$ ls -la /Users/taylor/.claude/agents/synod-jasnah.md
-rw-r--r--@ 1 taylor staff 9320 Jun 12 16:07 /Users/taylor/.claude/agents/synod-jasnah.md
```

`synod-jasnah.md` rides the existing `agents/` rsync — no Taskfile change needed.

## Verification — fresh-session routing + behavior transcript (sub-task 2.6)

A subagent constrained to read **only** `~/.claude/CLAUDE.md` and `~/.claude/agents/synod-jasnah.md` (skimming sibling `description:` frontmatter solely to judge routing ambiguity) ran four checks. **Result: PASS on all four.**

| Check | Result | Governing quote |
|-------|--------|-----------------|
| **A — Routability** | **PASS** | Prompt `"review this diff for code quality before merge"` hits jasnah's exact triggers ("PR or diff before merge, code quality"). Elend's triggers ("architecture decisions, module boundaries") and Marsh's ("auth, tokens, secrets") are not touched — no collision. |
| **B — Advisory, not veto** | **PASS** | Body: *"Verdict (advisory): [SHIP / SHIP WITH NITS / REWORK]"* and *"The Verdict is advisory … not a gate."* Charter Vetoes section: *"the two advisory agents wax and jasnah — they investigate/review and report; they do not block."* |
| **C — Self-verification** | **PASS** | Headers present: `## 🔬 Self-Check (before every verdict)` and `## 🎯 Confidence Levels` defining HIGH/MEDIUM/LOW. |
| **D — Bidirectional coordination + Not-in-scope** | **PASS** | Outbound: `→ synod-elend (architecture)`, `→ synod-marsh (security)`, `→ synod-vin (implementation)`. Inbound: *"Sazed and synod-kelsier dispatch you … synod-vin requests your review … Elend and Marsh may defer line-level quality concerns to you."* Output Format ends: `Not in scope: …`. |

**Conclusion:** `synod-jasnah` is unambiguously routable for diff/quality review, is consistently **advisory (non-veto)** in both the agent body and the charter table, carries a Self-Check section and HIGH/MEDIUM/LOW confidence levels, and provides bidirectional coordination (outbound to elend/marsh/vin, inbound from Sazed/kelsier/vin/elend/marsh) with a terminating `Not in scope:` line. No secrets or credentials appear in the file or this artifact.
