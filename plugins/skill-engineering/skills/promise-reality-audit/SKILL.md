---
name: promise-reality-audit
description: >
  Check that every sentence the product or its docs say about the system's
  own state is still TRUE right now. Page copy, toasts, empty states, banners,
  confirm dialogs, tooltips, onboarding text, runbooks, the project's
  CLAUDE.md/README and code comments that describe behaviour ("reports are
  paused", "your answer goes straight to your coach", "runs at 08:00 UTC",
  "delivery is off", "nothing is queued"). Each one is a claim that was true
  when it was typed and goes stale silently when the system changes. Run after
  any switch-on/switch-off, schedule change, feature retirement or launch, and
  in every comprehensive audit. Trigger phrases: "is the copy still right",
  "the page says X but", "users were told", "docs out of date", "after we
  switched it on", "launch checklist", "stale copy".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Promise vs Reality Audit

## Why this skill exists

In one week on one product (recorded 2026-10-03), six separate surfaces stated
the opposite of what the running system did — and every other audit passed
them, because each sentence rendered perfectly and no code path was broken:

- A manager page's header said report generation and delivery were **both off**,
  and offered two "Publish" buttons that only toasted "nothing is queuing". The
  weekly job had been switched back on that morning and delivery that afternoon.
  A manager reading it on launch day would believe no end user was getting
  anything — and the page's own "Generate" button, pressed in good faith, would
  have deleted the report a user had just received.
- A dashboard card asked a daily question and answered every submission with
  "Thanks — that goes straight to your coach." Nothing had read those answers
  for three weeks: the only consumer was a job that had been switched off.
- A history page's empty state said "reports are paused while we rebuild them"
  the day reports came back.
- A runbook, a plan, a script docstring, the project roadmap and the audit's own
  brief all said a job ran at "08:00 UTC". The host ran on America/New_York and
  cron used local time: it ran at 12:00 UTC (13:00 after daylight saving ends).
  The schedule maths built on the wrong clock (see clock-and-timezone-audit).
- The project's top-level instructions file — the first thing every engineering
  session reads — still said the delivery switch was off, and contradicted its
  own job count three lines apart.
- A roster banner told managers that seven users had "never connected a
  capture client — you're coaching them blind". Capture had moved server-side
  two weeks earlier; those users were being recorded fine.

## What makes this class invisible

- **It is not a bug in any code that runs.** A hard-coded sentence is correct
  code. Correctness, security and render audits all pass it.
- **It was true when written.** Review approved it. The change that made it
  false happened somewhere else — a settings flip, a cron edit, a retirement —
  and that change's diff never touched the sentence.
- **Tests pin it.** Often a test asserts the exact text, so the stale sentence
  is *protected* by the suite.
- **Its cost lands on a human decision.** A wrong promise does not crash; it
  makes a user act wrongly (a manager regenerates, a user keeps answering, an
  operator schedules a check at the wrong hour). That is why it is not LOW.

## The check

### Step 1 — Inventory every state claim

Search the shipped frontend, server-rendered templates, notification/email
templates, bot message templates, docs and runbooks for sentences that describe
**what the system is doing or will do**. Grep patterns to start (adapt):

    paused|is off|are off|disabled|not (yet )?(available|enabled|running)|coming soon|
    goes (straight )?to|we'll (send|email|DM|notify)|you'll (get|receive)|automatically|
    every (day|week|monday)|at \d{1,2}:\d{2}|UTC|nothing is|no longer|retired|replaced

Also: every toast/success message (`toast(`, `alert(`, flash messages), every
empty state, every confirm() text, every banner, every scheduled-time mention,
and every "why" comment that states current behaviour (`# runs daily`, `# the
bot delivers this`). Record file:line and the exact sentence.

### Step 2 — Find the live truth for each claim

For each sentence, name the signal that decides it and READ IT LIVE:
a settings row, the installed crontab and the host timezone (`timedatectl`), a
service's state, the newest row of the table it says is being written, a
feature flag, whether anything reads the data it says is being sent. Never use a
doc to check a doc (see trust-the-live-signal).

### Step 3 — Verdict per claim

- **TRUE** — matches the live signal.
- **FALSE** — contradicts it. State what the user does on reading it, and what
  happens as a result.
- **TRUE-BY-ACCIDENT** — matches today, but is hard-coded while the state it
  describes is switchable (a "delivery is off" header typed by hand). It goes
  false the next time someone flips the switch; report it as a finding with the
  switch named.
- **UNCHECKABLE** — no live signal exists. That is itself a finding: the system
  promises something it does not record.

### Step 4 — The fix shape (recommend, don't just patch the words)

Prefer making the sentence **derived** over re-typing it:
- render the state from the same setting the code obeys (one source);
- hide or remove a control whose action no longer exists, rather than keeping
  it with an apologetic toast;
- for docs, state the authority ("08:00 America/New_York — the host clock; cron
  has no TZ"), and where a number recurs, point to the one place it is defined;
- add a test that fails when the state and the sentence disagree (drive the
  page with the switch on and off and assert the copy follows).

## Severity

Rate by the action a reader takes. A false sentence that leads a user or
operator to do something harmful (regenerate, delete, stop, mis-schedule) is
HIGH even though nothing crashed. A false sentence that only misinforms is
MEDIUM. TRUE-BY-ACCIDENT is MEDIUM when the switch is expected to flip.

## Output

    PROMISE-REALITY FINDINGS:
    HIGH: "<sentence>" | FILE: file:line | TRUTH: <live signal + value> | USER DOES: <action> | FIX: <derive / remove / reword + test>
      evidence: <the sentence quoted at file:line AND the live command/query you ran with its actual output> [proven|inferred]
    ...
    ALL CLEAR: each claim checked TRUE, with the live signal you read for it

Every finding carries an `evidence:` line tagged **[proven]** (live signal read
this run) or **[inferred]**. UNCHECKABLE and "nothing reads this data" are
absence claims: state where you searched for the signal or the reader (the grep
pattern, the file set, the host and table queried).

An ALL CLEAR without the live signal named is not a pass: the check must have
been able to come back FALSE.
