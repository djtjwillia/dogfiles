---
name: execute-github-issue
description: "User-invoked end-to-end GitHub issue workflow: claim the issue, plan it, stop for approval, implement, clean up, review, open a PR linked to the issue, and drive CI to green."
argument-hint: "<issue number | #N | owner/repo#N | issue URL> [plan_model:<m>] [review_model:<m>]"
disable-model-invocation: true
---

# Execute GitHub Issue

Take one GitHub issue from open to a reviewed pull request with green CI. The skill claims the issue, produces a plan, stops for explicit human approval, implements the approved plan on a branch, runs cleanup and review passes, opens a PR that closes the issue, and iterates until checks pass. It does not merge. Every phase reports a short status line so the user can interrupt at any boundary.

## Required host skills

| Skill | Used for | Phase |
|---|---|---|
| `simplify` | Code cleanup on this branch's diff | 5 |
| `anthropic-skills:humanizer` (or `humanizer`) | All human-facing prose | 2, 4, 5, 7, 8 |
| `code-review` | Review of the branch diff | 6 |
| `security-review` | Review when auth, secrets, tokens, CI permissions, or dependencies are touched | 6 |

Rule: a missing skill is never a silent no-op. If a required skill is unavailable, name the missing skill, state which phase depends on it, and stop that phase. Ask the user whether to install it or proceed without that pass.

## Usage

```
/execute-github-issue 412
/execute-github-issue #412 plan_model:opus review_model:sonnet
/execute-github-issue owner/repo#412
/execute-github-issue https://github.com/owner/repo/issues/412
```

### Model overrides

- Carriers: `plan_model:<m>` selects the model for the Phase 2 planning subagent. `review_model:<m>` selects the model for the Phase 6 review passes.
- Natural language works too: "plan with opus", "review using haiku", "use sonnet for the plan".
- Valid values are Agent tool models: `sonnet`, `opus`, `haiku`, `fable`. Reject anything else and ask once.
- Default for both is the current session model.
- Strip all carriers from the argument string before parsing the issue identifier. Never pass a carrier into a `gh` lookup.
- Disclose the resolved models in the opening status line, for example: `Issue 412 | plan: opus | review: session default`.

## Critical gates

1. **Approval gate is a hard stop.** After the plan is presented, wait for an explicit user response. Silence is not consent. An unrelated message is not consent. "Looks good" is consent; nothing weaker is.
2. **Claim before plan.** Assign and label the issue before any planning work begins, so nobody duplicates the effort.
3. **No product code before approval.** Reading, searching, and running tests are allowed during planning. Edits to product code are not.
4. **`simplify` and humanizer run before review.** Review the cleaned diff, not the raw one.
5. **Review runs before the CI loop.** Do not chase checks on code that has not been reviewed.
6. **Humanizer on all human-facing prose.** Plan synthesis, documentation written during implementation, PR title and body, and every issue or review comment.
7. **Never merge unless the user explicitly asks.** Green CI is the stopping point.
8. **The issue closes via `Closes #N` on merge**, not by a manual close during the workflow. Remove the status label after merge.

## Phase checklist

Publish this list with the todo tool at the start of the run and keep it current:

1. Parse arguments
2. Claim the issue
3. Plan
4. Await approval
5. Implement
6. Cleanup
7. Review
8. Open PR
9. CI loop
10. Report
11. After merge

## Workflow

### Phase 0: Parse

- Accept `412`, `#412`, `owner/repo#412`, or a full issue URL. Strip model carriers first.
- Resolve the target repository:
  ```
  gh repo view --json nameWithOwner,defaultBranchRef
  ```
  If the identifier carried `owner/repo` or a URL host path, prefer that and pass `--repo owner/repo` on every later `gh` call.
- Confirm authentication:
  ```
  gh auth status
  ```
- If the issue number, the repository, or authentication cannot be resolved, ask once for the missing piece and stop. Do not guess.

### Phase 1: Claim

```
gh issue view <N> --json title,body,labels,assignees,comments,url,state
gh issue edit <N> --add-assignee @me --add-label "status: in-progress"
```

If the label does not exist, create it and its review counterpart:

```
gh label create "status: in-progress" --color 1D76DB --description "Work has started"
gh label create "status: in-review" --color FBCA04 --description "PR open, awaiting review"
```

If label or assignee operations are refused for permission reasons, post a single-line issue comment stating that work has started, then continue. Do not stop the run over a label.

Tell the user in one line that the issue is claimed, with its title.

### Phase 2: Plan

Dispatch the Agent tool with `subagent_type: Plan` and `model` set to the resolved plan model. Give the subagent:

- The full issue title, body, labels, and comment thread.
- Any linked issues, PRs, or documents referenced in the issue.
- Repository conventions: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, and the PR template if present.
- An explicit instruction: produce a specification only. No file edits.

Synthesize the returned plan into these sections:

- **Goal**: what done looks like, in the issue's terms.
- **Approach**: the ordered strategy.
- **Key files**: paths the change will touch.
- **Risks and open questions**: including anything the issue leaves ambiguous.
- **Acceptance checks**: commands or observations that prove the work is complete.
- **Ask**: the explicit request for approval.

Run the humanizer on the synthesis before showing it to the user.

### Phase 3: Approval

Hard stop. Present the plan and wait.

| User response | Action |
|---|---|
| Approves | Proceed to Phase 4. |
| Requests changes | Revise the plan, re-humanize, present again, wait again. |
| Rejects or defers | Leave the issue claimed, post nothing further, summarize the state in chat, end the run. |

Do not proceed on silence, on an ambiguous reply, or on your own reading of intent.

### Phase 4: Implement

- Branch from the default branch: `<type>/<N>-<slug>`, where type comes from the issue labels (`feat`, `fix`, `docs`, `chore`) and slug is a short kebab-case form of the title.
- Break the approved plan into ordered tasks with the todo tool and work them in order.
- Follow repository conventions for style, testing, and structure.
- Commit in small focused commits. One logical change per commit.
- Run the humanizer on any documentation or user-facing text written during implementation.
- Push the branch.

### Phase 5: Cleanup

- Run `simplify` on the diff against the default branch. Scope it to code this branch added or changed.
- Run the humanizer on prose in that same diff.
- Behaviour must not change. Cleanup is quality only.
- Commit and push if anything changed. Never create an empty commit.

### Phase 6: Review

```
gh issue edit <N> --remove-label "status: in-progress" --add-label "status: in-review"
```

- Run `code-review` at high effort using the resolved review model.
- Run `security-review` when the diff touches authentication, secrets, tokens, CI workflow permissions, or dependency manifests.
- Fix every must-fix finding. Record deliberate non-fixes with a reason.
- Push the fixes.
- Re-run a review pass only when the fixes were substantive.

### Phase 7: Open the PR

```
git fetch origin && git rebase origin/<default-branch>
git push --force-with-lease
```

- Use `.github/pull_request_template.md` or `.github/pr-template.md` if present. Otherwise use: Summary / Changes / Testing / Notes.
- The body must contain `Closes #<N>`.
- Humanize the title and body before creating the PR.

```
gh pr create --base <default-branch> --title "<title>" --body-file <path>
gh pr view --json url
```

Capture the PR URL for the report.

### Phase 8: CI loop

```
gh pr checks <pr-url> --watch
```

On failure:

```
gh run view <run-id> --log-failed
```

- Read the failure, fix it, push, and watch again.
- Resolve review threads you have addressed with a short humanized reply.
- Stop and ask the user when a failure needs product judgment, or when a failure looks like unrelated flake and has recurred after 2 retries.

### Phase 9: Report

Report in chat, not on the PR:

- Issue reference and title.
- PR URL.
- One-line summary of what changed.
- CI status: green.

Do not merge.

### Phase 10: After merge

Only when the user reports the merge, or `gh pr view --json state` returns `MERGED`:

```
gh issue edit <N> --remove-label "status: in-review"
```

Confirm the issue closed via `Closes #<N>`. If it is still open:

```
gh issue close <N> --comment "Closed by <pr-url>"
```

## Guardrails

- No secrets, tokens, or personal data in issue comments, commit messages, or PR bodies.
- Never force-push the default branch. `--force-with-lease` applies to the feature branch only.
- Never skip git hooks or CI checks.
- Never skip the approval gate.
- Never skip cleanup or the humanizer passes.
- A missing required skill stops the phase and surfaces to the user.
- Never merge unless the user explicitly asks.
- Destructive repository operations (branch deletion, history rewrite, label deletion) require user confirmation first.

## Output contract

Post a short status update at each phase boundary. Two lines maximum: what finished, what is next.

Final success message:

```
Issue #<N>: <title>
PR: <pr-url>
<one-line summary of the change>
CI: green. Not merged, waiting on your call.
```
