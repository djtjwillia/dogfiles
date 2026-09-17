---
name: obsidian-transcript
description: Save the full transcript of the current Claude Code session to the Obsidian vault. Use when asked to save the transcript, export this chat or conversation to Obsidian, or log the full conversation.
allowed-tools: Bash, Read
---

## Purpose

Render the complete transcript of the current Claude Code session — every user message and assistant response, in order — to Obsidian-flavoured markdown, and write it to the vault. Unlike `obsidian-summary` (which distills a session into a curated note), this skill preserves the raw back-and-forth for cases where the full record matters more than a synthesis.

Tool results and extended thinking are never rendered, since tool output can contain secrets or excessive noise. The transcript is always user prompts, assistant prose, and one-line `> 🔧` tool-call markers.

---

## Step 1 — Locate the session file

Compute the project slug from the current working directory: take `pwd`, then replace every `/` and `.` with `-`.

```bash
pwd | sed 's/[\/.]/-/g'
```

Find the most recently modified `*.jsonl` file in `~/.claude/projects/<slug>/`:

```bash
ls -t "$HOME/.claude/projects/<slug>"/*.jsonl 2>/dev/null | head -1
```

Read enough of the file to report:
- The `sessionId`
- An excerpt of the first user prompt (for confirmation this is the right session)
- A rough turn count (`jq -c 'select(.type=="user" or .type=="assistant")' <file> | wc -l`)

Show this and confirm before proceeding:
> `→ Session: <sessionId>` — first prompt: "<excerpt>" — `<n>` turns.
> Is this the right session? (y/n)

---

## Step 2 — Derive project, label, and filename

Same derivation as `obsidian-summary`:

```bash
git branch --show-current 2>/dev/null || echo "no-branch"
git rev-parse --show-toplevel 2>/dev/null || echo "no-repo"
```

- **Project:** final component of the repo root path.
- **Label:** branch name, with common prefixes (`feature/`, `fix/`, `chore/`, `bugfix/`, `hotfix/`) stripped; preserve ticket patterns.
- **Engagement (optional):** if the project maps to a `20-engagements/<NN_engagement-slug>` entry in the vault, note the slug for frontmatter; omit otherwise.
- **Filename:** `<YYYY-MM-DD>-transcript.md`.

Ask only about genuinely ambiguous components, same rules as `obsidian-summary`.

---

## Step 3 — Render and assemble

Render the transcript body:

```bash
bash ~/.claude/skills/obsidian-transcript/render-transcript.sh "<session.jsonl>" > /tmp/transcript-body.md
```

Prepend frontmatter and a title:

```markdown
---
type: transcript
project: <project>
branch: <full branch name>
label: <label>
date: <YYYY-MM-DD>
session_id: <sessionId>
engagement: <slug, if applicable — omit otherwise>
tags:
  - claude-code
  - <project>
  - transcript
turns: <n>
---

# <label> — transcript — <date>

> [!warning] Full Transcript
> Tool results and thinking are never included; only your prompts and the assistant's replies. Scan for secrets you typed yourself before syncing.
```

Concatenate frontmatter + rendered body into the final note content.

---

## Step 4 — Preview and confirm

Show the first ~40 lines of the assembled note plus the total line count — not the whole thing. Then ask:

> **Ready to write?** (`y` to confirm, `e` to edit first, `n` to cancel)

Do not write anything until confirmed.

---

## Step 5 — Write to vault

```bash
bash ~/.claude/skills/obsidian-transcript/render-transcript.sh "<session.jsonl>" | { cat /tmp/transcript-frontmatter.md; cat; } | bash ~/.claude/skills/obsidian-transcript/write-to-vault.sh "<project>" "<label>" "<filename>"
```

- `<project>` / `<label>` / `<filename>` — as derived in Step 2.

Pass the full assembled markdown via stdin. The script defaults to the `work` vault at `$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/work` and the `50-notes` root; override with `OBSIDIAN_VAULT` / `OBSIDIAN_NOTES_ROOT` if needed. Notes land under `50-notes/Transcripts/<project>/<label>/`. If the script fails, show the error and offer to print the markdown to the terminal for manual saving.

---

## Step 6 — Confirm and link

Report the path written to using the script's stdout output:
> ✓ Saved to `<path from script>`

If `obsidian-summary` was also used for this session, suggest linking the two:
> 💡 You may want to add `[[<label>/<date>-session]]` to this note to link it to the summary of the same session.

---

## Context monitoring

When invoked manually, skip any preamble and go straight to Step 1.
