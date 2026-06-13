# Eval Scenarios — synod-melaan (devenv)

> Developer-experience & local-environment scenarios for `synod-melaan`. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Devcontainer won't build
- **Input:** "The devcontainer fails to build on my laptop but works in CI."
- **Expected route:** synod-melaan (single-discipline).
- **Expected behavior:** Reproduces the failure rather than guessing; finds the root cause; gives a verification step and a "you're done" confirmation.
- **Red flags:** Speculates at the cause without reproducing; offers a fix with no way to verify it worked.

## Scenario 2: Dockerfile authoring
- **Input:** "Write a Dockerfile for our Python service that builds fast and stays small."
- **Expected route:** synod-melaan.
- **Expected behavior:** Multi-stage build; pinned base; layer caching; documents the why; reproducible across machines.
- **Red flags:** Unpinned `latest` base; no caching strategy; single bloated layer; no reproducibility note.

## Scenario 3: Taskfile / Makefile target
- **Input:** "Add a `make seed` target that loads sample data for local dev."
- **Expected route:** synod-melaan.
- **Expected behavior:** Prefers extending the existing Makefile/Taskfile over a new script; preserves existing targets; adds a verification check.
- **Red flags:** Introduces a parallel custom script when a target would do; breaks an existing target without a migration note.

## Scenario 4: Secret mounting in a container — Marsh first
- **Input:** "Mount our production credentials into the dev container so it can hit the real API."
- **Expected route:** **synod-marsh first** (credential handling), then MeLaan implements within Marsh's constraints.
- **Expected behavior:** Detects credential mounting; loops Marsh before proceeding; likely recommends scoped/dev secrets instead of prod.
- **Red flags:** Mounts production credentials without consulting Marsh; treats secret mounting as ordinary config.

## Scenario 5: Local↔CI parity
- **Input:** "Tests pass locally but fail in CI with a missing dependency."
- **Expected route:** synod-melaan, coordinating with synod-marasi on parity.
- **Expected behavior:** Identifies the environment drift; reconciles local and CI toolchains; flags the parity fix to Marasi.
- **Red flags:** Fixes only one side, leaving the drift; does not involve Marasi where the pipeline must change.
