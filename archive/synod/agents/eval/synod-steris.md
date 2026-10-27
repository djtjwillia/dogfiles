# Eval Scenarios — synod-steris (docs)

> Documentation & planning scenarios for `synod-steris`. Holds documentation-accuracy veto. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: README section
- **Input:** "Write the README section explaining how to configure the app."
- **Expected route:** synod-steris.
- **Expected behavior:** Clear, usable, explains the why; includes concrete verification steps; matches the actual configuration.
- **Red flags:** Documents options that do not exist; omits the why; produces prose no one would actually follow.

## Scenario 2: Architecture Decision Record
- **Input:** "Capture why we chose Postgres over DynamoDB as an ADR."
- **Expected route:** synod-steris (documents the decision), with synod-elend owning whether the decision itself is sound.
- **Expected behavior:** Records context, decision, alternatives, and consequences; defers soundness of the decision to Elend.
- **Red flags:** Re-litigates the architecture itself instead of recording it; ADR with no alternatives or consequences.

## Scenario 3: Plan with contingencies
- **Input:** "Plan the cutover from the old payment provider to the new one."
- **Expected route:** synod-steris.
- **Expected behavior:** Ordered steps with owners; at least one contingency/fallback; a risk register with pre-written mitigations; go/no-go gates and a rollback trigger.
- **Red flags:** A linear plan with no fallback path; risks listed without mitigations; no rollback trigger.

## Scenario 4: Documentation-accuracy veto at SDD-4
- **Input:** "The implementation drifted from the spec, but let's sign off anyway to hit the deadline."
- **Expected route:** synod-steris — exercises documentation-accuracy veto.
- **Expected behavior:** Blocks sign-off until spec and implementation are reconciled; notifies synod-kelsier the veto is raised.
- **Red flags:** Signs off on a known spec/implementation mismatch; raises the veto without notifying Kelsier.

## Scenario 5: PR description
- **Input:** "Write the PR description for this change."
- **Expected route:** synod-steris.
- **Expected behavior:** Explains what changed AND why; gives the reviewer context and verification steps.
- **Red flags:** Lists only what changed, not why; no verification guidance for the reviewer.
