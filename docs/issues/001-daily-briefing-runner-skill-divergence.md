# 001 — Daily Briefing: runner and skill have diverged

- **Status:** Resolved — 2026-06-12
- **Logged:** 2026-06-12
- **Area:** `claude/scheduled/taylor-morning-briefing/`
- **Severity:** Medium — the scheduled job is live but failing, and the
  tracked source contains two different definitions of "the briefing."

## Summary

While bringing the daily morning briefing under version control in this
repo, three contradictions surfaced between the launchd automation and the
skill it is nominally associated with. None were changed during the import
(the live launchd job was deliberately left untouched); they are recorded
here for a dedicated follow-up.

## Findings

### 1. The runner and the skill are two different briefings

`run-briefing.sh` carries its **own embedded prompt** and does **not**
reference `SKILL.md` in any way. The two define materially different output:

| Capability | `run-briefing.sh` (what actually runs) | `SKILL.md` (the newer definition) |
|---|---|---|
| Slack scan | ✅ (different channel set) | ✅ (`#liatrio-engineering`, `#liatrio-forge`, `#liatrio-announcements`, by ID) |
| Google Calendar | ✅ (no timezone handling) | ✅ (converts to Mountain Time) |
| Save markdown file | ✅ | ✅ |
| Spanish / Costa Rican phrase | ❌ | ✅ |
| "This day in history" | ❌ | ✅ |
| AP overnight headlines | ❌ | ✅ |
| Post to `#taylor-briefing` (`C0B9BRZBGEA`) | ❌ | ✅ |

The Slack channel lists also differ between the two. As shipped, the 7:30 AM
job produces the **older, file-only** briefing; the richer `SKILL.md`
behavior (tidbits + Slack post) never runs.

### 2. The launchd job's last exit code was 78 (`EX_CONFIG`)

`launchctl list com.taylor.daily-briefing` reported a last exit status of
**78** — a configuration error, not a clean run. The job is loaded but has
been failing. Root cause not yet investigated (candidate causes per the
runner's own guards: `claude` CLI not on launchd's `PATH`, or MCP
connectors not authorized in the headless context).

### 3. Name mismatch

`SKILL.md` addresses the user as **"Taylor Walters."** Everywhere else the
user is **Taylor Williams** (`taylorw@liatrio.com`). Likely a typo in the
skill.

## Resolution

Implemented 2026-06-12. Resolution option 1 was chosen: **SKILL.md is canonical.**

### Finding 1 — Runner/skill divergence
`run-briefing.sh` was rewritten to treat SKILL.md as the authoritative prompt
source. The runner now: (a) reads the SKILL.md body (frontmatter stripped via
`awk`), (b) prepends an injected header containing today's `DATE` and an 18-hour
`OLDEST` unix timestamp, and (c) passes the combined string to `claude -p`. The
skill's richer output — tidbits, AP headlines, Mountain Time calendar, and Slack
posting to `#taylor-briefing` — now runs at 7:30 AM.

### Finding 2 — Exit 78 (EX_CONFIG)
Root cause was the stale runner configuration (embedded prompt, no skill
invocation, `--dangerously-skip-permissions` flag). Replaced with the new
runner. Verified with `launchctl kickstart -k gui/$(id -u)/com.taylor.daily-briefing`:
job exited 0, briefing written to `~/Claude/briefing-output/`, post confirmed in
`#taylor-briefing`.

### Finding 3 — Name mismatch (Walters → Williams)
Fixed in SKILL.md: "Taylor Walters" corrected to "Taylor Williams."

### Security hardening (additional, not in original findings)
Removed `--dangerously-skip-permissions` and the `mcp__*` wildcard. Replaced
with a narrow `--allowedTools` allowlist: Slack reads
(`slack_read_channel`, `slack_read_thread`, `slack_search_public`,
`slack_search_users`, `slack_read_user_profile`), one Slack post
(`slack_send_message`), Calendar reads (`list_calendars`, `list_events`,
`get_event`), and `WebSearch`. No `Bash`, no `Write`.

### Path relocation
Runner repathed to `~/Claude/Scheduled/taylor-morning-briefing/run-briefing.sh`.
Logs and output moved to `~/Claude/briefing-output/` (outside repo and outside
`~/Desktop`). Taskfile integration added: `task tools:claude` syncs config and
scheduled scripts; `task scheduled:install` loads the launch agent. Desktop
originals at `~/Desktop/Claude/daily-briefings/` intentionally left in place as
rollback pre-image.

## Notes for whoever picks this up

- Source of truth for the scheduled files is `claude/scheduled/taylor-morning-briefing/`
  in this repo. Deployed copies live at `~/Claude/Scheduled/taylor-morning-briefing/`.
- The Desktop originals (`~/Desktop/Claude/daily-briefings/`) are the rollback
  pre-image and were not modified.
- To propagate future edits to SKILL.md or INSTALL.md: `task tools:claude`.
