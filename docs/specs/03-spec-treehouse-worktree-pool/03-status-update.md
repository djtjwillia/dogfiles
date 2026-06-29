# 03-status-update.md — Treehouse Worktree Pool

> **Status addendum to `03-spec-treehouse-worktree-pool.md`.** This does not modify or regenerate the spec. It records a decision, proposes the gating first task, and flags the verification owed before a full task list.

## 1. Decision: proceed toward the go/no-go gate

The user has decided to **pick up the Treehouse experiment**. The spec is and remains **PROPOSED**. This decision does **not** authorize adoption and does **not** clear the §9 go/no-go gate — it authorizes the work needed to *reach* the gate empirically.

Per the spec (§9), the gate requires a recorded benchmark meeting a user-agreed threshold, plus viable mitigations for R1, R2, and R4, **before** any move to `/SDD-2-generate-task-list-from-spec`. The path forward is therefore **benchmark-first**: produce the measurement that the gate consumes, then let the user make the GO/NO-GO call on data.

## 2. Proposed benchmark-first task (the gate-clearing task)

This is proposed as **the first and only SDD task authorized now** — a measurement task, not an adoption task. It maps directly to Adoption Requirement **AR7** and Success Criterion **1**, and it is designed to produce the artifact §9 requires.

```
TASK 0 — Benchmark: Treehouse-leased worktrees vs. Claude Code native isolation
Objective: Produce a recorded, repeatable wall-clock comparison of parallel-agent
           cold-start cost on THIS repo, so the §9 gate can be cleared on data.
Owner: synod-vin (execution) — measurement harness only; NO adoption changes.
Preconditions:
  - vendell Gate (§3 below) cleared: Treehouse's actual lease/cleanup CLI surface confirmed.
  - A throwaway, version-pinned Treehouse binary available in a scratch location
    (NOT yet wired into task init or task tools:* — this is measurement, not adoption).
Method:
  1. Define the workload: N parallel agent "tasks" that each (a) acquire an isolated
     worktree, (b) run this repo's actual per-worktree setup, (c) make a trivial edit,
     (d) tear down. N and the setup steps chosen to mirror real parallel fan-out.
  2. Arm A — Claude Code native: run the workload with Agent `isolation: "worktree"`.
  3. Arm B — Treehouse pool: pre-warm a pool (`treehouse get --lease` / `treehouse return`),
     run the same workload leasing from it.
  4. Measure wall-clock cold-start + total per arm, repeated runs, report median + spread.
  5. Probe R1 (detached HEAD on lease) and R2 (lease survival on simulated crash) as
     part of the harness — these are gate inputs, not just timing.
Output:
  - docs/specs/03-spec-treehouse-worktree-pool/03-proofs/benchmark.md
    (methodology, raw numbers, median/spread, R1/R2 observations).
Explicitly NOT in this task:
  - No `task tools:treehouse` target. No `treehouse.toml` checked in. No agent-workflow
    change. No `task init` wiring. Adoption is a SEPARATE, later authorization.
Contingencies:
  - If Treehouse will not run on this repo at all → record the blocker, NO-GO, stop.
  - If R1 (detached HEAD) cannot be forced to a named branch on lease → flag to user;
    this is a gate-blocking finding, not a benchmark footnote.
  - If R2 (crashed-agent lease) cannot be reliably reclaimed → flag to user; per §11
    this alone is a NO-GO condition.
Go/No-Go gate (decided by USER on this artifact):
  - GO: benchmark shows a meaningful, repeatable speedup at the user-agreed threshold,
    AND R1/R2/R4 have viable mitigations.
  - NO-GO: negligible speedup, OR R2 crash-reclamation unreliable, OR R4 layering
    unresolved. Nothing is adopted.
Rollback: trivial — the benchmark touches only a scratch binary and a proofs file;
          delete both. No managed config is altered.
```

**Threshold note:** Success Criterion 1 deliberately leaves the speedup magnitude "to be set with the user at the gate." That threshold must be agreed **before** the benchmark is read as GO/NO-GO, so the bar is not retrofitted to the result. Recommend setting it at task kickoff.

## 3. Verification owed BEFORE the full task list (vendell gate)

Open Question **Q5** is a hard pre-task-generation gate, not a nice-to-have:

> **Q5 — stale-lease detection mechanism.** What does Treehouse *actually* expose for detecting and reclaiming a stale lease (TTL? heartbeat? manual reap only?), and is it sufficient for **unattended** agent runs?

This is a **synod-vendell verification item** against current upstream Treehouse docs/source. It gates the R2 mitigation (lease cleanup on crash) and AR4 (documented cleanup strategy). The benchmark's R2 probe (Task 0, step 5) depends on knowing what reclamation primitive even exists. **vendell must confirm Treehouse's real lease/cleanup CLI surface before the benchmark harness is designed**, because the harness has to exercise whatever mechanism actually exists — not the TTL/heartbeat this spec speculates about in R2.

Adjacent vendell confirmations owed at the same time (cheap to bundle):
- Treehouse's actual `get --lease` / `return` CLI flags and detached-HEAD-on-lease behavior (R1, AR3).
- Whether Treehouse and Claude Code native isolation can be made non-overlapping (R4, AR5) — confirm one can be cleanly disabled when the other is in use.

## 4. Marsh note (unchanged, light)

Per spec §11, marsh's read stays **light**: Treehouse takes no API keys and runs no daemon. The one thing to confirm at task time is that no credential handling enters via the `treehouse.toml` setup hooks. No change to that posture here.

## 5. Status after this addendum

- Spec: **PROPOSED** (unchanged).
- Authorized now: **Task 0 (benchmark) only**, and only after the §3 vendell gate clears.
- Blocked until gate clears + benchmark recorded: `/SDD-2-generate-task-list-from-spec`, and all of AR1–AR6 (adoption).
- Decision owner at the gate: **the user**, on the `03-proofs/benchmark.md` artifact.

---

**Confidence: HIGH on process, MEDIUM on Treehouse specifics.** The decision-record and benchmark-first structure are sound and match the spec's own §9 gate. The Treehouse CLI/lease specifics (Q5, R1, R2, R4) remain unconfirmed against upstream — that is exactly the vendell gate above, and I flag it rather than paper over it.
