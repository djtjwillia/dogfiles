---
name: taylor-morning-briefing
description: Daily morning briefing for Taylor — Slack highlights, calendar, AP headlines, and daily tidbits
---

Generate a daily morning briefing for Taylor Williams, a Lead DevOps Engineer and AI Enablement Engineer at Liatrio.

## Objective
Check Slack and Google Calendar, summarize what's coming up today, flag anything needing preparation, emit the briefing as your final markdown response (the runner persists it to disk), post the briefing to the #taylor-briefing Slack channel (channel ID: C0B9BRZBGEA), and include daily tidbits to start the morning well.

---

## Step 1 — Daily Tidbits

### A. Spanish / Costa Rican phrase of the day
Choose one Spanish word or colloquial Costa Rican phrase. Provide:
- The word/phrase
- Pronunciation guide (informal phonetic)
- Meaning and a short usage example

### B. This Day in History
Find one notable event that occurred on the date provided at the top of this prompt. Prefer events that are interesting or surprising over obvious ones. One sentence.

### C. AP Overnight Headlines
Search for the top 3–5 major news headlines from the past 12 hours. Use web search targeting AP News (apnews.com) or equivalent reputable sources. One line per headline with source.

---

## Step 2 — Check Slack

Use the date and the Slack `oldest` timestamp provided at the top of this prompt. Read recent messages (last 18 hours, using the provided `oldest` unix timestamp) from these channels:
- **#liatrio-engineering** (channel ID: C07930A44DV)
- **#liatrio-forge** (channel ID: C0AE9CLD7CH)
- **#liatrio-announcements** (channel ID: C05JELM6DFT)

Also scan for any urgent messages or recent mentions directed at Taylor (search: "to:me", recent @mentions).

Note: threads, decisions, action items, blockers, open questions, or anything requiring follow-up.

---

## Step 3 — Check Google Calendar
Pull calendar events for the date provided at the top of this prompt.

**IMPORTANT: Taylor is in the Mountain Time zone (America/Denver). All event times must be converted to and displayed in Mountain Time (MT). The Google Calendar API may return times in UTC or other zones — always convert before displaying.**

For each event note: title, time (in MT), attendees, and whether prep is likely needed (e.g., client meetings, reviews, demos, presentations).

---

## Step 4 — Emit the Briefing as Markdown

Emit the full briefing markdown as your final response — the runner persists it to disk automatically. Do not attempt to save the file yourself.

Structure:
```
# Daily Briefing — [Day, Month Date, Year]

## Daily Tidbits

### 🇨🇷 Spanish / Costa Rican Phrase
**[Word/Phrase]** — [Pronunciation]
[Meaning + usage example]

### 📜 This Day in History
[One interesting fact from today's date in history]

### 📰 AP Overnight Headlines
- [Headline 1] — [Source]
- [Headline 2] — [Source]
- [Headline 3] — [Source]

---

## 📅 Today's Calendar
[List today's events with times in MT and attendees]

## 💬 Slack Highlights

### #liatrio-engineering
[Key updates, decisions, open threads — or "Quiet" if nothing notable]

### #liatrio-forge
[Key updates, decisions, open threads — or "Quiet" if nothing notable]

### #liatrio-announcements
[Key updates, decisions, open threads — or "Quiet" if nothing notable]

### Other / Direct Mentions
[Any urgent or notable items directed at Taylor]

## ⚡ Prep Needed
[Bulleted list of specific, actionable prep items]

## 🔁 Open Loops
[Unanswered questions, pending decisions, items awaiting follow-up]
```

---

## Step 5 — Post to #taylor-briefing

Post the formatted briefing to Slack channel **C0B9BRZBGEA** (#taylor-briefing).

Use mrkdwn formatting:
- *bold* for section headers and event titles
- `---` dividers between sections
- Flag the phrase section, history, and headlines with their respective section headers
- Flag prep-needed items clearly
- Keep it scannable — morning read, not a report

Do NOT include any @mention of Taylor in the message — it will not trigger a notification and will render as literal text.

---

## Constraints
- Be concise. No filler or motivational language.
- Only flag prep items that are genuinely actionable.
- If a channel has no notable activity, write "Quiet" — do not omit the section.
- Output should be crisp and useful from the first line.
- Use the date provided at the top of this prompt — do not compute or assume today's date independently.