# Task 1 Proofs — herdr wired into Brewfile and init task

## Task Summary
Task 1.0 adds `brew "herdr"` to the Brewfile in alphabetical position, introduces `HERDR_SRC` and `HERDR_DEST` vars to the Taskfile, adds a `tools:herdr` task (implemented fully per the preferred batch approach), and wires `- task: tools:herdr` into the `init` sequence after `tools:claude` and before `tools:node`. This ensures herdr is installed via the existing brew workflow and its config is synced on every `task init`.

## What This Task Proves
- `brew "herdr"` is present in `Brewfile` in alphabetical order between `hadolint` and `helm`
- `HERDR_SRC` and `HERDR_DEST` vars are declared in the `vars:` block following the `CLAUDE_SRC`/`CLAUDE_DEST` pattern
- `tools:herdr` task exists in `Taskfile.yml` with a correct DRY_RUN-aware body
- `init` calls `tools:herdr` in the correct position (after `tools:claude`, before `tools:node`)
- `DRY_RUN=true task init` completes without error and includes a herdr config entry

## Evidence Summary
`DRY_RUN=true task init` ran to completion with no errors. The herdr config line appears in the expected position — after the Claude config block and before the node block — printing `[change] herdr config: would create (not present)`, which is the correct output for a clean machine where the destination does not yet exist. All other existing entries reported their expected `[ok]` or `[change]` states, confirming no regressions.

## Artifact: DRY_RUN=true task init output

**What it proves:** `tools:herdr` is wired into the `init` task and its DRY_RUN branch executes correctly.
**Why it matters:** A reviewer can confirm the full bootstrap sequence includes herdr config sync without needing to run it on a live machine.
**Command:** `DRY_RUN=true task init`
**Result summary:** The output includes `[change] herdr config: would create (not present)` with no errors. The entry appears after the claude config block and before the node block, confirming insertion order matches the task spec.

```
[ok] oh-my-zsh: already installed
[ok] Homebrew: already installed
[ok] tpm: already present
[ok] zsh-autosuggestions: already present
[ok] zsh-syntax-highlighting: already present
[change] brew bundle: 0 package(s) would be installed
[change] brew outdated: 29 package(s) have updates available
  aws-vault
  docker
  ...
[ok] .zshrc: identical
[ok] .gitconfig: identical
[ok] .gitconfig-liatrio: identical
[ok] .gitconfig-personal: identical
[ok] allowed_signers: identical
[change] iterm2 plist: would update
[ok] .p10k.zsh: identical
[ok] .tmux.conf: identical
[ok] dev: identical
[ok] CLAUDE.md: identical
[ok] charter-details.md: identical
[ok] settings.json: identical
[ok] statusline-command.sh: identical
[ok] agents/: no changes
[ok] commands/: no changes
[change] herdr config: would create (not present)
[change] node: LTS not installed, would run nvm install --lts
[ok] agent-browser: already installed globally
[ok] lavish-axi: already installed globally
```

## Reviewer Conclusion
The `init` task correctly includes herdr config sync, the DRY_RUN branch behaves as specified, and no existing task entries were disturbed.
