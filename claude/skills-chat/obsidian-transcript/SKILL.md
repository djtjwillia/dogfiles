---
name: obsidian-transcript
description: Reproduce the full visible transcript of this conversation as an Obsidian-flavoured markdown file, ready to download and drop into your vault. Use when asked to save the transcript, export this chat to Obsidian, or log the full conversation.
---

## Purpose

Render the full visible conversation — every user message and assistant response, in order — to Obsidian-flavoured markdown, and produce it as a downloadable file. Unlike `obsidian-summary` (which distills the conversation into a curated note), this skill preserves the back-and-forth for cases where the full record matters more than a synthesis.

Tool results and extended thinking are never rendered, since tool output can contain secrets or excessive noise. The transcript is always user prompts, assistant prose, and one-line `> 🔧` tool-call markers.

> [!note] Chat runtime, not Claude Code
> This variant runs in claude.ai / Claude Desktop, which has no session JSONL to read from disk and no timestamps for individual turns. It works entirely from what is visible in this conversation, and numbers turns sequentially instead of timestamping them. It cannot write directly to your vault — it produces a downloadable `.md` file and tells you where to file it.

> [!warning] Model-reproduced, not byte-exact
> This transcript is reconstructed by the model from the visible conversation. It is not a byte-exact log the way the Claude Code variant (which reads the session's JSONL file directly) is. Long or heavily-edited turns may be paraphrased if reproducing them exactly would exceed what can be reliably reconstructed — call this out explicitly in the note if it happens for any turn.

---

## Step 1 — Establish scope

Count the visible turns in this conversation. Report:
> `→ This conversation has <n> turns.`

If the conversation is long enough that reproducing every turn verbatim in one file is impractical (very long turns, many turns, or content that risks exceeding a single response), say so plainly and offer to split it:
> This conversation is long enough that I may not reproduce it faithfully in a single file. I can split it into multiple files by turn range (e.g. turns 1–20, 21–40). Would you like that, or should I proceed with one file and flag any turn I had to shorten?

Do not silently summarise or shorten turns to make them fit — always flag it if it happens.

---

## Step 2 — Derive project, label, and filename

There is no git branch or repo here, so ask instead of inferring:

- **Project:** the subject/product/client this conversation is about. Propose from context if obvious; otherwise ask.
- **Label:** a short slug for this conversation (e.g. `pricing-page-copy`). Derive from the subject; ask only if unclear.
- **Engagement (optional):** note the slug if you know this maps to a named client/engagement in the vault; omit otherwise.
- **Filename:** `<YYYY-MM-DD>-transcript.md`.

Ask at most one combined question if project/label are unclear.

---

## Step 3 — Render and assemble

Frontmatter and title:

```markdown
---
type: transcript
project: <project>
label: <label>
date: <YYYY-MM-DD>
tags:
  - claude-chat
  - <project>
  - transcript
turns: <n>
---

# <label> — transcript — <date>

> [!warning] Model-Reproduced Transcript
> This is a model-reproduced transcript of the visible conversation, not a byte-exact log. Tool results and thinking are never included; only prompts, assistant replies, and one-line tool-call markers. Scan for secrets you typed yourself before syncing.
```

Then, for each turn in order:

```markdown
## 🧑 User — <n>

<verbatim user text>

---

## 🤖 Assistant — <n>

<verbatim assistant text>

> 🔧 `<tool>`: <one-line description of what it did — no results, no thinking>

---
```

Rules:
- Use turn numbers, not times — there are no timestamps in a chat conversation.
- Reproduce user and assistant text verbatim. Do not summarise, shorten, or paraphrase a turn unless it was flagged as too long in Step 1 — if so, mark it inline: `%%shortened — see note below%%`.
- Render tool calls as a single `> 🔧` line each: tool name + one-line description. Never include tool results or extended thinking.
- Separate turns with `---`.

---

## Step 4 — Preview and confirm

Show the first ~40 lines of the assembled note plus the total turn/line count — not the whole thing. Then ask:

> **Ready to save?** (`y` to confirm, `e` to edit first, `n` to cancel)

Do not produce the file until confirmed.

---

## Step 5 — Write the file and offer for download

Write the assembled markdown to `/mnt/user-data/outputs/<YYYY-MM-DD>-transcript.md` and offer it to the user as a download.

If `/mnt/user-data/outputs/` is not writable in this environment, fall back to printing the complete markdown in a fenced code block (or split across multiple messages if long) so the user can copy it manually.

---

## Step 6 — Tell the user where it goes

> ✓ Transcript ready: `<filename>`. Drop it into `50-notes/Transcripts/<project>/<label>/` in your vault.

If `obsidian-summary` was also used for this conversation, suggest linking the two:
> 💡 You may want to add `[[<label>/<date>-session]]` to this note to link it to the summary of the same conversation.
