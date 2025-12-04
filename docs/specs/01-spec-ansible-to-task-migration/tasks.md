# Task List – Ansible-to-Task Migration

## Phase 1 – Foundations & Tooling
1. **Install go-task tooling**
   - Add prerequisite note in README for installing go-task.
   - Optionally add Homebrew tap entry if not already present.
2. **Document `.env` strategy**
   - Create `env/.env.example` with required keys (git names/emails/signing keys, SSH hosts, persona flag).
   - Update `.gitignore` to ensure `.env` (or `env/.env`) is ignored.
3. **Modernize `init.sh`**
   - Ensure script installs Homebrew (if needed) and then installs go-task automatically.
   - Drop the Ansible fallback; once go-task is present, always execute `task init`.
   - Fail fast with a helpful message if `Taskfile.yml` is missing.

## Phase 2 – Taskfile Structure
4. **Create `Taskfile.yml` skeleton**
   - Configure `version: '3'`, global vars, `dotenv: ['.env']` (or `env/.env`).
   - Define DRY_RUN handling helpers (e.g., template functions or env vars).
5. **Implement `bootstrap:prereqs` task**
   - Check/install oh-my-zsh.
   - Check/install Homebrew.
   - Log status clearly; honor DRY_RUN.
6. **Implement `brew:bundle` task**
   - Run `brew bundle` using existing Brewfile.
   - Add sub-task for dumping updates (`brew bundle dump --force`).
   - Ensure idempotence, e.g., skip if lockfile up-to-date.
7. **Implement `dotfiles:sync` task**
   - Move dotfiles assets (aliases/functions/globals) into a shared top-level `dotfiles/` directory.
   - Copy from `dotfiles/` to `~/.dotfiles/...`.
   - Ensure directories exist; compare checksums before copying when possible.
   - Add optional `dotfiles:pull` to sync from home directory back to repo.
8. **Implement `shell:zshrc` task**
   - Convert `zshrc.j2` template to envsubst-compatible format and place new `.tmpl` under `templates/` root.
   - Render into `~/.zshrc`, respecting DRY_RUN + idempotence.

## Phase 3 – Identity & Persona Handling
9. **Implement persona-aware git config**
   - Convert `gitconfig-template.j2` to new template language and store in `templates/`.
   - Task reads persona env vars (`PERSONA`, names/emails/signing keys) and writes aux gitconfig files.
   - Provide toggle to skip entirely if user disables git config.
10. **Implement persona-aware SSH config**
    - Convert `ssh_config.j2` accordingly and store alongside other `.tmpl` files.
    - Support multiple host entries via `.env` arrays or structured file (document format).
11. **Secrets loading + validation**
    - Task verifying required env vars exist before templating.
    - Provide friendly error messages when missing.

## Phase 4 – IDE & Windsurf Sync
12. **Extract current Windsurf settings + AI chat configuration**
    - Identify files (settings.json, keybindings.json, snippets, chat config from this session).
    - Store in a top-level `windsurf/` directory with documentation.
13. **Move iTerm2 profile to top level**
    - Relocate `com.googlecode.iterm2.plist` into a new `iterm2/` directory.
    - Document the expected source (export instructions) for updating the plist.
14. **Implement `ides:windsurf` task**
    - Copy/export files into `~/Library/Application Support/Windsurf/User/` (confirm exact path).
    - Provide DRY_RUN logging + idempotence (skip when identical).

## Phase 5 – Orchestration & UX
14. **Wire up `task init`**
    - Sequence tasks: prereqs → brew → dotfiles → shell → identities → ides.
    - Support flags (e.g., `SKIP_BREW=true task init`).
15. **Add targeted commands**
    - Ensure each major task has standalone invocation (`task brew`, `task dotfiles`, etc.).
    - Document use in README.
16. **Implement DRY_RUN + logging helpers**
    - Centralize echo helpers for start/finish/skipped states.
    - Add `task dry-run` shortcut if helpful.

## Phase 6 – Validation & Docs
17. **Testing + verification**
    - Run `task init` on a test machine; confirm idempotence (rerun, ensure no changes).
    - Capture dry-run output as proof artifact (log snippet).
    - Verify persona toggles.
18. **Documentation updates**
    - Update README Setup/Usage sections to reference Taskfile flow, `.env`, persona usage, dry-run.
    - Add notes for maintaining Brewfile/dotfiles and Windsurf exports.
19. **Cleanup**
    - Remove unused Ansible playbook/roles once parity achieved (or mark deprecated until confident).
    - Ensure repo scripts/tests reference new workflow only.
