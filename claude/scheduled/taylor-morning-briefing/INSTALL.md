# Daily Morning Briefing — Installation Guide

Runs every day at **7:30 AM** via macOS launchd. Checks Slack + Google Calendar and saves a markdown briefing to `~/Claude/briefing-output/`.

---

## Prerequisites

- **Claude CLI installed.** Verify with `which claude` in Terminal. If missing, install from [claude.ai/download](https://claude.ai/download) or via Homebrew: `brew install claude`.
- **Slack and Google Calendar connected** in Claude Desktop (Cowork mode). Both must be authorized before the briefing will have data.

---

## Install

The briefing is managed via the dogfiles Taskfile. From the repo root:

```bash
# 1. Sync Claude config and scheduled scripts into place
#    (must run before scheduled:install — populates ~/Claude/Scheduled/)
task tools:claude

# 2. Install and load the launch agent (run separately — not part of init)
task scheduled:install
```

`task tools:claude` copies:
- `claude/CLAUDE.md` and `claude/settings.json` → `~/.claude/`
- `claude/agents/` → `~/.claude/agents/` (synced with --delete)
- `claude/scheduled/` → `~/Claude/Scheduled/`

`task scheduled:install` then:
- Creates `~/Claude/briefing-output/.logs/`
- Backs up the current plist to `/tmp/`
- Unloads the old agent (if any), installs the updated plist, sets permissions, and loads the new agent

The underlying mechanism is `launchctl load ~/Library/LaunchAgents/com.taylor.daily-briefing.plist`.

---

## Test it manually

Run the script right now to confirm everything works:

```bash
bash ~/Claude/Scheduled/taylor-morning-briefing/run-briefing.sh
```

Check the output:

```bash
cat ~/Claude/briefing-output/briefing-$(date +%Y-%m-%d).md
```

Or trigger via launchd:

```bash
launchctl kickstart -k gui/$(id -u)/com.taylor.daily-briefing
```

---

## Troubleshoot

**No output / empty file:**

```bash
cat ~/Claude/briefing-output/.logs/run-$(date +%Y-%m-%d).log
```

Look for `ERROR:` lines. Common causes: `claude` not in PATH, MCP connectors not authorized.

**claude not found by launchd but works in Terminal:**

launchd doesn't load your shell profile, so `claude` might not be on its PATH. Find the real path:

```bash
which claude
```

Then edit `run-briefing.sh` and hardcode it at the top:

```bash
CLAUDE_BIN="/path/from/which/claude"
```

**Check launchd loaded correctly:**

```bash
launchctl list | grep taylor
```

Should return a line with `com.taylor.daily-briefing`.

---

## Manage

| Action | Command |
|---|---|
| Unload (stop scheduling) | `launchctl unload ~/Library/LaunchAgents/com.taylor.daily-briefing.plist` |
| Reload after edits | `task scheduled:install` |
| Check status | `launchctl list com.taylor.daily-briefing` |
| View logs | `ls ~/Claude/briefing-output/.logs/` |

---

## Change the time

Edit `claude/scheduled/taylor-morning-briefing/com.taylor.daily-briefing.plist` in the repo, change `Hour` / `Minute`, then reinstall:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>7</integer>   <!-- change this -->
    <key>Minute</key>
    <integer>30</integer>  <!-- and this -->
</dict>
```

```bash
task tools:claude && task scheduled:install
```

---

## Notes

- If your Mac is **asleep at 7:30 AM**, the job runs the next time it wakes up that day.
- If a briefing already exists for today, the script skips to avoid duplicates.
- macOS will show a **notification** on success or failure.
- Briefings are named `briefing-YYYY-MM-DD.md` and accumulate in `~/Claude/briefing-output/` indefinitely.
- Source scripts live in `~/Claude/Scheduled/taylor-morning-briefing/` (synced from repo).
- The Desktop originals at `~/Desktop/Claude/daily-briefings/` are left in place as a rollback reference.
