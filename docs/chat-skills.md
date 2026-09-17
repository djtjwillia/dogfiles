# Chat skills

`claude/skills-chat/` holds claude.ai-chat / Claude Desktop variants of two of
this repo's Claude Code skills: `obsidian-summary` and `obsidian-transcript`.

## Why a separate variant

Claude Code skills in `claude/skills/` assume a Claude Code session: a git
repo to derive project/branch names from, a local filesystem to write vault
notes to directly, and (for `obsidian-transcript`) a session JSONL file to
read the exact conversation history from. None of that exists in the claude.ai
/ Claude Desktop chat sandbox — there's no filesystem access to the user's
Mac, no git, and no session log to read back.

The chat variants adapt accordingly:

- Project/label are asked for (or inferred from the conversation subject)
  instead of read from `git branch` / `git rev-parse`.
- Notes are written to `/mnt/user-data/outputs/` and offered as a download,
  instead of being written straight into the vault by a `write-to-vault.sh`
  script. Neither `write-to-vault.sh` nor `render-transcript.sh` exist in the
  chat variants — they depend on local disk access the sandbox doesn't have.
- `obsidian-transcript` reconstructs the transcript from what's visible in
  the conversation (numbering turns instead of timestamping them) rather than
  parsing a session JSONL file, and says so explicitly in the note as a
  model-reproduced, not byte-exact, record.
- There's no Synod Council agent roster in a chat session, so the `agents:`
  frontmatter field and "Agent Findings" section are dropped from the
  `obsidian-summary` templates.

The user downloads the resulting `.md` file and drops it into the vault
folder the skill tells them to use — the same `50-notes/...` layout the
Claude Code variants write to directly.

## Building the upload zips

```sh
task tools:claude-skills-chat-zip
```

This zips each directory under `claude/skills-chat/` into
`dist/skills-chat/<name>.zip`, with the skill's folder (containing
`SKILL.md`) at the zip's top level — the shape claude.ai's skill uploader
expects. `dist/` is gitignored; these zips are build output, not source.

Preview without writing anything:

```sh
DRY_RUN=true task tools:claude-skills-chat-zip
```

This target is **not** part of `task init` — building and uploading a chat
skill is a manual, occasional action, not something every machine bootstrap
should repeat.

## Uploading to claude.ai / Claude Desktop

1. Run `task tools:claude-skills-chat-zip`.
2. In claude.ai or Claude Desktop, go to **Settings → Capabilities → Skills**.
3. Upload `dist/skills-chat/obsidian-summary.zip` and/or
   `dist/skills-chat/obsidian-transcript.zip`.
4. In a chat, ask Claude to save a summary or transcript to Obsidian. It will
   produce a downloadable `.md` file and tell you which vault folder to drop
   it into.

## Maintaining the chat variants

Edit inside `claude/skills-chat/<name>/SKILL.md` directly — these are not
generated from the Claude Code versions in `claude/skills/`. When the Claude
Code skill's behavior changes in a way that also applies to chat (e.g. a
template or callout convention), port the change by hand and note in the
commit message that it also covers the chat variant.
