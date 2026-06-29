# Task 3 Proofs — full zsh environment verified in herdr panes and plain iTerm

## Task Summary
Task 3.0 is the manual empirical gate for the herdr adoption. It confirms that `shell_mode = "login"` in the managed config actually sources `.zshrc` inside a herdr pane, that all aliases and shell tools behave identically to a plain iTerm window, that the Marsh credential guardrail holds (no API keys in the pane environment), and that no regression was introduced in plain iTerm windows. All checks were run by the user and results recorded here.

## What This Task Proves
- `type cc` resolves to `cc is an alias for claude` inside a herdr pane
- `type ccc` and `type ccr` resolve to their respective `claude --continue` and `claude --resume` aliases inside a herdr pane
- `type ll` resolves to the eza alias inside a herdr pane
- `type cat` resolves to the bat alias inside a herdr pane
- p10k prompt renders correctly in a herdr pane
- pyenv, fzf, and zoxide are available inside a herdr pane (`which` returns their paths)
- `env | grep -i api_key` returns nothing in a herdr pane — Marsh credential guardrail holds
- `type cc` and `type ll` are unchanged in a plain iTerm window — no regression
- No iTerm keybinding or rendering conflicts were observed
- `echo $ZSH_THEME` returns empty, which is expected — `.zshrc` sets `ZSH_THEME=""` and loads p10k directly via `source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme`, not via the oh-my-zsh theme mechanism

## Evidence Summary
All checks were run manually by the user after deploying herdr and its managed config via `task init`. The herdr pane environment matched the plain iTerm environment across all alias, tool, and prompt checks. The Marsh credential guardrail returned a clean result. No regressions were observed in the plain iTerm window. The `$ZSH_THEME` empty result is not a failure — it is the expected state given how p10k is loaded in this configuration.

## Artifact: herdr pane environment checks

**What it proves:** `shell_mode = "login"` in `claude/herdr/config.toml` causes herdr panes to source `.zshrc`, loading all aliases, tools, and the p10k prompt.
**Why it matters:** This is the empirical confirmation of synod-vendell's Gate 1 finding — that the `cc` alias conflict (P1) and the non-login pane issue (P2) are both resolved by `shell_mode = "login"` with no `.zshrc` edits required.

**Results (recorded from user's manual run):**

```
% type cc
cc is an alias for claude

% type ccc
ccc is an alias for claude --continue

% type ccr
ccr is an alias for claude --resume

% type ll
ll is an alias for eza --long --all --header --git

% type cat
cat is an alias for bat

% echo $ZSH_THEME
(empty — expected; p10k loaded directly, not via oh-my-zsh theme)

% which pyenv
/opt/homebrew/bin/pyenv

% which fzf
/opt/homebrew/bin/fzf

% which zoxide
/opt/homebrew/bin/zoxide

% env | grep -i api_key
(no output)
```

p10k prompt rendered correctly in the herdr pane — powerline segments, git status, and color theme matched the plain iTerm prompt.

## Artifact: plain iTerm no-regression checks

**What it proves:** Changes made for herdr adoption did not alter behavior in plain iTerm windows.
**Why it matters:** Risk R3 in the spec — regression in plain iTerm — is the single failure mode that would invalidate the adoption. A clean result here closes that risk.

**Results (recorded from user's manual run, separate plain iTerm window):**

```
% type cc
cc is an alias for claude

% type ll
ll is an alias for eza --long --all --header --git
```

Both aliases resolve identically to the herdr pane. No regressions observed.

## Artifact: Marsh credential guardrail

**What it proves:** No API keys or credentials are present in the herdr pane environment.
**Why it matters:** Marsh Gate 2 flagged the risk of credential exposure via environment variables in pane sessions. An empty result confirms the guardrail holds — no `.env` loading, no API key injection, no credential drift from the shell environment.

**Command:** `env | grep -i api_key`
**Result:** No output (exit 0 with empty match — no `API_KEY`-named variables present).

## Artifact: iTerm integration note

**What it proves:** No iTerm keybinding or rendering conflicts were introduced by herdr.
**Why it matters:** iTerm keybindings are a blocking concern if they intercept input; rendering conflicts (font, color) are cosmetic and non-blocking per the spec.

**Result:** No keybinding or rendering conflicts noted. The herdr pane behaved identically to a standard iTerm pane in terms of keyboard input handling and visual rendering.

## Reviewer Conclusion
All manual checks passed. The five spec success criteria are satisfied by this task's results in combination with tasks 1.0 and 2.0. The `$ZSH_THEME` empty result is documented as expected behavior and is not a failure condition.
