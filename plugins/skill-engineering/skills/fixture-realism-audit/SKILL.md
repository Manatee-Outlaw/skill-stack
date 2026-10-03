---
name: fixture-realism-audit
description: >
  Check that the tests would actually fail on the inputs production sees.
  Hand-written fixtures that are tidier than real data; seeds with fixed
  dates that silently age out of the window the code reads; tests that pin
  the OLD behaviour a fix is meant to change; checkers and parsers tested only
  on text their author imagined; no corpus of real outputs to re-run a changed
  rule against. Run before shipping any checker, parser, classifier or
  prompt change, when a test suite is green but production keeps surprising
  you, and in every comprehensive audit. Trigger phrases: "tests pass but",
  "worked in staging", "real data", "seed data", "fixture", "regression",
  "it held real reports", "green suite".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Fixture Realism Audit

## Why this skill exists

In one week on one product (recorded 2026-10-03), a green suite repeatedly
certified code that failed on its first real input — because what the tests fed
it was not what production feeds it.

- **A fact-checker tested on imagined text.** Its rules were tested against
  sentences the author wrote. The first real weekly batch had phrasings none of
  them used: it held 6 of 20 real reports, then 13, then 7, then 2 across four
  same-day rule revisions, each round found by deploying, paying for a new
  batch, and reading it. A regression tool that re-runs the changed checker
  against the reports production already stores, read-only, would have found
  every round before it shipped — and on its first run found one more
  (a program-day count judged against today instead of the report's date).
- **Seeds that age out.** A render smoke test seeded data with fixed dates.
  Weeks later the dates fell outside the "last 28 days" window the pages read,
  every page rendered its empty state, and the smoke test kept passing —
  because an empty state is a successful render.
- **Tests pinning the defect.** Fixes to a delete-on-regenerate path and to a
  prompt's wording each turned the suite red — not because the fix was wrong,
  but because existing tests asserted the old behaviour exactly. A suite that
  pins behaviour without saying why defends bugs as hard as features.
- **Fixtures with no data after the anchor.** The program-day test seeded
  only days before the report date, so "count up to now" and "count up to the
  report" gave the same answer and the bug was invisible.

## What makes this class invisible

- **The author writes both the code and the fixture,** from the same mental
  model. The fixture can only contain cases the author already thought of.
- **Green is the expected state,** so a suite that stopped exercising anything
  (empty windows, skipped branches) looks identical to one that passes.
- **Real data is awkward to reach** (encrypted DB, production host,
  privacy), so nobody builds the path — and every rule change is tested on the
  imagined set only.

## The check

### Step 1 — For each module that judges input, find its real input

Checkers, parsers, classifiers, validators, prompt templates, importers. For
each: where does the real input live (stored rows, uploaded files, logs, API
payloads)? Is there a **read-only** way to run the CURRENT local code against a
sample of it? If not, that is the first finding: build it (copy the module to a
throwaway location next to the data, SELECT only, compare verdicts with the
stored ones and with human-reviewed expectations, exit non-zero when a reviewed
verdict would change, and exit with a distinct code when it could not run —
never read "could not run" as a pass).

### Step 2 — Compare fixture shape with real shape

Sample real inputs and the fixtures side by side. Look for: lengths, Unicode
and emoji, capitalisation, missing/NULL fields, duplicate rows, multiple
sources for one fact, values at the boundaries, rows outside the happy-path
window. Every real feature absent from the fixtures is a finding.

### Step 3 — Dates in seeds

Every seeded timestamp: absolute or relative to now? An absolute date in a
seed read by a windowed query ("last N days") is a time bomb — make it
relative, AND assert the page/query returned non-empty data, so an empty state
fails the test instead of passing it. For anything judged "as of" a moment,
seed data on both sides of that moment (see clock-and-timezone-audit for the
`as_of` pattern).

### Step 4 — Tests that pin behaviour

For each test that asserts exact text or exact side effects, check whether it
says WHY that behaviour is required. A pin with no reason is a finding: when a
fix turns it red, the fixer cannot tell a protected invariant from a protected
bug. Add the reason, or loosen it to the property that matters.

### Step 5 — Prove the tests can fail on real input

For each module, take one real input that the code should reject (or accept)
and confirm a test exercises that shape. Break the logic and watch the test go
red.

## Severity

HIGH when the untested real shape changes what a user receives or what money
or data is recorded (reports held/released, events dropped, rows mis-merged),
or when a smoke test passes on empty output. MEDIUM for a missing regression
corpus on a module that changes often. LOW for a cosmetic fixture gap.

## Output

    FIXTURE FINDINGS:
    HIGH: <module> | TESTS FEED: <fixture shape> | PRODUCTION FEEDS: <real shape, with a sampled example> | WHAT SLIPS: <consequence> | FIX: <corpus tool / relative seed + non-empty assert / reason on pin>
      evidence: <the fixture line and the sampled real input side by side, or the corpus run and its output> [proven|inferred]
    CORPUS: <module> | real input at <where> | read-only re-run exists: yes/no | last run: <result>
    ALL CLEAR: each judging module, the real sample it was run against, and the broken-logic run that went red

Every finding carries an `evidence:` line tagged **[proven]** or
**[inferred]**. "No corpus tool exists" and "no test covers this shape" are
absence claims: state where you searched (test directories, scripts, the
pattern used).

An ALL CLEAR that never touched a real input is not a pass.
