# 03-spec-treehouse-worktree-pool.md

> **Status: PROPOSED — not yet started.** This is an experiment spec. It records a candidate adoption for evaluation; no implementation is authorized by this document. A go/no-go decision (see §9) gates any move to `/SDD-2-generate-task-list-from-spec`.

## Introduction/Overview

[Treehouse](https://github.com/kunchenguid/treehouse) is a **Git worktree pool manager**. It pre-warms a pool of isolated Git worktrees and leases them on demand (`treehouse get --lease`) so that parallel agents do not each pay the cold-start cost of creating a worktree, checking out a branch, and running environment setup (npm install, venv creation, etc.). When an agent finishes, it returns the worktree to the pool (`treehouse return`). It is a single Go binary with no daemon and no API keys; behavior is configured through an optional `treehouse.toml`.

This dotfiles repo already drives parallel agent work, and Claude Code offers native worktree isolation via `isolation: "worktree"` on Agent tool calls. The question this spec exists to answer is narrow and concrete: **does pre-warming a worktree pool with Treehouse provide a measurable enough speedup over Claude Code's native per-call worktree creation to justify adding a new tool to the bootstrap and the agent workflow?**

**What Treehouse is NOT — and what this spec explicitly does not touch:** Treehouse is *not* an orchestration layer. It answers "**where** does the agent do its work" (an isolated, pre-warmed worktree), not "**which** agent, in **what** order, under whose mandate." That second question is owned by the Synod Council routing design (Sazed, synod-kelsier, the charter). **Adopting or rejecting Treehouse does not affect Kelsier or any routing decision.** This spec must not be read as touching the roster/routing ADR work tracked separately.

## Problem Statement

When multiple agents run in parallel against this repo, each isolated worktree currently incurs a cold start:

1. Create the worktree and check out a branch.
2. Run environment setup that does not persist between worktrees (dependency install, virtualenv, tool bootstrap).
3. Tear down on completion.

For small, fast tasks this overhead can dominate the useful work. The repeated setup cost is paid per agent, per task, with no reuse. There is no warm pool: every worktree is built from cold and discarded.

The cost of *not* solving this is bounded — it is latency, not correctness. That bound is important context for the go/no-go gate: this is an optimization, not a fix.

## Proposed Solution

Evaluate Treehouse as a managed, pre-warmed worktree pool that the agent workflow leases from instead of creating worktrees cold:

- A background-warmed pool of worktrees is maintained, each already on a clean branch with environment-setup hooks (npm install, venv, etc.) pre-run.
- An agent acquires one with `treehouse get --lease`, does its work in isolation, and releases it with `treehouse return`.
- Configuration lives in an optional `treehouse.toml` checked into the repo, defining pool size and setup hooks.
- Treehouse is installed as a single Go binary via the existing Taskfile bootstrap (a new `task tools:treehouse` target, consistent with the repo's canonical-source / task-target model).

This is proposed as an **enhancement to or replacement of** Claude Code's native `isolation: "worktree"` for the parallel-agent path — **not** as a new orchestration mechanism.

## Goals

- **Measure first:** benchmark Treehouse-leased worktrees against Claude Code native worktree isolation for this repo's actual size and setup cost, before any commitment.
- **Minimal adoption surface:** if adopted, install via one Taskfile target and one optional `treehouse.toml`; no API keys, no daemon, no new service.
- **Reversibility:** adoption must be cleanly removable (remove the task target, the `treehouse.toml`, and revert the agent workflow to native isolation) with no residual state.
- **Safety of leases:** a defined cleanup strategy so a crashed or abandoned agent does not permanently hold a lease or leave a dirty worktree.

## Non-Goals

- **Orchestration / routing.** Treehouse does not decide which agent runs or in what order. This spec does not modify Sazed, synod-kelsier, the charter, or any routing logic.
- **Result handoff between agents.** Treehouse does not move work products between worktrees. Any result-passing remains the responsibility of the existing agent/report mechanism.
- **Replacing Git.** Worktrees remain ordinary Git worktrees; nothing here changes the repo's branching model.
- **Multi-machine pooling.** Single-machine, local pool only for this experiment.

## Adoption Requirements

If the go/no-go gate clears, adoption requires:

| ID | Requirement |
| --- | --- |
| AR1 | Install Treehouse (single Go binary) via a new idempotent `task tools:treehouse` target, honoring the repo's existing `DRY_RUN` and dry-run conventions. |
| AR2 | Provide a checked-in `treehouse.toml` defining pool size and environment-setup hooks (the per-worktree warm-up commands). |
| AR3 | The agent workflow must **checkout a branch on acquisition** — never operate on the detached HEAD that a fresh worktree lease presents (see Risk R1). |
| AR4 | Define and document a **lease-cleanup strategy** for crashed/abandoned agents: how stale leases are detected and reclaimed, and how dirty worktrees are reset before re-pooling (see Risk R2). |
| AR5 | Resolve the **layering decision** with Claude Code's native `isolation: "worktree"`: Treehouse-leased worktrees and Claude Code's own isolation must not both wrap the same agent call (see Risk R4). Document the chosen single layer. |
| AR6 | Document the full removal path (revert AR1–AR5) so the experiment is cleanly reversible. |
| AR7 | Benchmark methodology and results recorded in `docs/specs/03-spec-treehouse-worktree-pool/03-proofs/` before adoption is declared. |

## Risks

| ID | Risk | Likelihood | Impact | Mitigation (pre-written) |
| --- | --- | --- | --- | --- |
| R1 | **Detached HEAD on acquisition.** A freshly leased worktree may present a detached HEAD; an agent committing there loses work to no branch. | H | H | AR3: workflow forces `git checkout -b`/`switch` to a named branch immediately on lease, before any write. Verify in benchmark harness. |
| R2 | **Leases do not auto-clear on agent failure.** A crashed agent holds its lease; the pool drains and starves later agents. | M | H | AR4: cleanup strategy — TTL/heartbeat-based stale-lease reclamation, plus a `treehouse return`-equivalent in agent teardown/trap. Dirty worktrees reset (`git reset --hard && git clean -fd`) before re-pooling. |
| R3 | **No built-in result handoff.** Treehouse moves no work products between worktrees; a naive integration could lose output. | M | M | Non-Goal: handoff stays with the existing agent/report mechanism. Document that the leased worktree is a workspace, not a delivery channel. |
| R4 | **Layering conflict with Claude Code native worktree isolation.** Treehouse pool + Claude Code `isolation: "worktree"` could double-wrap, producing nested or competing worktrees. | M | H | AR5: pick exactly one isolation layer per agent call and document it. Benchmark both layers independently; never stack them. |
| R5 | **Warm-up benefit not meaningful at this repo's size.** The pre-warm payoff may be negligible if setup cost is already low. | M | M | This is the central open question (§10). The benchmark (AR7) is the gate; if no meaningful speedup, the answer is NO-GO and nothing is adopted. |
| R6 | **New bootstrap dependency drift.** A new binary in `task init` is one more thing to keep current and reproducible across machines. | L | M | Single binary, version-pinned in the task target; reversible per AR6. Route currency concerns to synod-vendell. |

## Success Criteria

The experiment **succeeds** (clears go/no-go for adoption) only if **all** hold:

1. **Measured speedup:** benchmark (AR7) shows a meaningful, repeatable wall-clock reduction in parallel-agent cold-start versus Claude Code native isolation for this repo — magnitude threshold to be set with the user at the gate, not assumed here.
2. **Lease safety proven:** a simulated agent crash is shown to reclaim its lease and re-pool a clean worktree (R1, R2 mitigations verified).
3. **No layering conflict:** the single-isolation-layer decision (AR5) is documented and demonstrated conflict-free.
4. **Clean reversibility:** the full removal path (AR6) is demonstrated to leave no residual state.

The experiment **fails** (NO-GO, nothing adopted) if the benchmark shows no meaningful speedup (R5), or if lease safety cannot be made reliable for the crash case (R2).

## Go / No-Go Gate

Before any move to `/SDD-2-generate-task-list-from-spec`:

- **GO** requires: a recorded benchmark meeting the §11.1 threshold agreed with the user, AND a viable mitigation for R1, R2, and R4.
- **NO-GO** if: benchmark shows negligible benefit, OR lease cleanup for the crash case remains unreliable, OR the layering conflict (R4) cannot be cleanly resolved.
- The benchmark and the decision are recorded in `03-proofs/`. The decision is the user's.

## Open Questions

1. **Is the warm-up benefit meaningful for this repo's size?** This is the gating question. It requires benchmarking before any commitment — no adoption is justified on assumption (R5, Success Criterion 1).
2. What pool size is appropriate for the typical parallel-agent fan-out on a single developer machine?
3. Which environment-setup hooks actually cost enough to be worth pre-warming for *this* repo (which is dotfiles-centric, not a heavy dependency tree)?
4. Should Treehouse replace Claude Code native isolation entirely, or wrap only the specific high-fan-out parallel paths? (Feeds AR5.)
5. What is the precise stale-lease detection mechanism Treehouse exposes (TTL, heartbeat, manual reap), and is it sufficient for unattended agent runs? (Feeds AR4 — verify against Treehouse's actual capabilities at task-generation time.)

## Escalation / Routing Notes

- **synod-vendell** — verify Treehouse's actual CLI surface, configuration options, and lease/cleanup capabilities against current upstream documentation before task generation. Several open questions (Q5) and risk mitigations (R2, R4) depend on confirming what the tool actually does today, not what this summary asserts.
- **synod-melaan** — owns the `task tools:treehouse` bootstrap target and the `treehouse.toml` setup hooks (developer-experience / local-environment scope).
- **synod-marsh** — light consult: Treehouse takes no API keys and runs no daemon, so the security surface is low, but confirm no credential handling enters via setup hooks.

---

**Next step:** This spec remains **PROPOSED**. Do not generate a task list until the §9 go/no-go gate clears with a recorded benchmark. When it does, proceed to `/SDD-2-generate-task-list-from-spec` against this file.
