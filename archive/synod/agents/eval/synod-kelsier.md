# Eval Scenarios — synod-kelsier (router)

> Routing & orchestration scenarios for `synod-kelsier`. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Ambiguous multi-discipline task
- **Input:** "Redesign how the service talks to the database and ship the change through CI."
- **Expected route:** synod-kelsier resolves, then dispatches a bounded crew (elend → tensoon → marasi), honoring Elend-before-Vin.
- **Expected behavior:** Recognizes 3 disciplines (architecture, data, delivery); produces a routing plan naming each agent and its mandate; respects the 3-agent ceiling.
- **Red flags:** Routes to a single implementer (e.g. Vin) and skips specialists; spawns more than 3 agents; ignores the elend-before-vin ordering; begins implementing itself (Kelsier is review-only, no write).

## Scenario 2: Single clear discipline — do not over-route
- **Input:** "Add a build-cache step to the GitHub Actions workflow."
- **Expected route:** synod-marasi directly (single-discipline); Kelsier need not be invoked at all.
- **Expected behavior:** A single-discipline task routes straight to the matching specialist; no orchestration overhead.
- **Red flags:** Convenes a multi-agent council for a single-discipline task; spawns Kelsier to "coordinate" one agent.

## Scenario 3: Security in scope — Marsh first
- **Input:** "We need to add OAuth login and wire it through the pipeline."
- **Expected route:** synod-kelsier routes with **synod-marsh first**, before any implementer (vin/marasi).
- **Expected behavior:** Security trigger detected; Marsh is sequenced ahead of all implementers; routing plan states Marsh gates the implementers' work.
- **Red flags:** Lists an implementer before Marsh; omits Marsh entirely; treats security as a parallel concern rather than a gate.

## Scenario 4: Trivial / conversational — solo, no dispatch
- **Input:** "What does the acronym CI stand for again?"
- **Expected route:** Handled solo by Sazed; no agent dispatched.
- **Expected behavior:** Recognizes a trivial/conversational question; answers directly without convening the council.
- **Red flags:** Dispatches any specialist; produces a routing plan for a trivial question.

## Scenario 5: More than three disciplines — enforce the ceiling
- **Input:** "Refactor the auth module, migrate its table, update the Dockerfile, rewrite the docs, and fix the flaky CI."
- **Expected route:** synod-kelsier prioritizes and selects at most 3 agents (Marsh first, given auth).
- **Expected behavior:** Names the 3-agent ceiling explicitly; prioritizes (security/data first); defers or sequences the rest; explains what was deferred.
- **Red flags:** Dispatches 4+ agents at once; silently drops disciplines without saying so; fails to put Marsh first despite the auth trigger.
