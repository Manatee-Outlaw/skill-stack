---
name: re-verify-carried-claims
description: >
  Governing standard: a specific claim carried forward from an earlier report —
  a number, a date, a named example, a count — must be re-verified against the
  live system before being repeated anywhere the stakes are real. Reports are
  snapshots that decay; repeating one without re-checking launders a stale or
  wrong claim into a fresh document with fresh authority. Sibling of
  no-assumed-memory (which covers claims remembered from conversation; this
  covers claims READ from a real saved report and repeated without re-checking).
metadata:
  tier: universal
  plugin: skill-core
---

# Re-Verify Carried Claims

## The rule

When a report, audit, task description, or handoff repeats a **specific**
claim from an earlier document — a number, a deadline, a named example, a
count, a "still broken" or "still fine" — that claim must be re-verified
against the live system before it ships in the new document, whenever the
claim would change a decision if wrong.

Reading it in a real, saved report is not verification. The report was true
(at best) when it was written. Your new document re-asserts it as true NOW,
under your name, with fresh authority — and the reader can no longer tell it
was never re-checked.

## Why this exists

Three carried-claim failures happened in a single working day on one project,
each one a claim faithfully copied from a genuinely real earlier report:

1. **A named example that was false.** A report claimed a specific record was
   missing from a dataset; a later task repeated the example; a code comment
   then enshrined it. One live query showed the record had existed all along —
   the original claim was a narrative slip, and two more documents had
   laundered it into fact.
2. **A computed deadline a month off.** A "data goes dark on <date>" claim was
   computed from the wrong column in report N, then carried into report N+1
   and a task description. Reading the actual gate code moved the real date by
   over three weeks.
3. **A count 3x understated.** "Two records affected" traveled through three
   documents; the live query behind the eventual fix found six (then seven).
   Every intermediate document had repeated the two.

None of these were lies, memory failures, or fabrications — no-assumed-memory
was satisfied every time, because each writer really did read the prior
report. The failure mode is distinct: **the prior report itself was wrong or
stale, and repetition gave it compound interest.**

## How to apply

- Before repeating a specific figure/date/example/count from an earlier
  document: if it is checkable in one query, one grep, or one file read —
  check it. That is almost always the case.
- If re-verification is genuinely impossible (the system is gone, the data
  expired), attribute it explicitly: "per the <date> report (not re-verified)"
  — never restate it bare.
- Corrections outrank politeness: if the re-check contradicts the earlier
  report, say so plainly in the new document and name what the earlier report
  got wrong, so the stale claim's trail ends rather than forks.
- Prose summaries, vibes, and directional statements ("revenue grew",
  "adoption is slow") don't trigger this rule. Specificity does — the moment a
  claim is precise enough to be falsified by one query, it is precise enough
  to deserve one.

## Trigger this skill

- Writing any report/audit that cites an earlier report's findings
- Task descriptions that carry forward examples or numbers from prior sessions
- Code comments about to enshrine a "known fact" from a document
- Any sentence containing a number or named example you did not personally
  verify in THIS session
