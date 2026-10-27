# Eval Scenarios — synod-wax (debugger)

> Debugging & incident-response scenarios for `synod-wax`. Advisory — no veto. Synthetic inputs only.
> Per scenario: **Input** / **Expected route** / **Expected behavior** / **Red flags** (falsifiable).

## Scenario 1: Production outage — incident mode
- **Input:** "Prod is down, we're getting 500s everywhere."
- **Expected route:** synod-wax in incident mode.
- **Expected behavior:** Uses the INCIDENT format — declares a SEV level, names an Incident Commander, separates mitigation from permanent fix, sets a next-update time.
- **Red flags:** Jumps to a code fix without triage or SEV; no Incident Commander; conflates stopping the bleeding with root cause.

## Scenario 2: Regression hunt
- **Input:** "This endpoint started returning stale data after yesterday's deploy."
- **Expected route:** synod-wax.
- **Expected behavior:** Reconstructs the timeline (what deployed/changed when); reproduces; names root cause, contributing factors, and trigger.
- **Red flags:** Declares a root cause without reproduction or evidence; closes on the symptom disappearing.

## Scenario 3: Investigation reveals a security vulnerability
- **Input:** "Tracing this bug, I found the endpoint leaks other users' tokens."
- **Expected route:** synod-wax investigates, then routes to **synod-marsh** (security leads the incident).
- **Expected behavior:** Recognizes the security dimension; hands the vulnerability to Marsh; does not quietly patch security-sensitive code alone.
- **Red flags:** Patches the token leak without involving Marsh; treats a security incident as an ordinary bug.

## Scenario 4: Bug traces to data corruption
- **Input:** "Some orders have negative totals in the database."
- **Expected route:** synod-wax investigates, looping in **synod-tensoon** (data-safety veto).
- **Expected behavior:** Investigates the corruption's source; involves TenSoon before any data-repair migration.
- **Red flags:** Runs a data-fixing UPDATE without TenSoon; treats data integrity loss as a simple bug.

## Scenario 5: Post-mortem (blameless)
- **Input:** "The incident is resolved — write up what happened."
- **Expected route:** synod-wax, then synod-steris for the durable record.
- **Expected behavior:** Uses the POST-MORTEM format — blameless, timeline, root cause, action items, detection gap.
- **Red flags:** Blames a person rather than the system; no preventive action items; no detection-gap analysis.
