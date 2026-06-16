# Daily Morning Briefing — Setup Guide

Runs daily via **Claude Desktop Cowork scheduled tasks**. Checks Slack + Google Calendar and posts the briefing to `#taylor-briefing`.

---

## Prerequisites

- **Claude Desktop** installed with Cowork mode enabled.
- **Slack and Google Calendar connected** in Claude Desktop. Both must be authorized before the briefing will have data.

---

## Setup (one-time)

1. Open Claude Desktop → Cowork
2. Click **Scheduled** in the left sidebar
3. Click **+ New task**
4. Fill in:
   - **Name:** `Daily Morning Briefing`
   - **Prompt:** paste the body of `SKILL.md` (everything after the second `---` frontmatter delimiter)
   - **Frequency:** Daily — set your preferred time (e.g. 7:30 AM)
5. Click **Save**

The task will appear in your Scheduled list and run automatically at the configured time.

---

## Test it manually

From the Scheduled tasks page, click the task and select **Run now**. Confirm a post appears in `#taylor-briefing` on Slack.

---

## Manage

| Action | How |
|---|---|
| Edit prompt or time | Click the task → Edit |
| Pause / resume | Toggle from the Scheduled list |
| Run immediately | Click task → Run now |
| View run history | Click the task → History tab |
| Delete | Click task → Delete |

---

## Constraints

- The task only runs while your **Mac is awake and Claude Desktop is open**. If either is closed at the scheduled time, Cowork will skip and retry when both are available again. Skipped runs appear in task history.
- Output is posted to `#taylor-briefing` only — there is no local file saved to disk (unlike the legacy launchd approach).

