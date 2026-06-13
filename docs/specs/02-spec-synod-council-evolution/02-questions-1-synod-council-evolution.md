# 02 Questions Round 1 — Synod Council Evolution

Please answer each question below (check one or more options, or add your own notes under any question). The planning brief (`docs/planning/synod-council-evolution-brief.md`) already locked most decisions; these are only the genuinely-open forks the brief flagged for SDD-1.

---

## 1. Spec boundary — is the eval harness in scope here?

The brief defines 5 workstreams. I propose folding them into 4 demoable units (auto-routing / agent-body upgrades / charter-split+governance+new-agents / eval-harness). Workstream 5 (eval harness + `/run-evals` skill) is the most separable.

- [x] (A) **Keep all four units in this one spec.** One cohesive change, one PR series. (My recommendation — the units share the same files and verifying auto-routing *needs* the eval scenarios anyway.)
- [ ] (B) **This spec = units 1–3; defer the eval harness to a follow-on `03-spec`.** Smaller blast radius now, evals later.
- [ ] (C) Other (describe)

---

## 2. `synod-e2e` agent — add, extend Vin, or defer?

The brief left this explicitly undecided. Candidate: a Playwright/browser end-to-end testing agent that pairs with the `agent-browser` skill.

- [x] (A) **Do not add; fold e2e into synod-vin's scope** (note browser-testing in Vin's body + Coordination map). Keeps the ceiling. (My lean — no recurring e2e demand evidenced yet.)
- [ ] (B) **Add `synod-e2e` as a new agent** with full body + description + eval scenarios.
- [ ] (C) **Defer entirely** — out of scope for this spec, revisit later.
- [ ] (D) 

---

## 3. `synod-reviewer` agent — add now in this spec?

The brief rated this "Add — strong" (recurring PR/diff-review discipline, distinct from Elend's architecture and Marsh's security; we have `/code-review` skills but no review *agent*).

- [ ] (A) **Add `synod-reviewer` now** — full body, routable description, bidirectional Coordination, eval scenarios. (Matches the brief's verdict.)
- [ ] (B) **Define it in the spec but mark implementation as a fast-follow** (governance rubric applied, body authored later).
- [ ] (C) **Don't add** — the `/code-review` skill is sufficient; skip the agent.
- [x] (D) **Add `synod-reviewer` now** — full body, routable description, bidirectional Coordination, eval scenarios. (Matches the brief's verdict.) please also suggest a name for this agent, maybe from the Stormlight Archive that would be a fitting personality

---

## 4. Escape hatch — which routing posture ships as the *default*?

The brief locked "auto-route on discipline match" + a documented, reversible escape hatch (narrow to "multi-discipline OR high-risk only"). Question is which state the charter ships in.

- [ ] (A) **Ship aggressive** — auto-route on any single-discipline match by default; escape hatch documented as the dial-down. (Matches the primary ask; max responsiveness, higher token cost.)
- [x] (B) **Ship conservative** — default to "multi-discipline OR high-blast-radius only"; document the dial-*up* to full discipline-match. (Lower token cost out of the gate.)
- [ ] (C) Other (describe)

---

## 5. How do evals actually *run*? (defines proof artifacts + `/run-evals`)

The eval scenarios are markdown (Input / Expected route / Expected behavior / Red flags). "Running" them needs a defined mechanism, since there's no compiler for prompt-routing.

- [x] (A) **`/run-evals` spawns a subagent per scenario** that reads the prompt, reports which agent *would* route, and self-judges pass/fail against Expected; appends to `eval/results.md`. (Automatable proof artifact.)
- [ ] (B) **`/run-evals` is a structured manual checklist** — it prints scenarios for a human to run interactively and record verdicts. (Cheaper, less repeatable.)
- [ ] (C) **Both** — manual checklist now, automated subagent-judging as a documented stretch goal.
- [ ] (D) Other (describe)

---

## 6. Alias map — documentation-only, or functional alternate invocation?

The brief adds a `synod ↔ descriptive` alias map (kelsier=router, vin=coder, …).

- [x] (A) **Documentation-only** — a reference table in `charter-details.md` for cross-referencing Nate's evals and human readability. Agents keep their `synod-*` names only. (Simplest; no harness behavior change.)
- [ ] (B) **Functional aliases** — descriptive names also resolve as invocable agent references (requires duplicate files or harness support — likely not supported for loose-file agents).
- [ ] (C) Other (describe)

---

## 7. Anything the brief got wrong, or any constraint changed since 2026-06-12?

The brief is dated today, but confirm nothing has shifted (e.g., a decision to reconsider packaging, renaming, or the Sazed persona).

- [x] (A) **Brief still holds — no changes.**
- [ ] (B) Something changed (describe below)
