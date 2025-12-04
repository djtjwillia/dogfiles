# Spec – Ansible-to-Task Migration

## 1. Summary
Migrate the current Mac provisioning workflow from Ansible playbooks to a Taskfile-based runner that preserves the critical capabilities (dotfiles, Homebrew bootstrap, zshrc templating, git/ssh config, and IDE setup) while improving ergonomics. The new system must deliver a single entrypoint (`task init`) with idempotent, safe execution, optional dry-run mode, and richer validation/logging. Configuration secrets move to an untracked `.env`, and the workflow must make it easy to keep Brewfile/dotfiles up to date plus support personal vs. work identities on the same Apple Silicon Mac.

## 2. Goals
1. Replace `ansible-playbook` usage with `Taskfile.yml`, removing the dependency on Ansible entirely.
2. Provide a one-command bootstrap (`task init`) that orchestrates prerequisite installers, Brew bundling, dotfiles templating, and IDE configuration (Windsurf replacing VSCode setup).
3. Preserve ability to manage git and ssh configs via templates/files but make the new structure modular so those pieces can be toggled off without code surgery.
4. Centralize secrets (git signing keys, SSH identities) via an untracked `.env`, surfaced as Task env vars.
5. Ensure idempotent runs with pre-checks, dry-run capability, and detailed logging per step.
6. Enable future extensibility for Brewfile/dotfiles updates and per-machine overrides (e.g., work-only tasks or persona toggles).

## 3. Non-Goals
- Supporting non-macOS hosts or Intel-specific divergence (Apple Silicon assumed default).
- Re-architecting dotfiles content itself (only delivery mechanism changes).
- Managing GUI installers that currently require manual intervention beyond existing init script scope.
- Building a full CI bootstrap flow (should remain possible later but not implemented now).

## 4. User Stories
1. **Single-command bootstrap** – As the repo owner, I run `task init` on a fresh Apple Silicon Mac and get all prerequisites (oh-my-zsh, Homebrew, Brew bundle, dotfiles, Windsurf config) applied without touching Ansible.
2. **Safe rerun** – After partially configuring a machine, I re-run `task init` and nothing breaks or re-copies files unnecessarily; the command reports that everything is already up to date.
3. **Persona override** – I specify whether I’m bootstrapping a personal or work identity (or both) and the correct git/ssh config templates are applied, pulling secrets from `.env`.
4. **Selective updates** – I invoke targeted tasks (e.g., `task dotfiles:update`, `task brew:bundle`) when iterating on Brewfile/dotfiles without re-running the full bootstrap.

## 5. Functional Requirements
| ID | Requirement |
| --- | --- |
| FR1 | Introduce `Taskfile.yml` with a default `init` task orchestrating prerequisite installers, Brew bundling, and config tasks. |
| FR2 | Break orchestration into logical sub-tasks: `bootstrap:prereqs`, `brew:bundle`, `dotfiles:sync`, `shell:zshrc`, `identities:git`, `identities:ssh`, `ides:windsurf`. Each task must be callable independently. |
| FR3 | Implement environment handling via an untracked `.env` (documented sample) loaded by Task; variables include git name/email/signing key and ssh hosts. |
| FR4 | Preserve existing dotfiles assets (aliases, functions, globals) but convert copy logic from Ansible modules to shell/file ops within Task commands. |
| FR5 | Replace VSCode automation with Windsurf config sync sourced from the current Windsurf profile (this machine’s settings + AI chat settings), copied into the correct user config directory. |
| FR6 | Add persona switch (e.g., `PERSONA=personal|work|both`) controlling which git/ssh templates are rendered or skipped. |
| FR7 | Provide a dry-run flag (`DRY_RUN=true task init`) that prints intended actions without mutating state; tasks must honor the flag. |
| FR8 | Emit structured logging per task (start/end, skipped because up-to-date, errors) and exit non-zero on failure. |
| FR9 | Include validation steps before destructive actions (e.g., check file hashes/mtime before overwriting, verify directories exist, ensure Brewfile present). |
| FR10 | Provide documentation (`docs/specs/.../spec.md` + README update) explaining how to install go-task, manage `.env`, run init, and toggle components. |

## 6. Technical Considerations
- **Tooling Choice**: go-task (`Taskfile.yml`) selected over Just/Make for cross-platform convenience, YAML familiarity, and richer task features.
- **Prerequisite Installer**: Convert `init.sh` responsibilities into Task tasks: install oh-my-zsh, check/install Homebrew, run `brew bundle`. Retain `init.sh` as a thin shim that simply invokes `task init` for familiarity.
- **File Operations**: Use shell commands via Task (`cmds`) for copying/templates. For templating, leverage envsubst or gomplate; if simple variable substitution suffices, `envsubst` with `.env` exports is acceptable.
- **Templates**: Existing Jinja2 templates must be ported to a format consumable by chosen templater (e.g., `envsubst` with `${VAR}` placeholders). Document how persona-specific values map to env vars.
- **Windsurf Config**: Snapshot the current Windsurf profile (settings, keybindings, snippets, AI chat settings from this conversation) and copy them into the repo; need to confirm destination path (likely `~/Library/Application Support/Windsurf/User/`).
- **Idempotence**: Track state via checksum comparison or `test -e` + diff before copy; optionally store stamp files in `~/.dogfiles/state`. Emphasize "no-op when unchanged" semantics.
- **Dry Run**: Implement by wrapping commands with conditionals. Example pattern: `cmds: ['{{if not .DRY_RUN}} actual command {{else}}echo "DRY: ..."{{end}}']` using go-task templating.
- **Logging**: Standardize `echo "[task] message"` plus Task’s native output. Optionally tee to log file in repo.

## 7. Persona & Secrets Handling
- `.env` keys (document in example file): `GIT_USER_PERSONAL`, `GIT_EMAIL_PERSONAL`, `GIT_SIGNINGKEY_PERSONAL`, `SSH_HOST_WORK`, etc.
- Provide `env/.env.example` showing structure; actual `.env` stays `.gitignore`d.
- Task runtime loads `.env` using `dotenv: ['.env']` feature so values are available in tasks.

## 8. Extensibility Plan
- Design Taskfile so Brewfile updates are just `brew bundle dump` + `task brew:bundle`.
- Dotfiles updates: keep sources in repo; `task dotfiles:sync` copies into `~`. Provide `task dotfiles:pull` to grab changes from `~` back into repo for iteration.
- Per-machine overrides: allow `PERSONA` env plus optional `config/machines/<name>.yaml` to toggle tasks (future hook). Minimal requirement: env-based gating with defaults.

## 9. Validation & Demo Criteria
1. **Bootstrap Demo**: Fresh Apple Silicon Mac (or clean user) runs `task init` with populated `.env`; verify oh-my-zsh, Homebrew, Brew bundle, dotfiles, Windsurf config applied.
2. **Idempotence Demo**: Re-run `task init`; log should mark tasks as skipped/up-to-date and no files change (check via `git status` and timestamps).
3. **Dry Run Demo**: Run `DRY_RUN=true task init`; command outputs planned actions without modifying files (`test` of targeted file mtimes proves no change).
4. **Persona Toggle Demo**: Run `PERSONA=work task init` and confirm work-specific git/ssh config applied; run `PERSONA=personal` for personal values.
5. **Targeted Tasks Demo**: Run `task dotfiles:update` after editing repo files and see only dotfile sync occurs.

## 10. Open Questions / Follow-ups
1. Confirm Windsurf settings directory + list of files that must be synced (settings.json, keybindings, snippets, AI chat config?).
2. Decide templating engine (envsubst vs gomplate vs simple heredoc) for replacing Jinja2 functionality—preference?
3. Retain `init.sh` as a thin wrapper calling `task init` for compatibility.

---
Next step after approving this spec: generate a detailed task list (`/generate-task-list-from-spec`) covering Taskfile creation, template conversions, `.env` handling, documentation updates, and migration rollout.
