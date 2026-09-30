# Scheduled task: Obsidian morning brief

These tasks live server-side in Cowork, bound to this Mac; nothing in this repo deploys them. The vault folder `…/iCloud~md~obsidian/Documents/work` must be attached when the task is created — folders cannot be added afterwards, so recreate the task instead. To (re)create: in a Cowork chat, say "create a scheduled task, requires this computer, cron X, prompt Y" with the values below, verbatim.

- **Name:** `Obsidian morning brief (7:30 + hourly catch-up)`
- **Cron:** `CRON_TZ=America/Denver 30 7-11 * * 1-5` — 07:30, then 08:30 … 11:30; later firings no-op once the morning block exists
- **Requires this computer:** yes · **Approval:** automatic · **Notify:** push

Prompt:

````text
MORNING BRIEF — runs at 07:30 Denver and again hourly until 11:30 as a catch-up for a laptop that was asleep. FIRST, the idempotency guard: on the linked Mac run `grep -q "claude:begin morning" "$HOME/mnt/work/10-daily/$(TZ=America/Denver date +%F).md"`. If it succeeds (exit 0), today's morning pass already ran: reply with one line "Morning brief already done for today — no action" and STOP. If the Mac is unreachable after one retry, reply "Mac unreachable, will retry next hour" and STOP. Otherwise continue.

Run the MORNING pass of the `obsidian-daily-note` skill (invoke it as /obsidian-daily-note morning). Do NOT push anything to Things — Taylor runs /things-sync himself after reviewing the note. This is an unattended scheduled run: never ask questions; make reasonable choices, state them in the run summary, and finish.

If the skill is not available, follow this contract instead:
- Vault is on the linked Mac at $HOME/mnt/work (device path $HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/work). Daily notes: 10-daily/YYYY-MM-DD.md. Helper: python3 "$HOME/mnt/work/.obsidian/scripts/daily_note.py" with commands ensure, prior-workday, read, open-items, promised, meetings, set-section, config (run it with no args to print usage). Timezone America/Denver. Load Taylor's Slack id and other identifiers with python3 "$HOME/mnt/work/.obsidian/scripts/daily_note.py" config (slack_user_id); below it is written <@SLACK_USER_ID>.
- TODAY = Denver date. `ensure TODAY` creates the note from the template. PRIOR = `prior-workday TODAY` (Monday → previous Friday).
- Fill sections with `set-section TODAY "<Heading>" PASS` (content on stdin; writes only inside <!-- claude:begin PASS --> … <!-- claude:end PASS --> markers, preserves everything Taylor typed):
  1. "Open loops" (PASS morning), one block, carried lines first then promised lines. Carried: from PRIOR's note — unchecked tasks, Today's three not done, the Ledger "Unspoken → goes in tomorrow's post" text, Capture lines that read as intentions, overdue `@promised` items (`promised TODAY`); format `- [ ] item — from [[10-daily/PRIOR|Ddd M/D]]`. Promised: Slack search from:<@SLACK_USER_ID> after:(PRIOR − 1 day), keywords I'll / "I will" / "will do" / today / tomorrow / EOD / "on it" / "let me". Keep only first-person forward commitments due today, overdue, or undated within 2 workdays. Format `- [ ] commitment — to person/#channel, said Ddd HH:MM @promised YYYY-MM-DD`.
  2. "Calendar" (PASS morning): Google Calendar events TODAY 06:00–20:00 Denver, skip declined; `- HH:MM–HH:MM Title (organizer)`, flag overlaps and unanswered invites, end with a one-line count + largest free block.
  3. "Needs attention" (PASS attention): Slack since PRIOR 17:00 — (a) keywords ["<@SLACK_USER_ID>"] filters `after:PRIOR -from:<@SLACK_USER_ID>`; (b) filters `is:dm after:PRIOR -from:<@SLACK_USER_ID>` channel_types im,mpim. Keep only questions/requests to Taylor with no later reply from him (check with a from:<@SLACK_USER_ID> in:<channel> after:<date> search or slack_read_thread). Format `- [ ] who — ask (channel/DM, Ddd HH:MM) [↗](permalink)`; if none `- nothing waiting on you in Slack since Ddd HH:MM`.
- Never touch Standing post, Today's three, Capture, Action items, EOD post, Ledger. `## Meetings` must exist; recreate it if missing. Keep any existing ` ⇢things` markers. Re-read the note once to confirm it is intact.
- Finish with a 3–5 bullet run summary: counts (carried / promised / meetings / attention), the single most important item, a reminder to review then run /things-sync, and anything that failed or was assumed.
````
