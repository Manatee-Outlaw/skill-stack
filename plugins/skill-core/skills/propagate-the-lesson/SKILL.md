---
name: propagate-the-lesson
description: >
  Whenever a genuinely general-purpose lesson, fix, or process improvement
  is identified — not a narrow, one-off bug, but a real insight about how
  something should be done — actively check every place that same lesson
  would apply, and apply it there too in the same pass, rather than fixing
  only the one spot that prompted it. This is propagate-the-fix's scope
  raised one level: from "this pattern repeats elsewhere in the codebase"
  to "this pattern repeats elsewhere in the skill library, other bundles,
  or other projects entirely." This explicitly includes
  checking whether a new skill needs registering in comprehensive-audit's
  own AUDIT SKILLS or GOVERNING STANDARDS lists — a new skill existing is
  not the same as it actually being run. Trigger automatically whenever a
  new skill is created or an existing one is meaningfully rewritten
  because a real gap was found — no trigger phrase needed.
metadata:
  tier: universal
  plugin: skill-core
---

# Propagate The Lesson

## Why this skill exists

verify-before-versioning was built after two sessions independently wrote
conflicting versions of the same bundle file, six days apart. That skill
was written, added to the engineering bundle — and then almost left there,
scoped to engineering only, even though the exact same collision risk
applies equally to every other bundle sharing the same Drive skill
library (creative, enterprise, productivity, and any future one). The
lesson was general. The first fix was narrow. Only a direct follow-up
question caught the gap.

**This skill had its own version of the exact problem it exists to catch.**
comprehensive-audit was updated so its governing
standards apply automatically to every audit — a real, valuable fix. But
nothing was added to check whether *future* new skills would automatically
be registered in comprehensive-audit's own lists (the AUDIT SKILLS list
for new audit categories, the GOVERNING STANDARDS list for new always-on
disciplines). A direct question caught this too: "are we making sure new
skills get added going forward, or will we have to remember each time?"
The honest answer was the same as before — no, not yet. This is now fixed
by adding it as an explicit, permanent step below, rather than being the
third time this exact shape of gap gets caught by someone asking about it
after the fact.

This is the same shape of problem propagate-the-fix exists to catch in a
codebase — a fix applied in one place while an identical need sits
unaddressed somewhere else — just one level up. Here, the "codebase" is
the whole body of skills, bundles, and working practices, not just one
project's code.

## The core rule

**A lesson worth writing down as a skill is, by definition, a lesson that
generalizes.** If it didn't generalize, it wouldn't be worth turning into
a reusable skill in the first place — it would just be a one-time fix.
That means every new or meaningfully-rewritten skill carries an implicit
question that must be answered explicitly, not left implicit: **where
else does this apply, and has it been applied there too?**

## What to do, every time a new or rewritten skill is created

1. **State the lesson in its most general form**, separate from the
   specific incident that prompted it. The general form is what reveals
   where else it applies.
2. **Check every bundle/skill-set within reach for the same applicability.**
   Within this shared Drive skill library, that means checking all
   bundles — not just the one the triggering incident happened in.
3. **Apply the lesson everywhere it's found to apply**, not just note that
   it could. Add the new skill to every relevant bundle's load list.
4. **Check comprehensive-audit's own lists specifically.**
   If the new skill is a genuine AUDIT CATEGORY (something that should
   examine the codebase for a class of problem, like the existing 10), it
   needs to be appended to comprehensive-audit's AUDIT SKILLS list. If the
   new skill is an ALWAYS-ON DISCIPLINE (something that should govern how
   every finding gets evaluated, like verify-before-claiming or
   no-dead-ends), it needs to be added to comprehensive-audit's GOVERNING
   STANDARDS list. A skill existing in the bundle's "skills to load" list
   is NOT the same as it actually being applied inside a comprehensive
   audit run — those are two different registration points, and both
   need to be checked, not just the first one. This applies specifically
   because comprehensive-audit is itself a self-contained skill file with
   its own internal lists (see its AUDIT SKILLS and GOVERNING STANDARDS
   sections) — updating the bundle alone is not sufficient to make a new
   discipline actually run inside an audit.
5. **Be explicit about the boundary of what could actually be checked and
   applied directly, versus what's outside reach.** A genuinely separate
   Claude Project this conversation has no access to is not reachable
   from here — state that plainly rather than pretending otherwise.
6. **State what was actually done, explicitly** — including, per point 4,
   whether the new skill was added to comprehensive-audit's lists, and if
   not, why not (e.g. "this is a narrow one-off fix, not an audit category
   or a governing discipline, so no comprehensive-audit changes needed").

## Distinguishing a general lesson from a narrow one

Not every fix generalizes, and forcing generalization onto something
narrow wastes effort and adds noise. A rough test: **would this same
reasoning, worded generally, make sense as advice to someone working on a
completely different project with a completely different codebase?** If
yes, it's general — propagate it, including checking comprehensive-audit's
lists per point 4. If the fix only makes sense in the specific context it
was found in, it's narrow — leave it where it is, and say so explicitly.

## Relationship to other skills

- **propagate-the-fix**: same discipline, scoped to bugs within one
  codebase.
- **verify-before-versioning**: the specific incident that prompted this
  skill's original creation.
- **skill-library-audit**: the periodic, scheduled sweep that can catch a
  missed propagation after the fact — including a missed comprehensive-
  audit registration, per point 4 above. propagate-the-lesson is the
  in-the-moment version — catching it immediately is strictly better than
  catching it later.

## Trigger this skill

- Automatically, every time a new skill is written
- Automatically, every time an existing skill is meaningfully rewritten
  because a real gap was found (not a small wording tweak)
- No trigger phrase needed; always-on
