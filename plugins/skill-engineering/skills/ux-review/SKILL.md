---
name: ux-review
description: >
  Heuristic evaluation of the product's interface — the end-user-facing
  product AND the internal operator/staff/owner-facing tooling (CRM, admin
  dashboards). Checks whether the UI follows established UX principles: system
  status visibility, error prevention, consistency, user control, helpful
  error messages, empty states, loading feedback, and whether controls are
  actually reachable from the states a real user will be in. Also checks
  domain-specific concerns: whether the product's voice matches its promise,
  progress visibility toward the user's main goal, and whether the interface
  feels encouraging vs clinical. Trigger phrases: "UX review", "usability
  review", "heuristic review", "is the UI good", "UI audit", "UX audit",
  "review the interface", "check the user experience".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# UX Review

> **Communication note:** The reader may not be technical. Frame all findings
> in terms of what the end user would experience, not in technical terms.
> Every finding should answer: "what does this cost the person using it" —
> confusion, wasted time, lost trust, a key product moment missed (end-user
> surfaces), or a task that can't actually be completed (internal operator/
> staff/owner surfaces).

A heuristic evaluation of the product's interface against usability
principles, adapted for the product's own domain. Covers BOTH the
end-user-facing product and the internal operator/staff/owner tooling — a
control that works correctly but can't actually be found by the person who
needs it is exactly as broken as one that doesn't work at all. This is not a
bug hunt — it's a quality-of-experience audit.

**First step — identify the product's 2–4 most frequent flows on this
surface and weight the review toward them.** Every check below applies
everywhere, but the flows users repeat most often are where friction costs
the most. Name them before starting, and come back to them in each check.

> **Example — a creator-coaching app:** the most frequent flows were the
> post-session check-in, taking (and retaking) the diagnostic questionnaire,
> reading the weekly coaching report, and glancing at progress toward the
> user's revenue goal. The domain vocabulary was the platform's own (gifts,
> diamonds, peak concurrent viewers, gifters) plus the product's coaching
> terms (archetypes, playbook, bottleneck). The examples in the checks below
> are drawn from that app; substitute your product's equivalents.

---

## The Checks

### CHECK 1 — System Status Visibility
*Does the user always know what the system is doing?*

Walk through every async operation in the front end:
- API calls (loading data, saving progress, generating reports)
- Scheduled/background events (reports arriving, an integration connecting)
- Long-running operations (generating an analysis, PDF creation)

For each: is there a loading indicator? Does it disappear when done? Can the
user tell the difference between "still loading" and "nothing to show"?

Flag any place where the interface goes silent while something is happening.

### CHECK 2 — Match Between System and Real World
*Does the language match how the product's users actually talk?*

Read every label, heading, button, and description in the interface. Check:
- Does it use the users' own domain vocabulary or software vocabulary
  (sessions, data, records)? *(Example — creator-coaching app: gifts,
  diamonds, peak viewers, gifters, rather than "records".)*
- Does it use the product's own specialist vocabulary consistently and in a
  way a new user would understand on first read? *(Example: archetypes,
  playbook, bottleneck.)*
- Are there any terms that appear without explanation that a user might not know?

Flag any language that sounds like a developer wrote it for another developer.

### CHECK 3 — User Control and Freedom
*Can users undo mistakes or escape bad states?*

Check for:
- Any destructive action (deleting data, submitting a form) without confirmation
- Any flow with no "back" or "cancel" option
- Any state the user can get into with no clear way out
- Whether a one-shot or rate-limited flow (a questionnaire, an assessment,
  an application) can be retaken if the user made a mistake *(example: the
  diagnostic)*
- Whether recurring submissions can be reviewed or corrected *(example:
  check-ins)*

Flag any place where a user could feel trapped or unable to undo an action.

### CHECK 4 — Consistency and Standards
*Do similar things look and behave the same throughout?*

Check:
- Do all primary action buttons look the same?
- Do all warning messages use the same visual treatment?
- Do all section headings use the same typography style?
- Is the tone consistent (encouraging/supportive vs neutral/clinical)?
- Does the nav highlight the active section consistently?
- Are icons used consistently (same icon always means the same thing)?

Flag any inconsistency where the same type of thing looks different in different places.

### CHECK 5 — Error Prevention
*Does the interface prevent mistakes before they happen?*

Check:
- Are forms validated before submission (or only after)?
- Is any cooldown, limit, or lockout clearly explained BEFORE a user runs
  into it? *(Example: the diagnostic retake cooldown.)*
- Is destructive confirmation written to actually prevent accidents?
- Are required fields clearly marked?
- Are there fields where the expected format is unclear (dates, handles, numbers)?

Flag any place where a mistake is easy to make and not clearly prevented.

### CHECK 6 — Recognition Over Recall
*Can the user see what they need, or do they have to remember it?*

Check:
- Does each screen show the user's key personal context prominently?
  *(Example: the playbook showing the user's archetype.)*
- Are the current stage/period labels always visible while the user is working?
  *(Example: month/phase labels.)*
- Does the dashboard surface the most important number — progress toward the
  user's main goal? *(Example: revenue progress toward the revenue goal.)*
- Are frequently-referenced things (goal, profile/type, current stage)
  visible at a glance?

Flag any place where the user needs to hold context in their head that the
interface could display.

### CHECK 7 — Flexibility and Efficiency
*Can experienced users work faster?*

Check:
- Can a user who knows the product navigate directly to what they need?
- Are the most common actions reachable in 2 clicks or fewer from the dashboard?
- Is there anything that requires repeated manual steps that could be streamlined?

### CHECK 8 — Aesthetic and Minimalist Design
*Is anything in the interface that doesn't help the user?*

Check:
- Is any section cluttered with content the user doesn't act on?
- Are there any data points displayed that a user can't do anything with?
- Does the dashboard surface the signal without noise?

### CHECK 9 — Helpful Error Messages
*When things go wrong, do error messages actually help?*

Find every error message, toast notification, and warning. For each:
- Does it say what happened in plain language?
- Does it say what the user should do next?
- Is the tone supportive rather than accusatory?

### CHECK 10 — Domain Voice: Product Presence
*Does the interface feel like the product it promises to be, or like a
generic dashboard?*

Name the product's promise first (a coach, a guide, a trusted advisor, a
fast tool) and check the interface against it:
- Does the product's main generated output read like what was promised, or
  like a generic report? *(Example: does the diagnostic output read like
  genuine coaching advice?)*
- Does the core guided content feel like a structured path toward a goal, or
  a list of tasks? *(Example: the playbook.)*
- Does the dashboard show progress toward the user's main goal as the primary
  story? *(Example: the revenue goal.)*
- Are the user's wins celebrated anywhere, or only logged?
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

Applies with equal weight to internal operator/staff/owner tooling as to the
end-user product — internal tools get tested less by real varied usage, so
this kind of gap is if anything more likely there, not less.

---

## Empty States (check all of these explicitly)

Check every screen for a brand-new user (no data). Enumerate the product's
own list — at minimum: the dashboard before any activity, each feature that
depends on an earlier step before that step is done, each history or report
list before its first entry, each chart with no data points, any community
or social view with no other members visible, and each internal-tooling
panel when there is nothing to act on.

> **Example — a creator-coaching app's list:**
> - Dashboard with no streams recorded
> - Playbook before diagnostic is complete
> - Reports section before any reports have been generated
> - Community section with no members visible
> - Check-in history before first check-in submitted
> - History tab before any streams (new empty chart state)
> - Manager coaching flags panel when no users are flagged

---

## Reporting Format

**evidence:** every finding carries one, in plain English — what you actually
opened, tapped, or walked through. "Opened the settings form, tapped save, no
spinner until the response returned" is evidence; it is the difference between
having looked and having assumed. Not a technical trace, and it does not change
how the finding itself is worded. A finding with an empty evidence line is a
hypothesis.

An absence — "no loading indicator anywhere", "no way back from this screen",
"no empty state" — has nothing to point at, so its evidence is the list of
screens and states you actually walked. An unchecked "looks fine" reads
identically to a real one.

**Before finalizing any finding below: grep the flagged surface for a
`REVIEWED` marker first** (see respect-settled-decisions). If one exists and
its stated scope covers what you're about to flag, cite it and treat the
matter as settled — don't re-flag it as friction, a blocker, or an
inconsistency.

Group findings by severity:
- **BLOCKER** — a UX failure that will cause an end user to give up, lose
  trust, or make a serious mistake — or, for internal tooling, cause an
  operator/staff member/owner to be unable to complete a real task
  (including "unable to find a control that exists," per Check 11)
- **FRICTION** — adds unnecessary effort or confusion but doesn't stop the
  user from completing their goal
- **POLISH** — a small improvement that would make the experience feel more
  professional or intentional

End with a **Top 3 Priorities** — the three changes that would most improve
the experience if fixed first.
