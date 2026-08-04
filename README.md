# dogfiles

this cowdog has dotfiles!

Development environment as code. A single `task init` provisions a macOS workstation — Homebrew packages, shell, git identities, terminal — **and** a fully codified [Claude Code](https://docs.anthropic.com/en/docs/claude-code) setup. Both are managed with the same rigor as production infrastructure: idempotent, rendered from a canonical source, reviewable in git, and dry-run-able before anything touches the machine.

The repo is the source of truth. Deployed destinations (`~/.claude`, `~/.dotfiles`, `~/.gitconfig`, …) are outputs — never hand-edited.

## Claude Code setup

The `claude/` directory is a version-controlled Claude Code configuration, synced to `~/.claude` by task targets. It treats an agentic coding workflow as infrastructure worth codifying and reviewing.

**What lives in `claude/`:**

- **`CLAUDE.md` + `charter-details.md`** — a structured multi-agent operating model. The core rules load on every session; the detail file is referenced on demand to keep context lean. The model is explicit about how the assistant behaves: **plan by default** (no file edits until the user promotes the session), **proactive routing** to specialist subagents by domain, **staged write permissions** (plan → probe → narrow → wide), and **output gates** requiring verification steps and a rollback path on every plan. (It is themed as a "Synod Council" persona; the substance underneath is the operating model, not the theme.)
- **`agents/`** — 12 specialist subagent definitions (`synod-*.md`): architecture, security, data safety, CI/CD, docs/planning, debugging, code review, DX, dependency currency, UX, implementation, and routing. Each carries structured frontmatter with routing triggers and write/veto scope. Plus an `eval/` directory for scenario-based routing evals.
- **`commands/`** — custom slash commands (`run-evals`, `summary`).
- **`skills/`** — a vendored, customized `handoff` skill.
- **`herdr/config.toml`** — herdr config with `pane_history` disabled, so agent output (which can contain secrets) is never written to disk.
- **`scheduled/`** — scheduled task definitions.
- **`settings.json`** — Claude Code settings. **`statusline-command.sh`** — a custom statusline.

**How it syncs:**

- `task tools:claude` installs the config files, **mirrors** `agents/` (`rsync --delete` — pruning agents removed from the repo), and **additively** syncs `commands/`.
- `task tools:claude-skills` syncs repo-owned skills: additive at the top level, per-skill mirror within each owned skill directory.

The mirror-vs-additive split is deliberate. `~/.claude` is co-tenanted with skills and commands this repo does not own, so a blanket `--delete` would clobber them. Agents are fully owned (safe to mirror); commands and top-level skills are shared (additive only).

**External skills** — some Claude Code skills are installed straight from third-party repos via the [`vercel-labs/skills`](https://github.com/vercel-labs/skills) CLI (`task tools:claude-skills-external`) rather than vendored into `claude/skills/`. See [`docs/external-skills.md`](docs/external-skills.md) for the full list and the rationale for what is excluded.

## Setup

1. Install [go-task](https://taskfile.dev/): `brew install go-task/tap/go-task`. (`init.sh` also installs it if missing.)
2. Set up SSH auth and commit-signing keys. If your signing key differs from your auth key, add it with `ssh-add`.
3. Run `./init.sh` (or `task init` directly). `init.sh` ensures go-task is present, then runs `task init`.

`task init` runs, in order:

```
brew:bundle → brew:upgrade → dotfiles:sync → tools:zshrc → config:git
→ tools:iterm2 → tools:p10k → tools:tmux → tools:dev-script
→ tools:claude → tools:claude-skills → tools:herdr → tools:node
```

`bootstrap:prereqs` (oh-my-zsh, Homebrew, tpm, zsh plugins) runs automatically as a dependency of `brew:bundle`.

**Manual steps after `task init`:**

- iTerm2 → menu bar → `Make iTerm2 Default Term`.
- Node LTS + global npm packages are installed by `tools:node`; adjust versions with `nvm` if needed.
- Install Tailscale if you use it.

## Usage

Every target is idempotent — re-running `task init` is safe at any time.

- `task init` — full bootstrap.
- `task dry-run` — preview everything `task init` would do, without changing the machine (alias for `task init DRY_RUN=true`).
- `DRY_RUN=true task init` — same preview, invoked directly.
- `task help` — list all available tasks.
- `task dotfiles:sync` / `task dotfiles:pull` — push repo dotfiles to `~/.dotfiles`, or pull live edits back into the repo.
- `task brew:bundle` / `task brew:dump` / `task brew:upgrade` — install from, refresh, or upgrade the Brewfile.
- `task config:git` — install base gitconfig + per-identity includes + `allowed_signers`.
- `task tools:zshrc | tmux | p10k | iterm2 | dev-script | herdr | node` — install individual dotfiles/tools.
- `task tools:claude` / `task tools:claude-skills` / `task tools:claude-skills-external` — sync Claude config/agents/commands, repo-owned skills, and external skills respectively.

### Maintaining assets

- **Dotfiles** — edit inside `dotfiles/`, then `task dotfiles:sync` to apply (or `task dotfiles:pull` to bring live edits back).
- **iTerm2** — export preferences to `iterm2/com.googlecode.iterm2.plist`, then `task tools:iterm2` to install.
- **External skills** — installed via `task tools:claude-skills-external`; the human-readable index and exclusion rationale live in [`docs/external-skills.md`](docs/external-skills.md).

Keeping these directories as the source of truth keeps Taskfile changes predictable and reviewable.

## Design principles

- **Idempotence** — every task checks current state before acting; re-running `task init` is safe, and sync tasks no-op when nothing changed.
- **Dry-run safety** — `task dry-run` / `DRY_RUN=true task init` prints `[ok]` / `[change]` diffs without mutating the machine.
- **Persona separation** — work and personal identities are committed as per-identity git includes (`gitconfig-liatrio`, `gitconfig-personal`) plus `allowed_signers`, installed by `config:git`. Git's `includeIf` selects the identity by directory.
- **Secrets stay out of git** — `.gitignore` blocks private keys (`id_*`, `*_ed25519`, `*_rsa`, `*.pem`, `*.key`) and `.env`; only public `.pub` signing keys are committed. herdr `pane_history` is off so agent output — which can include secrets — is never written to disk.
- **Source-of-truth discipline** — the repo is canonical. Deployed destinations (`~/.claude`, `~/.dotfiles`, …) are rendered by task targets and never hand-edited.
</content>
</invoke>
