---
name: no-dead-ends
description: >
  Whenever something can enter a "not working" or "stopped" state —
  whether by error, a dropped connection, or a deliberate, warned user
  action — don't stop at confirming the system correctly detects and
  reports that state. Also prove there is a clear, fast, tested path back
  to working, and test that recovery path directly, not just the
  detection/warning that precedes it. Trigger whenever building or
  reviewing anything with an error state, a disconnect/reconnect cycle,
  or a destructive/stopping action that a user can trigger — no trigger
  phrase needed.
metadata:
  tier: machine
  plugin: skill-engineering
---

# No Dead Ends

## Why this skill exists

Two real bugs shipped in the same night, both with the same underlying
shape, neither caught by any existing skill:

1. A bridge's reconnect logic correctly detected a dropped connection and
   correctly kept retrying — but its retry timer didn't reset properly
   after a successful connection, so a later drop could land in the
   slowest part of its wait cycle, up to a full minute before trying
   again. The detection worked. The path back to "connected" was
   technically present but untested at realistic timing, and looked
   broken to a real user watching it.
2. A confirmation warning correctly told a user that closing a window
   would stop tracking for their session — and it did, exactly as
   designed. But once they confirmed and the system stopped, there was no
   easy way back within that session — the automatic watcher that would
   normally relaunch things only runs once per login. The warning worked.
   The recovery path afterward didn't exist in any discoverable form.

Neither bug was a detection failure. Both were "the system correctly told
you something was wrong, and then left you without a clear way to make it
right again." Existing skills don't specifically catch this: verify-
before-claiming checks that fixes are proven, propagate-the-fix checks
that fixes reach every sibling instance, anticipate-user-mistakes checks
that innocent actions don't have disproportionate consequences — none of
them specifically ask "given this error/stopped state exists and is
correctly reported, what is the tested path back, and how long does it
actually take?"

## The core rule

**Every state that reports "not working" needs a proven path back to
"working" — not just correct detection of the problem.** If a system can
tell you something stopped, it should also be tested for how a real
person, or the system itself, actually gets back to normal — and that
recovery path deserves the same real-execution proof as the failure
detection itself.

## What to check, for anything with an error/stopped state

1. **Name every way the thing can end up "not working"** — a dropped
   connection, an error condition, a deliberate stop the user chose
   (even a warned, correct one), a crash, a timeout.
2. **For each one, ask: what's the actual path back to working?** Is it
   automatic? How long does it realistically take, tested under real
   timing, not just "the retry loop exists"? Is it manual? Is that manual
   step discoverable by someone without deep technical knowledge, or does
   it require finding a specific file in a specific folder they've never
   navigated before?
3. **Test the recovery path directly, not just the failure/warning that
   precedes it.** A reconnect loop that "should" retry needs to be tested
   at realistic timing, across multiple drop/reconnect cycles, not just
   confirmed to contain retry logic. A "you can undo this" message needs
   the actual undo path exercised, not just the message's wording
   verified.
4. **A deliberate, correctly-warned stop is not exempt from this.**
   Warning someone before a destructive action is necessary but not
   sufficient — if they proceed (which the warning exists to allow, not
   just prevent), there should still be a clear way back if they change
   their mind or stopped by accident despite the warning.

## Relationship to other skills

- **anticipate-user-mistakes** prevents entering a bad state accidentally
  in the first place. **no-dead-ends** assumes a bad state will happen
  regardless — by error, by design, or by a correctly-warned deliberate
  choice — and asks whether the way back out is real and tested.
- **hostile-environment-testing** tests whether something works under
  messy conditions. **no-dead-ends** specifically tests the recovery
  path's timing and discoverability, which is a narrower, easy-to-skip
  piece even when the broader hostile testing has otherwise been done.
- **verify-before-claiming** requires proof for any "fixed" claim.
  **no-dead-ends** is about a specific proof most easily skipped: proving
  not just that failure is detected, but that recovery is fast and
  reachable.

## Scope note (per propagate-the-lesson)

This lesson is specific to engineering/product work — systems, error
states, connection logic, user-facing stop/start flows. It was checked
against the creative, enterprise, and productivity bundles and does not
meaningfully generalize to any of them (a poster or a business email has
no "not working" state with a recovery path in any comparable sense) — so
it was NOT propagated to those bundles. This is a deliberate scope
decision, not an oversight.

## Trigger this skill

- Automatically, whenever building or reviewing anything with a
  connection/reconnection cycle, an error state, or a destructive/
  stopping action a user can trigger
- As part of anticipate-user-mistakes reviews and comprehensive audits —
  this is a natural companion check, not a replacement
- No trigger phrase needed; always-on for this category of work
