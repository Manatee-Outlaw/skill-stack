---
name: verify-before-claiming
description: >
  Require real execution evidence before reporting anything as fixed, working,
  deployed, or verified. Trigger automatically before writing "fixed",
  "deployed", "verified", "already resolved", "works correctly" or similar in
  any report. Applies equally to negative results — "clean", "no hits", "no
  errors found", "nothing to report", "all tests passed" need the same proof,
  because a check that aborted or never ran produces output identical to a
  genuine pass. Trigger before reporting any clean scan, audit, grep, health
  check or test result, and whenever a command returns nothing, an empty string,
  or "0". Also trigger before labelling anything outside the codebase — a tool,
  library, URL, author, licence — as fictitious, real, or verified: that needs
  an actual fetch or search performed this session, never an inference from
  what looks familiar. Re-verify rather than repeating a prior session's
  unproven claim.
metadata:
  tier: universal
  plugin: skill-core
---

# Verify Before Claiming

## Why this skill exists
On June 30, 2026 (Build 1.6 rollout), two things happened on the same night:
a code review reported a bug as "already fixed" — it wasn't; the code that
read correctly had a hidden character-parsing bug (stray parentheses read as
end-of-block by cmd.exe) that only broke when actually run. Separately, a
build was reported "pushed, deployed, active" before it had genuinely reached
the production server. Both cost real troubleshooting time on a live streamer
account, at the worst possible moment — hours after a mandatory rollout.
Reading code well is not the same as knowing what the code does when it runs.

## The core rule
**Code review tells you what should happen. Only running it tells you what
does happen.** Never write "fixed," "working," "deployed," or "verified" in
a report unless there is an actual execution trail behind that word.

## Before writing any status claim, ask
1. Did I actually run this, or did I read it and conclude it should work?
2. If I ran it — what exact command, what exact output? Could I paste it?
3. If I could NOT run it (no safe test environment, would affect a live
   user, no way to replicate the exact machine/condition) — have I said so
   explicitly, in the same sentence as the claim, not buried later?
4. Am I about to repeat a claim from an earlier report or session without
   re-checking it myself right now? A prior "verified" is not proof — verify
   again if it materially matters to what's being decided.
5. Have I actually tried to find evidence AGAINST this claim, not just
   evidence consistent with it? A claim that's only ever been checked in the
   direction that confirms it hasn't really been checked. If disproving it
   never occurred to me as something to attempt, that absence is itself a
   signal I stopped a step early.

## Required report format
Every fix/deploy/audit report must separate these two categories explicitly:
- **Proven by execution** — what was actually run, and the actual result
  (paste the real output where possible, not a paraphrase of it)
- **Believed correct by code review only** — what looks right but was not
  executed, and why (no safe test environment, would disrupt a live user,
  environment couldn't be replicated, etc.)

Never blend these into one undifferentiated "done." A person reading the
report needs to know at a glance which claims to fully trust and which are
still open.

## Specific traps to watch for
- **The "should work" report.** Code that reads correctly can still fail at
  runtime for reasons invisible on a read-through — a stray character a
  command interpreter misreads, a wrong working directory, a silently-caught
  exception, a dependency that resolves differently at runtime than assumed.
  If it hasn't run, it hasn't been proven — no matter how confident the read
  felt.
- **The stale "already fixed" claim.** A previous commit or an earlier
  session's report claiming something is resolved is a starting hypothesis,
  not a fact. Confirm it against the actual current state (the live server,
  the live file, a real run) before repeating it in a new report.
- **The "deployed" claim without checking the actual target.** "Pushed"
  means it left the local machine. "Deployed" means it is genuinely running
  on the real target right now. Confirm the live target's actual state (its
  real git HEAD, its actual running process) — don't infer deployment from
  a successful local push or an earlier assumption.
- **The happy-path-only test.** Running the success case once is not the
  same as testing the failure case, the edge case, or the specific scenario
  a real user actually hit. If a real user reported a specific symptom,
  reproduce that exact symptom as closely as possible — don't settle for a
  nearby, easier-to-run scenario and call it equivalent.
- **Skipping the branch that's inconvenient to test.** If a code path is
  hard to test (needs a machine with no Python, needs a fresh clean install,
  needs a live streaming session), that difficulty is not a reason to skip
  it — it's usually a sign that path is exactly the one that's never been
  exercised for real and most likely to hide a bug. Find a safe way to
  simulate it rather than skipping it.
- **The check that cannot fail.** A scan that aborts, a grep with a rejected
  pattern, a test suite that never ran — all report "clean" identically to a
  real pass. Before trusting a negative result, prove the check was live:
  check the exit code, and feed it a positive control it must catch. See
  "The check that cannot fail" below.
- **The live instrument with the wrong pattern.** A control proves the probe
  fired; it says nothing about what the probe was pointed at. A scanner
  searching for full names will pass a file that uses first names, every time,
  with its canary green. Print the target — the path, the URL, the spelling —
  and read it back. See "A control proves the instrument runs" below.

## The check that cannot fail
A negative result is only meaningful if the check was capable of returning a
positive one. "No errors found" and "the error-finder didn't run" produce
identical output — and the second one is a lie that reads exactly like the
first.

Six instances of this pattern surfaced across two days, and the split
matters. In the product:
- An installer logged "seeded" without checking whether the seeding command
  had actually succeeded.
- A script wrote its own success flag without ever capturing the return code
  of the operation the flag was describing.
- A version marker advanced even when the command that should have set it
  failed silently.

In the tooling built to catch bugs like those:
- A fix for the first item raised a NON-TERMINATING parse error on corrupt
  input, so the corrupt case exited 0, wrote an empty value, and logged
  "seeded ()" — the fix reproduced the bug it was fixing. Only executing the
  malformed case caught it; code review passed it.
- A credential scan used a regex syntax the search tool rejected outright
  (rc=128). It reported "clean" while matching nothing at all — it could not
  have found the credentials it was written to find.
- A blocklist scan printed "0 hits" while the underlying search aborted on
  every single term.

An audit has the same shape when it asks the wrong question: it can confirm
that a write-only telemetry field is HARMLESS (nothing reads it, so nulls
can't break anything) while never asking whether anything is ARRIVING in it.
Both answers are "fine." Only one of them is true. Live-signal checks are
only as good as the question asked of them.

**Prove the check can fail before trusting that it didn't.** Every time a
scan, a grep, a validator, a health check, or a test suite returns a clean
result, ask:
1. What is the exit code? Not the output — the exit code. A tool that aborts
   often prints nothing and returns non-zero, which a loop will happily
   discard.
2. Did I feed it a POSITIVE CONTROL — something it MUST catch? If a scan for
   secrets returns zero hits, plant a known string and confirm it's found.
   If a test suite passes, break something and confirm it goes red. A suite
   that passes on broken code is worse than no suite.
3. Am I checking that something is HARMLESS when I should be checking that
   it WORKS? Those are different questions with the same reassuring answer.
4. Did the thing I'm reporting on actually EXECUTE, or did I only observe
   that nothing complained? Silence is not success.

## A control proves the instrument runs. It does not prove you measured the right thing.

This is the refinement, and it is the harder half. A positive control answers
"did my probe fire?" It does not answer "was my probe pointed at the right
thing, spelled the right way, on the right machine?" A live instrument with the
wrong pattern returns the same clean zero as a live instrument with the right
one.

The proof: a credential scan passed the most sensitive file in a library every
day for a week — **with a planted canary proving the scanner was live each
time.** The scan list held people's full names. The file used their first names.
Live scanner. Wrong pattern. Clean zero. The canary was doing its job perfectly
and guarding nothing.

Five more of the same class, all from one day:

- A history rewrite removed `board-of-directors.md`; the sensitive blob survived
  as `board-of-directors-v1.1.md`, because an earlier rename had moved it. The
  check asked "is it gone?" and it was — under that name.
- An API endpoint returned a 401 error object; `len()` of its three keys read as
  "3 stars", and nearly triggered a false stop.
- A probe meant to scan a fresh clone re-scanned the local repo, because a `sed`
  silently failed on Windows backslashes and left the path hardcoded.
- A scope check read an empty string as "absent". It happened to be the right
  answer, from a broken instrument — the most dangerous kind of correct.
- Two people compared tree hashes and nearly declared a mismatch a finding. One
  had run `git ls-tree --name-only | sha256sum`, the other `git ls-tree |
  sha256sum`. Different instrument, same name, different number.

**The countermeasure: print what the probe is actually targeting.** The path, the
URL, the machine, the spelling, the exact command. Every one of those five was
caught by that and by nothing else — not by the control, which fired correctly
in most of them.

So ask, in this order:
1. Did the probe fire? (the positive control)
2. **What did it fire AT?** Print the target and read it back. Is that the thing
   you meant, spelled the way the data actually spells it, in the place the data
   actually lives?
3. Would it still have fired if the answer were the other one?

## Two anti-patterns, named literally

These are named as exact strings, not as principles, deliberately. The exit-code
principle already existed in this skill — and was violated three times in one
week, once *inside the commit that added it*. A principle did not fire at the
moment of error. A literal string might.

**Anti-pattern 1 — the exit code of the wrong command:**

```bash
python script.py; echo "---"; echo "EXIT CODE: $?"     # WRONG: $? is echo's status
```

This reports `EXIT CODE: 0` while `script.py` is dying. Capture it immediately:

```bash
python script.py; rc=$?; echo "EXIT CODE: $rc"          # correct
some_cmd | tail -5; rc=${PIPESTATUS[0]}                 # correct through a pipe
```

**Anti-pattern 2 — the leading slash on Git Bash:**

```bash
gh api /user     # WRONG on Git Bash: rewritten to C:/Program Files/Git/user
gh api user      # correct
```

MSYS path translation rewrites the leading `/` into a Windows path. The call
fails, prints nothing, and your parser reads the empty output as a finding —
"no scopes", "not present", "clean".

**What these two share is the reason they are worth naming together: both hand
back a plausible empty-or-zero result instead of crashing.** That is the whole
family. A tool that fails loudly is safe — you cannot miss it. These fail
quietly and hand you a value you have no reason to distrust. Whenever a check
returns "nothing found", "0", or an empty string, the first question is not
"what does that mean?" — it is **"did the command actually run?"**

## Applied to writing code, not just running checks
The same discipline applies when writing the code itself: any operation whose
failure is discarded (`>nul 2>&1`, a bare `except:`, an unchecked return
code, a non-terminating error mode) must not be followed by an unconditional
success log or flag. Either capture the result and branch on it, or don't
claim success.

"Write the marker, log success, discard the evidence" is a habit, not an
accident. It has appeared six times. Assume it is present wherever a status
is recorded and the operation that produced it is not checked.

## When execution genuinely isn't possible
Sometimes real execution isn't available — no safe way to test on a live
production system, no second machine to replicate a real user's exact
environment. That's a legitimate limitation, not a failure. But say so
plainly, in plain language, right next to the claim: "not verified by
execution — reasoned from code review only, because [specific reason]."
Never let an unverified claim read the same as a verified one in a report.

## External claims need external verification, not internal inference
Everything above concerns claims about THIS codebase — did it run, did it
deploy, did the scan actually fire. There is a second category this skill
failed to cover until it caused real damage: claims about the world OUTSIDE
the codebase — does this tool exist, who made it, what license does it use,
is this library real or invented. These need the same discipline, applied
differently, because the failure mode is different.

**The incident this section exists because of:** on 2026-07-23, a skill file
described a real, 85,000-star, MIT-licensed, actively maintained third-party
tool as "fictitious," and a fix for that error confidently replaced it with a
second false claim — that the tool was "Anthropic-authored... NOT a
third-party tool" — also stated as "Verified true." Neither claim had an
actual fetch or search behind it. Both were inferred from indirect,
in-session signals: a plugin name resembling something available in the
current session was treated as proof of that plugin's origin, license, and
popularity. It is not. Availability in a session proves the plugin is
installed. It proves nothing about who wrote it, under what license, or
whether the specific name in a file matches the specific thing installed.

**The rule:** before labeling anything external as fictitious, made-up,
real, verified, or resolved, there must be an actual fetch or search
performed in that session, with the result shown — the same "paste the real
output" standard as any other verified claim. If the environment cannot
reach the external source (no internet access, no search tool available),
the correct claim is "cannot verify externally from this environment" —
stated plainly, per the section above — never a confident-sounding narrative
built from what merely seems plausible or what happens to be locally
available.

**Specifically do not infer:**
- Authorship or origin, from a name being locally available or familiar
- Popularity, license, or maintenance status, from anything other than
  actually checking the source
- That something is fictitious, from simply not recognizing it — not
  recognizing a real thing and confirming a thing doesn't exist are
  different findings requiring different evidence

## Trigger this skill
- Before finalizing any report that uses the words "fixed," "resolved,"
  "deployed," "working," "verified," or "complete"
- Whenever repeating a claim made in an earlier session or an earlier task
  report, rather than treating it as already-settled
- After any holistic-code-audit, engineering-review, or comprehensive-audit
  finding is marked resolved — confirm the fix was actually run, not just
  written and read back
- Immediately after a live production incident, before writing the
  after-action summary — this is exactly when the temptation to round up
  "should be fine now" to "fixed" is highest
- Before reporting ANY clean/negative result from a scan, audit, or test —
  "found nothing" is a claim like any other and needs the same proof as
  "fixed"
- Whenever a command returns nothing, "0", or an empty string — ask whether it
  actually ran before deciding what the emptiness means
- Whenever a check passes with a green control — ask what it was pointed at,
  and whether the data spells the thing the way the check spells it
- Before labeling anything OUTSIDE the codebase — a tool, a library, a URL,
  an author, a license — as fictitious, real, made-up, or verified. This
  needs an actual fetch or search this session, not an inference from what's
  locally available or familiar-sounding

## Notes moved from the description (2026-08 — description length limit)

The description was trimmed to fit the 1,024-character cap. The reasoning it
carried, in full:

- **Prove the check could fail before trusting that it didn't.** Use an exit code
  or a positive control. A check that aborted, matched nothing, or never ran is
  indistinguishable from a genuine pass by its output alone.
- **A positive control proves the probe fired — not that it was aimed correctly.**
  It does not prove the target was spelled right, on the right machine, or the
  right path. Print the target and read it back.
- **Some tools fail silently** and return a plausible empty result rather than
  crashing. An empty result is a claim like any other.
- **Prior reports are not evidence.** If an earlier session or report claims
  something is already true with no logged execution proof attached, re-verify
  rather than repeating the claim as-is.
