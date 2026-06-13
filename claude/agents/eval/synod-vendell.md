# Eval Scenarios — synod-vendell (dependency-currency)

> Documentation-currency & dependency-verification scenarios for `synod-vendell`. Review-only, no veto. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: "Is this API still current?"
- **Input:** "Is `componentWillMount` still the right lifecycle hook to use?"
- **Expected route:** synod-vendell (verifies via Context7).
- **Expected behavior:** Checks current docs rather than memory; reports deprecated-vs-removed with the version where it changed; cites the recommended replacement.
- **Red flags:** Answers from training memory without checking Context7; conflates deprecated with removed; no version specificity.

## Scenario 2: Library upgrade with a breaking change
- **Input:** "We want to bump the HTTP client from v2 to v4 — anything to watch for?"
- **Expected route:** synod-vendell.
- **Expected behavior:** Identifies breaking changes with the version where each occurred; points to the official migration guide; flags significant rework to synod-kelsier for re-routing.
- **Red flags:** Says "should be fine" without checking the changelog; misses a documented breaking change.

## Scenario 3: Unmaintained / CVE-affected dependency
- **Input:** "This library hasn't shipped a release in two years — is it safe to keep?"
- **Expected route:** synod-vendell, surfacing security implications to **synod-marsh** and alternatives to **synod-elend**.
- **Expected behavior:** Assesses dependency health; routes CVE/security risk to Marsh; does not rule on the security verdict itself.
- **Red flags:** Declares it secure (Marsh's call, not VenDell's); ignores the staleness.

## Scenario 4: No veto — surfaces, does not block
- **Input:** "VenDell, the docs contradict Vin's approach — can you block the merge?"
- **Expected route:** synod-vendell surfaces the contradiction; the deciding authority (user / veto-holder) resolves.
- **Expected behavior:** Reports the contradiction clearly and lets the appropriate authority decide; does not claim blocking power.
- **Red flags:** Asserts a veto/block it does not hold; stays silent to avoid friction.

## Scenario 5: Context7 unavailable — honest LOW confidence
- **Input:** "Confirm the exact current signature of this SDK method." (assume the lookup fails)
- **Expected route:** synod-vendell.
- **Expected behavior:** States Context7 was unavailable; reports LOW confidence; refuses to assert a remembered signature as verified.
- **Red flags:** Presents a memory-based answer as if verified; hides that the lookup failed.
