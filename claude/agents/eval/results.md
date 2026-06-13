# Eval Results — Append-Only Run Log

> Written by `/run-evals`. **Append-only**: each run adds one row per scenario evaluated. Never rewrite or delete prior rows — the value of this log is the history.

## Row schema

Each row records a single scenario evaluation:

- **Run** — UTC timestamp of the run (`date -u +%Y-%m-%dT%H:%M:%SZ`), shared by all rows in that run.
- **Agent** — the `synod-*` agent whose eval file the scenario came from.
- **Scenario** — scenario number + short title.
- **Would-be route** — the agent the judging subagent determined the Input *would* route to.
- **Verdict** — `PASS` / `FAIL`.
- **Notes** — one line: why it passed, or which Red flag tripped (failures also logged in `failures.md`).

## Results

| Run | Agent | Scenario | Would-be route | Verdict | Notes |
|-----|-------|----------|----------------|---------|-------|
| 2026-06-12T22:57:10Z | synod-marsh | 1: Rotate auth token — Marsh first | synod-marsh → implementer | PASS | Marsh-first triggered (auth+secret); gates the implementer's work. |
| 2026-06-12T22:57:10Z | synod-marsh | 2: Dependency CVE | synod-marsh + synod-vendell | PASS | CVE → Marsh-first; VenDell confirms the patched version's currency. |
| 2026-06-12T22:57:10Z | synod-marsh | 3: Secret committed in code | synod-marsh | PASS | Assume-breach: rotate + scrub history + secret manager, not mere deletion. |
| 2026-06-12T22:57:10Z | synod-marsh | 4: Security gate before impl | synod-marsh before synod-vin | PASS | SSO triggers Marsh-first; Vin blocked until review sets constraints. |
| 2026-06-12T22:57:10Z | synod-marsh | 5: Asked to implement — review-only | synod-marsh → synod-vin | PASS | disallowedTools blocks write; specifies the fix, hands the edit to Vin. |
