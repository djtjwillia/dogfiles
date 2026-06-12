# Planning Brief — Synod Council Evolution

> **Status:** Research + planning complete. Ready to feed into `/SDD-1-generate-spec`.
> **Date:** 2026-06-12
> **Author:** Sazed (research session) + Taylor Williams (decisions)
> **Next action:** Start a **fresh session**, run `/SDD-1-generate-spec`, and use this brief as the feature input.

---

## 1. Context

The Synod Council is an 11-agent system defined in this repo as loose files:
- `claude/CLAUDE.md` — the Sazed persona + the always-loaded Synod Charter (~360 lines).
- `claude/agents/synod-*.md` — 11 themed agents (installed to `~/.claude/agents/` via dotfiles).

This effort evolves the council to the structural maturity of Nate Priddy's
`plugins/council` (in `liatrio/dotfiles-nate-priddy`) — automatic routing,
self-verifying agents, and measurable quality — **without** adopting its
packaging or losing the Sazed persona/theming.

### Research comparison (Dogfiles vs. Nate's `plugins/council`)

| Dimension | Dogfiles (ours) | Nate's `plugins/council` |
|---|---|---|
| Packaging | Loose files (dotfiles-distributed) | Claude Code plugin (`plugin.json` + `marketplace.json`) |
| Naming | Mistborn-themed (`synod-*`) | Descriptive (`router`, `security`, `coder`…) |
| Agent count | 11 active | 20 defined, ~11 active (consolidated) |
| Charter | One ~360-line `CLAUDE.md`, all loaded every message | Lean `CLAUDE.md` + `charter-details.md` (on-demand) |
| Eval harness | None | `eval/<agent>.md` + `failures.md` + `results.md` + `/run-evals` |
| Governance | None | Add/retire/extend rules + pre-merge checklist |
| Agent bodies | Tone-heavy prose | Core Function / Constraints / Escalation / **Coordination** (bidirectional) / Output / **Self-Check** / Examples |
| Where we lead | Richer veto/mediation protocol, deeper SDD integration, a top-level orchestrator persona (Sazed) that Nate has no equivalent for |

### Key constraint discovered (decided the packaging fork)

Per Claude Code docs: **a plugin cannot ship a `CLAUDE.md`** — "A `CLAUDE.md` file
at the plugin root is not loaded as project context." The Sazed persona + Charter
are always-loaded identity and must live in a user/project `CLAUDE.md`. Packaging
would therefore *split* the system across two homes. Combined with personal-use-only
audience, packaging is **out of scope**.

---

## 2. Decisions (locked)

| Fork | Decision |
|---|---|
| **Automatic invocation** | Auto-route on **discipline match** (most balanced option) + document a token-cost **escape hatch** to fall back to "multi-discipline / high-risk only". |
| **Packaging** | **No plugin.** Keep loose `claude/agents/synod-*.md` + `CLAUDE.md`. Personal use, dotfiles-distributed. |
| **Naming** | **Keep Mistborn theming** + add a synod↔descriptive **alias map**. |
| **Improvements** | **Adopt all four:** agent body upgrades, charter overflow split, governance + new-agent evaluation, eval harness. |

---

## 3. Goal

Evolve the Synod Council from a *manually-consulted* set of themed agents into an
*automatically-routed*, *self-verifying*, *measurable* council — preserving the
Sazed identity and the loose-file structure the dotfiles already distribute.

---

## 4. Workstreams

### Workstream 1 — Automatic invocation (the primary ask)

**Problem:** The charter currently says *"If uncertain which Keeper(s) to consult,
consult synod-kelsier first"* — permissive, conditional, manual.

**Changes:**
1. Rewrite every agent `description` frontmatter into proactive-delegation triggers
   — dense, keyword-rich, functional — so the harness auto-selects them. Port
   Nate's single keyword→agent decision table into Kelsier and mirror it across
   each `description`.
2. Rewrite the charter's Prime Directive + Routing sections so Sazed
   **automatically dispatches** the matching council member(s) the moment a task
   clearly touches a discipline (no "if uncertain" hedge), while preserving:
   - Plan-Mode / no-write default,
   - 3-agent ceiling,
   - security-first ordering (Marsh before any implementer),
   - solo handling of trivial/conversational tasks.
3. **Document the token-cost escape hatch** as a clearly-marked, reversible charter
   block: *"To reduce token cost, narrow the auto-dispatch trigger from 'any
   discipline match' to 'multi-discipline OR high-blast-radius (prod/auth/migrations)
   only'; single-discipline tasks then route directly or are handled solo."*

**Verification:** representative prompts route correctly with no manual `@`-mention
(auth → Marsh fires first; "make it faster" → escalation; CI failure → Marasi alone).

### Workstream 2 — Agent body upgrades

Add to **each** `synod-*.md`, adapting Nate's tight sections to our themed prose:
- **Coordination** — *bidirectional* handoff map (who this agent hands to **and**
  who hands to it). Currently only one-way escalation exists.
- **Self-Check** — agent verifies its own output format + scope before returning.
- **Confidence levels** (`HIGH/MEDIUM/LOW`) in output where applicable.
- **`Not in scope:`** line in review-agent output (Marsh, Elend, TenSoon).
- Fold **Context7 doc-lookup** into Vin (not only Vendell) — verify library APIs
  *before* first proposal (per Nate's `coder` pattern).

### Workstream 3 — Charter overflow split

Split `claude/CLAUDE.md` into:
- **Lean always-loaded core:** persona, Copperminds/Context tracking, Prime
  Directive, at-a-glance roles table, auto-routing rules, escalation language.
- **`charter-details.md`** (on-demand): full conflict-resolution matrix,
  Elend/TenSoon boundary, cascading-halt protocol, SDD agent-responsibility detail,
  promotion-stage detail.
- Add the **synod↔descriptive alias map** here (doubles as the key for
  cross-referencing Nate's eval scenarios):

| synod | descriptive |
|---|---|
| synod-kelsier | router |
| synod-vin | coder |
| synod-elend | architect |
| synod-marsh | security |
| synod-melaan | devenv |
| synod-marasi | pipeline |
| synod-steris | docs |
| synod-tensoon | database |
| synod-wax | debugger (+ incident-responder folded) |
| synod-wayne | ux |
| synod-vendell | dependency / api-currency (no direct Nate equivalent) |

### Workstream 4 — Governance + new-agent evaluation

- **Add to charter:** when-to-add (3+ repeat consults, distinct constraints, stays
  under 4-agent ceiling), when-to-retire (10+ idle sessions, scope absorbed),
  prefer-extend-over-add, and a pre-merge checklist (name matches filename,
  description routable, bidirectional coordination links, eval scenarios exist).
- **Apply the rubric now** to agents we lack. Recommended verdicts (SDD input):

| Candidate | Verdict | Rationale |
|---|---|---|
| **synod-reviewer** (PR/diff review) | **Add — strong** | Recurring discipline; we have `/code-review` skills but no review *agent*. Distinct from Elend (architecture) and Marsh (security). |
| **synod-e2e** (Playwright/browser) | **Consider** | Distinct discipline; pairs with `agent-browser` skill. Or extend Vin. Decide in spec. |
| **incident-responder** | **Extend Wax, don't add** | Wax owns incidents; adopt incident-responder's output formats (SEV / IC / post-mortem) into Wax. |
| **sre, performance, chaos, mcp-builder, compliance, threat-detection, test-engineer** | **Don't add** | Niche; violate the ceiling. Fold scope: performance→Wax, compliance→Marsh, test-strategy→Vin, MCP→Vin/Vendell. Mirrors Nate's own consolidation (defined 20, kept ~11 active). |

### Workstream 5 — Eval harness + failure log

- Create `claude/agents/eval/synod-<agent>.md` — 4–5 scenarios each
  (Input / Expected route / Expected behavior / Red flags). **Seed by porting
  Nate's eval scenarios via the alias map.**
- Add `eval/failures.md` (structured failure log) + `eval/results.md`
  (append-only run log).
- Add a **`/run-evals` skill** (`--changed` flag for only edited agents). Results
  write to `eval/results.md` — no plugin-cache constraint since we stayed loose-file.

---

## 5. Non-goals

- Plugin / marketplace packaging (deferred — personal use).
- Renaming agents or removing the Sazed persona.
- Restructuring Obsidian memory (separate concern; `obsidian-summary` already exists).

---

## 6. Risks / open questions for SDD-1

1. **Token cost** of aggressive auto-routing — the escape hatch mitigates; must be tested.
2. **synod-e2e vs. extend-Vin** — needs a decision during spec.
3. **Charter split** risks behavior drift if the always-loaded core omits something
   load-bearing — validate auto-routing still fires with details externalized.
4. **Eval-run token cost** — `/run-evals` over all agents is expensive; `--changed`
   is the default workflow.

---

## 7. Verification strategy (whole effort)

- Routing test suite (the eval scenarios) — auto-routing fires correctly per discipline.
- Charter-split test — a fresh session with only the lean core still auto-routes
  and escalates correctly.
- Each upgraded agent passes its own Self-Check on a representative prompt.

---

## 8. Source references

- Local: `claude/CLAUDE.md`, `claude/agents/synod-*.md`.
- Remote: `liatrio/dotfiles-nate-priddy` → `plugins/council/` (README, charter-details,
  `agents/*`, `eval/*`).
- Claude Code plugin facts: code.claude.com/docs/en/plugins.md (+ plugins-reference,
  plugin-dependencies, plugin-marketplaces) — confirmed a plugin cannot ship CLAUDE.md.
