# Proof Artifacts — Task 4.0: Standardize agent Group B (build & delivery implementers)

> Spec: `02-spec-synod-council-evolution` · Task: **4.0** (single combined per-file pass over vin, melaan, marasi)
> One edit per file (description + body in the same sweep), per the locked "edit each agent file once" decision.

## Summary of changes

| File | Tier (preserved) | Changes |
|------|------------------|---------|
| `claude/agents/synod-vin.md` | sonnet / blue / **write-enabled** / no-veto | Denser proactive `description` (adds browser/e2e + Context7 cues); **folds applied** — browser/end-to-end testing scope paired with the `agent-browser` skill (Core Function) + Context7 API-currency verification "before the first proposal" (Core Function + new Operating Principle); added bidirectional `🤝 Coordination` (↔ Elend before structural, ↔ Marsh security-first, ↔ Jasnah review, ↔ VenDell/Context7, → TenSoon, → Wax, ← Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`. |
| `claude/agents/synod-melaan.md` | sonnet / green / **write-enabled** / no-veto | Denser proactive `description`; added `🤝 Coordination` (↔ Marasi CI-parity, → Marsh secrets, → Elend service structure, → Steris onboarding docs, ← VenDell, ← Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`. |
| `claude/agents/synod-marasi.md` | sonnet / cyan / **write-enabled** / no-veto | Denser proactive `description`; added `🤝 Coordination` (↔ MeLaan CI-parity, → Marsh secrets, → TenSoon migration timing, → Elend significant restructure, ← VenDell, ← Kelsier), `🔬 Self-Check`, `🎯 Confidence Levels`. |

**No `Not in scope:` line on any of the three** — that line is reserved for veto-bearing review agents (elend/marsh/tensoon/steris). These three are write-enabled implementers, so they correctly omit it. No charter edit required.

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
 claude/agents/synod-marasi.md | 44 ++++++++++++++++++++++++++++++++++--
 claude/agents/synod-melaan.md | 46 +++++++++++++++++++++++++++++++++++---
 claude/agents/synod-vin.md    | 52 +++++++++++++++++++++++++++++++++++++++----
 3 files changed, 133 insertions(+), 9 deletions(-)
```

## Invariant check (frontmatter preserved, write-enabled)

| Agent | model | color | `disallowedTools` (must be ABSENT) | veto | Coordination | Self-Check | Confidence | `Not in scope:` (must be ABSENT) |
|-------|-------|-------|-----------------------------------|------|--------------|------------|------------|----------------------------------|
| vin | sonnet | blue | absent ✓ | none | yes | yes | yes | absent ✓ |
| melaan | sonnet | green | absent ✓ | none | yes | yes | yes | absent ✓ |
| marasi | sonnet | cyan | absent ✓ | none | yes | yes | yes | absent ✓ |

All tiers, colors, and write-enabled status unchanged from pre-Task-4.0 state. No write-block was introduced (these agents must remain able to apply edits in IMPLEMENT stages).

## Vin folds (sub-task 4.1)

Both folds confirmed present in `claude/agents/synod-vin.md`:

1. **Browser/e2e** — Core Function: *"Test authorship and coverage — unit, integration, and **browser/end-to-end** (you pair with the `agent-browser` skill to drive real user flows and assert on what the user actually sees)."* Self-Check includes a browser/e2e line.
2. **Context7 API currency** — Core Function: *"Before you propose code that leans on a library, framework, or API, you **verify it against current documentation via Context7**…"* plus a new Operating Principle: *"Verify the API before you write against it. Check current docs (Context7) before the first proposal."* Self-Check includes an API-verification line. Coordination routes stale references to VenDell.

## Verification — fresh-session routing transcript (sub-task 4.4)

A subagent constrained to read **only** the installed lean core (`~/.claude/CLAUDE.md`) and the three Group B agent files (skimming sibling `description:` lines solely to judge routing) ran five checks. Three returned clean PASS. Two were returned as FAIL by the verifier; **both were cross-referenced against the charter text and determined to be verifier interpretation errors, not regressions in the edits.** They are recorded transparently below with the governing evidence.

| Check | Verifier verdict | Adjudicated result | Governing evidence |
|-------|------------------|--------------------|--------------------|
| **A — "CI failing on main" → Marasi alone** | FAIL | **PASS (verifier misread charter)** | Charter routing rule: *"**Single-discipline** tasks route directly to the one matching agent."* CI is a triggered specialist domain (Marasi), so it routes directly to Marasi. The verifier conflated this with the separate rule *"Default to synod-vin when **no specialist domain is triggered**" — but a specialist domain* is *triggered here. No edit defect; the routing intent holds.* |
| **B — "CLI flag with validation" → Vin** | PASS | **PASS** | synod-vin `description` lists "CLI flags"; single-discipline implementation → default implementer Vin. |
| **C — "devcontainer won't build" → MeLaan** | PASS | **PASS** | synod-melaan `description` triggers on "devcontainers" + "why doesn't this work on my machine"; single-discipline → MeLaan alone. |
| **D — Vin folds present (browser/e2e + Context7)** | PASS | **PASS** | synod-vin body pairs browser/e2e with `agent-browser` (Core Function) and states Context7 verification "before the first proposal" (Core Function + Operating Principle). |
| **E — Standardized sections; no veto blocks** | FAIL | **PASS (verifier self-contradicted)** | The verifier's own evidence reads *"Standardized sections present; no veto blocks. PASS."* — all three have Coordination/Self-Check/Confidence; none carry `disallowedTools`; none carry `Not in scope:`. Confirmed independently by the scripted invariant check above. The FAIL label contradicts the verifier's own finding. |

### Note on the verifier's Check-A reasoning

The verifier proposed that single-discipline CI tasks "must be explicitly added to the trigger list for Marasi routing." This is unnecessary: the charter already routes single-discipline tasks directly to their matching specialist, and Marasi's `description` carries the CI/CD trigger keywords. The behavior is correct as written. Recorded here so the reasoning is not lost — if a future eval (Task 6.0) shows real-world drift on single-discipline routing, this is the line to revisit. No change made now.

## Security & secrets check

No secrets, tokens, or credentials appear in any edited file or in this artifact. All inputs in the routing transcript are synthetic prompt strings. No security control was touched — Marsh-first ordering lives in the charter (unchanged), and Vin/MeLaan/Marasi each route security-sensitive work (auth, secrets, credential mounting, secret injection) to Marsh *first* via their Coordination maps, reinforcing the control rather than weakening it.

**Conclusion:** Group B (build & delivery implementers) is standardized — dense proactive descriptions, bidirectional Coordination, Self-Check, and Confidence Levels across all three; both Vin folds (browser/e2e + Context7) applied; every tier, color, and write-enabled status preserved with no write-block or `Not in scope:` line introduced. Fresh-session routing: 3 clean PASS + 2 verifier-flagged items adjudicated as verifier misreadings against the charter text (not edit defects).
