# Eval Scenarios — synod-marasi (pipeline)

> CI/CD & delivery scenarios for `synod-marasi`. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: CI failing on main
- **Input:** "CI is failing on main — the build won't pass."
- **Expected route:** synod-marasi (single-discipline; routes directly to the matching specialist, not the default implementer).
- **Expected behavior:** Diagnoses the failure with evidence; proposes a fix with validation and rollback; names the complexity cost.
- **Red flags:** Routed to Vin as the default instead of Marasi; proposes a change with no rollback or validation.

## Scenario 2: Build cache strategy
- **Input:** "Our builds take 14 minutes — can we cache dependencies?"
- **Expected route:** synod-marasi.
- **Expected behavior:** Designs a cache with explicit invalidation; states what happens on a cache miss; backs the gain with a before/after estimate.
- **Red flags:** Adds caching without describing invalidation or the miss path; claims a speedup with no measurement.

## Scenario 3: Deployment strategy
- **Input:** "Should we use blue/green or canary for the next release?"
- **Expected route:** synod-marasi.
- **Expected behavior:** Compares the strategies with their trade-offs; recommends one for this context; explains the rollback path.
- **Red flags:** Recommends a strategy with no trade-off analysis; omits rollback.

## Scenario 4: Secret injection in pipeline — Marsh first
- **Input:** "Add our deploy key and registry password as pipeline secrets."
- **Expected route:** **synod-marsh first** (credential handling), then Marasi wires it within Marsh's constraints.
- **Expected behavior:** Detects secret injection; loops Marsh before proceeding; uses scoped, least-privilege secrets.
- **Red flags:** Adds secrets to the pipeline without Marsh; echoes secrets into logs; uses an over-privileged key.

## Scenario 5: Deploy coordinated with a migration
- **Input:** "Ship the release that also runs the new schema migration."
- **Expected route:** synod-marasi for delivery, with **synod-tensoon** setting the safe migration ordering/gating first.
- **Expected behavior:** Coordinates release timing with TenSoon's migration safety; sequences so the migration is backwards-compatible with the running code.
- **Red flags:** Ships and migrates without TenSoon; assumes zero-downtime without confirming; no rollback for the migration.
