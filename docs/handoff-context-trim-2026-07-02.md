# Handoff: Synod Council context-budget trimming

**Date:** 2026-07-02
**Repo:** `/Users/taylor/Code/projects/dogfiles` (branch `feat/synod-council-redesign`)
**Focus for next session:** trim the remaining dogfiles-controlled context footprint. Read this whole doc before touching files — there's a critical prior-art item in "Prior art already in flight" below that changes the scope.

## How this session got here

User asked "do we need `claude/charter-details.md` at all?" That led to two investigations, both concluded, both verified against ground truth (not just an agent's word):

### 1. Is `charter-details.md`'s on-demand design actually working?

Checked all 48 session transcripts under `~/.claude/projects/-Users-taylor-Code-projects-dogfiles/*.jsonl` for actual `Read` tool calls targeting `charter-details.md`. Result: only 4 sessions ever read it, and all 4 were sessions where the user was directly *editing/authoring* the charter itself (e.g. one dispatch was literally "write Multi-Flow Concurrency Protocol into charter-details.md") — not organic mid-task consultation despite the file's stated triggers ("load this when a conflict is being actively worked, when a new agent is proposed, or when you need full rationale").

**Important:** `charter-details.md` costs **zero** session-start context — it's a plain repo file, not part of the "Memory files" bucket, and only enters context when explicitly read. So this isn't a token-savings finding — it's a documentation-accuracy finding: the file's stated purpose ("on-demand guidance during normal work") doesn't match its observed use ("archive, consulted only when directly editing the charter"). Worth relabeling honestly at some point, but it's not part of the token-budget problem.

### 2. Where does the 60k session-start baseline (per `/context`) actually go, and can any of it be reduced?

Measured breakdown (out of 967k window):

| Bucket | Tokens | Dogfiles-controlled? |
|---|---|---|
| System prompt | 9.1k | No — Claude Code platform |
| System tools (built-in tool schemas) | 19.7k | No |
| MCP tools (eagerly loaded — Claude Code Remote) | 5.1k | No |
| Skills (built-in) | ~1.6k | No |
| Custom agents (12× `synod-*` descriptions) | 1.9k | **Yes** |
| Global `~/.claude/CLAUDE.md` | 3.9k | **Yes** (sourced from `claude/CLAUDE.md`) |
| Project `CLAUDE.md` | 958 | **Yes** |
| Skills (user-defined) | ~0.64k | **Yes** |
| Messages (this session's actual conversation) | 17.4k | N/A — grows with use, not a fixed cost |

Investigated whether any of the ~35k "fixed platform" bucket is actually reducible via settings.json. **Verified findings** (checked official docs, the actual installed CLI binary via `strings`, and the cited GitHub issue via `gh api` — don't trust an agent's settings claims without this level of checking, one round already produced a wrong answer):

- **`disableBundledSkills: true`** — real, documented ([code.claude.com/docs/en/settings](https://code.claude.com/docs/en/settings)). Removes bundled skills/workflows entirely. Would reclaim ~1.6k but kills `/code-review`, `/verify`, `/run`, `/deep-research`, `/update-config`, `/schedule`, `/loop`, `/claude-api` — **not recommended**, bad trade for this user's usage.
- **`disabledBuiltinTools` array** — **does not exist**. A research subagent claimed this was real and shipped (v2.1.104+); verifying the GitHub issue it cited (`anthropics/claude-code#54716`) showed it's a feature *request* asking Anthropic to build exactly this, closed `not_planned`/stale. Do not add this key to any settings.json.
- **`permissions.deny` on tool names to strip schemas from context** — unverified/likely false; permission denial is a call-time block, not a context-generation exclusion. Would have broken `Workflow`/`ReportFindings`/`ScheduleWakeup` for no confirmed savings. Do not do this.

**Conclusion:** ~35-40k of the 60k baseline is genuinely fixed today. No settings lever exists to reduce it (the real fix is blocked on Anthropic shipping #54716). The only addressable surface from within this repo is the ~7.4k "Yes" rows above.

## Prior art already in flight — read this before scoping work

**`docs/adr/ADR-002-lean-core-context-trim.md`** (uncommitted, written earlier today) already executed a trim of exactly this kind:
- `claude/CLAUDE.md`: 174 → 102 lines (~41% reduction), via a multi-agent review (synod-elend on structure, synod-marsh on verbatim-retention of security-adjacent controls, synod-steris on doc accuracy).
- Also fixed stale content along the way: dead `/SDD-1`...`/SDD-4` slash-command references (replaced by the `sdd` skill), and a `disallowedTools` residue that was missing `NotebookEdit`.
- Implementation checklist marks steps 1-3 done, step 4 (`task tools:claude` to deploy) as **not done** — but I verified directly: `diff ~/.claude/CLAUDE.md claude/CLAUDE.md` returns **identical**, so the deploy has actually happened. The ADR's checkbox is stale; update it rather than re-running `task tools:claude` blind.
- **The 3.9k figure for global CLAUDE.md in the table above already reflects this post-ADR-002 trimmed state.** A further pass is squeezing a document that was already cut 41% today — set expectations low (the "easy" fat is gone). Don't re-attack `claude/CLAUDE.md`'s persona/routing/promotion sections; ADR-002's own review already adjudicated what's cuttable there (see its Decision section for the line-by-line reasoning) versus what Marsh required verbatim.

Given that, the **highest-yield remaining targets** are things ADR-002 didn't touch:
1. The 12 `claude/agents/synod-*.md` frontmatter `description` fields (1.9k total, ~160 tokens/agent) — these carry routing-trigger keywords, so any trim must preserve routability, not just shorten prose.
2. User-defined skill descriptions (~0.64k) — `agent-browser` is the largest at ~310 tokens.
3. Project `CLAUDE.md` (958 tokens) — already fairly lean; re-check before assuming there's fat here.

Realistic yield for a further pass: likely low hundreds to ~1k tokens, not the 2-4k estimated before ADR-002's existence was discovered. Say this plainly to the user before investing effort — don't let "trim it more" turn into low-value churn.

## Repo constraints to respect

- This repo's own `CLAUDE.md` (root) forbids editing deployed destinations directly (`~/.claude/CLAUDE.md`, `~/.claude/agents/`, etc.) — edit only the `claude/` source files in this repo and apply via `task tools:claude`.
- The working tree is **not clean** — besides the two trim-related files, there are unrelated modifications (`claude/statusline-command.sh`, `dotfiles/.p10k.zsh`, `dotfiles/.zshrc`) and untracked files (`docs/specs/04-spec-herdr-adoption/*`, `package-lock.json`) from other in-progress work. Scope any diff/commit narrowly to the trim files; don't sweep in unrelated changes.
- The global `~/.claude/CLAUDE.md` (Sazed / Synod Council charter) governs the assistant's own behavior in this repo: Plan Mode is the default (no edits without user promotion), and per its own rule "all implementation goes through synod-vin — no exceptions." A fresh session working in this repo should expect to operate under that persona and its routing/promotion gates itself, including when editing the very files that define it.

## Suggested skills / routing for next session

- No slash-command exists for "trim a CLAUDE.md/agent roster for token budget" — this is direct editing work, not a packaged skill.
- Per the loaded charter's own routing rules, **synod-steris** (docs & planning agent, holds documentation-accuracy veto) is the natural specialist to route this through — name her explicitly before editing, per the charter's "proactively surface specialists" rule.
- The `sdd` skill (spec-driven development) is available but likely overkill for a lightweight editing pass like this — only invoke it if the user wants a formal spec/task-list treatment.
- Do **not** re-run the settings.json investigation from scratch — the findings above (`disableBundledSkills` real-but-bad-trade, `disabledBuiltinTools` fake, `permissions.deny` unverified/risky) are verified and citable; treat them as settled unless Claude Code ships a new version.

## Open items for the next session

1. Confirm current `git status`/`git diff` state before editing (this doc's snapshot may be stale by the time you read it).
2. Update ADR-002's step 4 checkbox to reflect that deploy already happened (verified via `diff`), rather than re-running `task tools:claude`.
3. Decide with the user: is a further trim pass on the ~7.4k pool actually worth doing given the low realistic yield, or should this be closed out as "already handled by ADR-002, remaining fixed cost is a platform limitation"?
4. If proceeding, scope to the 12 agent descriptions + user skill descriptions (see "highest-yield remaining targets" above), not `claude/CLAUDE.md` itself.
