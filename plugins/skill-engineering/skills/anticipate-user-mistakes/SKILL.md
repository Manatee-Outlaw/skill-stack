---
name: anticipate-user-mistakes
description: >
  For every user-facing control, window, or prompt, deliberately imagine how
  an ordinary, non-technical, possibly distracted person would misunderstand
  or mishandle it — not maliciously, just naturally — and check whether that
  innocent mistake causes damage out of proportion to how it looks. Use when
  designing or reviewing anything a real end user (not a developer) will
  see and interact with directly. Trigger whenever a feature is about to
  ship to real users, and as a standing check inside any comprehensive
  audit.
metadata:
  tier: universal
  plugin: skill-engineering
---

# Anticipate User Mistakes

## Why this skill exists

Twice in two days, the exact same shape of bug reached a real streamer, and
neither was a coding error in the traditional sense — both were a normal,
well-intentioned human doing the most natural thing in the world:

1. The bridge's startup process opened an unlabeled black console window
   with scrolling text. To anyone who hasn't seen a command line before,
   this looks exactly like "something has gone wrong" — the natural,
   reasonable response is to close it. Doing so silently killed the entire
   watcher process, with no way to restart it short of a full
   logout and login.
2. The coaching popup window, once live, had no indication that closing it
   does anything more than close a window. A streamer closing it the way
   they'd close any other window — out of curiosity, to declutter their
   screen, by mis-click — silently ended the entire bridge process with no
   warning and no way to recover until their next login.

Neither of these was reckless or careless user behavior. Both were the
single most natural, most predictable thing a reasonable person would do,
given what the interface showed them. The bug wasn't in the code path — it
was in the gap between what the interface implied and what actually
happened.

## The core question

For every button, window, toggle, or prompt a real end user will see, ask:
**what's the single most natural, least-effort thing an ordinary person
would do here without reading carefully — and if they do that, does the
result match what they'd reasonably expect?**

If the answer is "no, the real consequence is much bigger, more
permanent, or more hidden than the interface suggests" — that's the exact
shape of bug this skill exists to catch.

## The walkthrough, for every user-facing control

1. **What does this look like to someone seeing it for the first time,
   with no context?** Not what it's supposed to communicate — what it
   actually looks like cold. An unlabeled console window looks broken. A
   small "x" in the corner of any window looks safe to click, always.
2. **What's the path of least resistance — the thing someone does on
   reflex, not the thing they'd do if they stopped and read?** Closing
   something unfamiliar. Clicking the biggest or most colorful button.
   Assuming a control works the way the same-looking control works
   everywhere else they've used a computer.
3. **What actually happens if they do that?** Trace the real, technical
   consequence — not the intended one.
4. **Does step 3 match what a reasonable person expects from step 1?** If
   there's a gap — the action looked harmless or ordinary, but the real
   consequence is significant, silent, or hard to undo — that gap is the
   bug.
5. **Is the real consequence visible and recoverable?** Can the person
   tell something happened? Can they undo it or fix it themselves, or does
   it require finding you and asking for help?

## Severity: prioritize by how easy the mistake is, times how bad it is

The bugs worth fixing first are the ones where the innocent mistake is
both *easy to make* (no special knowledge or unusual action required) and
*costly* (silent, significant, or hard to reverse). A control that's easy
to misuse but harmless isn't urgent. A control that's catastrophic but
requires a deliberate, unusual action to trigger isn't urgent either. The
dangerous zone is the overlap: easy + costly.

## Common fixes, once a gap is found

- **Add a confirmation for any action whose real consequence is bigger
  than it looks** — this is what closing the coaching window now does.
  The confirmation's wording should state the real consequence in plain
  terms ("this will stop tracking"), not a generic "are you sure?"
- **Make the safe interpretation the real behavior where possible** —
  closing a window should generally just close the window, not silently
  end an unrelated background process, unless that's genuinely the
  window's entire purpose and it's labeled as such.
- **Make silent failures loud** — if something can fail invisibly, give it
  a visible status somewhere the person will actually see it, not just a
  log file only a developer would think to check.
- **Match labels and appearance to real mental models** — an unexplained
  console window reads as "broken" to a non-technical person regardless
  of what it's actually doing; either label it clearly or don't show it
  at all (see: this week's fix making the startup process invisible).

## Trigger this skill

- Before shipping any new user-facing control, window, or prompt to real,
  non-technical end users
- As a standing check inside any comprehensive audit, alongside flow-test
  and ux-review — this skill asks a different question than either (not
  "does the intended path work" or "does this follow UI heuristics," but
  "what happens when a reasonable person does the unintended thing")
- Whenever reviewing anything that can silently stop, delete, or disable
  something with no visible warning
- Whenever a support conversation reveals a user did something that
  seemed reasonable to them but had an unexpected, serious consequence —
  that's a signal this skill should have caught it earlier
