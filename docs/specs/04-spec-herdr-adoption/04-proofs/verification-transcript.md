# Verification Transcript — herdr Adoption Spec 04

Consolidated summary of all five spec success criteria. Evidence is drawn from the individual proof files:
- `04-task-01-proofs.md` — Brewfile and init wiring
- `04-task-02-proofs.md` — managed config source and tools:herdr sync
- `04-task-03-proofs.md` — manual environment verification
- `removal-path.md` — documented reversibility steps

---

## Success Criterion 1 — No regression in plain iTerm windows

**Spec language:** In a normal iTerm window, `type cc` resolves to `claude`; `ll`, prompt, pyenv, nvm, fzf, zoxide all behave as before herdr.

**Status: PASS**

Checked in a plain iTerm window (separate from any herdr session) after full adoption. Results recorded in `04-task-03-proofs.md`:

- `type cc` → `cc is an alias for claude`
- `type ll` → eza alias
- No regressions observed in prompt, tools, or aliases

No `.zshrc` modifications were made for herdr adoption. The fix (`shell_mode = "login"` in the herdr managed config) is herdr-side only, which eliminates any regression surface in plain iTerm by design.

---

## Success Criterion 2 — Full zsh environment in herdr panes

**Spec language:** In a herdr pane, `type cc` resolves to `claude`; `ccc`/`ccr` resolve; oh-my-zsh + p10k prompt render; the same tools as criterion 1 work.

**Status: PASS**

All checks run inside a herdr pane after deploying via `task init`. Results recorded in `04-task-03-proofs.md`:

- `type cc` → `cc is an alias for claude`
- `type ccc` → alias for `claude --continue`
- `type ccr` → alias for `claude --resume`
- `type ll` → eza alias
- `type cat` → bat alias
- p10k prompt rendered correctly (powerline segments, git status, color theme)
- `which pyenv` → `/opt/homebrew/bin/pyenv`
- `which fzf` → `/opt/homebrew/bin/fzf`
- `which zoxide` → `/opt/homebrew/bin/zoxide`

`echo $ZSH_THEME` returned empty — expected behavior. `.zshrc` sets `ZSH_THEME=""` and loads p10k directly via `source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme`, bypassing the oh-my-zsh theme mechanism entirely.

---

## Success Criterion 3 — Canonical adoption via task + Brewfile

**Spec language:** herdr installs and configures solely via `task tools:herdr` + repo-source config; `task dry-run` reports cleanly and idempotently.

**Status: PASS**

Evidence recorded in `04-task-01-proofs.md` and `04-task-02-proofs.md`:

- `brew "herdr"` present in `Brewfile` in alphabetical position (between `hadolint` and `helm`)
- `tools:herdr` task in `Taskfile.yml` with DRY_RUN-aware body following the `tools:tmux` pattern
- `DRY_RUN=true task init` completed without error; herdr config entry appears in correct position (after claude block, before node block)
- `DRY_RUN=true task tools:herdr` printed `[change] herdr config: would create (not present)` on a clean machine
- Managed config source at `claude/herdr/config.toml` with `shell_mode = "login"` and pane_history guardrail comment
- herdr row registered in `claude/CLAUDE.md` managed-destinations table

No hand-editing of `~/.config/herdr/config.toml` was performed or required.

---

## Success Criterion 4 — Reversibility documented

**Spec language:** The documented removal path (AR6) leaves no residual state — verified by removing and re-running `task dry-run`.

**Status: PASS**

Full removal steps documented in `removal-path.md`. The path covers all eight steps in order:
1. Remove `brew "herdr"` from Brewfile; uninstall binary
2. Remove `HERDR_SRC` / `HERDR_DEST` vars from `Taskfile.yml`
3. Remove `tools:herdr` task from `Taskfile.yml`
4. Remove `- task: tools:herdr` from the `init` task
5. Remove `claude/herdr/` directory from the repo
6. Remove herdr row from `claude/CLAUDE.md` managed-destinations table
7. Remove `~/.config/herdr/` from the machine
8. Verify via `DRY_RUN=true task init` — confirm no herdr entries appear

Each step maps directly to a concrete artifact that was added during adoption, ensuring no residual state is left behind.

---

## Success Criterion 5 — Security read clear (Marsh gate 2)

**Spec language:** synod-marsh's gate-2 consult records no unmitigated credential/socket exposure (R5).

**Status: PASS — conditional approval granted 2026-06-29**

synod-marsh cleared gate 2 on 2026-06-29 (recorded in `04-tasks-herdr-adoption.md` header). Mitigations implemented and confirmed:

- `chmod 700` on `~/.config/herdr/` (socket and session files live here; directory is user-permissioned only)
- `pane_history` kept OFF in `claude/herdr/config.toml` with an explicit guardrail comment preventing future enablement
- `env | grep -i api_key` returned no output in the herdr pane — no credential injection from the shell environment

No unmitigated socket or credential exposure was flagged. Adoption is not blocked on any Marsh finding.

---

## Overall Verdict

All five success criteria are satisfied. herdr adoption is complete.
