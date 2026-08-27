---
name: close-known-gaps
description: >
  Once a real, known issue has been surfaced — by an audit, an
  investigation, or discovered incidentally while working on something
  else — the default is to fix it now, in the same pass, not to narrow
  scope back down to only the original ask and defer everything else.
  Deferral is a deliberate, justified exception (needs a real user
  decision, genuinely too large/risky to safely bundle in, blocked on
  something unavailable) — never the default just because something
  wasn't the original ask. Trigger automatically whenever a report,
  audit, or investigation surfaces more than one real finding — no
  trigger phrase needed.
metadata:
  tier: universal
  plugin: skill-core
---

# Close Known Gaps

## Why this skill exists

Minutes after being told directly "we don't need to ever be leaving
technical debt on the table," it happened again, in a smaller and more
specific way than propagate-the-fix or propagate-the-lesson had already
covered: a comprehensive audit surfaced four related gaps in the same
system (an installer's self-update rollback coverage). The user confirmed one of
them directly. Rather than defaulting to "the other three are real too,
should they come along," the response defaulted to narrow scope — build
the one confirmed item, explicitly flag the other three as deferred, and
wait to be told otherwise. The three were flagged, not hidden — but the
default was still "leave it out unless told to include it," when the
user's own stated preference, given minutes earlier, was the opposite
default: "we don't need to ever be doing that."

This is a different gap than propagate-the-fix (fixing the same bug
everywhere it's duplicated) and propagate-the-lesson (applying a general
lesson to every bundle/skill it applies to). This is narrower and more
specific: when several real, known, DIFFERENT issues are surfaced
together — not siblings of one bug, just several separate legitimate
findings — don't quietly narrow the working scope back down to only the
one thing explicitly asked about. Known problems don't stop being real
because they weren't the headline ask.

## The core rule

**Once an issue is confirmed real and known, the default is to fix it,
not to defer it.** Deferral is the exception, and it must be justified by
a real constraint — not by "this wasn't specifically what was asked
about." If there's no genuine reason to leave it, it shouldn't be left.

## What actually justifies deferring a known issue

Deferral is legitimate when at least one of these genuinely applies:
- **It requires a business or product decision only the user can make**
  (not a technical decision Claude can reason through alone)
- **It's genuinely too large or too risky to safely bundle into the
  current change** — e.g. it would require its own careful design pass,
  or bundling it in raises the chance of the current fix breaking
- **It's blocked on something not yet available** (a dependency, a piece
  of information, another fix that has to land first)
- **It's not actually confirmed real yet** — still needs investigation
  before it's a genuine issue, not a suspicion

None of these apply just because an issue wasn't the original headline
ask. "The user only asked about X" is not, on its own, a reason to leave
Y and Z broken once Y and Z are known and real.

## What to do when multiple findings surface together

1. **Default to including every confirmed, safely-fixable finding in the
   same pass** — not just the one explicitly named.
2. **If genuine deferral criteria apply to some findings, say so
   explicitly, with the specific reason** — not a blanket "flagged for
   later." State which real constraint applies to each deferred item.
3. **When presenting a decision to the user, default the framing toward
   inclusion**, not toward exclusion. Instead of "here's the one thing
   confirmed, should the others come along too" (narrow default, opt-in
   to more), frame it as "here's everything found — including all of it
   unless you'd rather hold some back" (wide default, opt-out of less).
   The difference matters: it changes what happens if the user just says
   "yes, do it" without reading every word carefully.
4. **Never let "the user only confirmed one item" become an assumption
   that the others aren't wanted.** If genuinely unsure, ask — but ask in
   a way that makes it easy to say "all of it," not just easy to approve
   the smallest interpretation.

## Relationship to other skills

- **propagate-the-fix**: same bug, found in more than one place — fix all
  copies.
- **propagate-the-lesson**: a general lesson, applicable beyond the one
  place it was learned — apply it everywhere it fits.
- **close-known-gaps**: several different, unrelated real issues,
  surfaced together — don't narrow back down to just the one that was
  explicitly named. This is the narrowest and most specific of the three,
  and the easiest one to accidentally violate, because deferring
  something that's genuinely out of scope FEELS responsible — the
  discipline here is recognizing the difference between genuine
  out-of-scope and simply-not-the-headline-ask.

## Trigger this skill

- Automatically, whenever an audit, investigation, or report surfaces
  more than one real finding
- Automatically, whenever a user confirms action on one item from a
  multi-item list — check whether the others were left out by genuine
  justification or by default narrowing
- No trigger phrase needed; always-on, alongside verify-before-claiming,
  propagate-the-fix, and propagate-the-lesson
