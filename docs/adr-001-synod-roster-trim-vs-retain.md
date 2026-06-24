# ADR-001: Synod Council Roster — Trim vs. Retain

- **Status:** PROPOSED — decision pending user review
- **Date:** 2026-06-18
- **Deciders:** User (Mistborn); informed by synod-steris (docs & planning)
- **Supersedes:** none
- **Related:** `docs/kelsier-audit.md` (role-by-role Kelsier audit, 2026-06-18); commit `e859969` (routing dialled to advisory)

---

## Context and Problem Statement

The Synod Council is a 12-agent roster (`~/.claude/agents/synod-*.md`) coordinated by
Sazed, the main assistant governed by `CLAUDE.md`. As of commit `e859969`, Sazed's
routing posture was dialled to **advisory**: Sazed names a specialist and waits for
user approval, auto-dispatching only for multi-discipline or high-blast-radius tasks.

This raises a roster-design question with two layers:

1. **Narrow (Kelsier-specific):** Given that Sazed already routes and narrates, and the
   charter lean-core already encodes the routing controls (Marsh-first, Elend-before-Vin,
   the 3-agent ceiling, the escape-hatch dial) — and each agent's `description`
   frontmatter already carries the keyword triggers the harness dispatches on — is
   **synod-kelsier** redundant?

2. **Broad (whole-roster):** More generally, is a 12-agent roster the right size, or
   should it be trimmed? The charter's own governance rules (`charter-details.md:76–93`)
   set explicit ADD/RETIRE criteria and prize a roster "small enough that routing remains
   legible." That principle invites periodic re-examination.

We need a record that lays out the forces, the options, and the decision criteria — so
the decision, whenever made, is made deliberately and is traceable later.

---

## Decision Drivers

- **Legibility:** the charter explicitly values a roster small enough that routing stays
  legible (`charter-details.md:78`). Every agent added is cognitive and maintenance load.
- **Single source of truth:** routing logic currently exists in **three** places — each
  agent's `description` frontmatter (what the harness actually dispatches on), Sazed's
  `CLAUDE.md` routing rules, and Kelsier's keyword table. Triplication is a drift hazard.
- **Honest documentation:** the charter should describe what the system actually does. An
  agent that is silently skipped in most sessions makes the charter aspirational rather
  than descriptive — a condition this agent (synod-steris) holds veto against.
- **Structural integrity of the veto protocol:** `charter-details.md:25, 28, 36` name
  **synod-kelsier** by name as the holder of veto-vs-veto synthesis, non-veto mediation,
  and the cascading-halt notification. Any change must keep those references coherent.
- **Cost vs. benefit per agent:** model allocation (`charter-details.md:40–45`) already
  reflects cost-consciousness (Opus reserved for Marsh/Elend). Agents that rarely fire
  carry low running cost but ongoing maintenance cost.
- **Reversibility:** roster changes are cheap to reverse (re-adding a markdown file), but
  charter references and eval scenarios must move with them.

---

## The Kelsier Re-examination

A direct test of each capability in `synod-kelsier.md` against "can Sazed + the charter
already do this?":

| Capability (source) | Already covered elsewhere? | Verdict |
|---|---|---|
| Keyword→agent table (`synod-kelsier.md:46–58`) | Yes — agent `description` frontmatter (harness dispatch signal) **and** `CLAUDE.md` routing rules | **Redundant** (triplicated logic) |
| Marsh-first / Elend-before-Vin (`:65–72`) | Yes — non-negotiable lean-core controls | **Redundant** (restates core) |
| 3-agent ceiling (`:71`) | Yes — lean-core control | **Redundant** (restates core) |
| Non-veto mediation (`:152–153`) | No — Sazed is narrator, not a write-blocked neutral mediator | **Genuine, rarely fires** |
| Veto-vs-veto synthesis (`:154–168`) | No — charter names Kelsier as the sole holder | **Genuine, structurally load-bearing** |
| Cascading-halt notification (`:166`) | Partial — rule is in core, but needs a notifiee | **Aspirational** (no auto-trigger) |

**Finding:** Kelsier is **mostly redundant on his headline function (routing)** and
**non-redundant on a small, infrequent function (conflict/veto synthesis + halt
coordination).** The routing table is a third copy of logic that already exists in two
more authoritative places; the harness dispatches on `description` frontmatter whether or
not Kelsier's table exists. Under the advisory dial, Sazed names specialists directly and
Kelsier is silently skipped on the majority of single-discipline tasks.

**What is genuinely lost if Kelsier is deleted outright:** a named, write-blocked holder
for veto-vs-veto synthesis and cascading-halt notification. Three charter references
(`charter-details.md:25, 28, 36`) point at "synod-kelsier" by name; deleting the agent
without amending them leaves the conflict-resolution protocol pointing at a non-existent
holder. This is the real capability gap — small, infrequent, but structurally present.

The redundancy is not merely "Sazed could do it too" — it is **active logic
triplication**, which is itself a maintenance and drift hazard independently of the
capability question.

---

## The Case FOR Trimming

- **Legibility dividend:** fewer agents → faster, more reliable routing; a reader can hold
  the whole roster in mind. The charter itself states this as a value.
- **Eliminate triplicated routing logic:** removing Kelsier's table (and any other
  agent whose triggers overlap heavily) collapses three copies of the routing map toward
  one authoritative source (frontmatter), reducing drift risk.
- **Honesty:** an agent silently skipped in most sessions is charter debt. Trimming makes
  the documented system match the operating system.
- **Maintenance cost compounds:** every agent needs a `description`, coordination links,
  an eval scenario, and a roles-table row (`charter-details.md:95–101`). Twelve of these
  is a non-trivial standing surface to keep accurate.
- **Overlap risk elsewhere:** VenDell's "API currency" review vs. Vin already verifying
  APIs via Context7; Jasnah's advisory review vs. Elend/Marsh on escalation — further
  candidates under the same RETIRE criteria.

## The Case AGAINST Trimming

- **The veto protocol needs a named holder:** veto-vs-veto synthesis and cascading-halt
  coordination are referenced by name and have no other home. Removing the holder without
  relocating the function breaks the protocol.
- **Separation of concerns is real:** a write-blocked mediator distinct from Sazed's
  narrator posture is a cleaner conflict-resolution design than folding mediation into the
  same voice that proposes the work.
- **Low running cost:** Kelsier is `sonnet`/`effort: low` and rarely invoked — cheap to
  keep.
- **Reversal is not free:** trimming requires amending three charter references, the roles
  table, and eval scenarios. Done carelessly, the trim creates more drift than it removes.
- **"Rarely fires" ≠ "never needed":** the RETIRE criterion is **10+ active sessions with
  no route** (`charter-details.md:91`). The mediation function may not have hit that bar;
  retiring on redundancy of the *routing* role alone over-reaches.

---

## Options Considered

### Option 1 — Retain as-is, with governance discipline

Keep all 12 agents. Accept that Kelsier's routing role overlaps Sazed/charter, and rely
on the existing ADD/RETIRE governance (`charter-details.md:76–93`) and the dial to manage
roster size over time. Optionally add a note acknowledging the routing-logic overlap.

- **Pros:** zero structural change; veto protocol stays intact; fully reversible (it's the
  status quo); no eval or charter-reference churn.
- **Cons:** routing logic stays triplicated; the charter remains partly aspirational about
  Kelsier; legibility cost of 12 agents persists; defers rather than resolves the question.
- **Right call if:** veto-vs-veto/mediation events are confirmed to occur (or are judged
  likely), and the maintenance overhead of 12 agents is acceptable.

### Option 2 — Targeted consolidation: strip Kelsier's routing role, keep him as mediator

Remove the keyword→agent table and routing rules from `synod-kelsier.md`. Reframe his
mandate around the three functions only Sazed cannot cleanly own: non-veto mediation,
veto-vs-veto synthesis, and cascading-halt coordination. Charter references stay valid
because the holder still exists. No `CLAUDE.md` or `charter-details.md` edits strictly
required. Optionally examine VenDell/Jasnah overlap under the same lens as a second pass.

- **Pros:** kills the triplicated routing logic; charter becomes honest about what Kelsier
  does; veto protocol keeps its named holder; smaller, more legible Kelsier definition;
  fully reversible.
- **Cons:** the council still has 12 names (legibility of *count* unchanged); requires
  careful edit + an updated eval scenario for Kelsier's narrowed role; a borderline
  multi-discipline triage now lands on Sazed rather than a specialist router.
- **Right call if:** veto-vs-veto/mediation has genuine (even if rare) value, AND removing
  triplicated routing logic is judged worth a focused edit.

### Option 3 — Trim deeply (toward ~6 core agents)

Retire Kelsier entirely (folding veto-synthesis into Sazed's escalation language) and
apply the RETIRE criteria aggressively across the roster — e.g. fold VenDell into
Vin/Elend's existing Context7 verification, fold Jasnah's advisory review into Elend/Marsh,
consolidate where triggers are coin-flips. Target a lean core (~6) of clearly
non-overlapping domains.

- **Pros:** maximum legibility; one authoritative routing source; lowest standing
  maintenance surface.
- **Cons:** highest blast radius and least reversible in one step; requires rewriting the
  conflict-resolution protocol to remove Kelsier-by-name and rehome mediation in Sazed
  (mixing narrator and mediator roles); risks losing genuine specialist nuance (VenDell's
  Context7 discipline, Jasnah's dedicated review verdict); several agents may not have hit
  the 10-session RETIRE bar, so this would override the council's own governance criteria.
- **Right call if:** real usage data confirms multiple agents go 10+ sessions unrouted AND
  veto-vs-veto conflicts are confirmed absent, justifying a deliberate governance override.

---

## Decision

**OPEN — pending user review.**

This ADR is a record to inform the decision, not to make it. The prior audit
(`docs/kelsier-audit.md`) and this analysis both point toward **Option 2 (targeted
consolidation)** as the lowest-risk move that resolves the documented redundancy, but the
choice belongs to the user.

**Recommended decision sequence:**
1. User selects Option 1, 2, or 3.
2. If Option 2 or 3: route the Kelsier edit through **synod-vin** (implementation) —
   synod-steris holds docs-accuracy veto and must confirm the charter references and eval
   scenarios stay coherent before sign-off.
3. If Option 3: consult **synod-elend** first — retiring agents and rehoming the
   conflict-resolution protocol is a structural decision within Elend's veto domain.

---

## Consequences

**If Option 1 (retain):**
- No code/charter change. Routing-logic triplication and charter aspiration persist as
  known, accepted debt. Revisit when any agent crosses the 10-session RETIRE bar.

**If Option 2 (consolidate Kelsier):**
- `synod-kelsier.md` shrinks to mediation/synthesis/halt; routing table removed.
- Charter references at `charter-details.md:25, 28, 36` remain valid (holder still exists).
- A new eval scenario must cover the narrowed role; the old routing eval is retired.
- Routing logic collapses toward the frontmatter source of truth.
- Borderline multi-discipline triage now lands on Sazed directly.

**If Option 3 (deep trim):**
- Multiple agent files retired; `CLAUDE.md` roles table, `charter-details.md`
  conflict/escalation matrix, and the alias map all require coordinated edits.
- Conflict-resolution protocol must be rewritten to remove Kelsier-by-name and rehome
  mediation in Sazed — mixing narrator and mediator roles.
- Highest legibility gain, highest blast radius, least reversible. Overrides the council's
  own RETIRE criteria unless usage data justifies it — record that justification here when
  the decision is made.

**In all cases:** this ADR stays in `docs/` as the durable reference. Any future roster
change should append its outcome to this record rather than starting a fresh, contextless
discussion.
