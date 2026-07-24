---
name: ux-review
description: >
  Heuristic evaluation of the product's interface — the streamer-facing
  product AND the manager/scout/owner-facing tooling (CRM, admin dashboards).
  Checks whether the UI follows established UX principles: system status
  visibility, error prevention, consistency, user control, helpful error
  messages, empty states, loading feedback, and whether controls are actually
  reachable from the states a real user will be in. Also checks domain-specific
  concerns: coaching tone, progress visibility toward the revenue goal, and
  whether the interface feels encouraging vs clinical. Trigger phrases: "UX
  review", "usability review", "heuristic review", "is the UI good", "UI
  audit", "UX audit", "review the interface", "check the user experience".
last_updated: 2026-07-23
---

# UX Review

> **Communication note:** The reader may not be technical. Frame all findings
> in terms of what the end user would experience, not in technical terms.
> Every finding should answer: "what does this cost the person using it" —
> confusion, wasted time, lost trust, a coaching moment missed (streamer
> surfaces), or a task that can't actually be completed (manager/scout/owner
> surfaces).

A heuristic evaluation of the product's interface against usability
principles, adapted for the coaching platform context. Covers BOTH the
streamer-facing product and the internal manager/scout/owner tooling — a
control that works correctly but can't actually be found by the person who
needs it is exactly as broken as one that doesn't work at all. This is not a
bug hunt — it's a quality-of-experience audit.

---

## The Checks

### CHECK 1 — System Status Visibility
*Does the user always know what the system is doing?*

Walk through every async operation in the SPA:
- API calls (loading data, saving progress, generating reports)
- Cron-driven events (reports arriving, bridge connecting)
- Long-running operations (diagnostic generation, PDF creation)

For each: is there a loading indicator? Does it disappear when done? Can the
user tell the difference between "still loading" and "nothing to show"?

Flag any place where the interface goes silent while something is happening.

### CHECK 2 — Match Between System and Real World
*Does the language match how streamers actually talk?*

Read every label, heading, button, and description in the interface. Check:
- Does it use streaming/TikTok vocabulary (gifts, diamonds, PCU, gifters) or
  software vocabulary (sessions, data, records)?
- Does it use the product's coaching vocabulary (archetypes, playbook, bottleneck)
  consistently and in a way a new streamer would understand on first read?
- Are there any terms that appear without explanation that a streamer might not know?

Flag any language that sounds like a developer wrote it for another developer.

### CHECK 3 — User Control and Freedom
*Can users undo mistakes or escape bad states?*

Check for:
- Any destructive action (deleting data, submitting a form) without confirmation
- Any flow with no "back" or "cancel" option
- Any state the user can get into with no clear way out
- Whether the diagnostic can be retaken if a streamer made a mistake
- Whether check-in submissions can be reviewed or corrected

Flag any place where a streamer could feel trapped or unable to undo an action.

### CHECK 4 — Consistency and Standards
*Do similar things look and behave the same throughout?*

Check:
- Do all primary action buttons look the same?
- Do all warning messages use the same visual treatment?
- Do all section headings use the same typography style?
- Is the tone consistent (encouraging/coaching vs neutral/clinical)?
- Does the nav highlight the active section consistently?
- Are icons used consistently (same icon always means the same thing)?

Flag any inconsistency where the same type of thing looks different in different places.

### CHECK 5 — Error Prevention
*Does the interface prevent mistakes before they happen?*

Check:
- Are forms validated before submission (or only after)?
- Is the diagnostic cooldown clearly explained BEFORE a streamer tries to retake it?
- Is destructive confirmation written to actually prevent accidents?
- Are required fields clearly marked?
- Are there fields where the expected format is unclear (dates, handles, numbers)?

Flag any place where a mistake is easy to make and not clearly prevented.

### CHECK 6 — Recognition Over Recall
*Can the user see what they need, or do they have to remember it?*

Check:
- Does the playbook show the streamer's archetype prominently?
- Are the month/phase labels always visible while the streamer is working?
- Does the dashboard surface the most important number (revenue progress toward the revenue goal)?
- Are frequently-referenced things (goal, archetype, current phase) visible at a glance?

Flag any place where the streamer needs to hold context in their head that the
interface could display.

### CHECK 7 — Flexibility and Efficiency
*Can experienced users work faster?*

Check:
- Can a streamer who knows the product navigate directly to what they need?
- Are the most common actions reachable in 2 clicks or fewer from the dashboard?
- Is there anything that requires repeated manual steps that could be streamlined?

### CHECK 8 — Aesthetic and Minimalist Design
*Is anything in the interface that doesn't help the streamer?*

Check:
- Is any section cluttered with content the streamer doesn't act on?
- Are there any data points displayed that a streamer can't do anything with?
- Does the dashboard surface the signal without noise?

### CHECK 9 — Helpful Error Messages
*When things go wrong, do error messages actually help?*

Find every error message, toast notification, and warning. For each:
- Does it say what happened in plain language?
- Does it say what the user should do next?
- Is the tone supportive (coaching) rather than accusatory?

### CHECK 10 — Domain Voice: Coaching Presence
*Does the interface feel like a coaching platform or a dashboard?*

Check:
- Does the diagnostic output read like genuine coaching advice, or like a report?
- Does the playbook feel like a structured path toward a goal, or a list of tasks?
- Does the dashboard show progress toward the revenue goal as the primary story?
- Are the streamer's wins celebrated anywhere, or only logged?
- Is there anywhere the interface feels cold, impersonal, or clinical?

### CHECK 11 — Control Reachability (state-dependent hiding)
*If a control exists, can the target user actually GET to it from where
they'll realistically be, not just from where a developer tested it?*

This check exists because of a real bug: a delete button existed, worked
correctly, and was tested successfully — but it lived on a record-detail tab
that the app only auto-opens for candidates who've reached that specific
pipeline stage. For an early-stage candidate, a manager landed on a
completely different tab and had no way to discover the button was six tabs
away. The control wasn't broken. It was unreachable from the one state a
real user was actually in.

This is a different question from error prevention (Check 5) or user
control (Check 3) — those assume the user already found the control. This
check asks whether they can find it at all, from their actual starting
point, not an ideal one.

It is also the mirror image of `anticipate-user-mistakes`, and the two are
easy to conflate: Check 11 asks *can the user reach this control* (a
discoverability question); `anticipate-user-mistakes` asks *what happens
when the user misuses the control once they have it* (a robustness
question). Reach for that skill when the concern is the second one — a
found-but-dangerous control — not this one.

For every control that isn't always visible on-screen (behind a tab, a
conditional render, a state-dependent view, an auto-navigation), trace:
1. What determines which view/tab/state a user lands on by default?
2. For each realistic real-world state (not just the happy-path state used
   in testing), does that default landing point actually expose the control,
   or does it require the user to already know to navigate somewhere else?
3. If the control is genuinely important across multiple states, does it
   appear in a place that's visible regardless of state (e.g. a persistent
   header), rather than being state-gated itself?

Applies with equal weight to manager/scout/owner tooling as to the streamer
product — internal tools get tested less by real varied usage, so this kind
of gap is if anything more likely there, not less.

---

## Empty States (check all of these explicitly)

Check each of these screens for a brand-new user (no data):
- Dashboard with no streams recorded
- Playbook before diagnostic is complete
- Reports section before any reports have been generated
- Community section with no members visible
- Check-in history before first check-in submitted
- History tab before any streams (new empty chart state)
- Manager coaching flags panel when no streamers are flagged

---

## Reporting Format

**Before finalizing any finding below: grep the flagged surface for a
`REVIEWED` marker first** (see respect-settled-decisions). If one exists and
its stated scope covers what you're about to flag, cite it and treat the
matter as settled — don't re-flag it as friction, a blocker, or an
inconsistency.

Group findings by severity:
- **BLOCKER** — a UX failure that will cause a streamer to give up, lose trust,
  or make a serious mistake — or, for internal tooling, cause a manager/scout/
  owner to be unable to complete a real task (including "unable to find a
  control that exists," per Check 11)
- **FRICTION** — adds unnecessary effort or confusion but doesn't stop the
  user from completing their goal
- **POLISH** — a small improvement that would make the experience feel more
  professional or intentional

End with a **Top 3 Priorities** — the three changes that would most improve
the experience if fixed first.
