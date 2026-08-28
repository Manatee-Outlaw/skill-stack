---
name: task-authoring
description: >
  Governs how a task.md is written for an implementer to execute. Every task
  file must open with an ASSUMPTIONS block enumerating each factual dependency,
  its source, and whether it is verified. In any domain the author cannot see —
  the codebase, the server, the database, the target OS — state the GOAL and
  never the mechanism. Trigger automatically before writing or sending any task
  file, instruction set, or work order to an implementer. Also trigger on the
  receiving side: an implementer reading a task.md that lacks an assumptions
  block, or that specifies a mechanism the author could not have verified,
  must say so and proceed by the goal rather than silently complying. Applies
  equally to any literal command handed to a human operator to paste: name the
  machine they should be sitting at, state what output proves it worked, and
  confirm host identity against current documentation before naming a host.
metadata:
  tier: universal
  plugin: skill-engineering
---

# Task Authoring

Applies to: whoever writes a task.md for an implementer to execute.
Always-on. Governing standard.

## Why this skill exists

An orchestrator wrote two instructions into task files that would have caused
real damage if followed literally:

- **"Verify the health check reports zero CRITICAL, or roll back."** The real
  pre-deploy baseline was ONE CRITICAL — a known, unrelated, pre-existing
  condition. Followed literally, a good deploy would have been rolled back.
- **"Dedupe this route, matching the scheduled job."** Literal compliance would
  have DELETED a prior period's record, because the table had no subject-period
  column and the scheduled job's approach did not transfer.

Both were caught by the implementer, not the author. Both share one root cause:
**the author specified a mechanism in a domain it could not see.**

This is not carelessness. It is structural. An orchestrator that cannot read the
codebase, the server, the database, or the target OS is not qualified to specify
HOW. It is qualified to specify WHAT and WHY. Every time it crosses that line it
is doing the implementer's job with strictly less information.

Note the tell: the instructions that were CORRECT were the ones the implementer
proposed during discovery and the orchestrator echoed back. The ones that were
WRONG were the ones the orchestrator invented.

"Be more careful" does not work here. A verify-before-claiming discipline was
already active and was violated five times in one day. An unverified assumption
does not feel like an assumption — it feels like knowledge. The countermeasure
must be a FORMAT THAT FORCES ENUMERATION, not a value to be remembered.

## Rule 1 — Every task.md opens with an ASSUMPTIONS block

Mandatory. No exceptions. Before any instruction:

```
ASSUMPTIONS — CHECK THESE FIRST. STOP IF ANY IS FALSE.
1. <the assumption> — source: <where it came from>. VERIFIED / NOT VERIFIED
   because <reason>.
2. ...
```

Rules for the block:

- Every factual claim the task depends on goes in it. Baselines, version
  numbers, schema shapes, file locations, "X is already done", "Y has no
  callers".
- State the SOURCE. "Yesterday's report", "a previous session", "the backlog",
  "inferred from a symptom" are all different reliability levels and must be
  distinguishable.
- Mark NOT VERIFIED honestly. A stale report is not verification. A memory is
  not verification. An inference from a symptom is not verification.
- If the block is empty, the author has not thought about it. It is never empty.

The implementer checks this block FIRST, at step 0, before doing anything. A
false assumption dies in thirty seconds instead of being excavated from prose.

## Rule 2 — In any domain the author cannot see: state the GOAL, never the mechanism

If the author cannot read the code, the schema, the server, or the target OS,
then the author does not know what the correct mechanism is, and must not name
one.

- **WRONG:** "Dedupe by period, matching the scheduled job."
  **RIGHT:** "A record for a given period should exist exactly once. Achieve
  that correctly given the ACTUAL schema — the scheduled job's approach may not
  transfer. Check before copying it."
- **WRONG:** "Verify the health check shows 0 CRITICAL, or roll back."
  **RIGHT:** "Verify the deploy introduced NO NEW problems. Capture the real
  pre-deploy baseline first and compare against it — do not assume the baseline
  is clean."
- **WRONG:** "Add the field to the payload at line N."
  **RIGHT:** "The two ingestion paths should carry the same fields. Find where
  they diverge and close the gap."

The second form is what the author actually meant in every case. The first form
is a guess at implementation, dressed as an instruction.

**Where the author IS qualified, and should be specific:**

- WHAT outcome is wanted, and WHY it matters
- Priorities, ordering constraints, and what must not break
- Decisions already made and the reasoning behind them
- Deadlines and external context the implementer cannot know
- Which standards apply, and which prior findings are relevant

## Rule 3 — The implementer enforces this

If a task.md arrives WITHOUT an assumptions block, or specifies a mechanism in a
domain the author demonstrably cannot see:

- Say so explicitly, up front, in the report.
- Proceed by the GOAL, not the stated mechanism, if the goal is clear.
- STOP and ask if the goal is not clear.

Do not silently comply with a bad instruction because it was written
confidently. Do not silently improve it either — SAY that you deviated and WHY.
A deviation that is reported is a correction; a deviation that is not reported
is a divergence nobody can audit.

This rule exists because the author cannot self-enforce the other two. The
person who does not know they are assuming cannot catch themselves assuming.

## Rule 4 — Do not assert what you cannot see

Outside task files too: when about to state a fact about a codebase, a server,
or a machine you have no access to — do not. Choose one:

- Verify it (search, fetch, or ask the implementer to check), or
- Say "unverified" and mark it as an assumption, or
- Do not say it.

Absence of evidence in the half you CAN see is not evidence of absence. An
orchestrator once concluded "no documentation exists" after searching only the
document store it had access to. The documentation existed — in the repository
it could not read. It drew a conclusion about the whole system from the half it
could see, while writing the case that everyone else's documentation was
untrustworthy.

## Rule 5 — Prefer discovery over specification

If a task requires knowing something the author cannot see, the answer is not to
guess better. It is to ASK FIRST:

- **Phase 1: discovery (read-only)** — the implementer reads the actual code,
  surfaces ambiguities, proposes an approach, flags decisions.
- **Phase 2:** the author approves, then the build task is written FROM the
  discovery's findings rather than from the author's imagination.

Two-phase is slower per task and faster per outcome. It has caught, repeatedly:
scope traps (a "one-line fix" that dragged an entire subsystem), false premises
inherited from stale audits, and unanswerable questions surfaced before rather
than after implementation.

The temptation to skip discovery is strongest under time pressure. That is
exactly when it pays.

## Rule 6 — A command handed to a person is a task file too

Every literal command given to a human operator to paste is a MECHANISM specified in a
domain the author cannot see: their shell dialect, their OS, their PATH, their SSH config,
their host inventory, which machine they are sitting at right now. Rule 2 applies in full.

**Before giving any command, three things are mandatory:**

1. **Name the machine.** "From PowerShell on your desktop", "in the browser console on the
   production host". A command with no stated origin is unrunnable by anyone who does not
   already know the answer — and a person who already knew would not need the command.
2. **State what proves it worked.** The expected output, or the observable change. Without
   it the operator cannot distinguish success from silent failure, and neither can you when
   they paste the result back.
3. **Verify host identity against the project's own current-state document**, not against
   memory or an older report. Infrastructure gets migrated. A host named correctly in a
   document written six weeks ago may be decommissioned, repurposed, or — worse — kept
   running as a warm rollback asset, where operating on it looks exactly like success.

**Do not infer a machine's health from a signal that does not touch it.** A public URL
responding proves the thing serving that URL is up. Behind a CDN, a tunnel, a load
balancer or a proxy, that is not necessarily the machine in question. Name what the signal
actually measured before drawing a conclusion from it.

**When the operator is not an engineer, a wrong command costs more than no command.** They
cannot distinguish "wrong syntax for my shell" from "the system is broken", so a failed
command reads as a failed system. Worse, a silently failed command followed by a
successful-looking next one produces exactly the class of damage `push-to-git` Step 1.6
exists to catch: the cleanup that did not happen, followed by the commit that claimed it
did.

Two corollaries:

- **Prefer the route with no prerequisites** when their machine's configuration is
  unverifiable. A browser console that needs no keys beats an SSH command that assumes a
  config entry you have never seen.
- **Do the work yourself where you can, and say plainly where you cannot.** "I tested
  whether I could reach it and I cannot" is a real answer. Handing over a command while
  implying it is routine, when it depends on setup you never confirmed, is not.

## The check, before sending any task

1. Does it have an ASSUMPTIONS block? Is every factual dependency in it, with
   its source and verification status?
2. Have I specified any MECHANISM in a domain I cannot see? Rewrite as a goal.
3. Am I stating something as fact that I have not verified today?
4. Would this task have been better as a discovery?
5. If the implementer follows this LITERALLY and the world is not as I assume —
   what breaks? If the answer is "something irreversible", the task is not
   ready.
