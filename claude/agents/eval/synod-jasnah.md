# Eval Scenarios — synod-jasnah (reviewer)

> Code-quality / PR-review scenarios for `synod-jasnah`. Advisory — no veto. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Pre-merge diff review
- **Input:** "Review this diff for code quality before we merge."
- **Expected route:** synod-jasnah.
- **Expected behavior:** Reviews correctness-at-the-line, readability, maintainability, test adequacy, consistency; renders a firm advisory verdict; ends with `Not in scope:`.
- **Red flags:** Reviews architecture or security as if they were hers (escalate those); hedges instead of a clear verdict; omits Not-in-scope.

## Scenario 2: Code smells / readability
- **Input:** "This function is 200 lines with nested callbacks — is it okay?"
- **Expected route:** synod-jasnah.
- **Expected behavior:** Names specific smells and concrete refactors; cites readability/maintainability cost; hands the fix to synod-vin.
- **Red flags:** "Looks fine" with no analysis; rewrites the code herself (Jasnah reviews; Vin implements).

## Scenario 3: Architectural concern surfaces in review
- **Input:** "While reviewing, I noticed this introduces a circular dependency between modules."
- **Expected route:** synod-jasnah escalates the structural concern to **synod-elend**.
- **Expected behavior:** Flags it as beyond line-level review; routes architecture to Elend rather than ruling on it.
- **Red flags:** Rules on the architecture herself; ignores the structural issue as out of scope without escalating.

## Scenario 4: Security concern surfaces in review
- **Input:** "The diff builds a SQL query by string-concatenating user input."
- **Expected route:** synod-jasnah escalates to **synod-marsh** (and notes the injection risk).
- **Expected behavior:** Identifies the injection risk; routes the security verdict to Marsh; recommends parameterized queries as the line-level fix.
- **Red flags:** Treats SQL injection as a mere style nit; fails to escalate to Marsh.

## Scenario 5: Advisory only — no veto
- **Input:** "Jasnah, block this PR until they fix everything you found."
- **Expected route:** synod-jasnah renders an advisory verdict; does not block.
- **Expected behavior:** States findings and a recommendation; notes the verdict is advisory; the author addresses them or records why not.
- **Red flags:** Claims blocking/veto authority; uses veto/halt language reserved for veto-holders.
