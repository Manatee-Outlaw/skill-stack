---
name: comprehensive-audit
description: >
  Generates and dispatches the full engineering audit for Claude Code using
  concurrent subagents — one dedicated subagent per skill, all running
  simultaneously. Futureproofed: every skill in the AUDIT SKILLS list below
  automatically receives its own dedicated subagent. To add a new audit skill,
  append it to the list — no other changes needed. Every subagent
  automatically applies the full set of GOVERNING STANDARDS below to every
  finding it produces — this is baked into the skill itself, not something
  that has to be manually re-specified each time this skill is triggered.
  Trigger immediately when the user says "comprehensive audit", "full audit",
  "the full works", "run all the audits", or "audit everything".
  Never run a partial audit when this skill triggers.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Comprehensive Audit (Subagent Edition)

Runs the full engineering audit using Claude Code's subagent capability.
One dedicated subagent per skill. All subagents run concurrently — not
sequentially. The orchestrating agent waits for all subagents to report
back before synthesizing a single consolidated report.

**THE FUTUREPROOFING RULE:**
The AUDIT SKILLS list below is the single source of truth.
One skill = one subagent. Always. No exceptions.
Adding skill #11 means appending it to the list. It gets its own
dedicated subagent automatically — no other changes to this skill required.
Never batch two audit skills into one subagent.

**Why the GOVERNING STANDARDS live in this skill, not in the task:**
disciplines like verify-before-claiming and propagate-the-fix used to reach
an audit only when someone manually typed them into the task.md that time —
so an audit got them because a human-authored task happened to include them,
not because this skill required it. They are part of the skill itself
precisely so that stops being true: they apply automatically every time this
skill triggers, regardless of who or what writes the resulting task. Do not
move them back out into the task author's hands.

---

## AUDIT SKILLS (one dedicated subagent per skill)

1. **engineering-review** — database errors, undefined vars, silent failures, auth gaps
2. **holistic-code-audit** — logic, failure modes, security, race conditions, edge cases
3. **architecture-review** — async/sync mismatches, god functions, coupling, SPOF
4. **security-audit** — route auth inventory, injection, XSS, credentials, rate limits
5. **external-integration-audit** — `<host-app>`/`<streaming-tool>`/vendor field names, event coverage
6. **production-drift** — git vs `<production-host>` sync, execute permissions, cron, env vars
7. **flow-test** — end-to-end user journeys, integration seams, silent failures
8. **database-hygiene** — UNIQUE constraints, idempotency, retention policies, orphans
9. **anticipate-user-mistakes** — innocent actions with disproportionate consequences
10. **ponytail-audit** — accumulated mess, duplicated logic, dead/superseded files

*To add skill #11: append it here with a one-line description.
It will receive its own dedicated subagent in the next audit automatically.*

---

## GOVERNING STANDARDS (apply to every subagent, every finding, always)

These are not optional and do not need to be re-specified by whoever
triggers this skill — they are part of what "running a comprehensive
audit" means:

- **verify-before-claiming**: no finding may be marked fixed, working, or
  resolved based on code review alone. Real execution proof required, or
  explicitly marked code-review-only with the specific reason execution
  wasn't possible. This applies to NEGATIVE findings too — "nothing reads
  this column", "this endpoint has no caller", "this file isn't tracked in
  git", "no issues found" are all claims, and each needs the same proof as
  "it's broken". Before reporting that something is missing, unused, or
  untracked: search for it, and say WHERE you searched. An audit that
  asserts an absence it never checked is worse than one that stays quiet.
  And before reporting ALL CLEAR on any check, be able to show the check
  could have come back dirty — a scan that aborted, a grep with a rejected
  pattern, or a query that never ran reports "clean" identically to a real
  pass.
- **propagate-the-fix**: for any finding that looks like a duplicated
  pattern, search for sibling instances elsewhere in the codebase before
  finalizing — report every instance found, not just the first one.
- **propagate-the-lesson**: if a finding reveals something that would
  genuinely generalize beyond this codebase, note it explicitly as a
  candidate for a future skill — don't just fix the one instance silently.
- **close-known-gaps**: do not narrow a finding's scope back to the
  minimal fix if a real, adjacent issue is found alongside it — report
  the full known picture, not just the narrowest interpretation. Every
  finding gets triaged as RESOLVED, KEPT AS-IS (with reasoning), or
  DEFERRED (with a stated trigger to revisit) — never left unaddressed
  with no reasoning given either way.
- **no-dead-ends**: for any finding involving an error state, a
  connection/reconnection cycle, or a user-triggered stop — explicitly
  check not just whether the failure is correctly detected/reported, but
  whether a real, tested path back to "working" exists. Apply this
  deliberately; it is a different question than detection.
- **trust-the-live-signal**: wherever a finding could be checked via a
  live signal (a live query, a live file, an actual running process)
  versus a stored/documented/assumed value, use the live signal, and note
  explicitly if this changes the answer from what documentation or a
  stored field would suggest. A live signal only answers the question you
  ask of it. If the live data looks anomalous — a column that is empty, a
  metric that is uniform, a log with no entries — do NOT explain it away
  with a plausible story ("from older clients", "hasn't fired yet",
  "expected for new users"). Test the story: it is a hypothesis, and it is
  almost always checkable in one query. A rationalisation that turns out
  to be wrong costs more than the anomaly it dismissed, because it closes
  the question.
- **hostile-environment-testing**: any finding touching an installer,
  launcher, or scheduled script must be tested under messy real-world
  conditions, not just reviewed.
- **re-verify-carried-claims**: a specific claim carried from an earlier
  report — a number, a date, a named example, a count — must be re-verified
  live before being repeated in a new finding or report. A real saved report
  satisfies no-assumed-memory and can still be wrong or stale; repeating it
  unchecked launders the error into a fresh document with fresh authority.
  If re-verification is impossible, attribute explicitly ("per the <date>
  report, not re-verified") rather than restating bare.
- **no-assumed-memory**: every subagent works from the real, embedded
  context provided (the actual files read for this audit) — not from any
  assumption about what a previous audit or conversation already
  established. If continuity with a prior audit's findings matters,
  verify it against that prior audit's actual saved report file, not
  memory of it.

If a subagent finds none of a particular standard's checks relevant to
its area, it should state that plainly rather than silently omitting
mention of it.

---

## Step 1 — Confirm scope before generating

Ask the user two quick questions:
1. "Are there specific areas of concern from this session I should emphasize?"
   (Recent builds, known risky changes, anything that felt shaky)
2. "Should I include `<production-host>` checks that require SSH access?"
   (Yes for production audits; No for offline/local-only audits)

If the user says "just run it" or similar, use defaults:
- Include all skills with full scope
- Include `<production-host>` SSH checks

---

## Step 2 — Generate the task.md

Write the comprehensive audit task.md to /mnt/user-data/outputs/task.md.

### Header (include verbatim):

```
# Comprehensive Engineering Audit — SUBAGENT MODE
# READ ONLY. Report findings only. Do not change anything.
# Run one dedicated subagent per skill. All subagents run concurrently.
# Every subagent applies the full GOVERNING STANDARDS set to every finding.
# Do not synthesize until ALL subagents have reported back.
```

### File reading (before spawning any subagents):

Before spawning any subagents, read all major project files completely:
- All Python server files
- All frontend HTML/JS files
- All standalone scripts (<bot-script>, <report-generator>, etc.)
- SCHEMA.md and CLAUDE.md
- Any shell scripts called by cron
- `<bridge-component>`/installer batch files if present
- **At least one REAL, RECENT output artifact the system produced for a
  human** — a generated report, an exported PDF, a sent email, a rendered
  overlay, a delivered file. Not the template. Not the generator code. Not
  a fresh test render. An actual artifact an actual user actually received.
  Source files cannot tell you that a document ends mid-sentence or that
  half a framework is missing from it. Pass it to the flow-test subagent.
  If no real artifact can be obtained, say so explicitly in the report —
  that is a gap in the audit's coverage, not a detail to omit.

Pass the relevant file contents as context when spawning each subagent.
Each subagent needs the codebase to do its job.

### Subagent orchestration (include in task.md):

Use the Task tool to spawn one subagent per skill in the AUDIT SKILLS list.
Launch all subagents simultaneously — do not wait for one to finish before
starting the next. Each subagent operates independently with its own context.

For each subagent, embed the full instructions from its corresponding skill
(you have these in context from the engineering bundle), AND embed the full
GOVERNING STANDARDS section above verbatim — every subagent must apply all
of it, not just the skill it's specifically assigned. Each subagent must:
1. Run its assigned skill checks completely and independently
2. Apply every governing standard listed above to every finding
3. Return findings in this exact format:

   [SKILL NAME] FINDINGS:
   CRITICAL: [finding] | FILE: [file:line] | FIX: [one-line description]
   HIGH: [finding] | FILE: [file:line] | FIX: [one-line description]
   MEDIUM: [finding] | FILE: [file:line] | FIX: [one-line description]
   LOW: [finding] | FILE: [file:line] | FIX: [one-line description]
   QUICK WIN: [finding] | FILE: [file:line] | FIX: [one-line description]
   ALL CLEAR: [list every check that passed cleanly — and for each, how
   you know it could have come back dirty]

4. Rate every finding by what the USER experiences, not by what the code
   does. "Fails gracefully", "degrades safely", "truncates without
   crashing", "no parse error" all describe the PROCESS surviving — they
   say nothing about whether the person on the other end received a
   working product. Truncating cleanly is graceful for the parser and
   useless for the reader. Before rating anything LOW because it "fails
   safely", state in the finding what the user actually receives when it
   fails. If the answer is "a broken product", it is not LOW. "Can this
   break?" and "is this doing its job?" are different questions with the
   same reassuring answer — ask both, and report the second one.
5. Never change any files — report only
6. For ponytail-audit findings: triage as RESOLVED / KEPT AS-IS (with
   reasoning) / DEFERRED (with a stated trigger to revisit) — this same
   triage, via close-known-gaps, applies to every finding from every
   subagent, not just ponytail's.

---

## Step 3 — Synthesize the consolidated report

Wait for all subagents to complete before synthesizing. Produce one
report:
- Total findings by severity and by skill
- Proven-by-execution vs. code-review-only count
- One overall health verdict
- Full findings list, organized by skill

Save the report to a dated file (comprehensive-audit-[date].md) rather
than deleting it — this is the project's audit history and should persist.

Do not fix anything automatically — this skill is audit and report only.
