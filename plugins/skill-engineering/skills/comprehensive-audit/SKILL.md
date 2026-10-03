---
name: comprehensive-audit
description: >
  Generates and dispatches the full engineering audit for Claude Code using
  concurrent subagents — one per skill in the AUDIT SKILLS list below, all
  running simultaneously, each automatically applying the full GOVERNING
  STANDARDS set to every finding it produces.
  Trigger immediately on "comprehensive audit", "full audit", "the full works",
  "run all the audits", "audit everything" — and ALSO on the bare, unqualified
  asks: "audit my code", "code audit", "code review", "run an audit", "check the
  codebase", "review the code". Those generic phrasings belong to THIS skill, not
  to its components: engineering-review, holistic-code-audit and
  architecture-review are dispatched BY this audit, and firing one alone in answer
  to a generic request gives a fraction of the coverage while looking complete.
  Never run a partial audit when this skill triggers.
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
  portability_exempt:
    raw-github: "The dev box runs this audit without installed plugins; it fetches each sub-skill from its raw URL."
---

# Comprehensive Audit (Subagent Edition)

Runs the full engineering audit using Claude Code's subagent capability.
One dedicated subagent per skill. All subagents run concurrently — not
sequentially. The orchestrating agent waits for all subagents to report
back before synthesizing a single consolidated report.

**THE FUTUREPROOFING RULE:**
The AUDIT SKILLS list below is the single source of truth.
One skill = one subagent. Always. No exceptions.
Adding the next skill means appending it to the list. It gets its own
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
4. **security-audit** — route auth inventory, injection, XSS, credentials, rate limits, identity trust chain
5. **external-integration-audit** — `<host-app>`/`<streaming-tool>`/vendor field names, event coverage
6. **production-drift** — git vs `<production-host>` sync, execute permissions, cron, env vars
7. **flow-test** — end-to-end user journeys, integration seams, silent failures
8. **database-hygiene** — UNIQUE constraints, idempotency, retention policies, orphans
9. **anticipate-user-mistakes** — innocent actions with disproportionate consequences
10. **ponytail-audit** — accumulated mess, duplicated logic, dead/superseded files
11. **render-smoke** — rendered-DOM broken-render signatures (undefined/NaN/$0/undefinedh) + interaction-backed fake-success, driven through a seeded non-production environment
12. **persistence-audit** — write paths that silently stopped: tables that should be growing and aren't, and the guards that blocked themselves
13. **promise-reality-audit** — sentences the product or docs state about system state (copy, toasts, empty states, runbooks, CLAUDE.md, schedules) checked TRUE against the live signal
14. **decision-conformance-audit** — every recorded owner decision written as an invariant, every code path that could violate it enumerated and proven, one cross-path test per decision
15. **clock-and-timezone-audit** — every time comparison, schedule and 'today' names its clock (host TZ vs cron vs UTC vs user; DST; as_of)
16. **fixture-realism-audit** — tests fed what production feeds: real-input regression corpus, relative seed dates that never age out, behaviour pins with reasons

*To add skill #17: append it here with a one-line description.
It will receive its own dedicated subagent in the next audit automatically.*

**Where each subagent gets its skill text.** Where the skill-engineering plugin is
installed, every skill above loads by name — use that copy. Where it is not (a
server or dev box that runs this audit without installing plugins), fetch the
skill raw from its single source of truth:

```
https://raw.githubusercontent.com/Manatee-Outlaw/skill-stack/main/plugins/<plugin>/skills/<name>/SKILL.md
```

Every skill in this list lives in `skill-engineering`. Fetch the raw file with a
plain HTTP GET (`curl -fsSL`), never through a summarising web fetch — a summary
silently drops the rules the subagent is supposed to apply. A fetch that fails or
returns anything but a file starting with `---` is a stop: report which skill could
not be loaded, never run its subagent from memory.

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
- **Every finding carries an `evidence:` line**, tagged `[proven]` or
  `[inferred]` — the command run and its output, or the exact text quoted.
  The negative-findings rule above is the most-violated standard in this set
  precisely because it lives in prose and nothing in a report format asks for
  it. The evidence line is where it gets enforced: an absence finding whose
  evidence line does not name where you searched is not reportable.
**A proxy check is not a content check.** `ls` and `find` prove a file exists.
`diff -q` and checksums prove bytes differ. `grep -c` and `grep -l` prove a match
count. None of them prove what the file *says*. If the command on your evidence
line is one of those, the finding is `[inferred]` at best — open the file before
it ships. (This is not hypothetical: on 2026-09-09 an `ls` that listed a README
became "no version control", a `diff -q` became "stale, needs re-upload", and a
`grep -c` became "this rule needs writing" — all three wrong, all three one file
read away from correct.)

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

## Step 0 — Run the test suite BEFORE looking for anything new

Find the project's test suite and run it. Report the pass/fail/skip counts as the
first line of the audit, before any finding.

If there is no runner, that is the first finding — write it up and say how many test
files exist with nothing executing them.

If the suite is red, or will not run at all, **say so at the top and treat every
other finding as provisional.** An audit that reports fresh findings while the
existing gates are broken is measuring the wrong thing: it discovers new problems
while the ones already caught sit unnoticed.

Do not accept a green result you did not watch execute. "There are tests" is not
evidence; an exit code is. A suite that cannot run on the machine you are auditing
from has been proving nothing for as long as that has been true — and the longer a
project has gone without this check, the more likely that is the actual finding.

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
  half a framework is missing from it. Pass it to the flow-test AND the
  render-smoke subagents (render it as the user saw it, at phone and
  desktop widths). Save a copy in the audit folder so every subagent reads
  the same artifact. If no real artifact can be obtained — including when a
  permission policy refuses copying real user content out of production —
  say so explicitly in the report, and say what was used instead (e.g. text
  built from the code's own templates in the production shape): that is a
  gap in the audit's coverage, not a detail to omit.

Pass the relevant file contents as context when spawning each subagent.
Each subagent needs the codebase to do its job.

### Subagent orchestration (include in task.md):

Use the Task tool to spawn one subagent per skill in the AUDIT SKILLS list.
Launch all subagents simultaneously — do not wait for one to finish before
starting the next. Each subagent operates independently with its own context.

For each subagent, embed the full instructions from its corresponding skill
(loaded by name, or fetched raw as described under AUDIT SKILLS), AND embed the full
GOVERNING STANDARDS section above verbatim — every subagent must apply all
of it, not just the skill it's specifically assigned. Each subagent must:
1. Run its assigned skill checks completely and independently
2. Apply every governing standard listed above to every finding
3. Return findings in this exact format:

   [SKILL NAME] FINDINGS:
   CRITICAL: [finding] | FILE: [file:line] | FIX: [one-line description]
     evidence: [proven|inferred] [command + output, or exact quoted text; for an absence, where you searched]
   HIGH: [finding] | FILE: [file:line] | FIX: [one-line description]
     evidence: ...
   MEDIUM: [finding] | FILE: [file:line] | FIX: [one-line description]
     evidence: ...
   LOW: [finding] | FILE: [file:line] | FIX: [one-line description]
     evidence: ...
   QUICK WIN: [finding] | FILE: [file:line] | FIX: [one-line description]
     evidence: ...
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
5. Never change any files — report only. Each subagent gets its OWN private
   scratch folder, named in its prompt (e.g. `<audit-folder>/<skill>/`), and
   writes every repro script, dump and query result there. Never a shared
   filename: in a measured run two subagents both wrote `prod_schema.txt` to
   the shared scratchpad and one silently overwrote the other's evidence
   mid-run. The findings file is the only thing written outside that folder.
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

---

## Step 4 — Fix wave (ONLY when the user explicitly asks for fixes)

The audit itself never fixes. When the user asks to "do all fixes", run this
procedure; it is what kept a 50-finding fix wave across one large codebase to
zero regressions and one deploy (measured 2026-10-02).

1. **Verify before fixing.** Re-read each finding's proof yourself. Findings
   reported by several subagents independently are usually the most real; a
   finding with only code-review proof gets a repro first.
2. **Batch the decisions, not the fixes.** Separate findings that need the
   OWNER (they change what users or staff experience — sign-in methods, what a
   delete button does, what a card promises) from those you can rule on. Ask
   the owner all of theirs at once, with a recommendation each, while subagents
   are still running. Record each answer as a dated decision.
3. **Partition by file ownership.** Group the rest into batches so no two
   batches edit the same functions (e.g. reports / bot / auth / UI / docs).
   Where two batches must touch one file, assign each the exact region
   ("only the Account email card markup and its handler").
4. **One worktree + branch per batch**, created by the orchestrator from the
   current main. One implementer subagent per batch, given: a shared rules file
   (worktree only; never merge, push to main or deploy; TDD — every behaviour fix
   has a test watched FAILING on the old code first, the break proven to have
   landed; known environment-only test failures listed; no secrets; production
   read-only) and its batch file (the findings by id, and every owner decision
   and ruling verbatim). Each writes a per-batch report: change, test, red→green
   proof, open questions.
5. **Review each branch before merging.** Read the security-sensitive diffs
   yourself (anything touching auth, identity, money or outbound messages).
   Answer implementers' open questions as rulings; send small follow-ups back to
   the same implementer rather than patching in the merge.
6. **Integrate on a separate branch**, merging smallest/least-conflicting first.
   Resolve each conflict by COMBINING both sides (two batches appending to the
   same list or doc line), never by picking one; re-run the tests both sides
   touched. Cross-batch concerns no batch owned (e.g. a new notification type
   that must be scoped to the right audience) are fixed here with their own
   red-first test.
7. **Before merging any branch, confirm the pushed tip is the whole branch**
   (no unpushed commits or uncommitted files in any worktree for it). A merged
   branch once missed its author's final, unpushed commit; the trial merge and
   the full suite both passed on the incomplete code.
8. **Full suite in the main checkout** on the integrated code (not a worktree:
   some tests only run there), plus the project's layout/journey checks. Then
   deploy through the normal gated path, then any manual production steps the
   batches listed (crontab, service units), each with a backup, a diff that shows
   only the expected change, and a live verification.
9. **Report** findings fixed / deferred (with triggers) / kept, the deployed
   commit, and the suite results; record decisions and outcomes in the project's
   roadmap or decision register the same day. Remove merged worktrees only after
   checking each for uncommitted or unmerged work.
