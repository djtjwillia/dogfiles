# dogfiles — AI Agent Instructions

This is a dotfiles repository. Files here are the **canonical source of truth**. Changes are applied to the machine by running task targets — never by editing deployed files directly.

## Critical constraint

**Do not edit files outside this repository.**

The following paths are managed destinations, not sources. Editing them directly creates drift between the repo and the machine that will be silently overwritten the next time a task runs:

| Destination | Source in this repo | Task target |
|-------------|---------------------|-------------|
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` | `task tools:claude` |
| `~/.claude/charter-details.md` | `claude/charter-details.md` | `task tools:claude` |
| `~/.claude/settings.json` | `claude/settings.json` | `task tools:claude` |
| `~/.claude/statusline-command.sh` | `claude/statusline-command.sh` | `task tools:claude` |
| `~/.claude/agents/` | `claude/agents/` | `task tools:claude` |
| `~/.claude/commands/` | `claude/commands/` | `task tools:claude` |
| `~/.claude/skills/` | `claude/skills/` | `task tools:claude-skills` |
| `~/.dotfiles/` | `dotfiles/` | `task dotfiles:sync` |
| `~/.zshrc` | `dotfiles/.zshrc` | `task tools:zshrc` |
| `~/.gitconfig` (and identity includes) | `dotfiles/gitconfig*` | `task config:git` |
| `~/.tmux.conf` | `dotfiles/.tmux.conf` | `task tools:tmux` |
| `~/.p10k.zsh` | `dotfiles/.p10k.zsh` | `task tools:p10k` |
| `~/.local/bin/dev` | `dotfiles/dev` | `task tools:dev-script` |
| `~/Library/Preferences/com.googlecode.iterm2.plist` | `iterm2/` | `task tools:iterm2` |
| `~/.config/herdr/config.toml` | `claude/herdr/config.toml` | `task tools:herdr` |
| Obsidian work vault: template, helper, `.obsidian/` settings, plugin configs | `daily-note/vault/` | `task daily-note:vault` |
| `~/Library/Application Support/Claude/claude_desktop_config.json` (`mcpServers.things` only) | `daily-note/claude_desktop_config.things.json` | `task daily-note:things-mcp` |

> Note: `~/.config/herdr/` must not be committed to the repo; `pane_history` must remain off in managed config to prevent plaintext agent output (which can include secrets) from being written to disk.

## Daily-note helper

`daily-note/vault/.obsidian/scripts/daily_note.py` is the only thing allowed to edit daily notes programmatically. It must stay idempotent: edits happen only inside `<!-- claude:begin PASS --> … <!-- claude:end PASS -->` markers (plus the one-time `## Risks` carry). Never commit `daily-note.local.json`, `things-sync.json`, or a rendered Granola `data.json`; they hold engagement identifiers and secrets and are gitignored. See `docs/daily-note.md`.

## Workflow

1. **Edit only files within this repository.**
2. Commit and push changes.
3. Apply to the machine by running the relevant task target (or `task init` for a full sync).

To preview what would change without applying anything:

```sh
task dry-run
```

To apply all changes:

```sh
task init
```

## Read-only references

If you need to understand what is currently deployed, read the files in this repo — they are the source. Do not read the deployed destinations to inform edits; they may be stale or manually modified.
