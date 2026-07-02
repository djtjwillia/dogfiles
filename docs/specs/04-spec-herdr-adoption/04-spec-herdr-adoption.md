# 04-spec-herdr-adoption.md

> **Status: PROPOSED — not yet started.** This spec records a candidate adoption for review. No implementation is authorized by this document. Two pre-task-generation gates (see §10) must clear before `/SDD-2-generate-task-list-from-spec`: a **synod-vendell** verification of herdr's current install mechanism, and a **synod-marsh** light security read of its PTY/socket model.

## Introduction/Overview

[herdr](https://herdr.dev) is a **terminal-based agent multiplexer** — "one terminal, the whole herd." It provides real PTY panes, tabs, and workspaces in which multiple AI agents run concurrently, with semantic state tracking (blocked / working / done / idle), sessions that persist across terminal close, and a CLI/JSON socket API for orchestration. It is installed as a pre-built binary via a curl script. herdr explicitly states it is **not** a terminal emulator: it claims to preserve the user's existing shell, fonts, and keybindings, running *inside* the terminal the user already uses.

This spec covers adopting herdr into the `dogfiles`-managed environment so it runs inside iTerm2 with the user's full zsh environment available **both inside herdr panes and in regular iTerm windows, with no regression to either**.

**What this spec is NOT:** it is not the multi-agent routing protocol. How herdr panes map to concurrent SDD task flows, and how Sazed/Kelsier route across them, is owned by `docs/specs/05-spec-multi-agent-concurrent-sdd/`. This spec stops at "herdr runs correctly and the shell environment is whole." The orchestration question is explicitly deferred to spec 05.

## Problem Statement

A prior adoption attempt surfaced two concrete, reproducible failures. Both are now grounded in the actual managed shell config (`dotfiles/.zshrc`, `dotfiles/config.sh`), not speculation:

### P1 — `cc` alias shadowed after herdr install

`dotfiles/config.sh` defines `alias cc='claude'` (alongside `ccc='claude --continue'` and `ccr='claude --resume'`). After herdr installation, `cc` stopped resolving to `claude`.

**Root cause (high confidence, pending vendell confirmation of install path):** `cc` is the traditional Unix C-compiler command. `dotfiles/.zshrc` runs `export PATH="$HOME/.local/bin:$PATH"` — prepending `~/.local/bin` to PATH — and this line executes *after* `config.sh` is sourced. The herdr installer is documented to drop its binary in a user-local bin directory. If a `cc` binary (or a herdr-related `cc` symlink) lands on PATH ahead of the alias's effective resolution, or if herdr panes resolve commands before aliases load (see P2), the alias is shadowed. The alias-vs-PATH interaction is the suspect; the exact path herdr writes to is a **vendell verification item** (§10, V1).

### P2 — zsh environment absent inside herdr panes

Inside herdr's PTY panes, none of the user's aliases or customizations were present — no `cc`, no `ll`, no oh-my-zsh, no powerlevel10k.

**Root cause (high confidence):** herdr spawns panes as **non-login, non-interactive shells** (or a bare `sh`), so `~/.zshrc` — and therefore `config.sh`, oh-my-zsh, pyenv, nvm, fzf, zoxide, and zsh-syntax-highlighting — is never sourced. The user's entire interactive environment lives in `.zshrc` and the files it sources; a pane that does not source `.zshrc` is effectively a stranger's shell.

The cost of *not* solving this is correctness-of-environment, not data loss: the tool is usable but the environment inside it is wrong, which defeats the purpose of "preserve the existing shell."

## Proposed Solution

Adopt herdr through the repo's canonical-source / task-target model, with explicit shell-launch configuration that guarantees `.zshrc` is sourced in every pane.

1. **Bootstrap target.** Add an idempotent `task tools:herdr` target that installs/updates herdr as a pinned binary, honoring the repo's `DRY_RUN` and `[ok]`/`[change]` reporting conventions (model: `tools:node`, `tools:claude`). The install must **not** rely on piping curl directly to a shell at apply time without a pinned version/checksum (see Risk R5, marsh consult).

2. **Shell-launch configuration.** Configure herdr to launch panes as a **login interactive zsh** — `zsh -l -i` or herdr's documented shell-path/shell-args setting — so `~/.zshrc` is sourced in every pane. Exact mechanism (config key vs. env var vs. flag) is a **vendell verification item** (§10, V1). This resolves P2.

3. **Alias / PATH reconciliation.** Resolve P1 by the least-invasive option that holds:
   - **Option A (preferred):** ensure aliases survive by guaranteeing `.zshrc` (and thus `config.sh`) is sourced *after* any PATH mutation herdr introduces — the P2 fix may incidentally resolve P1, since an interactive login shell re-sources `config.sh` and aliases win over PATH lookup for command words.
   - **Option B (fallback):** if a real `cc` binary genuinely sits on PATH and the alias still loses, reorder so `config.sh`'s alias definitions are re-applied last, OR rename the alias (e.g. `clc='claude'`) and update `config.sh` + muscle memory. Renaming is the last resort because it touches the user's habits.
   - The chosen option is decided empirically once vendell confirms what herdr actually drops on PATH (§10, V1).

4. **iTerm integration.** herdr runs inside iTerm2 (config managed at `iterm2/` → `~/Library/Preferences/com.googlecode.iterm2.plist` via `task tools:iterm2`). Confirm no iTerm keybinding or profile setting conflicts with herdr's pane/tab controls; document any iTerm profile adjustment needed. UX scope owned by **synod-kaladin** (§11).

## Goals

- **No regression in regular iTerm windows.** All existing aliases, prompt, and tools work exactly as before herdr.
- **Full environment inside herdr panes.** `cc`, `ccc`, `ccr`, oh-my-zsh, p10k, pyenv, nvm, fzf, zoxide, and zsh-syntax-highlighting all work inside a herdr pane.
- **Canonical-source adoption.** herdr is installed and configured only via repo source + a `task` target; no hand-editing of deployed destinations.
- **Reversibility.** Adoption is cleanly removable: drop the task target, revert any `.zshrc`/`config.sh`/iTerm changes, uninstall the binary — no residual state.
- **Pinned, reproducible install.** The herdr binary is version-pinned, not "latest at apply time," so machines converge.

## Non-Goals

- **Multi-agent routing / orchestration.** How panes map to SDD task flows and how Sazed/Kelsier route across them is spec 05's job, not this one.
- **Replacing iTerm or tmux.** herdr runs inside iTerm; this spec does not change the terminal emulator and does not remove tmux.
- **Treehouse worktree pooling.** Worktree leasing for concurrent flows is spec 03 / spec 05 territory.
- **Authoring herdr's own agent definitions.** This spec gets herdr running with a correct shell; it does not define which agents run in it.

## Adoption Requirements

If both §10 gates clear, adoption requires:

| ID | Requirement |
| --- | --- |
| AR1 | Add an idempotent `task tools:herdr` target installing herdr as a **version-pinned** binary, honoring `DRY_RUN` and `[ok]`/`[change]` reporting (pattern: `tools:node`). Wire it into `task init`. |
| AR2 | Configure herdr to launch panes as a **login interactive zsh** so `~/.zshrc` is sourced in every pane (resolves P2). Mechanism documented and checked into the repo as herdr config source. |
| AR3 | Resolve the `cc` alias conflict (P1) via the chosen option from §Proposed Solution step 3; document which option was taken and why. Verify `cc`, `ccc`, `ccr` resolve to `claude` inside a herdr pane AND in a plain iTerm window. |
| AR4 | If herdr config is a managed file, register a destination → source → task-target row in `CLAUDE.md`'s managed-destinations table (consistent with the repo's drift-prevention model). |
| AR5 | Confirm iTerm2 profile/keybindings do not conflict with herdr's controls; document any required iTerm adjustment (synod-kaladin). |
| AR6 | Document the full removal path (revert AR1–AR5, uninstall binary) so adoption is cleanly reversible. |
| AR7 | Record a verification run in `docs/specs/04-spec-herdr-adoption/04-proofs/`: a transcript showing the success-criteria checks passing inside a pane and in a plain window. |

## Risks

| ID | Risk | Likelihood | Impact | Mitigation (pre-written) |
| --- | --- | --- | --- | --- |
| R1 | **P2 fix does not fully resolve P1.** Sourcing `.zshrc` in panes may not reorder PATH enough to un-shadow `cc` if a real `cc` binary sits ahead. | M | M | Option B fallback (§Proposed Solution 3): re-apply aliases last or rename. Decision gated on vendell V1 confirming what herdr drops on PATH. Verify per AR3. |
| R2 | **`zsh -l -i` slows pane startup.** Login+interactive sources the full `.zshrc` (oh-my-zsh, p10k, nvm, pyenv) per pane — measurable startup cost at high pane counts. | M | M | p10k instant-prompt already mitigates perceived latency. If startup is unacceptable, scope `.zshrc` heavy initializers behind a fast-path guard. Measure before optimizing. |
| R3 | **Regression in plain iTerm windows.** A `.zshrc`/`config.sh` change made for herdr breaks the normal shell. | L | H | Any `.zshrc`/`config.sh` edit verified in BOTH contexts (AR3, AR7). Smallest viable change first; prefer herdr-side config over shell-side edits. |
| R4 | **Unpinned curl-to-shell install drifts / is unreproducible.** "latest" binary differs across machines and time. | M | M | AR1: version-pin and (if upstream provides) checksum-verify. Route currency to synod-vendell. |
| R5 | **PTY/socket exposure.** herdr's JSON socket API and persistent sessions could expose a control channel or leak agent credentials between panes. | L | H | **synod-marsh light consult (§10, gate 2):** confirm socket is local-only (unix socket, user-permissioned), sessions do not persist secrets to disk in cleartext, and panes do not share a credential context they shouldn't. Flag if any finding raises impact. |
| R6 | **herdr ≠ terminal emulator claim is imperfect.** Fonts/keybindings/colors may not survive as cleanly as advertised. | L | M | AR5 (kaladin): verify the actual rendering and keybinding behavior in iTerm; document gaps. Cosmetic, not blocking unless it breaks input. |
| R7 | **Managed-config drift.** herdr config edited at its deployed destination, not the repo source. | L | M | AR4: register herdr config in the managed-destinations table; never edit the destination directly (repo `CLAUDE.md` constraint). |

## Success Criteria

Adoption **succeeds** only if **all** hold, verified in `04-proofs/` (AR7):

1. **No regression, plain iTerm:** in a normal iTerm window, `type cc` resolves to `claude`; `ll`, prompt, pyenv, nvm, fzf, zoxide all behave as before.
2. **Full environment, herdr pane:** in a herdr pane, `type cc` resolves to `claude`; `ccc`/`ccr` resolve; oh-my-zsh + p10k prompt render; the same tools as criterion 1 work.
3. **Canonical adoption:** herdr installs and configures solely via `task tools:herdr` + repo-source config; `task dry-run` reports cleanly and idempotently.
4. **Reversibility:** the documented removal path (AR6) leaves no residual state — verified by removing and re-running `task dry-run`.
5. **Security read clear:** marsh's §10 gate-2 consult records no unmitigated credential/socket exposure (R5).

Adoption **fails** if P1 or P2 cannot be resolved without breaking the plain-iTerm shell (R3), or if marsh flags an unmitigable socket/credential exposure (R5).

## Open Questions

1. **What does herdr's installer actually drop, and where?** Does it write a `cc` to `~/.local/bin` or elsewhere on PATH? (Gates the P1 fix choice. — vendell V1, §10.)
2. **What is herdr's documented mechanism for setting the pane shell?** Config key, env var, or launch flag — and does it accept `zsh -l -i`? (Gates AR2. — vendell V1.)
3. **Is the herdr config file a managed destination** (does it live at a stable path worth registering in the managed-destinations table)? (Gates AR4.)
4. **Is the JSON socket local-only and user-permissioned**, and do persistent sessions store anything sensitive on disk? (Gates marsh gate-2, R5.)
5. **What is the pane-startup cost of `zsh -l -i`** at the user's typical pane count, and is it acceptable? (Feeds R2; measure during implementation, not blocking.)

## Pre-Task-Generation Gates

Before `/SDD-2-generate-task-list-from-spec` against this spec:

- **Gate 1 — synod-vendell (V1):** verify herdr's *current* install mechanism (binary path, whether it drops a `cc`, version-pinning support, checksum availability) and its *current* shell-launch configuration surface, against live upstream docs — not this spec's asserted root causes. Resolves Open Questions 1–2.
- **Gate 2 — synod-marsh (light consult):** read herdr's PTY-spawning, JSON-socket, and persistent-session model for credential/socket exposure (R5). Resolves Open Question 4. Flag if any finding raises the risk impact above "light."

Both gates must clear (findings recorded) before task generation. The decision to proceed is the user's.

## Escalation / Routing Notes

- **synod-vendell** — owns Gate 1: confirm herdr's install mechanism, PATH behavior, and shell-launch config against current upstream docs. The P1/P2 root causes in this spec are high-confidence inferences from the actual `.zshrc`/`config.sh`, but the herdr-side specifics must be verified, not assumed.
- **synod-marsh** — owns Gate 2: light security read of the PTY/socket/session model (R5). Marsh-first applies: this consult precedes any implementer touching the socket or session config.
- **synod-melaan** — owns the `task tools:herdr` bootstrap target (AR1) and the shell-config integration (AR2, AR3) — developer-experience / local-environment scope.
- **synod-kaladin** — owns the iTerm-integration UX (AR5): herdr-inside-iTerm rendering, keybinding conflicts, "does it feel right."
- **synod-steris** — documentation-accuracy veto: the managed-destinations table update (AR4) and the chosen-option documentation (AR3) must match what actually ships.

---

**Next step:** This spec remains **PROPOSED**. Do not generate a task list until both §10 gates clear with recorded findings. When they do, proceed to `/SDD-2-generate-task-list-from-spec` against this file.
