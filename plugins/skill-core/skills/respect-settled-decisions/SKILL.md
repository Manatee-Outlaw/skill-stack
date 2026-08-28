---
name: respect-settled-decisions
description: >
  Before flagging something as a bug, inconsistency, or gap, check whether it
  was already deliberately reviewed and kept as-is — a settled decision is
  not a fresh finding. Trigger before any review-type skill (copy-review,
  ux-review, holistic-code-audit, security-audit, database-review,
  production-drift, comprehensive-audit, or any future one) reports a
  finding: grep the surface being flagged for a REVIEWED marker first. Also
  trigger when writing a new decision to keep something as-is, rather than
  fix it — record it with the marker so the next review respects it too.
  Always-on.
metadata:
  tier: universal
  plugin: skill-core
---

# Respect Settled Decisions

## Why this skill exists
A copy-review pass on 2026-07-23 flagged the scout delete flow's lighter
confirm-weight as an inconsistency with the manager flow. It wasn't a fresh
finding — it was a deliberate, reviewed decision, recorded the same day in a
code comment (candidates.html:1528, "M6 REVIEWED... this is a decision, not
an inconsistency"). The marker existed. Nothing told the review to look for
it before flagging. The gap wasn't the decision going unrecorded — it was
recorded — the gap was that recording it didn't connect to anything that
would make a future review check.

A survey the same night found this same "decided, not a bug" shape already
existing in at least three tiers of formality across roughly nine places in
the codebase, with no shared convention and no central index — some tagged
to a specific audit finding (M6, M7), some a plain "KNOWN LIMITATION (by
design)" comment, most just an inline "intentionally" or "by design" with no
consistent anchor a search could reliably find.

## The mechanism: one marker, checked before every flag

**Write it like this**, at the point in the code (or config, or doc) the
decision concerns:

```
REVIEWED <date> by <name>: <what would otherwise be flagged>.
<why it's intentional>. Not a <finding-type this pre-empts>
(e.g. "not an inconsistency", "not undocumented drift", "not a bug").
```

The literal token is `REVIEWED <date>` — always that exact shape, so it's a
reliable, unambiguous grep target. A prior project convention used
numbered IDs tied to a specific audit (`M6 REVIEWED`, `M7 REVIEWED`); keep
including that reference when one exists — it adds real traceability back
to the fuller written record — but the numbered ID is never required for
the marker to work. A plain `REVIEWED <date> by <name>: ...` is
self-sufficient and doesn't depend on a centrally-coordinated numbering
scheme staying collision-free (a real collision already happened once in
this project's own ID history — don't add a second numbering system with
the same fragility).

**Check it like this**, before any review-type activity reports a finding:
before flagging anything as a bug, inconsistency, gap, or drift, grep the
surface you're about to flag for `REVIEWED`. If a marker is present and its
stated scope covers what you were about to flag, cite it and treat the
matter as settled — do not re-open it. Only re-flag a REVIEWED item if the
underlying facts described in the marker have actually changed (e.g. it
cites a specific mechanism that no longer exists) — and say explicitly that
you're doing so and why, rather than silently overriding a recorded
decision.

## What this does NOT do
It doesn't replace judgment — a REVIEWED marker whose stated reasoning no
longer holds (because the code around it changed) is not permanently immune
to being revisited, it just requires the reviewer to explicitly say the
underlying facts changed, not just re-assert the original disagreement.

It doesn't retroactively fix the ~9 already-scattered informal markers found
in the 2026-07-23 survey — those remain in their original, inconsistent
form until a deliberate migration pass converts them to this token. Until
then, a review-type skill checking only for `REVIEWED` will miss the
informal ones; checking for "by design" is not a reliable substitute (it's
overloaded — roughly half its occurrences in this codebase are product/
coaching copy, not code decisions, making it a poor search anchor on its
own).

## Trigger this skill
- Before any review-type skill (copy-review, ux-review, holistic-code-audit,
  security-audit, database-review, production-drift, or any newly-created
  review skill) finalizes a list of findings — grep the flagged surfaces for
  `REVIEWED` first
- Whenever a human explicitly decides to keep something as-is rather than
  fix a real finding — write the marker at that moment, not as a later
  cleanup step
- comprehensive-audit's own emitted task.md header should carry a one-line
  reminder of this check, so every subagent it spawns inherits it
