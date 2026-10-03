---
name: clock-and-timezone-audit
description: >
  Check that every time the system compares, displays, schedules or judges a
  moment, it names WHICH clock it is using and that clock is the right one.
  Host timezone vs cron vs database UTC vs the user's local zone; daylight
  saving; "today" and "this week" computed at run time instead of at the
  moment being judged; weekday names derived from UTC dates; a re-check that
  uses now() where the original used the report's date. Run after any
  scheduling change, any feature that says "today/this week/day N", any
  checker that re-judges stored output, before a DST change, and in every
  comprehensive audit. Trigger phrases: "what time does it run", "UTC or
  local", "off by a day", "wrong weekday", "DST", "day N of", "re-check later",
  "timezone bug", "cron runs at the wrong time".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Clock and Timezone Audit

## Why this skill exists

In one week on one product (recorded 2026-10-03), four separate defects came
from the same root: a piece of code used a clock without saying which one, and
it was the wrong one. Each passed review and its tests, because the tests ran on
the same clock the code assumed.

- **A schedule written in the wrong zone.** A runbook, a plan, a script
  docstring, the project roadmap and an audit brief all said the weekly job ran
  at "08:00 UTC". The host ran America/New_York and cron (vixie-cron, no
  `CRON_TZ`) fires on host-local time: it ran at 12:00 UTC, and will run at
  13:00 UTC after daylight saving ends. A check scheduled from the docs would
  have looked four hours early and reported "nothing sent".
- **Weekday names from UTC dates.** A fact-checker turned stored UTC
  timestamps into weekday names and held reports that said a user "was active
  Sunday" — true in the user's evening, already Monday in UTC.
- **"Today" taken at the wrong moment.** A program-day counter ("day 17 of
  120") counted active days up to *now*. The report was right when written;
  re-checked a week later by a regression tool, the same sentence was judged
  false and would have been held. The checker had to be given the report's
  own date (`as_of`) to judge it as it stood.
- **Logs and database on different clocks.** Database rows were UTC, log lines
  were host-local (EDT): matching a log line to the row it described meant a
  four-hour subtraction by hand, during an incident. One log (the web server's
  access log) kept local time weeks after the others were fixed, because its
  timestamp came from a different formatter.

## What makes this class invisible

- **The developer's clock agrees with the code.** Tests run on a box in the
  same zone, at a time of day when UTC and local share a date.
- **It is right most of the day.** A UTC/local date mismatch only exists for
  the 4–5 hours around midnight; a DST bug only on two days a year.
- **Docs repeat a time without its zone,** or with the wrong one, and every
  later doc copies it.
- **`now()` hides inside helpers.** A function that looks pure ("days in the
  program") reads the wall clock internally, so any caller judging the past
  silently judges the present.

## The check

### Step 1 — Inventory every clock use

Grep the code (adapt per language):

    datetime.now|utcnow|date.today|time.time|localtime|strftime|strptime|
    datetime\('now'|CURRENT_TIMESTAMP|Date\(\)|new Date|toLocale|getDay|
    weekday\(|isoweekday|%A|%a|timedelta\(days|'-\d+ days'|this week|today

Plus: the installed crontab(s) and each host's zone (`timedatectl`), systemd
timers, log formatter configs (every logger, including the web server's access
log), and every doc or comment that states a time of day.

### Step 2 — For each use, answer four questions

1. **Which clock?** UTC, host-local, the user's zone, or "whatever the box
   is". "Whatever the box is" is a finding unless the box is pinned.
2. **Which moment?** Is it judging *now*, or a stored moment (a report's
   date, a session's start)? A helper that reads `now()` while a caller judges
   the past is a finding — add an `as_of` parameter and pass the moment.
3. **Which date boundary?** Anything that turns a timestamp into a date,
   weekday, week or month: in whose zone? A weekday name shown to a person must
   come from that person's zone.
4. **Does it survive DST?** Fixed UTC offsets (`-4`, `-0400`), "add 24
   hours" for "tomorrow", and cron entries on a non-UTC host all shift by an
   hour twice a year.

### Step 3 — Cross-check schedules against the live host

For every scheduled job, write down: crontab line, host zone, resulting UTC
time now, resulting UTC time after the next DST change. Compare against every
doc, runbook, monitor and dependent job that names its time. A monitor that
expects output by a time must use the same computation. Read the host zone
live on `<production-host>` — never take it from a doc, which is exactly the
surface that was wrong in the measured case.

### Step 4 — Prove it with a clock that disagrees

For each finding you fix, add one test that runs with a clock that differs
from the developer's: a timestamp at 02:00 UTC (previous local day), a moment
in the past with data after it, a date across a DST change. Watch it go red on
the old code.

## Severity

HIGH when the wrong clock changes a decision: a report held or released, a
deadline missed, a monitor silent, money attributed to the wrong period, a
person told the wrong day. MEDIUM when it only misdisplays. A schedule doc in
the wrong zone is HIGH if anything (a person, a check) is timed from it.

## Output

    CLOCK FINDINGS:
    HIGH: <what> | FILE: file:line | CLOCK USED: <zone + moment> | SHOULD BE: <zone + moment> | WHEN IT BITES: <hours/days> | FIX: <name the clock / as_of / zone conversion + test>
      evidence: <the grep hit or live command (timedatectl, crontab -l) and its actual output> [proven|inferred]
    SCHEDULES: <job> | cron <line> | host <zone> | UTC now <hh:mm> | UTC after DST <hh:mm> | docs say <...>
    ALL CLEAR: each clock use with the zone and moment it uses, and the disagreeing-clock test that proves it

Every finding carries an `evidence:` line tagged **[proven]** (you ran it and
quote the output) or **[inferred]** (read from code only). An absence — "no
other clock uses", "no doc names this time" — cannot quote offending text:
state where you searched (the grep pattern and the file set, the hosts whose
crontab you read).

An ALL CLEAR that never ran a test on a clock different from the developer's
is not a pass.
