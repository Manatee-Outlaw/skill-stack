---
name: flow-test
description: >
  Walk through complete user journeys in a software product to find where flows
  silently fail, dead-end, show wrong state, or leave users stuck. Includes an
  integration seam check — mapping where data flows between components before
  tracing individual journeys, to catch cross-component bugs journey tracing
  alone misses. Use to test a feature end-to-end, verify an onboarding flow,
  check that data appears where it should, or confirm UI paths lead to correct
  outcomes. Also covers reading the real artifact a flow delivers — a report,
  PDF, email or export — as the recipient reads it, because a document that ends
  mid-sentence or leaks internal reasoning is invisible to code review and to
  "it generated without an error". Run before releasing a feature, after a
  significant codebase change, or when a user reports unexpected behaviour.
  Trigger phrases: "test this flow", "walk through the user journey", "check
  this end-to-end", "flow test", "check the actual report", "read a real
  output", "is the PDF right".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Flow Test

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Think of this skill like a mystery shopper exercise — you're walking through the product as a real user would, checking at every step whether what they see matches what should actually be happening behind the scenes.

Every flow test starts from the user's perspective — not the developer's. The goal is to find the places where a user tries to do something reasonable and either gets stuck, sees wrong information, or is silently failed without knowing it.

---

## Key ideas (explained plainly)

- **Flow** — a sequence of steps a user takes to accomplish one goal (e.g., "user signs up → completes onboarding → sees their dashboard"). A flow has a clear start, a clear end, and steps in between.
- **Precondition** — what has to be true before a step can happen (e.g., "user must be logged in"). If the precondition isn't met, the step will fail — sometimes visibly, sometimes silently.
- **Happy path** — the sequence of steps that works perfectly when everything goes right. This is the path developers test. It is not the path real users take.
- **Edge case** — an unusual but realistic situation that falls outside the happy path (e.g., user with no onboarding data tries to access the dashboard; user submits a form twice; user returns after 30 days).
- **Silent failure** — a bug that doesn't show an error message. The user thinks something worked, but it didn't. These are the most dangerous bugs because users don't report them.
- **Dead end** — a place in the flow where a user has nowhere obvious to go next, even though the task isn't finished.
- **State mismatch** — when what the user sees doesn't match what is actually stored (e.g., the dashboard says "check-in submitted" but the database has no record).
- **Integration seam** — a handoff point where one section of the app passes data to another section. Bugs at seams are invisible during individual component testing because each piece works correctly in isolation — the failure only appears at the join.
- **In-memory state** — data stored only in the app's working memory. It disappears when the page is refreshed or the user logs out. If a user's input is only in-memory, anything that interrupts the session — a refresh, a crash, navigating away — silently loses it.

---

## Process

### Phase 0 — Map data handoffs (integration seam check)

**Run this before tracing any individual journeys.** This phase catches the class of bugs that journey tracing alone misses: data that a user enters in one section but another section silently fails to use.

**Step 1: List all major sections of the app.**
Name each distinct area a user can be in (e.g., onboarding, dashboard, reports, settings). Don't trace flows yet — just name the sections.

**Step 2: For every meaningful piece of user input, trace its full journey.**
For every piece of data a user enters (an answer, a preference, a setting), ask:
- Where is it stored? (In-memory state only? Browser storage? Server database?)
- Which other sections need it?
- Does each section that needs it actually READ it from where it was stored — or does it use its own default state?

If any section that logically needs a piece of data doesn't explicitly reference the data source in the code, flag it as a risk before even running the flow test.

**Step 3: For each major section transition, ask the handoff question.**
When a user moves from section A to section B, what state from A does B need? Verify that B reads it. A section that uses its own default initial state when it should be reading data from the previous step is a silent failure waiting to happen.

**Why this matters:** Components each work correctly in isolation. The bugs live in the connections. A user can complete every visible step successfully while their data silently fails to travel between sections. This step catches that before any journey tracing begins.

Flag any seam where data is needed but not flowing as a finding before moving to Phase 1.

---

### Phase 1 — Trace individual journeys

For each flow being tested, walk through it step by step:

1. **State the preconditions** — what must be true for this flow to start? Is that state achievable?
2. **Walk the happy path** — follow the normal route and verify each step works correctly.
3. **Check each step for:**
   - Does the UI show the right information at this point?
   - Is the right data being written to the database?
   - Are there any loading states that could freeze?
   - Are there any error states that aren't handled?
4. **Test the edge cases** — what happens if the user:
   - Refreshes the page mid-flow?
   - Submits the same form twice?
   - Has no data yet (first time use)?
   - Has incomplete data from a previous session?

---

### Phase 2 — Check for silent failures

For each flow, ask:
- Is there any step where the user could think something worked when it didn't?
- Is there any step where an error is caught and swallowed without telling the user?
- Is there any step where partial success (some data saved, some not) could leave the system in an inconsistent state?
- Is there any step where the UI state and the database state could diverge?

---

### Phase 3 — Read the actual thing the user receives

If a flow ends in something a person is handed — a generated report, an exported PDF, an email, an overlay, a downloaded file — **open a real one and read it.** Not the template. Not the code that builds it. Not a fresh test render made for the audit. A real, recent artifact that a real user was actually sent.

Read it the way the recipient reads it, start to finish, and ask:
- Does it end where it's supposed to end, or does it just stop mid-sentence?
- Are all the parts there? If it promises five sections, count five.
- Is anything in it the recipient should never see — internal notes, debug output, placeholder text, raw error messages, the system's own reasoning?
- Does it actually say something useful, or is it shaped correctly and empty?

**"It generated without an error" is not "it is correct."** Reading the code that produces a document cannot tell you the document ends mid-sentence, or that it delivered half of what it promised. Those are only visible in the artifact itself. A person reading two real outputs for ten minutes will find things a full code audit will not.

---

## Output format

For each issue found:
1. **Flow name** — which user journey this appears in
2. **Step** — where in the flow this occurs
3. **What the user experiences** — plain English, from the user's perspective
4. **What's actually happening** — the technical cause, in plain English
5. **Severity:**
   - SILENT FAILURE — user thinks it worked, data is wrong or missing
   - DEAD END — user is stuck with no obvious path forward
   - STATE MISMATCH — what they see doesn't match what's stored
   - FRICTION — works but confusing or slow
6. **Suggested fix** — one sentence, direction only

End with: **Integration Seam Summary** — which seams are clean, which have gaps.

---

## Hard Rules

- Always run Phase 0 (seam check) before any journey tracing
- Never skip Phase 2 (silent failures) — these are the ones users don't report
- If the flow hands the user an artifact, run Phase 3 on a real recent one — never rate an output by whether the generator exited cleanly
- Frame every finding from the user's perspective, not the developer's
- After fixes: re-run the affected flows to confirm they're resolved
