---
name: diagnose
description: "Disciplined diagnosis loop for hard bugs and performance problems. Follows a strict sequence: build a feedback loop, reproduce, hypothesise, instrument, fix, regression-test. Use when user says 'diagnose this', 'debug this', reports a bug, says something is broken or failing, or describes unexpected behaviour or slow performance."
metadata:
  tier: machine
  plugin: skill-engineering
---

# Diagnose

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Use analogies and plain language throughout.

A discipline for hard bugs. Skip phases only when explicitly justified.

---

## Phase 1 — Build a feedback loop

This is the most important phase. The goal is to find a reliable, repeatable way to make the bug appear on demand — like a fire drill that actually starts a fire. Without this, debugging is just guesswork.

Try these approaches in order:

1. Write a test that fails because of the bug.
2. Write a short script or command that triggers the wrong behaviour and shows it.
3. Strip away everything until you have the smallest possible version of the problem.
4. Save a real example that causes the bug and replay it in isolation.
5. Build a stripped-down version of just the part that's broken.
6. If the bug only happens sometimes, run it many times and look for the pattern.

Once you have a reliable way to trigger the bug, you're 90% of the way to fixing it.

Make the trigger better: can you make it faster? Can you make it more consistent? Can you make it show exactly what's wrong rather than just "it crashed"?

If you genuinely cannot find a reliable trigger, stop and say so. List what you tried. Ask the user for logs, error output, or permission to add temporary tracing. Do not move to Phase 2 without a reliable trigger.

---

## Phase 2 — Reproduce

Use the trigger from Phase 1. Watch the bug happen.

Confirm:
- This is the bug the **user** described — not a different nearby problem. Wrong bug = wrong fix.
- It happens consistently enough to work with.
- The exact symptom is captured so you can verify later that the fix actually worked.

---

## Phase 3 — Form theories

Before testing anything, come up with 3–5 possible causes, ranked by likelihood. Testing one theory at a time is far faster than randomly poking around.

For each theory, state it as a prediction: "If X is the cause, then doing Y will make the bug disappear" (or get worse). If you can't state the prediction, the theory isn't solid enough yet.

Show the ranked list to the user before testing — they often know something that immediately rules one out or moves another to the top.

---

## Phase 4 — Test theories

Test one theory at a time. Add targeted logging or tracing only where needed to confirm or rule out each theory.

Tag any temporary logging you add with a unique label like `[DEBUG-a4f2]` so it's easy to find and remove later.

For slowness problems: measure first, then fix. Don't guess what's slow.

---

## Phase 5 — Fix and lock it in

If possible, write a test that fails because of the bug *before* applying the fix. Then fix it, watch the test pass, and re-run your original trigger to confirm the bug is gone.

If there's no clean way to write a test for this bug, note that — it means the code structure made this bug hard to catch, which is worth flagging.

---

## Phase 6 — Clean up and reflect

Before calling it done:
- Confirm the original trigger no longer shows the bug
- Remove all temporary logging (`[DEBUG-...]` tags make this easy)
- Delete any throwaway files created during diagnosis

Then ask: **what would have prevented this bug?** The answer points to which skill to run next:

- "The code was too tangled to test in isolation" → run **improve-codebase-architecture** to find and fix the structural problem that made this bug hard to catch.
- "The user journey had a step that silently lost data, or two parts of the app didn't share information correctly" → run **flow-test** (especially Phase 0, the integration seam check) to find other gaps in the same flow.
- "The bug would have been caught by a thorough pre-release review" → run **holistic-code-audit** across the affected files to check all 9 disciplines and catch any similar issues that haven't surfaced yet.

One bug is rarely alone. Finishing the fix is the right time to look for its siblings.
