# dogfiles — AI Agent Instructions

This is a dotfiles repository. Files here are the **canonical source of truth**. Changes are applied to the machine by running task targets — never by editing deployed files directly.

## Critical constraint

**Do not edit files outside this repository.**

The following paths are managed destinations, not sources. Editing them directly creates drift between the repo and the machine that will be silently overwritten the next time a task runs:

| Destination | Source in this repo | Task target |
|-------------|---------------------|-------------|
| `~/.Codex/AGENTS.md` | `Codex/AGENTS.md` | `task tools:Codex` |
| `~/.Codex/charter-details.md` | `Codex/charter-details.md` | `task tools:Codex` |
| `~/.Codex/settings.json` | `Codex/settings.json` | `task tools:Codex` |
| `~/.Codex/statusline-command.sh` | `Codex/statusline-command.sh` | `task tools:Codex` |
| `~/.Codex/agents/` | `Codex/agents/` | `task tools:Codex` |
| `~/.Codex/commands/` | `Codex/commands/` | `task tools:Codex` |
| `~/.Codex/skills/` | `Codex/skills/` | `task tools:Codex-skills` |
| `~/.Codex/hooks/synod/` (repo-owned subdir, mirrored with `rsync --delete`; includes `lib/` and `schemas/`) | `Codex/hooks/` advisory set (`factory-status.sh`, `secret-detector.sh`, `subagent-audit.sh`), `Codex/hooks/lib/`, `Codex/hooks/schemas/` | `task tools:Codex` |
| `~/.Codex/workflows/` (additive) | `Codex/workflows/` | `task tools:Codex` |
| `/Library/Application Support/Codex/managed-settings.json` | `Codex/managed-settings.json` | `sudo`-elevating `task tools:Codex-managed` (not in `task init`) |
| `/Library/Application Support/Codex/hooks/` (gate hooks, `lib/`, `schemas/`, `manifest.sha256`) | `Codex/hooks/` minus the advisory set | `task tools:Codex-managed` |
| `/Library/Application Support/Codex/.Codex/agents/` (veto seats + `factory-*`) | `Codex/agents/synod-{marsh,elend,tensoon,steris}.md`, `Codex/agents/factory-*.md` | `task tools:Codex-managed` |
| `/Library/Application Support/Codex/srt/` (sandbox runtime, pinned) | `Codex/srt/package.json` + `package-lock.json` | `task tools:Codex-managed` |
| `~/.dotfiles/` | `dotfiles/` | `task dotfiles:sync` |
| `~/.zshrc` | `dotfiles/.zshrc` | `task tools:zshrc` |
| `~/.gitconfig` (and identity includes) | `dotfiles/gitconfig*` | `task config:git` |
| `~/.tmux.conf` | `dotfiles/.tmux.conf` | `task tools:tmux` |
| `~/.p10k.zsh` | `dotfiles/.p10k.zsh` | `task tools:p10k` |
| `~/.local/bin/dev` | `dotfiles/dev` | `task tools:dev-script` |
| `~/Library/Preferences/com.googlecode.iterm2.plist` | `iterm2/` | `task tools:iterm2` |
| `~/.config/herdr/config.toml` | `Codex/herdr/config.toml` | `task tools:herdr` |

> Note: `~/.Codex/hooks/` itself is co-tenanted (`herdr-agent-state.sh` is not repo-owned); `task tools:Codex` only ever mirrors the `synod/` subdir. The managed tier (`/Library/Application Support/Codex/`) is root-owned and installed only by `task tools:Codex-managed`, which refuses to run as root or from a dirty tree; preview it with `DRY_RUN=true task tools:Codex-managed`. `task check` lints the hooks and JSON, then runs `task factory:selftest`.

> Note: `~/.config/herdr/` must not be committed to the repo; `pane_history` must remain off in managed config to prevent plaintext agent output (which can include secrets) from being written to disk.

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
