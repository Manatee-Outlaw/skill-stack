---
name: propagate-the-fix
description: >
  Whenever a bug is fixed, actively search the rest of the codebase for
  other places doing the same thing — not just the exact same bug, the
  same underlying pattern — and fix every instance found, in the same
  pass, not just the one that was reported. Use immediately after
  diagnosing any bug, before considering the fix complete. Trigger
  phrases: none needed — this applies automatically to every bug fix,
  the same way verify-before-claiming applies automatically to every
  status claim.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Propagate The Fix

## Why this skill exists

The same shape of mistake happened at least five times in one week on
this project, and each time the fix only touched the one copy that had
been reported, leaving an identical, unfixed twin sitting somewhere else
in the codebase:

1. A database connection function silently fell back to an unencrypted
   connection when its security key was missing — but this logic existed
   in two separate places (a shared file and a duplicate copy elsewhere).
   Both were caught and fixed together that time — but the pattern of
   duplication itself was never addressed, only patched.
2. A later fix added a timeout setting to prevent a rare database-locking
   bug — but it was only added to one of the two duplicate database
   functions from item 1. The other was missed and stayed broken for
   weeks until a scheduled audit caught it.
3. A cron job's hardcoded log-file path was fixed in two scripts that
   shared the exact same bug — but a third script with the identical
   pattern was missed, and only caught later by a structural code audit,
   not by anyone deliberately looking for siblings.
4. Five separate scripts each had their own hand-copied version of the
   same file-logging code, accumulating independently over weeks, never
   noticed until a dedicated cleanup pass went looking for duplication on
   purpose.
5. An emergency fallback system's package-check logic was fixed in the
   one file being actively worked on — but two OTHER files had their own
   independent copies of the same check, with the same bug, undiscovered
   until a real user's install crashed hours after the "fix" shipped,
   because the fix never reached its siblings.

In every case, the fix itself was correct. The failure was narrower and
more specific: nobody asked "does this exact same pattern exist anywhere
else?" at the moment the bug was found — that question got asked later,
by luck, by a different task, or by a real user hitting the twin bug in
production.

## The core rule

**A bug fix is not complete until you've checked whether the same pattern
exists anywhere else in the codebase.** Not just the literal same lines of
code — the same underlying logic, reproduced independently. If it exists
elsewhere, fix it in the same pass, not as a follow-up, not as something
the next audit will catch.

## What to do, every time a bug is fixed

1. **Name the pattern, not just the bug.** Before fixing, articulate what
   the underlying mistake actually is in general terms — not "this one
   line has a bug" but "anywhere that does X without checking Y has this
   bug." This reframing is what makes the next step possible.
2. **Search for the pattern, not the exact bug.** Grep/search for the
   general shape identified in step 1 — the same function name, the same
   kind of check, the same category of logic — across the whole codebase,
   not just the file currently open. A duplicate is often not
   byte-for-byte identical; it may have drifted slightly, use different
   variable names, or be in a completely different language/file type
   (e.g. the same conceptual bug appearing in both a .bat file and a
   .py file, as happened this week).
3. **Fix every instance found, in the same commit/pass.** Don't file the
   others as follow-ups. The whole point is closing the gap between "I
   fixed the one I was looking at" and "I fixed the actual problem."
4. **If 3 or more independent copies of the same logic are found,
   consider consolidating** into one shared function/helper instead of
   leaving N copies that can drift again in the future — this overlaps
   with ponytail-audit's job, and it's fine to flag it for that skill's
   attention rather than always refactoring on the spot, but don't ignore
   the signal.
5. **State the search explicitly in the fix report.** "I searched for
   other instances of this pattern and found/fixed: [list]" or "I
   searched and found no other instances." Make the search a visible,
   checkable step — not an assumed one that may or may not have happened.

## Relationship to other skills

This is the in-the-moment discipline: the instant a bug is found, before
moving on. ponytail-audit is the periodic safety net that catches
duplication on a schedule, independent of any specific bug fix. Both
matter — this skill exists specifically because waiting for the next
scheduled audit to catch a sibling bug means a real user can hit it in
the meantime, which is exactly what happened in incident #5 above.

## Trigger this skill

- Automatically, every time a bug is diagnosed and fixed — no trigger
  phrase needed, this is always-on the same way verify-before-claiming is
- Especially when the bug involves logic that's plausible to have been
  copy-pasted or independently reimplemented (installers, launchers,
  connection/setup checks, logging, config loading) — these are exactly
  the kinds of things that tend to get duplicated across files rather
  than shared
- As part of comprehensive-audit: any finding from any other audit check
  should itself be checked for siblings before being marked
  resolved
