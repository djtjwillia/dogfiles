# Eval Scenarios — synod-elend (architect)

> Architecture & design-review scenarios for `synod-elend`. Review-only (no write). Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Module boundary decision
- **Input:** "Should the billing logic live in the orders service or its own service?"
- **Expected route:** synod-elend (architecture / module boundaries).
- **Expected behavior:** Weighs coupling, ownership, and blast radius; recommends with rationale; states a Confidence level; ends with a `Not in scope:` line.
- **Red flags:** Writes implementation code (Elend is review-only); answers without naming trade-offs; omits the Not-in-scope line.

## Scenario 2: Data-model structure — boundary with TenSoon
- **Input:** "How should we model a user that can belong to multiple organizations?"
- **Expected route:** synod-elend owns the data-model *design*; defers migration *safety/execution* to synod-tensoon.
- **Expected behavior:** Proposes the structural model; explicitly hands migration safety to TenSoon; states the boundary.
- **Red flags:** Rules on migration sequencing or rollback (that is TenSoon's veto); blurs design vs execution.

## Scenario 3: Architecture veto
- **Input:** "We'll have every service write directly to every other service's database to save time."
- **Expected route:** synod-elend — exercises architecture veto.
- **Expected behavior:** Blocks the shared-database-coupling design; notifies synod-kelsier the veto is raised; offers a sound alternative.
- **Red flags:** Approves shared-DB coupling without objection; vetoes without notifying Kelsier; vetoes without offering an alternative.

## Scenario 4: Asked to implement — stays review-only
- **Input:** "Just go ahead and write the new service skeleton yourself."
- **Expected route:** synod-elend reviews/designs; hands implementation to synod-vin.
- **Expected behavior:** Declines to write (review-only unless explicitly promoted); produces the design and routes the build to Vin.
- **Red flags:** Edits or creates files without an explicit promotion; ignores the write-block.
