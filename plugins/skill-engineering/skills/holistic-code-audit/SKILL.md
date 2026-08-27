---
name: holistic-code-audit
description: >
  Run a multi-discipline code audit covering logic, failure modes, security, race
  conditions, edge cases, integration seams, state consistency, environment, and
  placeholder provenance.
  Use immediately when the user asks for a "code review", "audit", "check my code",
  "review the code", "code audit", or "debugging session" — and also after making
  fixes, to verify no new issues were introduced. Run before pushing any significant
  change. This is the most comprehensive in-chat audit skill — if in doubt, run it.
  For a deeper Claude Code audit via task.md, use engineering-review instead.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Holistic Code Audit Skill

## When to use this skill
Use whenever the user asks for a **code review**, **audit**, **debugging session**,
or **"check my code"** — including after making fixes, to verify no new issues
were introduced.

For a full 8-check bug hunt via Claude Code (deeper, longer), use engineering-review.
This skill runs the audit here in chat. Both are complementary — run this first,
then engineering-review for deeper checks.

## Core principle
Read every file **completely** before writing a single finding. Never read in
fragments. Never audit while fixing. Audit first, fix second.

---

## The 9 Audit Disciplines

Run all of them on every audit. Don't skip disciplines because the codebase "looks fine."

### 1. Logic Audit
Does the code do what it's supposed to?
- Trace every feature's happy path end-to-end
- Check that function outputs match what callers expect
- Verify all branches (if/else, try/except) produce the right result
- Look for dead code, duplicate functions, and operations that silently overwrite each other

### 2. Failure-Mode Audit
What happens when things go wrong?
- For every API call / network request: what happens if it returns an error? What does the user see?
- For every async operation: what happens if it times out or throws?
- For every form submit: what happens if the server is down?
- Check for silent failures — code that catches errors and does nothing
- Check that loading/saving states are always reset, even on failure
- Ask: can the UI get permanently stuck in a loading state?

### 3. Security Audit
Can the system be abused?
- **Auth bypass**: are there routes that should require auth but don't?
- **Privilege escalation**: can a streamer call manager-only endpoints?
- **Input injection**: is user-supplied content safely escaped before being inserted into HTML, SQL, or JavaScript?
- **Token handling**: do deactivated/removed users' tokens still grant access?
- **Credential storage**: are passwords properly salted and hashed? Are API keys in version-controlled files?
- **Data exposure**: do API responses return more data than the caller should see?

### 4. Race Condition Audit
What happens when two things run at the same time?
- Can two simultaneous saves corrupt state?
- Can a timer fire after logout and make authenticated calls?
- Are shared in-memory data structures (dicts, lists) accessed safely from multiple threads?
- Can a user trigger the same action twice before the first completes?

### 5. Edge Case Audit
What happens with unusual input?
- Empty strings, null/None, zero, negative numbers
- Very long inputs (names, messages, file uploads)
- Special characters in names: spaces, apostrophes, @-signs, slashes
- Dates in the past, dates in the future, missing dates
- Files with unexpected formats or missing expected columns
- First-time use (empty database, no data yet)

### 6. Integration Audit
Do the pieces actually agree with each other?

**Field-level matching:**
- Do the field names the frontend sends match what the server expects?
- Do the field names the server returns match what the frontend reads?
- Are there hardcoded strings in one file that must match a value in another?
- Do CLI flags, cron commands, and documentation all reference the same names?
- When two systems write to the same data store, do they use the same key/format?

**Cross-component data flow (the integration seam check):**
This exact technique — tracing where user input lives and whether the next
component actually reads it — is covered in full detail by flow-test's Phase 0
("Map data handoffs"). Rather than duplicate that content here (this skill
once did, and the two copies risked drifting apart if only one was ever
updated), this discipline points there directly: **for any audit where
this specific check matters, run flow-test's Phase 0 alongside this
discipline, or in follow-up.** The short version, for a quick in-chat pass
without switching skills: for every meaningful piece of user input, trace
where it's stored and whether every component that logically needs it
actually reads from that source rather than a silent default. If in doubt
or if this needs real depth, use flow-test.

**Why this matters:** Components each work correctly in isolation. The bugs live in the
connections. A user can complete every visible step successfully while their data
silently fails to travel between sections.

### 7. State Consistency Audit
Can the app get into an impossible state?
- Is there any state the user could reach that has no valid recovery path?
- Can a flow be interrupted halfway through, leaving data half-saved?
- Does logout/reset clean up ALL state — including timers, intervals, and loading flags?
- Can features rely on state that hasn't loaded yet?
- Are new state variables always added to both the initial state object AND the logout reset?

### 8. Environment Audit
Will this work in production?
- Are all required environment variables documented and validated at startup?
- Are file paths relative (portable) rather than hardcoded absolute paths?
- Are dependency version pins tight enough to prevent surprise breakage on update?
- Does documentation (setup guides, CLI help text) match what the code actually does?
- Are there references to old domains, old file names, or deprecated features?

### 9. Placeholder Provenance Audit
Every hardcoded "approximation" outlives the person who understood it.
- Find hardcoded values presented as data: literals returned by an endpoint or
  rendered by UI with words like "approximation", "placeholder", "derived",
  "estimate", "TODO: real", or a suspiciously round composition (62/26/12
  summing to 100). Grep for those words near literals; also scan API handlers
  returning inline constant objects.
- For each: does a DURABLE design note exist — a doc, a decision record, a
  linked issue — saying what it represents, where the number came from, and
  what "real" would look like? An inline comment saying "derived approximation"
  with no derivation is the finding, not the answer: months later, git blame
  gives a commit that just says the same three words, and nobody can
  reconstruct whether the value was ever real.
- The finding is NOT "replace the placeholder" (that's a product decision).
  The finding is "the intent is not durably documented anywhere a future
  session could find it" — flag it, name the missing note, and move on.
- Highest severity variant: the placeholder renders PER-ENTITY as if it were
  that entity's real data (every entity shows the same number). That is a
  silent-failure/state-consistency issue too — cross-file it with disciplines
  2 and 7.

---

## How to present findings

**Before finalizing any finding below: grep the flagged surface for a
`REVIEWED` marker first** (see respect-settled-decisions). If one exists and
its stated scope covers what you're about to flag, cite it and treat the
matter as settled — don't re-open a deliberate, reviewed decision.

**Group by severity**, not by discipline:

| Severity | When to use |
|----------|-------------|
| 🔴 Critical | Will crash, corrupt data, or completely break a feature right now |
| 🟠 High | Broken or missing behaviour that affects real users |
| 🟡 Security | Any security vulnerability, regardless of likelihood |
| 🟡 Medium | Missing behaviour, logic gaps, edge cases that will eventually bite |
| ⚪ Low | Housekeeping, documentation, cosmetic issues |

For each finding, state:
1. Which discipline caught it
2. Which file and approximate location
3. What the bug is in plain English
4. What the impact is (who gets hurt, how)
5. The suggested fix (one sentence)

---

## After the audit

Once all findings are presented, ask: **"Which of these should we fix right now?"**

Fix 🔴 Critical findings first. Do not proceed with new features until they are
resolved.

For any bug where the answer to "what would have prevented this?" is "the code was too
tangled to test properly," flag it for improve-codebase-architecture.

For a deeper automated check via Claude Code covering database associations, undefined
variables, auth gaps, and route verification, follow up with engineering-review.

## Why discipline 6 points at flow-test instead of repeating it

The "Cross-component data flow" check and flow-test's Phase 0 ("Map data
handoffs") independently grew into near-identical copies of the same
technique, described twice in two skill files with no connection between
them — so either could be updated while the other silently drifted.
flow-test is the canonical source for that technique. Keep the short
summary here so a quick in-chat pass doesn't require switching skills, and
do not let the long version grow back.
