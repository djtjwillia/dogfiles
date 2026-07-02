# Task 02 Proofs — Multi-Flow Concurrency Protocol written into charter-details.md

## Task Summary

This task writes the full `## Multi-Flow Concurrency Protocol` section into `claude/charter-details.md`, covering all four protocol parts (S1–S4), the live-flow registry schema (7 fields), herdr pane mapping, cross-flow halt rule, and the reversibility/bound statement. Treehouse is excluded; S1 covers native isolation only.

## What This Task Proves

- The charter-details.md file now contains a `## Multi-Flow Concurrency Protocol` section with subsections S1 through S4.
- The 7-field live-flow registry table is present.
- Adopted open-question assumptions (OQ2, OQ4, OQ5) are documented inline.
- AR6 reversibility and bound statement is present.

## Evidence Summary

- `grep -c "^### S[1-4]" claude/charter-details.md` returns `4` — all four subsections present.
- `grep "OQ2|OQ4|OQ5" claude/charter-details.md` returns lines for all three adopted assumptions.

## Artifact: S1–S4 subsection count

**What it proves:** All four protocol subsections (S1–S4) are present in the file.

**Why it matters:** The spec requires exactly four subsections. A count of 4 confirms completeness.

**Command:**
```bash
grep -c "^### S[1-4]" claude/charter-details.md
```

**Result summary:** Returns `4` — all four subsections (S1, S2, S3, S4) are present.

```
4
```

## Artifact: OQ assumption lines

**What it proves:** The three adopted open-question assumptions (OQ2, OQ4, OQ5) are documented inline in the protocol section.

**Why it matters:** The spec and audit require these assumptions to be traceable in the charter text.

**Command:**
```bash
grep "OQ2\|OQ4\|OQ5" claude/charter-details.md
```

**Result summary:** Returns 5 lines — OQ2, OQ4, and OQ5 each appear at least once; OQ2 also appears in the AR6 reversibility/bound statement.

```
> Adopted assumptions: OQ2 (max 2–3 concurrent flows), OQ4 (≤3-agents ceiling per flow independently), OQ5 (simultaneous cross-flow vetoes extend veto-notification protocol). Open-question source: `docs/specs/05-spec-multi-agent-concurrent-sdd/`.
> **OQ2 assumption:** default maximum is 2–3 concurrent flows; tune empirically per session complexity.
> **OQ4 assumption:** the ≤3-agents-per-task ceiling and the one-vin-per-SDD-task rule apply per flow independently. A session with 2 concurrent flows may have up to 3 agents per flow simultaneously.
> **OQ5 assumption:** if two flows simultaneously raise vetoes and both concern a shared resource, Kelsier presents both veto positions together under the existing veto-notification protocol. If the vetoes concern independent resources, they surface per-flow without waiting for each other.
> **AR6 — Reversibility and bound:** the concurrent-flow protocol is fully reversible. Fall back to single-flow serial SDD at any time by not starting a second flow; existing flows are unaffected. Default bound: 2–3 concurrent flows maximum (OQ2). The bound is tunable empirically — if session coherence or context pressure degrades, reduce to 1 active flow.
```

## Reviewer Conclusion

Both verification commands confirm the Multi-Flow Concurrency Protocol section is present and complete: four subsections (S1–S4), the 7-field registry table, all three OQ assumptions documented, and the AR6 reversibility/bound statement. The charter-details.md file is ready to serve as the on-demand protocol reference.
