# 04-tasks-herdr-adoption.md

> **Status: TASK LIST — sub-tasks generated. Planning audit TBD.**
>
> Gates cleared: synod-vendell (2026-06-29), synod-marsh (2026-06-29).
>
> **Material spec correction (vendell Gate 1):** herdr installs only a binary named `herdr` — no `cc` binary is dropped. P1 (`cc` alias shadowed) was caused entirely by P2: a non-login pane never sourced `.zshrc`, so `alias cc='claude'` never loaded and `cc` fell through to the system compiler (gcc is in the Brewfile). `shell_mode = "login"` fixes both symptoms with one change.
>
> **Install approach:** herdr is installed via `Brewfile` + `task brew:bundle`. `task tools:herdr` manages configuration only — no install logic.

## Relevant Files

| File | Why It Is Relevant |
| --- | --- |
| `Brewfile` | Add `brew "herdr"` so herdr is installed by the existing brew workflow |
| `Taskfile.yml` | Add `tools:herdr` target (config sync only) and wire it into the `init` task |
| `claude/herdr/config.toml` | New managed config source — create this file |
| `CLAUDE.md` | Add managed-destinations row for herdr config with Marsh guardrail note |
| `docs/specs/04-spec-herdr-adoption/04-proofs/verification-transcript.md` | AR7 proof — shell sessions confirming environment in pane and plain iTerm |
| `docs/specs/04-spec-herdr-adoption/04-proofs/removal-path.md` | AR6 — step-by-step removal instructions |

### Notes

- Follow the `tools:tmux` / `tools:claude` patterns in `Taskfile.yml` for DRY_RUN handling, `[ok]`/`[change]` output, and `install -m 0644` for single-file syncs.
- Taskfile vars follow the `CLAUDE_SRC` / `CLAUDE_DEST` pattern: declare `HERDR_SRC` and `HERDR_DEST` at the top of the vars block.
- `chmod 700` the `~/.config/herdr/` directory on creation (Marsh guardrail — socket and session files live here).
- All edits to `CLAUDE.md` go to `claude/CLAUDE.md` (the repo source), not the deployed `~/.claude/CLAUDE.md`.

## Tasks

### [x] 1.0 Add herdr to the Brewfile and wire `task tools:herdr` into init

#### 1.0 Proof Artifact(s)

- CLI: `DRY_RUN=true task init` output includes herdr config entry without error — demonstrates wiring
- Diff: `Brewfile` contains `brew "herdr"` in alphabetical position — demonstrates install managed via brew
- Diff: `Taskfile.yml` `init` task calls `task: tools:herdr` — demonstrates wiring into bootstrap

#### 1.0 Tasks

- [x] 1.1 Add `brew "herdr"` to `Brewfile` in alphabetical order (between `hadolint` and `helm`)
- [x] 1.2 Add `HERDR_SRC` and `HERDR_DEST` vars to the `vars:` block in `Taskfile.yml`, following the `CLAUDE_SRC`/`CLAUDE_DEST` pattern:
  - `HERDR_SRC: '{{default "claude/herdr/config.toml" .HERDR_SRC}}'`
  - `HERDR_DEST: '{{default "$HOME/.config/herdr/config.toml" .HERDR_DEST}}'`
- [x] 1.3 Add a `tools:herdr` task stub to `Taskfile.yml` with `desc: Sync herdr config into place` — body implemented in task 2.0
- [x] 1.4 Add `- task: tools:herdr` to the `init` task in `Taskfile.yml`, after `tools:claude` and before `tools:node`

---

### [x] 2.0 Create managed herdr config source and implement `tools:herdr` sync

#### 2.0 Proof Artifact(s)

- Diff: `claude/herdr/config.toml` exists with `default_shell`, `shell_mode`, and a comment on pane_history — demonstrates managed source
- CLI: `DRY_RUN=true task tools:herdr` prints `[change] herdr config: would create (not present)` on a clean machine, or `[ok] herdr config: identical` when already deployed — demonstrates idempotent dry-run
- CLI: `task tools:herdr && cmp claude/herdr/config.toml ~/.config/herdr/config.toml && echo "identical"` — demonstrates sync correctness
- Diff: `claude/CLAUDE.md` managed-destinations table contains the herdr row

#### 2.0 Tasks

- [x] 2.1 Create `claude/herdr/` directory and `claude/herdr/config.toml` with the following content (based on vendell-confirmed config surface):
  ```toml
  [terminal]
  default_shell = "zsh"
  shell_mode = "login"

  # pane_history is OFF by default and must stay off.
  # If enabled, ~/.config/herdr/ will contain plaintext agent output
  # (which can include API keys and tokens). Never enable in managed config.
  ```
- [x] 2.2 Implement the `tools:herdr` task body in `Taskfile.yml`, following the `tools:tmux` pattern:
  - DRY_RUN branch: `cmp -s` to detect changes, print `[ok]` or `[change]`
  - Live branch: `mkdir -p "$(dirname "$DEST")"`, `chmod 700 "$(dirname "$DEST")"`, then `install -m 0644 "$SRC" "$DEST"`, print `[herdr] Installed config to $DEST`
- [x] 2.3 Add the herdr row to the managed-destinations table in `claude/CLAUDE.md`:
  - Destination: `~/.config/herdr/config.toml`
  - Source: `claude/herdr/config.toml`
  - Task: `task tools:herdr`
  - Add inline note: `~/.config/herdr/` must not be committed; pane_history must remain off

---

### [x] 3.0 Verify full zsh environment in herdr panes and plain iTerm windows

This task is performed manually and produces the proof transcript. It is the empirical gate for vendell's Q3 (does `shell_mode = "login"` actually source `.zshrc`?) and the Marsh credential guardrail.

#### 3.0 Proof Artifact(s)

- File: `docs/specs/04-spec-herdr-adoption/04-proofs/verification-transcript.md` — shell sessions showing all checks below in both contexts
- CLI in transcript (herdr pane): `type cc` → `cc is an alias for claude`; `type ccc` → alias; `type ccr` → alias
- CLI in transcript (herdr pane): `type ll` → eza alias; `type cat` → bat alias; p10k prompt renders
- CLI in transcript (herdr pane): pyenv, nvm, fzf, zoxide respond to `which`/`type` without "command not found"
- CLI in transcript (herdr pane): `env | grep -i api_key` returns nothing (Marsh Q3 guardrail)
- CLI in transcript (plain iTerm window): same `type cc` / `type ll` checks pass — no regression
- Note in transcript: iTerm keybinding/rendering assessment (any conflicts documented; cosmetic issues non-blocking, input conflicts blocking)

#### 3.0 Tasks

- [x] 3.1 Run `task init` (or `brew install herdr && task tools:herdr`) to deploy herdr and its config
- [x] 3.2 Launch herdr inside iTerm2 (`herdr` in a terminal); open a new pane
- [x] 3.3 **If `shell_mode = "login"` does not source `.zshrc`** (aliases missing in pane): investigate whether a `.zprofile` shim is needed to explicitly source `.zshrc` for login shells, add it to `claude/herdr/`, update `task tools:herdr` to sync it, and re-test. Do not proceed to 3.4 until sourcing is confirmed.
- [x] 3.4 Run all alias checks inside the herdr pane and record output in `04-proofs/verification-transcript.md`:
  - `type cc` / `type ccc` / `type ccr` → confirm alias for claude
  - `type ll` / `type ls` / `type cat` → confirm eza/bat aliases
  - `echo $ZSH_THEME` or visually confirm p10k prompt renders
  - `which pyenv` / `which nvm` (source it first if needed) / `which fzf` / `which zoxide`
  - `env | grep -i api_key` → confirm empty
- [x] 3.5 Open a separate plain iTerm window (no herdr) and record the same `type cc` / `type ll` checks — confirm no regression
- [x] 3.6 Note any iTerm keybinding or rendering issues in the transcript; document workarounds if any

---

### [x] 4.0 Document removal path and finalize proof transcript

#### 4.0 Proof Artifact(s)

- File: `docs/specs/04-spec-herdr-adoption/04-proofs/removal-path.md` — complete removal steps
- CLI: `DRY_RUN=true task init` after simulated removal shows no herdr entries — demonstrates clean reversibility
- File: `docs/specs/04-spec-herdr-adoption/04-proofs/verification-transcript.md` finalized from task 3.0 — all five success criteria covered

#### 4.0 Tasks

- [x] 4.1 Create `docs/specs/04-spec-herdr-adoption/04-proofs/` directory
- [x] 4.2 Write `docs/specs/04-spec-herdr-adoption/04-proofs/removal-path.md` with these steps:
  1. Remove `brew "herdr"` from `Brewfile`; run `brew uninstall herdr`
  2. Remove `HERDR_SRC` and `HERDR_DEST` vars from `Taskfile.yml`
  3. Remove `tools:herdr` task from `Taskfile.yml`
  4. Remove `- task: tools:herdr` from the `init` task in `Taskfile.yml`
  5. Remove `claude/herdr/` directory from the repo
  6. Remove the herdr row from `claude/CLAUDE.md` managed-destinations table
  7. Remove `~/.config/herdr/` from the machine: `rm -rf ~/.config/herdr/`
  8. Verify: `DRY_RUN=true task init` — confirm no herdr entries appear
- [x] 4.3 Finalize `docs/specs/04-spec-herdr-adoption/04-proofs/verification-transcript.md` with the session output from task 3.0, structured to show each of the five success criteria from the spec
