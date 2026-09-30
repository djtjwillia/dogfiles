# Daily note

Twice a day a Cowork scheduled task, bound to the work Mac, updates today's note in the `work` Obsidian vault in place. Granola and Wispr Flow meeting notes sync into the vault through two community plugins. A manual `/things-sync` pushes reviewed tasks into Things 3.

The module is opt-in and work-Mac only. It is **not** part of `task init`; run `task daily-note` (or one of its three sub-tasks) deliberately.

## Daily loop

1. **07:30 MT** (retrying hourly until 11:30 if the Mac was asleep) the morning pass creates the note. Open `## Risks` lines carry forward from the prior workday automatically. It fills Open loops (carried-over items plus Slack commitments), Calendar, and Needs attention.
2. The user reviews and edits the note.
3. `/things-sync` in Cowork sends unchecked tasks from Open loops and Action items to the Things Inbox, tagged `@promised`, with deadlines and an `obsidian://` back-link. Every to-do's notes end with `ref: dn-<key>`. Sent lines gain ` ⇢things`; a ledger prevents re-sends; matching uses the ref, never the title.
4. **16:08 MT** the evening pass links Wispr and Granola notes under Meetings, extracts meeting action items, and writes a Things status block under Action items (ref'd to-dos completed in the Logbook are flipped to `- [x]`, plus a still-open list and other ref'd to-dos due today or earlier). It refreshes Needs attention and drafts a paste-ready Slack EOD post under EOD post.
5. The user reviews, posts the EOD, and fills in the Ledger.

## Components

| Component | Location on the Mac | Source in this repo |
|---|---|---|
| Vault | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work` | — |
| Daily note template | `<vault>/daily-note-template.md` | `daily-note/vault/daily-note-template.md` |
| Helper script | `<vault>/.obsidian/scripts/daily_note.py` | `daily-note/vault/.obsidian/scripts/daily_note.py` |
| Daily Notes plugin settings | `<vault>/.obsidian/daily-notes.json` | `daily-note/vault/.obsidian/daily-notes.json` |
| Community plugin list | `<vault>/.obsidian/community-plugins.json` (union-merged; other plugins kept) | `daily-note/vault/.obsidian/community-plugins.json` |
| Granola Sync settings | `<vault>/.obsidian/plugins/granola-sync/data.json` (rendered, mode 600, `apiKey` from `GRANOLA_API_KEY`) | `.../granola-sync/data.json.tmpl` |
| Wispr Flow Sync settings | `<vault>/.obsidian/plugins/wispr-flow-sync/data.json` (seeded once; stores `latestSyncWatermark`) | `.../wispr-flow-sync/data.json` |
| Wispr Flow Sync plugin | `<vault>/.obsidian/plugins/wispr-flow-sync/{main.js,manifest.json}` (downloaded, pinned, sha256-verified) | `daily-note/wispr-flow-sync-0.1.3.sha256` |
| Local config | `<vault>/.obsidian/scripts/daily-note.local.json` (never committed) | `.../scripts/daily-note.local.example.json` |
| Skills | Cowork account skills; also `~/.claude/skills/` via `task tools:claude-skills` | `claude/skills/obsidian-daily-note/`, `claude/skills/things-sync/` |
| Things MCP | `claude_desktop_config.json` → `mcpServers.things` | `daily-note/claude_desktop_config.things.json` (snippet), `task daily-note:things-mcp` |
| Scheduled tasks | Cowork, server-side, bound to this Mac | [`daily-note/scheduled-tasks/morning-brief.md`](../daily-note/scheduled-tasks/morning-brief.md), [`evening-closeout.md`](../daily-note/scheduled-tasks/evening-closeout.md) (recreated by hand) |

Tasks, all accepting `DRY_RUN=true`:

| Task | Effect |
|---|---|
| `task daily-note:vault` | Template, helper, `daily-notes.json`, example config always converge to the repo. Wispr `data.json` and `daily-note.local.json` are created only when absent. Granola `data.json` is rendered per the security rules below. |
| `task daily-note:wispr-plugin` | Installs Wispr Flow Sync `WISPR_VERSION` after verifying sha256. |
| `task daily-note:things-mcp` | Pre-warms pinned `things-mcp`, discovers `THINGSDB`, merges `mcpServers.things`, prints Full Disk Access paths. |
| `task daily-note` | Runs the three above. |

Overrides: `VAULT_DEST`, `CLAUDE_DESKTOP_CONFIG`, `THINGSDB`, `THINGS_MCP_VERSION`, `WISPR_VERSION`, `DAILY_NOTE_SRC`.

## Manual steps on a new Mac

1. **Granola API key.** Granola → Settings → API. Export it in the shell that runs the task; never put it on the command line or in a file in this repo:
   ```sh
   export GRANOLA_API_KEY="$(security find-generic-password -w -s granola-api-key)"
   ```
   If unset, the task skips Granola `data.json` with a warning.
2. **Local config.** Edit `<vault>/.obsidian/scripts/daily-note.local.json` (seeded from the example by `task daily-note:vault`). Keys: `slack_user_id`, `eod_author`, `eod_channels`, `eod_secondary` (`channel`, `applies_to`), `things_work_area_id`, `things_work_area_title`. The skills read it with `python3 $S config`.
3. **Wispr Flow.** Install it and use Notetaker once. The plugin reads `~/Library/Application Support/Wispr Flow/flow.sqlite` read-only; there is no API.
4. **Things URLs.** Things → Settings → General → Enable Things URLs (keep the auth token on).
5. **Full Disk Access** for Things reads — see [Security](#security-and-residual-risk). Grant Claude.app first and test.
6. **`ThingsData-<id>` folder.** It differs per Mac; `task daily-note:things-mcp` discovers it (exactly one match required) or accepts `THINGSDB=`.
7. **Claude Desktop.** Quit it (Cmd-Q) before `task daily-note:things-mcp`, reopen after. Link the Cowork session to this Mac with the vault folder attached.
8. **Scheduled tasks.** Create both through a Cowork chat from the files under `daily-note/scheduled-tasks/`.
9. **Obsidian.** Turn Restricted mode off, install Granola Sync from the community store, reload once (Cmd-R) after the files are placed.

## Runbooks

### Wispr → Obsidian

1. Install Wispr Flow and run Notetaker once; this creates `flow.sqlite` and `meetings/*.ndjson`.
2. `task daily-note:wispr-plugin` then `task daily-note:vault`.
3. In Obsidian, Community plugins → Restricted mode off, Cmd-R. Enable "Wispr Flow Sync": folder `00-inbox/Wispr`, transcripts `00-inbox/Wispr/Transcripts`, 30-minute poll, summary as a `> [!summary]-` callout.
4. Verify: command palette → "Wispr Flow Sync: Sync now" produces `Title,YYYY-MM-DD,HH-MM-SS.md` files with `wispr_id:` frontmatter.

The evening pass links these notes under Meetings; the plugin has no daily-note linking.

Limits: desktop only; runs only while Obsidian is open; depends on Wispr's local schema, which can change with Wispr updates. Alternative (not implemented): `wispr-cli` plus launchd.

### Granola → Obsidian

Community plugin Granola Sync (v3.x) from the store, configured from `data.json.tmpl`. `dailyNoteLinkHeading` is `## Meetings` (H2); the plugin default `# Meetings` creates a duplicate H1 in the daily note. The plugin appends `- HH:MM - [[00-inbox/Granola/<file>|Title]]` under `## Meetings`. After changing `data.json` on disk, reload Obsidian before the next 30-minute sync, or the plugin rewrites the file from memory.

### Things 3 MCP

1. `uv` comes from the Brewfile.
2. `task daily-note:things-mcp` pre-warms the pinned `things-mcp`, discovers `THINGSDB`, prints the Full Disk Access paths, and merges the config. The merged entry has this shape (see `daily-note/claude_desktop_config.things.json`):
   ```json
   {"mcpServers": {"things": {
     "command": "/opt/homebrew/bin/uvx",
     "args": ["--from", "things-mcp==0.8.1", "things-mcp"],
     "env": {"THINGSDB": "…/ThingsData-XXXXX/Things Database.thingsdatabase/main.sqlite"}
   }}}
   ```
3. `THINGSDB` is required on Things 3.15+. The database lives in a per-Mac `ThingsData-XXXXX` folder; without the variable, a privacy-blocked listing makes the server fall back to a legacy path, and every read fails with `unable to open database file`.
4. Quit and reopen Claude. In a Cowork session linked to this Mac the tools appear as `mcp__remote-devices__things__*` (`add_todo`, `update_todo`, `search_todos`, `get_logbook`, `get_inbox`, `get_today`).
5. Smoke test: `search_todos("ref: dn-")` returns without error.

Server: <https://github.com/hald/things-mcp>. Destination policy: Inbox only, tag `@promised`, deadline from the note, `obsidian://` back-link. Fallback when the MCP server is unavailable: `/things-sync` writes a one-click `things:///add-json` link into Action items; clicking it twice creates duplicates.

### Cowork prerequisites

- Session linked to this Mac with the vault folder attached; `device_bash` sees the vault at `$HOME/mnt/work`.
- `.claude/` paths inside connected folders are blocked; this is why the helper lives under `.obsidian/scripts/`.
- Connectors: Slack, Google Calendar, Granola. Wispr is read from vault files.
- The Mac must be awake with Claude Desktop running at fire time. The morning task self-heals hourly until 11:30; the evening task does not (rerun `/obsidian-daily-note evening` by hand).

## Verification checklist

- [ ] Helper with no args prints usage; `ensure` creates today's note with the correct date and weekday in frontmatter and H1.
- [ ] Obsidian Daily Notes points at `10-daily` and `daily-note-template.md`; a new daily note renders `{{date:dddd, MMMM D}}` correctly.
- [ ] Granola Sync and Wispr Flow Sync are enabled; "Sync now" on each produces files under `00-inbox/Granola` and `00-inbox/Wispr`.
- [ ] Granola links land under `## Meetings` (H2) with no stray `# Meetings` H1.
- [ ] `python3 $S config` prints the local config.
- [ ] Cowork `/obsidian-daily-note morning` fills Open loops, Calendar, and Needs attention, leaves everything else untouched; run twice, the note is identical.
- [ ] Add `- [ ] test risk — me — 10/1` under Risks, run `ensure` for the next workday: it appears with `(since …)`; a second `carry-risks` prints `risks already carried`; the risk is absent from Open loops and `things-extract`.
- [ ] Complete a hand-made to-do in a Work project (no ref) and one in Life; the evening pass lists only the Work one under `also done in Things today (not from this note)` and in the EOD draft.
- [ ] Things reads work: `search_todos("ref: dn-")` returns without `unable to open database file`.
- [ ] `/things-sync` creates Inbox to-dos tagged `@promised` whose notes end `ref: dn-<key>`; lines gain ` ⇢things`; the ledger has entries; a second run sends nothing.
- [ ] Rename one synced to-do and complete it; the evening pass still flips its note line to `- [x]`.
- [ ] `/obsidian-daily-note evening` writes Action items (plus the status block), Needs attention, and an EOD block in the exact `<eod_author> EOD :sunset: D-Mon-YYYY` format.
- [ ] Both scheduled tasks exist, show "requires this computer", and the last run SUCCEEDED.

## Design notes

- **One write path.** All programmatic edits go through `set-section`: content between claude markers inside one `## Heading`; user text outside is never touched; reruns replace the block; a missing heading is inserted before `## Ledger`. PASS names: `morning`, `evening`, `attention` (shared so evening replaces morning), `status` (Things check, a second block in Action items), `things` (fallback link). Multiple PASS blocks coexist. Writes are atomic (temp file plus `os.replace`).
- **Risks.** `## Risks` is a user-owned running list. `ensure`/`carry-risks` copies the prior workday's unticked lines once, stamps `(since Ddd M/D)`, and drops `<!-- risks carried from YYYY-MM-DD -->` so reruns no-op. It is plain user text, not a claude block, and is excluded from `open-items`, `promised`, and Things extraction.
- **Template.** Deliberately terse; section names are the contract; `## Meetings` must exist. Older notes have legacy headings; the helper and skills read both.
- **Things identity.** key = sha1(normalized raw note line)[:12], never changed (title cleanup happens after keying). Every to-do carries `ref: dn-<key>` as the last notes line, so renames, moves, and reschedules do not break status. To-dos without a ref are invisible by design.
- **Work scope** is structure, not tags: the Logbook returns `project_title`/`area_title`, never tags. Area Work, or a project in the Work area, resolved through `get_projects` each run. Inbox and Life are ignored. File work to-dos in a Work project to have them counted.
- **Open vs done.** `search_todos` returns open to-dos only; completed ones appear only in the Logbook. Status builds two sets and looks up done, then open.
- **Push dedupe, three layers:** the ledger (authoritative), `search_todos` by `dn-<key>` then by normalized title, and the visible ` ⇢things` marker.
- **Backfilling refs:** `update_todo(id, notes=<existing notes + "\nref: dn-<key>">)` with keys from `things-sent DATE`; never change the title.
- **Catch-up.** The hourly morning firing substitutes for "run on wake" (there is no wake trigger).
- **Time zones.** Wispr Flow Sync names files in UTC; Granola uses local time. `meetings` trusts the `created:` frontmatter converted to America/Denver and scans the next day's UTC-dated files.
- **Schedule.** Morning at :30 (07:30–11:30) and evening at 16:08 stay off the on-the-hour rush. Catch-up firings cost one grep and reply "already done". Narrow the hours to `7-9` to cut noise.
- **Scaling limits.** Vault discovery and hard-coded section names would need a config file; Slack "promise" heuristics need per-person tuning; the ledger should move to per-note frontmatter to survive sync conflicts.
- **Input hardening.** Dates must match `^\d{4}-\d{2}-\d{2}$`; PASS must match `^\w+$`; claude markers inside stdin are neutralized (`<!--` → `&lt;!--`); `set-section` refuses to write when a section has duplicate or unbalanced markers for the PASS (exit 3).

## Local config

`<vault>/.obsidian/scripts/daily-note.local.json` holds every engagement-specific identifier: Slack user id, EOD channels, Things work area. It is created from `daily-note.local.example.json` by `task daily-note:vault`, never overwritten, and ignored by git (`*.local.json`). Skills and scheduled-task prompts load it with `python3 "$HOME/mnt/work/.obsidian/scripts/daily_note.py" config`, which exits 1 with a message when the file is missing. Never copy it, the Things ledger (`things-sync.json`), or a rendered Granola `data.json` into this repo; `.gitignore` blocks them.

## Security and residual risk

**Granola API key.**
- Rendered with `jq '.apiKey = $ENV.GRANOLA_API_KEY'` from the environment at run time; never placed on a command line, echoed, or written by `envsubst`.
- Written via a temp file in the destination folder, validated (non-empty, not the `${GRANOLA_API_KEY}` placeholder), chmod 600, then moved into place.
- An existing real key is never overwritten; rotation = clear `apiKey` in the file, export the new key, rerun.
- Dry run reports only whether a key is present and whether it would create, skip, or preserve the file; it never prints key material.
- Residual risk: the vault is in iCloud, which is not end-to-end encrypted without Advanced Data Protection, and every Obsidian community plugin can read `data.json`. Rotate the key from Granola → Settings → API if the vault or a plugin is ever in doubt, then reload Obsidian.

**Full Disk Access (manual; the task only prints paths).** Grant in this order and test after each: Claude.app first; add the real `uvx` (`realpath "$(command -v uvx)"`) and Homebrew `Python.app` only if Things reads still fail.

> Granting Full Disk Access to `uvx` or Homebrew `Python.app` gives every Python script and uvx-launched tool on this machine unrestricted read access to protected data (Mail, Messages, Safari history, other apps' containers) — not just Things. Granting it to Claude.app extends it to every MCP server Claude Desktop launches. Revoke in System Settings → Privacy & Security → Full Disk Access when no longer needed.

**Supply chain.**
- Wispr Flow Sync is fetched with `curl -fsSL --proto '=https' --tlsv1.2` into a temp directory and verified against the committed `daily-note/wispr-flow-sync-0.1.3.sha256` (`shasum -a 256 -c` format) before being moved into place. A mismatch is a hard failure. "Already installed" requires matching version **and** matching hashes; a version match with a hash mismatch warns of modification and reinstalls. There is no trust-on-first-use path. Bumping `WISPR_VERSION` requires a human to review the release's `main.js` against the tagged source and commit a new `.sha256` file.
- `things-mcp` is pinned to an exact version in both the pre-warm and the config `args`. Its transitive dependencies are resolved by uv at install time and are not pinned; `uvx --from things-mcp==X` caches the resolved environment. Bump `THINGS_MCP_VERSION` deliberately after checking the PyPI project URLs still point at `github.com/hald/things-mcp`.

**Config files.** `claude_desktop_config.json` is merged under `jq` touching only `.mcpServers.things`: timestamped chmod-600 backup, temp file in the same directory, validity and other-keys-unchanged assertions, chmod 600, move. An existing invalid JSON file aborts the task. The task output shows only the `things` entry, never the whole file.

**Synced state.** The local config and the Things ledger sync through iCloud with the vault. Neither belongs in the repo.
