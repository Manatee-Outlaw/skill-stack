---
name: production-drift
description: >
  Audit the gap between what's in version control (GitHub) and what's
  actually running in production. Detects untracked changes, config drift,
  package drift, undocumented infrastructure, and dead write paths — code that
  is deployed and correct but never actually runs in production (a table with a
  real INSERT path that has zero rows, or a write endpoint whose caller was
  retired). Designed for single-server deployments (Raspberry Pi, VPS) and
  expandable to cloud environments. Read-only — produces a drift report, makes
  no changes.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Production Drift Audit Skill

## When to use
- After a period of rapid development across multiple sessions
- Before a major release or infrastructure change
- When something works in production but can't be explained by git history
- After any manual server-side changes (crontab, .env, config files)
- When a feature was built and shipped but you're not sure anyone actually
  uses it (a table that may be empty, an endpoint that may have no caller)
- Periodically as a health check (monthly or after major sprints)

This skill is read-only. It produces a report. Do not make changes.

---

## Step 1 — Git sync check

Verify the production server is in sync with the canonical git repository.

```bash
# On the production server
git log --oneline -5
git status
git diff HEAD
git remote get-url origin
```

Check:
- Is HEAD on the production server the same commit as origin/main?
- Are there any uncommitted changes to tracked files?
  (git status shows modified files, git diff HEAD shows the changes)
- Are there any merge conflicts or detached HEAD states?
- Does the remote URL point to the correct repository?

Flag:
- Production behind origin/main (commits not yet deployed)
- Production ahead of origin/main (local commits not pushed — dangerous,
  these changes exist only on the server and could be lost)
- Uncommitted changes to tracked files (CRITICAL — not in git, not
  recoverable if the server dies)
- Wrong remote URL

---

## Step 2 — Untracked file detection

Find files that exist in the production directory but aren't tracked by git:

```bash
git ls-files --others --exclude-standard
```

For each untracked file:
- Is it intentionally excluded by .gitignore (e.g., .env, *.db, __pycache__)?
- Or is it a file that SHOULD be in git but was accidentally created
  directly on the server?
- Or is it a file that SHOULD be documented somewhere (config, script)?

Also check for untracked directories:
```bash
find . -not -path './.git/*' -not -path './node_modules/*' -type d | \
  git check-ignore --stdin
```

---

## Step 3 — Crontab documentation audit

Read the production crontab and compare against any documentation:

```bash
crontab -l
```

For each cron entry:
- Is it documented anywhere? (README, CLAUDE.md, architecture docs)
- Was it added via git (in a setup script) or directly on the server?
- Is the command path still valid? Do the referenced scripts exist?
- Is the log file destination still valid?
- Does it match what the project documentation says should be running?

Flag:
- Cron jobs with no documentation anywhere
- Cron jobs that reference files not in git
- Cron jobs that were manually added and exist only in the crontab

---

## Step 4 — Execute permission audit (CRITICAL for cron)

This step catches silent failures where cron jobs appear correct in the
crontab but never execute because the script file lacks execute permission.
This is a common source of silent failures — the cron job fires on schedule,
gets "Permission denied", writes nothing to logs, and no alert is raised.

Check git-tracked file modes for all scripts called by cron:

```bash
# Check git file modes — should be 100755 for executable scripts, not 100644
git ls-files -s *.sh *.py | grep -v "100755"
```

Any .sh file showing mode 100644 (non-executable) will fail silently in cron.

Also verify execute bits on the production server:

```bash
ls -la *.sh *.py | grep -v "^-rwx"
```

Scripts called by cron that are missing the execute bit:

```bash
# For each script in crontab, check if it's executable
# Example: <scheduled-script>.sh, <scheduled-script>.py
stat -c "%a %n" <scheduled-script>.sh <scheduled-script>.py 2>/dev/null
```

Flag:
- Any .sh script tracked in git with mode 100644 (should be 100755)
- Any script called by cron that is not executable on the server
- Mismatch between git mode and server permissions (deploy will reset server bit)

Fix (when found):
```bash
git update-index --chmod=+x script_name.sh
git commit -m "fix: restore execute permission on script_name.sh"
```
Never use bare chmod +x without also fixing it in git — the next deploy
will strip the permission bit again, recreating the same silent failure.

**General rule:** Any file called directly by cron or a process manager
MUST have mode 100755 in git. Verify this after every session that adds
or modifies shell scripts.

---

## Step 5 — Environment variable drift

Compare the production .env against any template or documented variables:

```bash
# List keys only (never print values — they're secrets)
cat /path/to/.env | cut -d= -f1 | sort
```

Check:
- Are there variables in .env that aren't in any template or documentation?
  (Undocumented config — if the server dies, these are lost)
- Are there variables documented or referenced in code that aren't in .env?
  (Missing config — code may fail silently)
- Has any variable been changed from its last documented value?
  (Document when this was changed and why, without exposing the value)

Never print or log the actual values of environment variables.

---

## Step 6 — Package drift

Compare installed packages against the requirements file:

```bash
# What's actually installed
pip3 list --format=freeze | sort

# What's required
cat requirements.txt | sort
```

Check:
- Are there packages installed that aren't in requirements.txt?
  (Manual installs that would be lost on a fresh deploy)
- Are there packages in requirements.txt that aren't installed?
  (Requirements file out of date)
- Are installed versions different from pinned versions in requirements.txt?
  (Version drift — may cause non-reproducible builds)

Flag:
- Any installed package not in requirements.txt (deployment gap)
- Major version differences between installed and pinned versions

---

## Step 7 — Config file drift

Check any configuration files that live outside git:

```bash
# System service file
sudo cat /etc/systemd/system/<your-app>.service

# Logrotate config
sudo cat /etc/logrotate.d/<your-app>

# Any nginx/apache config if applicable
```

For each config file:
- Is it documented anywhere in the project?
- Was it set up via a documented process or manually?
- Does it match what the project documentation says it should contain?
- Would a fresh deployment recreate it correctly?

---

## Step 8 — Disk and filesystem health

Quick sanity check on the server's storage:

```bash
df -h
du -sh /path/to/project/
du -sh /path/to/project/* | sort -h | tail -20
```

Flag:
- Disk usage above 70% (planning threshold)
- Disk usage above 85% (action threshold)
- Any unexpected large files or directories
- Log files or data directories growing faster than expected

---

## Step 9 — Process and service health

Verify the application is running as expected:

```bash
# Service status
sudo systemctl status <service>

# What's actually running
ps aux | grep -E 'gunicorn|python|node'

# Port bindings
sudo ss -tlnp | grep -E '5000|8000|80|443'
```

Check:
- Is the service running under the expected user?
- Are the expected number of workers running?
- Is the application bound to the expected port?
- Is there anything unexpected running on the server?

---

## Step 10 — Dead write-path / orphaned-feature detection

Steps 1–9 catch drift between git and the server. This step catches a
different, quieter drift: code that is correct, deployed, and version-
controlled, but that **never actually runs in production** — a table with a
real INSERT path that has zero rows, or a write endpoint whose UI caller was
retired and never rewired.

Correctness audits (database-hygiene, holistic-code-audit) will pass this
code: it reads correctly and even runs correctly when driven. Only
cross-referencing the code's write paths against live production data reveals
that nothing ever exercises them. That cross-reference is production drift's
job, not a correctness skill's — database-hygiene checks whether the rows that
exist are *valid*, never whether a table is *used at all*, and asking it to
would fight its purpose.

### 10a — Enumerate write paths, then check live row counts

List every table the code can INSERT into:

```bash
# Every table named in an INSERT statement, deduped
grep -rhoiE "INSERT (OR (IGNORE|REPLACE) )?INTO [a-z_]+" --include=*.py . \
  | sed -E 's/.*INTO //I' | tr 'A-Z' 'a-z' | sort -u
```

For each such table, query its LIVE production row count — the real database
the server writes to, not a fixture or a local copy:

```sql
SELECT COUNT(*) FROM <table>;
```

Flag any table with a defined INSERT path that has **0 rows**, or whose count
has not moved in N weeks (compare against a prior run, or the max of a
created/updated timestamp column if one exists). A zero-row table with live
write code is the signal: the write path has never successfully committed in
production, across the whole lifetime of the table — not merely "quiet
lately."

### 10b — For each flagged table, classify WHY the path never fired

A zero-row-with-write-path table is an anomaly, not a verdict. Trace each
write path to its trigger and classify it — the two diagnoses need opposite
fixes and must not be conflated:

- **reachable-and-unused (workflow gap):** the trigger (a button, an admin
  action, a scheduled job) is live and reachable, but nobody runs it — the
  real workflow goes through a different feature. The code is fine; the
  feature is unadopted. This is a product decision, not a code change.
- **unreachable / orphaned (code rot):** the trigger was removed or hidden and
  the write path was never cleaned up — a button that no longer renders, a
  route whose page was retired, a caller deleted in a refactor. This is dead
  code to remove.

Do not guess which. Establish it per path with real evidence — the trigger's
reachability in the running app, and the access logs (has this endpoint ever
been hit? "nobody tried" vs "tried and silently failed" are different bugs).

### 10c — Orphaned write endpoints (no live caller)

The endpoint half is checkable from code alone. For every route handler that
writes to the database, confirm a live caller exists in the client:

```bash
# Every DB-writing route
grep -rnE "@app.route\(.*(POST|PUT|PATCH|DELETE)" --include=*.py .
# For each write route's path, search the client for an ACTUAL invocation
grep -rn "<route-path>" --include=*.html --include=*.js .
```

Flag any write route whose only references are **comments, note text, or a
retired page** — where no `fetch()` / `api()` / form action actually calls it.
That is an orphaned endpoint: live on the server, unreachable from the app.
(Verify the absence the way verify-before-claiming demands — say where you
searched; "no caller" is itself a claim.)

### 10d — Hand anomalies to trust-the-live-signal, don't re-derive it

Everything this step surfaces is a live-data anomaly — an empty table, a flat
count, a caller-less route. Do **not** explain it away here with a plausible
story ("probably new", "hasn't fired yet"). Hand each finding to the
**trust-the-live-signal** discipline: treat the story as a hypothesis and
check it in one query (the row count, the access log, the caller grep). This
step's job is to *surface* the anomaly proactively — the thing a pure
correctness pass never goes looking for; trust-the-live-signal governs how you
*resolve* it once surfaced. Don't duplicate that standard's logic here.

### 10e — Parallel-mechanism detection (two solutions, one problem)

10a-10c find single dead paths. This sub-step finds their most expensive
disguise: **two mechanisms in the same codebase that solve the same problem,
where one is dead or dying** — and the dead one hides because the problem IS
being solved, just by the other mechanism. A dead table next to a live
feature reads as "unused feature"; a dead table next to a THRIVING SIBLING
reads as "we already migrated," and nobody ever writes that down.

Real shape of the finding (a real case on this project, now CLOSED — kept as an
illustration of the pattern, not a current finding): a lightweight prospect-intake
table (0 rows, live write route) coexisted with a full CRM whose candidates table
was growing daily — the intake path had been superseded for weeks, its UI entry
point still rendered, and no document said which one was canonical. That intake
table was formally retired 2026-07-23, which is exactly the outcome this check
drives toward. Look for the pattern, not this specific table — and per
re-verify-carried-claims, confirm any table you cite here is still live before
reporting it as an open finding.

The check: take every zero-row/flat table and caller-less route from 10a-10c
and ask, per finding: **"what does this codebase use INSTEAD to do this
job?"** Search by domain noun, not by table name:

```bash
# e.g. the dead table is <intake_table> — search the domain concept, not the table name
grep -rniE "prospect|candidate|intake|lead" --include=*.py --include=*.html .   | grep -viE "<intake_table>"
```

Three possible answers, three different findings:

- **A live sibling exists and is clearly canonical** → the dead mechanism is
  SUPERSEDED. The finding is not "unused feature" but "unfinished migration":
  flag the leftover write path, any UI entry points still reachable, and the
  missing tombstone note saying which mechanism won. Recommend retiring the
  loser explicitly — half-retired mechanisms grow back.
- **A live sibling exists but they PARTITION the job** (each handles a
  distinct case) → not drift; document the split if no doc says it.
- **No sibling** → plain 10b classification applies (unadopted vs orphaned).

Also run the check in reverse once per audit: list the codebase's top-level
jobs (ingestion, reporting, alerting, imports, auth) and for each ask whether
TWO implementations exist. Duplicated jobs accrete during rewrites — the old
one rarely gets deleted the same week the new one ships.

---

## Step 11 — Watchdog self-validation (who watches the health check?)

Every step so far trusts the monitoring layer to be a fixed point of truth.
This step removes that assumption: **the watchdog is code too, and it can
carry the exact bug class it exists to catch.** In one real system, the
health-check script filtered "active streamers" through a denormalized role
column while the rest of the codebase had a known stale-mirror bug in that
very column — so the watchdog silently under-counted its own patrol area and
never flagged the users the bug was hiding. The check that should have caught
the bug HAD the bug, and nothing was positioned to notice: a watchdog that
under-reports looks identical to a healthy system.

For every health-check / watchdog / alarm script on the box (find them in the
crontab from Step 3):

1. **Predicate cross-check.** For each predicate the watchdog filters on
   ("active", "established", "recent", "streamer"), compare its result set
   against the same concept computed the way the application's most-recently-
   audited code computes it. A count mismatch is a finding — one of the two is
   wrong, and it's a coin flip which:

```bash
# e.g. watchdog says N monitored users; the authoritative query says M
# N != M -> someone is invisible to monitoring
```

2. **Known-bad probe.** Can each alarm actually fire? For every alarm,
   demonstrate a firing path with a synthetic known-bad condition — a test
   hook (`--stale-days 0`-style override), a dry-run against a doctored
   threshold, or a staging row. An alarm that has never once fired in its
   life is UNPROVEN, not healthy — the same standard verify-before-claiming
   applies to "the check reported clean": show the check COULD have come back
   dirty. Record when each alarm last demonstrably fired (real or test).

3. **Coverage drift.** Diff the watchdog's monitored surface against what
   the system now has: tables added since the health check was last touched
   (git log the check script vs the schema doc), new client paths without a
   liveness signal, new cron jobs with no failure alarm. Watchdogs are
   written once and grow stale while the system grows — staleness here is
   silent by construction.

Rate a predicate mismatch on an alerting path as HIGH: it means some part of
production is patrolled by nobody, and every OK summary since the mismatch
began has been partially vacuous.

---

## Output format

**Before finalizing any finding below: grep the flagged surface for a
`REVIEWED` marker first** (see respect-settled-decisions). If one exists and
its stated scope covers what you're about to flag, cite it and treat the
matter as settled — a deliberately-kept piece of drift (like a documented
override) is not the same as an undocumented one.

Produce a report with these sections:

### DRIFT SUMMARY
One-line status: "X items in sync, Y items drifted, Z items undocumented"

### CRITICAL FINDINGS
Changes that exist only on the production server and are not in git.
These are at risk of being lost if the server fails.

### GIT SYNC STATUS
Commit comparison between production and origin/main.

### EXECUTE PERMISSION AUDIT
List every cron-called script. Flag any missing execute bit or git mode mismatch.

### UNTRACKED FILES
Files on the server not in git, with assessment of whether each is
intentional (in .gitignore) or a concern.

### CRONTAB AUDIT
Every cron job with documentation status and any unexpected entries.

### ENVIRONMENT VARIABLE AUDIT
Key names present/absent. No values. Flag undocumented keys.

### PACKAGE DRIFT
Packages installed but not in requirements.txt, and vice versa.

### CONFIG FILE STATUS
System config files with documentation status.

### DISK HEALTH
Storage usage summary and any growth concerns.

### DEAD WRITE-PATH / ORPHANED-FEATURE AUDIT
Every table with an INSERT path and its live production row count. For each
zero-row (or long-stale) table: the per-path classification — reachable-and-
unused (workflow gap) vs unreachable/orphaned (code rot) — with the evidence
that decided it (trigger reachability, access-log hits). Every DB-writing
route with no live client caller. State where you searched for callers.

### REMEDIATION CHECKLIST
Ordered list of actions to bring production back in sync with git,
and to document anything that should be tracked but isn't.

### EXPANDING TO OTHER ENVIRONMENTS
When a project migrates from one host to another, re-run this audit
with the following adjustments:
- Replace crontab check with cloud scheduler (AWS EventBridge, GCP Cloud
  Scheduler, etc.)
- Replace .env check with secrets manager (AWS Secrets Manager, etc.)
- Replace systemd service check with container/process manager check
- Replace disk usage with cloud storage/volume metrics
- Add: load balancer config, CDN config, DNS records documentation
