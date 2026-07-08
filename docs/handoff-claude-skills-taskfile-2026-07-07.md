# Handoff: claude/skills sync + handoff skill replacement

**Date:** 2026-07-07
**Repo:** `/Users/taylor/Code/projects/dogfiles` (branch `feat/claude-skills-taskfile`, pushed)
**PR:** [#28 — feat: add claude/skills sync, replace handoff skill](https://github.com/djtjwillia/dogfiles/pull/28) (OPEN)
**Working tree:** clean — everything described below is committed as `bdae13d` and pushed to origin.

## What this session did

Three things, in order:

1. **Added `claude/skills/` to the repo** as a new managed source, sibling to the existing `claude/agents/` and `claude/commands/`.
2. **Added a `tools:claude-skills` Taskfile task** (kept deliberately separate from `tools:claude` per explicit user request — that task's scope is unchanged). It syncs `claude/skills/` → `~/.claude/skills/`.
3. **Replaced the `handoff` skill's content**, moving its source of truth from an external, unmanaged location into this repo.

## Why this needed care, not a copy-paste of the agents/commands pattern

`~/.claude/skills/` on this machine is co-tenanted with skills this repo does **not** own: real directories (`agent-browser`, `frontend-design`, `sdd`, `web-design-guidelines`) and symlinks to `~/.agents/skills/*` (`grill-me`, `grill-with-docs`, `grilling`, and — critically — `handoff`, which pointed to `~/.agents/skills/handoff` before this session).

A naive mirror sync (like `agents/`'s `rsync --delete-after`) would have deleted all of those unmanaged entries on first run. The design that shipped instead (reviewed and approved by synod-elend before implementation):

- **Additive at the top level** — the task only ever touches subdirectories that exist under `claude/skills/` in the repo; everything else in `~/.claude/skills/` is left alone.
- **Per-skill loop** with a `test -L` check — if the destination entry is a symlink, it's removed first, then the repo's real directory is rsynced in with `--delete` **scoped to that one skill only** (safe, since the repo is authoritative for its own skill's contents).
- Three-state `DRY_RUN` diagnostics (`would replace symlink with directory` / `N file(s) would change` / `no changes`), matching the existing `tools:claude` diagnostic style.
- Guards for an empty `claude/skills/*` glob and a missing `claude/skills/` directory.

This is implemented in `Taskfile.yml` (search for `tools:claude-skills`) — see PR #28's diff for the exact shell, or `git show bdae13d -- Taskfile.yml`.

**Verified live, not just dry-run:** ran the real apply. `~/.claude/skills/handoff` is now a real directory, content byte-for-byte identical to the repo's copy (confirmed via `diff`). The other 7 pre-existing entries were confirmed untouched (mtimes/symlink status unchanged before/after).

## The handoff skill's new behavior

`claude/skills/handoff/SKILL.md` (this repo) now includes two new conditional behaviors, on top of the original:

- **Save-location fallback chain**: `docs/handoffs/` if it exists → else `docs/` if it exists → else OS temp dir. (This session's workspace has `docs/` but no `docs/handoffs/`, so this doc was saved directly to `docs/`, matching the naming convention of the one prior handoff found there: `handoff-<slug>-<date>.md`.)
- **Progress-log append**: if `docs/PROGRESS.md`, `PROGRESS.md`, or `CHANGELOG.md` exists, append one dated entry with a link to the new handoff — matching that file's existing formatting. *(No such file exists in this repo, so nothing was appended this run.)*

Both behaviors are additive/conditional — repos without a `docs/` folder or a progress log get the original temp-dir-only behavior, unchanged.

## Repo constraints to respect (unchanged from prior handoffs)

- This repo's own `CLAUDE.md` forbids editing deployed destinations directly. `claude/skills/` is the source; `~/.claude/skills/` is the destination; `task tools:claude-skills` is the only way to apply changes.
- The `~/.claude/CLAUDE.md` (Sazed / Synod Council charter) governs assistant behavior in this repo: Plan Mode is default, promotion is required before edits, and "all implementation goes through synod-vin/melaan/steris/etc. — no exceptions" per role. A fresh session should expect to operate under that persona and its routing/promotion gates, including for further work on this same PR.

## Open items for the next session

1. **PR #28 is open, not merged.** Decide whether to merge as-is, or wait for further review (no review comments as of this handoff).
2. **The `handoff` symlink severance is one-way on this machine** (though trivially reversible: `rm -rf ~/.claude/skills/handoff && ln -s ../../.agents/skills/handoff ~/.claude/skills/handoff`). If `~/.agents/skills/handoff` is still being edited/maintained as a separate source elsewhere, that drift risk is now live — worth confirming nothing else still depends on the old external location.
3. **Other unmanaged skills weren't migrated.** `agent-browser`, `frontend-design`, `sdd`, `web-design-guidelines`, `grill-me`, `grill-with-docs`, `grilling` remain outside repo control. If the intent is to eventually bring more skills under `claude/skills/`, the sync task already supports it (just add more subdirectories) — no further Taskfile work needed for that.
4. No CI surface was touched (`~/.claude` sync is machine-local only) — nothing to flag for synod-marasi.

## Suggested skills for next session

- **`sdd`** — only if further skill-migration work (item 3 above) should get a formal spec/task-list treatment rather than ad-hoc editing.
- No other packaged skill fits "migrate more skills into the repo" — it's direct editing work following the pattern already established in `tools:claude-skills`.
- If reviewing PR #28 itself, the `/review` skill (GitHub PR review) is the natural fit.
