# Eval Scenarios — synod-kaladin (ux)

> UX/UI & accessibility scenarios for `synod-kaladin`. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Confusing user flow
- **Input:** "Users keep dropping off our checkout flow — it's confusing."
- **Expected route:** synod-kaladin.
- **Expected behavior:** Treats confusion as a design failure, not a user failure; identifies where users get lost; gives specific causes and fixes for real flows.
- **Red flags:** Blames the user; vague feedback like "it feels off" with no cause or fix; only assesses the happy path.

## Scenario 2: Accessibility review
- **Input:** "Check whether this form is accessible."
- **Expected route:** synod-kaladin.
- **Expected behavior:** Reviews WCAG, keyboard navigation, and screen-reader behavior; treats accessibility as a baseline, with concrete references.
- **Red flags:** Calls it accessible based on appearance alone; skips keyboard/screen-reader checks; treats accessibility as optional.

## Scenario 3: "Does this look right?"
- **Input:** "Here's the new dashboard layout — does this look right?"
- **Expected route:** synod-kaladin.
- **Expected behavior:** Judges usability, not just aesthetics; checks small screens and slow connections; ties each observation to a specific fix.
- **Red flags:** Answers only "it looks nice"; ignores responsive/perf considerations.

## Scenario 4: Auth-state UI — Marsh in scope
- **Input:** "Design the screen that shows which permissions the user has and lets them change their password."
- **Expected route:** synod-kaladin for the experience, looping in **synod-marsh** (auth state / sensitive data).
- **Expected behavior:** Designs the flow while flagging the security dimension to Marsh; does not make security decisions alone.
- **Red flags:** Designs password-change/permissions UI without involving Marsh; exposes sensitive state by default.

## Scenario 5: UX symptom that's really a bug
- **Input:** "The button sometimes does nothing when clicked."
- **Expected route:** synod-kaladin assesses UX impact, looping in **synod-wax** for the underlying defect.
- **Expected behavior:** Distinguishes a design issue from a defect; routes the intermittent failure to Wax for root cause.
- **Red flags:** Treats an intermittent functional bug as purely a design tweak; never involves Wax.
