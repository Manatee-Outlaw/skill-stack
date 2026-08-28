---
name: backlog-reconciliation
description: >
  Full audit of every open backlog item (TD-, DF-, BUG-, PE- numbered, or
  otherwise tracked) against live evidence, not memory or an old document.
  Combines a systematic git log sweep with a cross-reference against every
  available handoff/backlog document to determine the REAL current status of
  each item: done, open, retired, or genuinely unrecoverable. Use when a
  backlog document is suspected stale, before writing a new comprehensive
  backlog document, or periodically to prevent silent staleness from
  accumulating. Trigger phrases: "reconcile the backlog", "audit our
  backlog", "is this backlog item still open", "check the backlog against
  git".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Backlog Reconciliation

## Why this skill exists

On 2026-07-23, two items independently flagged as the HIGHEST-risk open work
in the entire backlog — TD-1 (a central-table schema migration) and TD-34 (a
form migration with real data-loss risk) — were both discovered to already
be fully done, weeks earlier, verified live, zero actual work remaining.
Neither had been marked closed anywhere. A subsequent full sweep found the
same pattern across roughly 20 more items. The root cause wasn't
carelessness — it was structural. This project moved from a structured
Deferred Backlog to a Master Backlog to pure session-narrative Hermes
Handoffs over about six weeks, and each transition dropped a bit of the
ability to see everything open at once. Nobody was lying about status;
nobody was even wrong at the time they wrote it. The record just never
caught up with the work.

## The core method: two evidence sources, cross-referenced

This skill is one applied instance of `trust-the-live-signal` — the parent
principle that a live signal (git history, a running system, a real query)
outranks any stored or documented claim about status. Backlog reconciliation
is that principle pointed specifically at TD-/DF-/BUG-/PE- tracking. Where the
two disagree, the live evidence wins and the document gets updated.

Neither source alone is reliable. Combined, they cover almost everything.

### Source 1 — git log, for anything closed via a code change
Any item closed with a commit that references its own ID in the message
(e.g. "TD-2: rename table") is found instantly by
`git log --all --grep="<ID>"`. This is cheap, fast, and completely
mechanical — run it for every known ID before doing anything more
expensive. A hit is strong evidence of closure; cite the actual commit hash
and message, don't just report "found."

### Source 2 — the full documentation trail, for anything closed via pure
verification or a decision with no code change
Not everything that's "done" involves a commit. A live verification (e.g.
confirming a credential really was rotated), a decision made in
conversation, or a retirement decision leaves no git trace at all. These
are only recoverable by reading every available handoff, backlog document,
and retirement log in full — not skimming titles, not trusting a table of
contents, since those tables themselves can be stale (see
verify-before-versioning). This is the expensive half of the method — but
it's what recovers items git alone reports as "unknown," which is not the
same as "open."

### The critical distinction: "not found in git" is not "still open"
This is the single most important thing this skill exists to prevent. A git
miss must always be reported as "not found via git, status unconfirmed" —
never silently upgraded to "confirmed still open." Only after checking
Source 2 as well (and finding nothing there either) can an item be honestly
called open. Treat every "not found" as a prompt to check further, not a
conclusion.

## Handling ID collisions

Backlog IDs can be reused by accident across a long project history —
confirmed at least once in this project (a "DF-33" bug-fix commit exists
that has nothing to do with the original "DF-33: undescribed UI bugs" open
item). Before treating any git hit as closing a specific ID, check that the
commit's actual description matches the item being checked, not just that
the number matches.

## Output format

One table, one row per ID: description, status (closed-with-evidence /
closed-via-verification-with-citation / retired / genuinely-open /
unconfirmed-needs-human), and the actual evidence — a commit hash, a
document name and date, or a plain "no evidence found anywhere checked."
Flag any finding that changes an item's priority — especially anything
previously treated as high-risk or urgent that turns out to already be
resolved, since that's the highest-value output of this skill.

## Success criterion & failure modes

**Done when:** every known ID has a row, and every row is either backed by
concrete cited evidence (a commit hash, or a named+dated document) OR
explicitly labelled `unconfirmed-needs-human` — never silently left as
"open" on a git miss alone. A reconciliation with any bare "still open" that
was never checked against Source 2 is NOT complete.

**When evidence is missing or contradictory, degrade honestly — don't guess:**
- *Git access unavailable* (no clone, no network): run Source 2 only and mark
  every git-dependent verdict `unconfirmed-needs-human` — do not upgrade a
  documentation hit to "closed-with-evidence" without the commit.
- *The documentation trail itself is incomplete or self-contradictory*
  (two handoffs disagree on status): report BOTH claims with their dates and
  mark the item `unconfirmed-needs-human`. Never silently pick the newer or
  the more convenient one — a contradiction is a finding, not a tiebreak.
- *An ID appears nowhere in either source*: `no evidence found anywhere
  checked`, which is distinct from "open" and must be reported as such.

## What this skill does NOT do

It doesn't fix anything, build anything, or make a priority call on
genuinely open items — it establishes ground truth so a human, or a
separate comprehensive-audit / task-authoring pass, can prioritize
accurately. A mismatch between this skill's findings and an existing
document is a reason to update that document, not to distrust this skill's
evidence.

## Trigger this skill

- Before writing a new comprehensive backlog document
- Whenever an item flagged as high-risk or blocking turns out, on first
  investigation, to already be resolved — that's a signal the whole list
  may be stale, not just that one item
- Periodically (recommend every 4-6 weeks, or whenever a handful of session
  narratives have accumulated since the last full reconciliation) to
  prevent the gap that caused this skill to be written from recurring
- When cold-starting a session where an item's current status genuinely
  matters for what gets built next
