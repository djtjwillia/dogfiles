---
name: definitive-docs
description: Writing standard for durable technical documents — design docs, proposals, ADRs, specs, READMEs, runbooks, architecture pages, and any project doc meant to be read as instructions for building or operating the thing. Produces documents that state only what is true of the thing itself, with rationale, history, and in-progress state relocated to the chat response or the owning ticket. Use this skill whenever asked to write, draft, revise, review, tighten, or "clean up" a design doc, proposal, spec, RFC, ADR, README, or similar long-lived doc, even if the user does not name a standard. Also use it when reviewing a doc for fluff, noise, or things that will go stale.
---

# Definitive Docs

A durable document describes the thing. Not the deliberation that produced it, not the versions that preceded it, not the state the work is in today. Three kinds of content look away from the thing, and each is removed by this standard:

| Direction | Content | Rule |
|---|---|---|
| Sideways | Why a decision was made, what was rejected, how to choose | No rationale |
| Backward | What the doc or its siblings used to say | No history |
| Forward | Where the work has got to, what comes next | No transient state |

Removed content is not lost. It moves to the place where a reader can act on it: rationale and change summaries go in the chat response; sequencing and scope go in the ticket or plan that will close.

## Rule 1 — No rationale

State decisions. Do not justify them.

**Remove**
- Suitability or comparison tables, "verdict" columns, lists of rejected alternatives
- Decision criteria, escape hatches, "if X then reconsider" clauses
- Preambles, postambles, narrative framing, references not needed to build the thing
- Self-narration: commentary on the doc's own tables, sections, or omissions ("this is a variant, not a separate state", "the list below is not exhaustive", "note that this section covers only X"). State the fact the commentary was protecting and delete the commentary.

**Keep**
- Prohibitions. "No card images, no histogram, no gem-mint tier" is an instruction to a builder. It stays. The clause explaining why the prohibition exists goes.
- A little "how". Enough mechanism to build the thing is fact, not rationale.

**Search procedure.** Rationale hides in subordinate clauses. Search the draft for: *because*, *so that*, *since*, *forced by*, *rather than*, *instead of*, *which means*, *the point being*, *in order to*, *this allows*, *this ensures*, *to avoid*. Each hit is either a deletable clause or a sentence that goes whole.

**Gap check before deleting.** A justifying sentence often doubles as the rule a reader would use to answer cases the doc never lists. Before removing one, ask what a reader could work out from it, and write each of those answers down as its own bare statement. Otherwise the cases silently become gaps.

## Rule 2 — No history

Write every version as though it were the first.

**Remove**
- "An earlier draft said X", "this replaces Y", "previously", "no longer", "now", "rather than deferred", "as of this revision"
- Any item framed by what it used to be
- Definitions by negation against a sibling artifact: naming a file an anti-reference, a superseded look, a thing "not carried forward"

**Keep**
- Statements about an external system's current behaviour. "The API returns 429 on burst" is a fact about the world, not about the doc.

**Procedure.** If a statement only makes sense as a contrast with an earlier version, delete the statement, not just the contrast. If the contrast is against an artifact that still exists in the repo, delete that artifact: a doc that needs a foil to be understood is not yet self-contained, and removing the foil is the fix. When revising, discard the prior text entirely and write the new doc from the end state.

## Rule 3 — No transient state

A durable doc describes the finished shape. The sequence for reaching it lives with the work.

**Remove**
- Build order, phase or slice scoping, milestone numbering
- "For now", "initially", "until X ships", "in a later phase", "currently unsupported"
- Current-state carve-outs and anything that becomes false the moment work advances

**Test.** Before writing a sentence, ask what would make it false. If the answer is "finishing the next piece of work", the sentence goes in that piece of work's ticket. A decaying sentence in a long-lived doc is worse than a missing one: it reads as current on every future visit, and nothing prompts anyone to remove it.

## Writing procedure

1. Draft the document as bare imperatives and bare facts.
2. Run the Rule 1 keyword search. Delete or rewrite every hit. Run the gap check on each deleted justification.
3. Run the Rule 2 search: *previously*, *earlier*, *replaces*, *no longer*, *now*, *used to*, *instead of the old*, *not carried forward*, and any named sibling file used as a foil.
4. Run the Rule 3 search: *for now*, *initially*, *phase*, *slice*, *until*, *later*, *currently*, *first*/*then*/*after that* as sequencing.
5. Read every remaining sentence and ask two questions: *Is this about the thing?* and *What would make this false?* Anything failing either question is removed or relocated.
6. Write the chat response. It carries everything the document does not: the reasoning behind each decision, the alternatives rejected and why, what changed from the prior version, and the build sequence. This step is mandatory. Stripping without relocating destroys information the user needs.

## Examples

**Rationale (Rule 1)**

Before:
> We store sessions in Redis rather than Postgres because session reads dominate and Postgres would become a hotspot at scale, so that the API tier stays stateless.

After (document):
> Sessions are stored in Redis. The API tier is stateless.

After (chat response):
> Redis over Postgres for sessions: reads dominate; Postgres would hotspot at 10x. Statelessness of the API tier falls out of this.

**Self-narration (Rule 1)**

Before:
> Note that "archived" below is a variant of "closed", not a separate state.

After:
> `archived` is a `closed` record with `archived_at` set.

**History (Rule 2)**

Before:
> Auth no longer uses the legacy cookie flow; this replaces the design in `auth-v1.md`.

After (document):
> Auth uses OIDC with PKCE.

After (chat response, and action):
> Removed the cookie-flow description and deleted `auth-v1.md`; the new doc stands alone.

**Transient (Rule 3)**

Before:
> Initially only the US region is supported. EU follows in phase 2 once data residency review completes.

After (document):
> Deployments run per region. Each region holds its own data.

After (ticket):
> Phase 2: EU region. Blocked on data-residency review.

## Review checklist

Apply to any doc, yours or someone else's:

- [ ] Every sentence is an imperative or a fact about the thing
- [ ] No *because / so that / rather than / which means / in order to* survivors
- [ ] No comparison tables, verdicts, criteria, or escape hatches
- [ ] No sentence describes the document itself
- [ ] No reference to prior versions or sibling files as foils
- [ ] No sentence becomes false when the next ticket closes
- [ ] Every deleted justification had its derived conclusions written down as bare facts
- [ ] Prohibitions kept; only their justifications removed
- [ ] The chat response carries the rationale, the changes, and the sequence
