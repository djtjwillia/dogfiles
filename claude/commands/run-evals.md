---
name: run-evals
description: Run the Synod Council routing/behavior eval scenarios — one judging subagent
  per scenario, record-and-continue, with a pass/fail/total tally.
tags:
- evals
- synod-council
- routing
enabled: true
arguments:
- name: scope
  description: "Optional. `--changed` runs only scenarios for agents whose eval or agent files changed vs the last commit. A bare `synod-<agent>` name runs just that agent. Omit to run all 12 agents."
  required: false
meta:
  category: quality
  allowed-tools: Bash, Read, Edit, Glob, Grep, Task
  command_format: markdown
  command_file_extension: .md
  version: 0.1.0
---

# Run Synod Council Evals

You are the **eval runner** for the Synod Council. You execute the routing/behavior scenarios stored in `~/.claude/agents/eval/synod-*.md` (repo source: `claude/agents/eval/`), judge each with an isolated subagent, and record the results. You **record and continue** — a failing scenario is logged, not a stop.

## Scope resolution (read `$ARGUMENTS`)

1. **`--changed`** — run only scenarios for agents whose files changed since the last commit. Determine the set with:
   ```bash
   git -C <repo> diff --name-only HEAD -- claude/agents/ ; git -C <repo> diff --name-only --staged -- claude/agents/
   ```
   Map each changed `claude/agents/synod-<agent>.md` **or** `claude/agents/eval/synod-<agent>.md` to its eval file `claude/agents/eval/synod-<agent>.md`. De-duplicate. If nothing changed, say so and stop (no run row).
2. **A bare agent name** (e.g. `synod-marsh`) — run only that agent's eval file.
3. **No argument** — run all twelve `eval/synod-*.md` files.

> `--changed` is the default working mode in practice: running all 12 agents × 4–5 scenarios is token-expensive. Prefer it after editing one or a few agents.

## Procedure

1. **Stamp the run.** Capture one UTC timestamp for the whole run: `date -u +%Y-%m-%dT%H:%M:%SZ`. Every row from this run uses it.
2. **Load scenarios.** Read each in-scope `eval/synod-<agent>.md`. Each scenario has **Input**, **Expected route**, **Expected behavior**, and **Red flags**.
3. **Judge each scenario with an isolated subagent.** Spawn **one subagent per scenario**. Give it ONLY:
   - the scenario's Input,
   - permission to read `~/.claude/CLAUDE.md` (routing rules) and the relevant `~/.claude/agents/synod-*.md` files (it may skim sibling `description:` lines to judge routing),
   - the scenario's Expected route, Expected behavior, and Red flags as the rubric.

   The subagent must return, as structured output:
   - **would_be_route**: which agent the Input would route to (and whether Marsh is correctly sequenced first when security is in scope),
   - **behavior_assessment**: whether the expected behavior would hold,
   - **red_flag_triggered**: the specific Red flag that tripped, or `none`,
   - **verdict**: `PASS` or `FAIL`,
   - **note**: one line of justification.

   The subagent judges against the rubric only; it does not edit files. It must not invent routing rules — apply the charter as written (single-discipline routes directly to the matching specialist; "default to Vin" applies only when no specialist domain is triggered; security → Marsh first).
4. **Record-and-continue.** For **every** scenario, append one row to `~/.claude/agents/eval/results.md` under the `## Results` table:
   `| <run-ts> | synod-<agent> | <N>: <title> | <would_be_route> | <PASS\|FAIL> | <note> |`
   For each **FAIL**, also append a failure block to `~/.claude/agents/eval/failures.md` using that file's template (Input, Expected route, Expected behavior, Observed, Red flag triggered, Suggested fix). A failure never halts the run.
5. **Tally.** After all scenarios, print an end-of-run summary: **passed / failed / total**, the scope that ran, and the run timestamp. List the failed scenarios by `agent — scenario` so the user can act.

## Notes

- **Synthetic inputs only.** Scenario inputs are synthetic; never substitute real credentials, tokens, or private repo contents.
- **Edit the installed copies' source.** `results.md`/`failures.md` are appended in `~/.claude/agents/eval/` for the run; the repo (`claude/agents/eval/`) is the source of truth — sync back or run from the repo per the project's workflow.
- **Security control under test.** At least one scenario (synod-marsh Scenario 1; synod-vin Scenario 3) checks **Marsh-first** ordering. A regression there is a high-severity FAIL — call it out explicitly in the tally.
- This command does not modify any `synod-*` agent file. It only reads agents and appends to the two log files.
