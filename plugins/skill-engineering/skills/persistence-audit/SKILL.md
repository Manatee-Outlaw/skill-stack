---
name: persistence-audit
description: >
  Verify that every promise the product makes to REMEMBER something is still
  being kept. For each thing a user can save, set, tick, toggle or submit:
  does a write actually reach storage, is it read back on the next load, and
  when did that storage last receive a write from the live application? The
  primary signal is FRESHNESS, not emptiness — a table with healthy rows that
  stopped being written looks perfect in every other audit. Run after any UI
  rewrite, framework migration, route reshuffle or "port the old screen to the
  new shell", and periodically thereafter. Trigger phrases: "did the redesign
  lose anything", "does this actually save", "why is this field empty",
  "the user says their changes disappeared", "port the old dashboard",
  "settings don't stick", "progress resets".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Persistence Audit

## Why this skill exists

A UI port preserved every read and dropped five writes. Every screen rendered
perfectly. Nothing threw an error. The success animation played. And the
product forgot the user's work for three weeks before anyone noticed
(recorded 2026-08-19).

The measured case: a coaching platform's playbook checklist. `GET /api/profile`
survived the rewrite; the corresponding `POST` did not. Ticking a task showed
progress and a completion percentage; every page load silently reset it to zero,
and twelve users' existing saved progress rendered as "0% complete" because the
new shell never hydrated from it either. Downstream, three consumers and a
monthly cron kept reading a column frozen at pre-rewrite values.

Four other write paths went the same way in the same port: a re-take flow that
computed new scores and discarded them, a settings panel hardcoded to fixed
values while a working endpoint sat uncalled, notification toggles that wrote
only to `localStorage` against a server column nothing read, and a "Sign out"
that cleared local state without ever telling the server — leaving a 30-day
session cookie alive on shared machines.

**None of them was found by the skill whose job it should have been, because no
such skill existed.** They surfaced incidentally, across four different audits,
and never as one finding.

## What makes this class invisible

Reads are exercised constantly — every page load runs them. Writes are exercised
only when a user performs the action, and some actions are performed once ever.
So a dropped read breaks immediately and loudly; a dropped write breaks silently
and stays broken.

Worse, the usual detectors are all pointed elsewhere:

- **Correctness audits pass it.** The code reads correctly and runs correctly
  when driven. There is no bug in the code that remains.
- **Render checks pass it.** The screen renders — that is the whole problem.
  A checklist that shows "0 of 12 done" is a valid render of wrong state.
- **Zero-row detection misses it.** In the measured case the table had 18 rows
  of real data. `production-drift` correctly owns "a write path that has NEVER
  run" (an empty table, a retired caller). This skill owns the harder sibling:
  **a write path that USED to run and stopped.** The table looks healthy. Only
  the timestamp is dead.
- **Journey tests can miss it.** Walking a flow shows the toast and the updated
  screen. Persistence fails on the NEXT load, which is a different session.

## The two-query test

This is the whole skill in one move. For any table or column that a user action
is supposed to write:

```sql
SELECT MAX(<write_timestamp>) FROM <table>;          -- when did this last change?
SELECT MAX(<timestamp>) FROM <a table you KNOW is live>;  -- is the app in use?
```

If the first is old and the second is current, **the write path is dead and the
app is still running.** That pair found the CRITICAL in two queries. It is
cheap enough to run over every table in the schema.

The control table matters. Without it, an old timestamp is ambiguous — the app
might simply be unused. Pick something the users demonstrably still do:
check-ins, logins, ingested events, sessions.

## Process

### Phase 1 — Inventory the promises

List every control in the UI that claims to persist something. Buttons labelled
Save, Submit, Apply, Connect, Set, Update; toggles and checkboxes; anything that
shows a success toast, a checkmark, or a progress figure.

For each, record: **what the user believes was stored, and where it should land.**

### Phase 2 — Follow each write to storage

For every promise, answer all three in order. Stopping at the first is how this
class survives:

1. **Does the client issue a request at all?** Search the frontend for the
   endpoint. A control that only mutates in-memory state or `localStorage` fails
   here. This is the most common form and the easiest to miss, because the
   in-memory update makes the screen correct until reload.
2. **Does the server persist it?** The endpoint may exist, return 200, and write
   nothing — or write to a column nothing reads.
3. **Is it read back on the next load?** A perfect write nobody hydrates from is
   the same user experience as no write at all. Check the *load* path, not just
   the save path. In the measured case the write AND the hydrate were both
   missing, and either one alone would have produced the same symptom.

### Phase 3 — Freshness census

Run the two-query test across the schema. For every table with a timestamp:

- **Last written when?** Compare against a known-live control table.
- **Last written by WHAT?** A table written only by a migration, a seed, or a
  retired UI is not in service. Grep for the writer and confirm it is reachable
  from the shipped app, not just present in the repo.
- **Anything reading it?** Grep for SELECTs. A write-only table is data going in
  and nothing coming out — the mirror image of the same defect, and it means a
  feature was half-built or half-removed.

Both directions are findings:

| Shape | Symptom | What it means |
|---|---|---|
| Fresh writes, no reader | Table grows, nothing surfaces it | Feature half-built, or its reader was removed |
| Stale writes, active readers | UI shows frozen values confidently | **Write path dropped — the dangerous one** |
| No writes ever, code exists | Empty table with a real INSERT | `production-drift` owns this |
| Written only by seed/migration | Uniform values, one timestamp | Never actually in service |

### Phase 4 — Round-trip the survivors

For anything that passed Phases 2–3 on inspection, prove it end to end where you
can: set a value, reload in a fresh session, confirm it came back. Inspection
proves a request is issued; only a reload proves the loop closes.

If you cannot execute (no test account, no safe environment), say so explicitly
and mark those findings code-review-only. Do not let "the code looks right"
stand in for a round trip — that is precisely what was true of all five measured
failures.

### Phase 5 — Rate by what the user loses

Severity here is not about crashes, because there are none. Ask: **what work
does the person lose, and do they know they lost it?**

Silent loss with a success signal is the worst case and is never LOW, however
gracefully the process survived. A control that visibly moves and does nothing
is worse than no control, because it spends the user's trust as well as their
time.

## Two worked examples from the census

Both came out of the same run, and they are the two answers the census gives.
Neither was found by an eleven-skill audit of the same codebase the same day.

**A real finding — a feature that blocked itself.** `<question_responses>` last
written 2026-07-29. Its sibling `<insights_table>` — written by the *same
function in the same file* — was written today. Same cron, same run, one alive
and one dead: that contrast is what makes it a finding rather than a quiet table.

The cause was not a dropped write. The writer gates on
`if not (SELECT id FROM <question_responses> WHERE user_id=? AND answered_at IS NULL)`
— ask a question only when none is outstanding. 23 users hold an unanswered
question, so **all 23 can never be asked another one, ever.** The feature is
permanently blocked for everyone who ever used it, and the block tightens as more
people leave a question unanswered. No error, no empty table, nothing to render
wrong.

Fixed the same day by adding an age clause: an unanswered question older than 14
days is abandoned, not outstanding. Worth noting what the fix did NOT need —
no schema change, no data migration, and no change to any of the three readers.
The read path already did `ORDER BY asked_at DESC LIMIT 1`, so the "one open
question" invariant was being enforced at READ time all along; the write gate was
belt-and-braces that deadlocked. **When a census finds a blocked write path, check
whether the invariant it was protecting is already enforced somewhere else — the
guard is often redundant as well as broken.**

**A false positive the discipline caught.** `<defaults_table>`: 5 rows, all
`user_id` NULL, all created 2026-05-18, and **zero INSERT statements anywhere in
the shipped code** — the only one in the repo is in a test file. Every signal said
"read path with no write path."

It is correct by design. One of the readers is
`SELECT 1 FROM <defaults_table> WHERE user_id IS NULL AND state_id=?` — those NULL
rows *are* the global defaults, seeded once and read as defaults forever. A table
written only by a migration is a finding **only if something is supposed to keep
writing it**. Ask what the reader expects before you report the writer missing.

## Applying this after a rewrite specifically

A port is the highest-yield moment for this skill, and it admits a mechanical
check: **diff the set of endpoints the old UI called against the set the new one
calls.** Anything in the old set and not the new is a candidate — either
deliberately retired, or dropped by accident. In the measured case that single
diff would have surfaced four of the five.

Do it in both directions. Endpoints the new UI calls that the old one did not are
where new bugs live; endpoints only the old one called are where lost features
live. Beware the shape of the call: one real port used a helper that stripped the
`/api` prefix, so a naive grep reported four legacy-only routes when the true
count was thirty-three — a live instrument with the wrong pattern.

## Proving the check could have come back dirty

Every negative in this audit needs a control, because "no stale tables found"
and "my query was pointed at the wrong database" produce identical output.

- Before reporting a table as freshly written, show a table that is **not** —
  if every table looks current, verify the query is reading the right host.
- Before reporting "nothing reads this column", show the same grep finding a
  reader for a column that **is** read. A rejected pattern returns clean.
- Before reporting a write path as healthy, confirm the value survived a
  **reload in a new session**, not a re-render in the same one.
- When a timestamp column exists but is empty, distinguish "never written" from
  "written but NULL" — they have different causes and different fixes.

## Output format

For each finding:

1. **The promise** — what the UI tells the user it stored, in their words.
2. **Where it breaks** — client never sends / server never persists / nothing
   reads it back, with file and line.
3. **evidence:** — the freshness pair, or the round-trip result. Live values,
   tagged **[proven]** (queried or round-tripped) or **[inferred]** (code
   review only). "No caller", "nothing reads it" and "never written" are
   absence claims: state where you searched — the grep pattern, the file set,
   and the database/host the query ran against.
4. **What the user loses** — concretely. "Ten minutes of free text", "their
   entire playbook progress", "their session stays open on a shared machine".
5. **Since when** — correlate the last-write timestamp against the deploy that
   dropped it. This turns "a bug" into "three weeks of lost work" and usually
   changes the priority.
6. **Disposition** — RESOLVED / KEPT AS-IS with reasoning / DEFERRED with a
   trigger.

## Boundaries

- **`production-drift`** owns write paths that have never run, and infra/config
  drift generally. This skill owns write paths that stopped, and the client half
  of the loop.
- **`flow-test`** walks journeys and catches state mismatch within a session.
  This skill is a census across all persisted state, and specifically tests the
  next session.
- **`render-smoke`** proves a screen renders. Every failure in this class
  renders perfectly.
- **`database-hygiene`** asks whether stored rows are valid. This asks whether
  anything is still storing them.

## The generalisation worth carrying

**A read surviving a rewrite tells you nothing about whether the write did.**
The two halves have completely different exercise rates — reads run on every
load, writes run when a user acts — so a port that is 100% correct on reads can
be silently 0% correct on writes and look finished to everyone who opens it,
including the person who wrote it.
