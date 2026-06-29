# Task 4 Proofs — removal path documented, proof transcript finalized

## Task Summary
Task 4.0 completes the herdr adoption spec by documenting the full removal path and producing the consolidated verification transcript. The `04-proofs/` directory was already present from tasks 1.0 and 2.0. `removal-path.md` records the eight-step reversal sequence. `verification-transcript.md` maps the evidence from tasks 1–3 to each of the five spec success criteria, giving a reviewer a single artifact covering the full adoption.

## What This Task Proves
- `docs/specs/04-spec-herdr-adoption/04-proofs/` directory exists and contains all proof artifacts
- `removal-path.md` documents all eight removal steps covering every artifact added during adoption (Brewfile, Taskfile vars and task, init wiring, config source, CLAUDE.md row, machine-side directory)
- `verification-transcript.md` covers all five spec success criteria with evidence references
- All four sub-tasks (4.1–4.3, including the proof file itself) are complete

## Evidence Summary
Both proof documents were created from the recorded results of tasks 1–3. The removal path is concrete and reversible — each step maps to a specific artifact added during adoption. The verification transcript draws evidence from the four individual proof files and presents it against the five criteria that define adoption success in the spec.

## Artifact: removal-path.md

**What it proves:** Adoption is cleanly reversible with no residual state.
**Why it matters:** Spec criterion 4 (reversibility) is satisfied only if the removal steps are complete, explicit, and verifiable. The document covers binary, config, Taskfile, Brewfile, repo source, CLAUDE.md, and machine-side directory.
**File:** `docs/specs/04-spec-herdr-adoption/04-proofs/removal-path.md`
**Steps covered:** 8 (binary uninstall, Taskfile vars, Taskfile task, init wiring, repo source dir, CLAUDE.md row, machine-side rm -rf, final dry-run verification)

## Artifact: verification-transcript.md

**What it proves:** All five spec success criteria are met.
**Why it matters:** This is AR7 from the spec — the consolidated proof that adoption succeeded across every required dimension. A reviewer reads one file to confirm the full picture.
**File:** `docs/specs/04-spec-herdr-adoption/04-proofs/verification-transcript.md`
**Criteria covered:**
1. No regression in plain iTerm windows — PASS
2. Full zsh environment in herdr panes — PASS
3. Canonical adoption via task + Brewfile — PASS
4. Reversibility documented — PASS
5. Security read clear (Marsh gate 2) — PASS (conditional approval 2026-06-29)

## Reviewer Conclusion
Task 4.0 is complete. All four sub-tasks are marked done. The `04-proofs/` directory contains five files covering the full adoption lifecycle: task 1 wiring proof, task 2 config proof, task 3 environment verification, removal path, and consolidated verification transcript. The herdr adoption spec is closed.
