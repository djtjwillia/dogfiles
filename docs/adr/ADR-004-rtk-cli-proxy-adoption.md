# ADR-004: rtk CLI Proxy — Evaluation and Non-Adoption

## Status
Proposed

## Date
2026-07-08

## Context

The user asked to add **`rtk`** (`github.com/rtk-ai/rtk`) — a third-party Rust CLI proxy that claims to cut LLM token consumption by **60–90%** by filtering and compressing shell-command output before it reaches the model's context — installed via Homebrew and wired into Claude Code. This ADR records the evaluation and the decision reached. **Nothing was implemented**: no binary installed, no hook injected, no file changed in this repo or on the machine. This is a decision record the user intends to review and revisit later, not a closed rejection.

### What rtk is and how it integrates

- rtk's own documented integration path is **`rtk init -g`**, which installs a **global Claude Code hook** that transparently rewrites Bash tool calls (e.g. `git status` → `rtk git status`) so its own binary intercepts, filters, and rewrites command output before it reaches the model. The README states the agent "doesn't know RTK is involved."
- Repo facts as of this review: `github.com/rtk-ai/rtk`, org `rtk-ai`, license Apache-2.0, language Rust, created 2026-01-22, **69,565 stars / 4,323 forks / 1,528 open issues**.

### This is a real project, not astroturf

A correction to the initial intake hypothesis: the star/fork velocity is **not** good evidence of astroturfing. The repo shows ~2,859+ PRs, dozens of active contributors with hundreds of commits each, heavy release automation, a `.semgrep.yml` in CI, a `SECURITY.md`, a `DISCLAIMER.md`, and independent third-party coverage. This is a real, heavily-developed project. **The risk is what the tool legitimately does — not fraud.**

### Security review findings (synod-marsh — authoritative)

The following findings are recorded verbatim in intent from synod-marsh's completed security review. They are not re-derived here.

| # | Severity | Finding |
|---|----------|---------|
| 1 | **CRITICAL** | The injected hook (`hooks/claude/rtk-rewrite.sh`) returns `permissionDecision: "allow"` on every successful rewrite, so Claude Code's normal permission-prompt gate is **silently bypassed** for any command rtk's closed rewrite/classification logic (`src/discover/registry.rs`) chooses to handle. An independent review (upstream issue #640) separately rated a related shell-injection path CRITICAL for this exact reason. Remediation if ever pursued: strip `permissionDecision: allow` from the hook so Claude Code still prompts — which removes rtk's core convenience. |
| 2 | **HIGH** | The proxy sees **every byte of every rewritten command's output** (`git diff`, `cat`, `env` — exactly where secrets live), and rtk's telemetry endpoint URL is injected at **compile time via `option_env!()`**, not visible in source. The destination of any phone-home traffic in a released binary therefore cannot be verified from source. |
| 3 | **HIGH** | **Disputed telemetry default.** rtk's own `docs/TELEMETRY.md` claims telemetry is opt-in and consent-gated; the independent review (issue #640) asserts the implementation sends device identifiers and usage patterns **by default**, and documents a broader policy-vs-implementation gap (e.g. `SECURITY.md` prohibits `Command::new("sh")` but the codebase reportedly uses it). Marsh's posture: treat as **on-by-default and unverified** until proven otherwise, per assume-breach. |
| 4 | **HIGH** | The documented install path `rtk init -g` writes directly into the live `~/.claude/settings.json`. This repo's `CLAUDE.md` designates that file a **managed destination** whose source of truth is `claude/settings.json`, deployed only via `task tools:claude`. Running the vendor installer creates silent drift the next `task tools:claude` run would overwrite, and injects a `rtk-awareness.md` CLAUDE.md fragment and hook script into `~/.claude/` **outside repo tracking**. |
| 5 | **MEDIUM** | Homebrew install is `brew tap rtk-ai/tap && brew install rtk` — a **vendor-controlled tap**, not homebrew-core, with no independent formula audit. The in-repo `Formula/rtk.rb` is stale (placeholder version/sha256), so the live tap formula is fetched and unseen at review time. |
| 6 | **MEDIUM** | Global scope (`-g`) maximizes blast radius to **every project on the machine**, not just one repo. |
| 7 | **LOW/INFO** | `install.sh` hygiene is reasonable: versioned release tarball, SHA-256 checksum verification by default (skippable only via `RTK_SKIP_CHECKSUM=1`), installs to `~/.local/bin`, path-traversal validation, no rc-file modification, no auto-update, no background processes. **No signature/provenance (cosign/GPG)** — checksums come from the same host as the binary, so this guards against corruption, not a compromised release host. |
| 8 | **LOW/INFO** | The hook **fails open** (exit 0) on any error (missing `jq`, missing `rtk`, stale version) — intentional and reasonable for availability, not a concern on its own. |

**Marsh's verdict:** **do not adopt as specified** (global auto-allow hook via `rtk init -g`).

**Marsh's confidence: MEDIUM.** Marsh read the actual injected hook script, the installer's documented behavior, the telemetry policy doc, the Homebrew formula, and the independent review issue. Marsh did **not** read the compiled binary's real network/syscall behavior, the closed rewrite/permission logic in `registry.rs`, or verify the telemetry default against source code directly. **Those two gaps are what would move findings #2/#3 from HIGH to CRITICAL if resolved unfavorably, or downgrade them if resolved favorably.**

## Decision

**rtk is not adopted at this time.** No hook installed, no binary installed, no files changed anywhere (repo or machine). This ADR exists purely as the decision record for future reference; status is `Proposed` because the user intends to review and revisit it themselves, not because implementation is pending.

The tool is a real, actively-developed project, and the token-savings claim may be genuine. The blocker is not the tool's legitimacy but its **default integration posture**: a global hook that silently returns `permissionDecision: "allow"` (bypassing Claude Code's permission gate — CRITICAL), a proxy that sees every byte of command output including secrets against a compile-time-hidden, disputed-default telemetry endpoint (HIGH/HIGH), and a vendor installer that writes directly into a repo-managed destination (`~/.claude/settings.json`), creating silent drift (HIGH). These together are disqualifying **as specified** (`rtk init -g`).

### If revisited later — minimum-risk path (least to most exposure)

Recorded so a future evaluation does not start from scratch. **None of this is authorized by this ADR** — each step requires separate, explicit user approval.

1. **Safest — no hook at all.** Install a pinned version and run `rtk git status` etc. **manually** in a scratch repo, with `RTK_TELEMETRY_DISABLED=1` set and network monitoring on, to confirm the token savings are real **before** granting any standing access.
2. **Pin, never float.** Use `install.sh` with an explicit `RTK_VERSION=<tag>` (never `latest`) and `RTK_TELEMETRY_DISABLED=1`; record the sha256 obtained. **Avoid the vendor Homebrew tap.**
3. **If a hook is genuinely wanted.** Vendor the hook JSON and `rtk-rewrite.sh` into this repo's own tracked source (`claude/settings.json` + a tracked script path), **project-scoped (not `-g`)**, with the `permissionDecision: "allow"` auto-approve **stripped** so Claude Code still prompts, deployed via `task tools:claude` — **never** via the vendor's `rtk init -g`.
4. **Non-negotiable in any revisit.** `RTK_TELEMETRY_DISABLED=1` set, and egress monitored on first runs.

## Consequences

**None. Status quo is preserved.** No binary, no hook, no config, no drift. The machine and repo are in exactly the state they were before the evaluation began.

The value of this ADR is that the security analysis is now on the record: a future reader (including the user revisiting this) has the full picture — findings, severities, and the minimum-risk path — without re-deriving any of it.

**Risk register** — the risks that would attach *if* rtk were adopted as specified. Since nothing is adopted, none are live; they are recorded so the cost of the rejected path is explicit.

| Risk (if adopted as specified) | Likelihood | Impact | Mitigation (pre-written) |
|--------------------------------|-----------|--------|--------------------------|
| Permission gate silently bypassed via `permissionDecision: "allow"` (finding #1, CRITICAL) | H (default behavior) | H | Do not adopt as specified. If ever pursued, strip `permissionDecision: allow` from the hook — accepting that this removes rtk's core convenience. |
| Secrets in command output (`git diff`, `env`, `cat`) exposed to proxy + compile-time-hidden telemetry endpoint (finding #2, HIGH) | M | H | No standing hook access; evaluate manually in a scratch repo with `RTK_TELEMETRY_DISABLED=1` and egress monitoring before any adoption. |
| Telemetry on-by-default despite opt-in claim (finding #3, HIGH, disputed) | M | H | Treat as on-by-default per assume-breach; set `RTK_TELEMETRY_DISABLED=1` always; verify telemetry behavior against source/network before trusting it. |
| Vendor installer writes to managed `~/.claude/settings.json`, creating silent drift (finding #4, HIGH) | H (documented install path) | M | Never run `rtk init -g`. Any hook must be vendored into `claude/settings.json` and deployed via `task tools:claude`. |
| Unaudited vendor Homebrew tap; stale in-repo formula (finding #5, MEDIUM) | M | M | Avoid the tap; use `install.sh` with pinned `RTK_VERSION` and recorded sha256. |
| Global scope maximizes blast radius to every project (finding #6, MEDIUM) | H (with `-g`) | M | Project-scope any future hook; never `-g`. |
| No signature/provenance on release; checksum co-hosted with binary (finding #7, LOW) | L | M | Pin version + record sha256; accept that this guards corruption, not a compromised release host; monitor egress on first runs. |
| Marsh's two unverified gaps (binary network behavior; closed `registry.rs` logic) resolve unfavorably, promoting #2/#3 to CRITICAL | Unknown | H | Do not adopt until those gaps are closed by direct binary/network inspection; that inspection is a precondition of any future revisit. |

**Go / No-go gate:** **No-go.** rtk is not adopted. Any future adoption requires (a) explicit user approval, and (b) the minimum-risk path above, starting with a manual scratch-repo evaluation and closing Marsh's two unverified gaps before any standing hook is granted.

**Rollback trigger:** Not applicable — nothing was deployed, so there is nothing to roll back beyond this document itself (see Rollback).

## Implementation Order

*Nothing is implemented and nothing is currently planned. Every box below is unchecked because the decision is non-adoption. The steps are the **optional future minimum-risk path** — recorded for reference only and **not authorized by this ADR**. Each would require separate, explicit user approval before any action.*

- [ ] **(Not authorized) User decides to revisit rtk** and explicitly approves an evaluation. No action before this.
- [ ] **(Not authorized) Close Marsh's two unverified gaps** — inspect the compiled binary's real network/syscall behavior and the closed rewrite/permission logic in `registry.rs`; verify the telemetry default against source. Findings #2/#3 could move to CRITICAL or downgrade based on the result.
- [ ] **(Not authorized) Manual scratch-repo evaluation** — install a pinned version, run `rtk <cmd>` manually with `RTK_TELEMETRY_DISABLED=1` and egress monitoring, confirm token savings are real. **No hook.**
- [ ] **(Not authorized) Pinned install** — `install.sh` with explicit `RTK_VERSION=<tag>` (never `latest`), `RTK_TELEMETRY_DISABLED=1`, record sha256. Avoid the vendor Homebrew tap.
- [ ] **(Not authorized) Vendored, project-scoped hook** — only if genuinely wanted: vendor hook JSON + `rtk-rewrite.sh` into `claude/settings.json` and a tracked script path, project-scoped (not `-g`), `permissionDecision: "allow"` stripped, deployed via `task tools:claude`. Never `rtk init -g`.

> This ADR authorizes **no** synod-vin dispatch. There is no approved build to hand off. It records a non-adoption decision only.

## Verification

This ADR is itself evidence that the evaluation stopped at the design/record stage. Confirmed at authoring time (2026-07-08):

- **No rtk hook in repo source:** `grep -in rtk claude/settings.json` → no match.
- **No rtk footprint in the deployed config:** `grep -in rtk ~/.claude/settings.json` → no match (`~/.claude/settings.json` unchanged).
- **No rtk binary installed:** `command -v rtk` → not found.
- **No vendor artifacts on the machine:** no `rtk-awareness.md` CLAUDE.md fragment and no `rtk-rewrite.sh` hook script in `~/.claude/` (these would only exist if `rtk init -g` had been run — it was not).
- **Working tree touched only by this file:** `git status --short` shows `docs/adr/ADR-004-rtk-cli-proxy-adoption.md` as the sole change introduced by this evaluation. No `claude/settings.json` entry, no other tracked file modified.

## Rollback

Trivial. Nothing was installed or configured, so the only artifact is this document:

```sh
rm docs/adr/ADR-004-rtk-cli-proxy-adoption.md
```

No binary to uninstall, no hook to remove, no `~/.claude/settings.json` to restore, no `task tools:claude` re-sync needed. Removing this file returns the repo to its pre-evaluation state completely.
