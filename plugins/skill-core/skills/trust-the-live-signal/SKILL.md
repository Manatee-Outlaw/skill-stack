---
name: trust-the-live-signal
description: >
  When a stored value, a cached field, official documentation, or a
  surface-level observation disagrees with a live, current, directly-
  checkable signal, trust the live signal — and investigate why they
  disagree rather than picking one arbitrarily. A remembered or recorded
  fact is a proxy for the truth, not the truth itself. Trigger whenever
  a claim about current state could be checked live but is instead being
  answered from a stored field, a document, or an assumption — no
  trigger phrase needed.
metadata:
  tier: universal
  plugin: skill-core
---

# Trust The Live Signal

## Why this skill exists

Three separate times, a stored, documented, or surface-level signal
disagreed with reality, and reality won each time:

1. A streamer's saved plugin-version field showed an old number. The
   field is only updated when someone manually re-downloads the app — it
   never reflects the app's own silent, in-background self-updates. The
   field looked authoritative (a specific version number, stored in the
   database) but was actually a frozen snapshot from whenever it was last
   manually touched, unrelated to what was actually running.
2. Official vendor documentation stated plainly that a certain "connected"
   status could only mean the user was live. A real, live screenshot of
   the user's own screen — genuinely connected, genuinely not broadcasting
   — proved the documentation wrong in practice, even though it wasn't
   lying about the vendor's intended design.
3. A program being visibly open (a window on screen, an icon in the
   taskbar) was treated as equivalent to a specific feature of that
   program actually being active. It wasn't — the program can be open
   without the one specific service inside it that mattered being
   switched on.

In each case, the wrong signal wasn't fake or malicious — it was a
reasonable-looking proxy that happened to diverge from the truth in a way
that only a live, direct check would catch.

## The core rule

**When a live, current, directly-checkable signal is available, trust it
over anything stored, cached, documented, or merely observed from a
distance.** A version field, a piece of documentation, or "the app looks
open" are all evidence — reasonable evidence, worth using when nothing
better is available — but none of them are the ground truth, and none of
them should be trusted over a direct, live check when one is possible.

## What to do

1. **Before answering a question about current state, ask: is there a
   live way to check this right now, or am I about to answer from
   something stored/cached/documented/assumed?** If a live check is
   possible and the stakes matter, do it — don't settle for the proxy
   when the real thing is reachable.
2. **When a live check and a stored/documented value disagree, don't just
   pick the live one and move on — understand why they diverged.** The
   stored version field wasn't wrong by accident; it revealed a real fact
   (the field is write-once-on-manual-download, not live-synced) that was
   worth knowing on its own. The disagreement itself is often the most
   useful piece of information in the whole investigation.
3. **State explicitly which kind of evidence supports a claim.**
   "Confirmed live, checked directly just now" is different from "per the
   stored field" or "per the documentation" — say which one, especially
   when they could plausibly disagree.
4. **Don't treat "the thing is visibly present/open" as proof that the
   specific feature you need is active.** A program running and a
   specific service inside that program running are different claims —
   verify the one that actually matters, not the easier-to-observe one
   that merely correlates with it.

## Relationship to other skills

- **verify-before-claiming** requires proof before claiming something is
  fixed or working. **trust-the-live-signal** is about which SOURCE of
  proof to prefer when more than one is available and they might not
  agree — the live one, not the recorded one.
- This also applies to Claude's own stored context — see no-assumed-
  memory for the specific case of trusting what a fresh session can
  verify over what it's merely told.

## Trigger this skill

- Whenever answering a question about current state where a live check is
  possible — status fields, version numbers, "is X currently true"
- Whenever documentation and a real, observable result disagree — trust
  the observed result, investigate the documentation gap
- Whenever something being "visibly present" is being used as proof that
  a more specific, related fact is also true
- No trigger phrase needed; always-on whenever current-state claims are
  being made
