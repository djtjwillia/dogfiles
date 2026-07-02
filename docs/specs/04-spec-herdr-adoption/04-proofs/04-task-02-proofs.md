# Task 2 Proofs — managed herdr config source and tools:herdr sync implemented

## Task Summary
Task 2.0 creates `claude/herdr/config.toml` as the managed config source for herdr with `shell_mode = "login"` (the fix for the cc-alias and non-login-pane issues) and a pane_history guardrail comment. The `tools:herdr` task body was implemented alongside task 1.0 (preferred batch approach) with full DRY_RUN idempotency — `cmp -s` to detect drift, `mkdir -p` + `chmod 700` on the destination directory, and `install -m 0644` for the file. The managed-destinations table in `CLAUDE.md` was updated to register the herdr config path.

## What This Task Proves
- `claude/herdr/config.toml` exists with the correct `[terminal]` section and pane_history guardrail comment
- `DRY_RUN=true task tools:herdr` prints `[change] herdr config: would create (not present)` on a clean machine
- The managed-destinations table in the root `CLAUDE.md` contains the herdr row with destination, source, and task columns
- The task body follows the `tools:tmux` pattern exactly (cmp-s idempotency, chmod 700 on directory, install -m 0644)

## Evidence Summary
`DRY_RUN=true task tools:herdr` returned `[change] herdr config: would create (not present)` — correct output for a clean machine. The config source file exists at `claude/herdr/config.toml` with the vendell-confirmed settings. The managed-destinations table in `CLAUDE.md` now registers the herdr path with the Marsh guardrail note, ensuring future agents and contributors do not attempt to manage the destination directly.

## Artifact: DRY_RUN=true task tools:herdr output

**What it proves:** The `tools:herdr` DRY_RUN branch executes correctly — it detects the absent destination and reports what would happen without touching the filesystem.
**Why it matters:** A reviewer can confirm the idempotency logic and the `[change]`/`[ok]` output convention without running a live sync.
**Command:** `DRY_RUN=true task tools:herdr`
**Result summary:** The command exited 0 and printed exactly one line — `[change] herdr config: would create (not present)` — matching the expected output for a machine where `~/.config/herdr/config.toml` does not yet exist.

```
[change] herdr config: would create (not present)
```

## Artifact: claude/herdr/config.toml contents

**What it proves:** The managed config source contains the correct settings and the pane_history security guardrail.
**Why it matters:** `shell_mode = "login"` is the fix for the cc-alias/non-login-pane issue confirmed by synod-vendell; the pane_history comment prevents a future operator from accidentally enabling a setting that would write API keys to disk.
**Command:** `cat claude/herdr/config.toml`
**Result summary:** File contains `[terminal]`, `default_shell = "zsh"`, `shell_mode = "login"`, and the pane_history OFF comment — matching the spec exactly.

```toml
[terminal]
default_shell = "zsh"
shell_mode = "login"

# pane_history is OFF by default and must stay off.
# If enabled, ~/.config/herdr/ will contain plaintext agent output
# (which can include API keys and tokens). Never enable in managed config.
```

## Reviewer Conclusion
The managed config source is correct, the DRY_RUN path behaves as specified, and the managed-destinations table is updated — task 2.0 is complete and ready for task 3.0 (manual verification in a live herdr pane).
