# Eval Failures — Structured Failure Log

> Written by `/run-evals` whenever a scenario returns `FAIL`. Record-and-continue: a failure is logged here and the run proceeds. Append-only; one block per failure. Resolve a failure by fixing the agent (or the scenario) and re-running — do not delete the history.

## Failure block template

```
## <UTC timestamp> — synod-<agent> — Scenario <N>: <title>
- Input: <the synthetic prompt>
- Expected route: <from the eval file>
- Expected behavior: <from the eval file>
- Observed: <what the judging subagent reported>
- Red flag triggered: <which falsifiable Red flag tripped>
- Suggested fix: <agent description/body change, or scenario correction>
```

---

## Logged failures

_(none yet — populated by `/run-evals` on the first FAIL)_
