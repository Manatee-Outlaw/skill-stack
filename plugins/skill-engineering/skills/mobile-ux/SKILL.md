---
name: mobile-ux
description: >
  Reviews the product's interface specifically for mobile use. Many users are
  on their phones for the product's most frequent, time-pressed moments —
  glancing at a dashboard, reading a report, submitting a quick update. This
  skill checks touch targets, text readability, navigation on small screens,
  scroll behaviour, and the specific mobile flows users actually rely on.
  Trigger phrases: "mobile review", "mobile UX", "check mobile", "how does
  this look on mobile", "mobile experience", "phone experience", "test on
  mobile".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Mobile UX Review

> **Communication note:** The reader may not be technical. Every
> finding should be framed around what the user experiences on their phone,
> not technical specifications. "A user with large thumbs can't hit this
> button reliably" is more useful than "touch target below 44px."

For many products, users live on their phones. They check the dashboard in
the gaps of their day. They read reports while commuting. They submit quick
updates from wherever they are. The desktop experience is the test
environment — the mobile experience is often where the product actually
gets used.

---

## Context: How Users Use the App on Mobile

Before reviewing anything, understand the mobile use cases. **Identify the
product's 2–4 most frequent flows on this surface and weight the review
toward them** — sort the product's flows into:
- **Time-pressed, frequent:** the quick actions users do right before or
  right after their core activity — these are where mobile matters most
- **On the go:** reading longer content (reports, results, history)
- **Rare on mobile:** admin/manager views, bulk exports, integration
  settings, and anything that only runs on a desktop host (`<host-app>`)

The review should weight the time-pressed, frequent flows most heavily.

> **Example — a creator-coaching app:**
> - **Pre-stream:** checking current goals, reviewing playbook tasks for tonight
> - **Post-stream:** submitting a check-in, quickly seeing if revenue updated
> - **On the go:** reading weekly/monthly reports, checking the diagnostic
> - **Rare on mobile:** the manager view, bulk export data, chat-integration
>   settings, the live overlay (`<host-app>` only — desktop)
>
> The pre/post-session flows were weighted most heavily.

---

## The 8 Mobile Checks

### CHECK 1 — Touch Target Size
*Can a user tap everything reliably with their thumb?*

The minimum reliable touch target is 44×44 pixels. Anything smaller causes
mis-taps — especially when used quickly, in a hurry, or one-handed.

Scan the frontend code for:
- Small buttons (look for a small-button class such as `btn-sm` — are these
  used for primary actions?)
- Icon-only buttons (the icon itself must be 44px, not the text it represents)
- Items in lists or tables (user rows, report cards) — are the tap targets
  the full row or just a small chip?
- Nav tab buttons — are these wide enough to tap confidently?

Flag any primary action button that appears to be below the 44px threshold.

### CHECK 2 — Typography and Readability
*Can a user read everything without zooming?*

Check the font sizes used in the frontend CSS variables:
- Body text should be at minimum 14px (16px preferred)
- Secondary/label text (`sm` class) — what size is this? Below 12px on mobile
  is unreadable
- Long-form generated text (results, analysis, advice) — is it readable at
  mobile width? *(Example: the diagnostic's coaching copy.)*
- Report cards — are numbers and key metrics large enough to read at a glance?

Also check: does the layout allow iOS/Android browsers to auto-zoom into text
fields when they're tapped? (This happens when font size is below 16px in
inputs — it's disorienting.)

### CHECK 3 — Navigation on Small Screens
*Can a user navigate the app comfortably on a phone?*

Check the nav bar:
- Enumerate the app's top-level tabs — on a 375px screen, do they all fit?
- Do any tab labels get truncated?
- Is the active tab clearly distinguishable from inactive ones at small size?
- Is there a horizontal scroll on the nav that a user might not discover?

Check any nested sub-navigation:
- Where a top-level tab has its own sub-tabs, enumerate them — do these work
  on mobile?

### CHECK 4 — Scroll Behaviour
*Does everything scroll correctly without trapping or losing the user?*

Check:
- Are there any fixed/sticky elements that eat into the usable screen space
  on mobile? (The nav bar being fixed at top reduces visible content)
- Are there any modal dialogs or overlays — do they scroll correctly on mobile?
  (Multi-step questionnaire flows, destructive-confirmation modals —
  *example: the diagnostic flow, the hard-delete confirmation modal*)
- Are there any tables or wide content areas that overflow horizontally
  without proper handling? (User rosters, bulk export data tables)
- Does the most frequent form work on mobile? (Text areas, dropdowns —
  *example: the check-in form*)

### CHECK 5 — The Core Mobile Flows
*Do the highest-priority mobile flows work end-to-end?*

Take the 2–4 most frequent flows identified in the Context section. For
each, write out its steps from "open app on phone" to the confirmation or
the end of the content, then walk it in the code:
- **Write flows (submitting something):** flag any step that has a small
  touch target, unclear input, or confusing state.
- **Read flows (consuming long content):** check that the content is
  readable at mobile width — do long sections collapse or require
  horizontal scrolling? Does the text reflow without awkward line breaks or
  overflow?

> **Example — a creator-coaching app:**
>
> **Flow A — Post-stream check-in (most frequent mobile action):**
> 1. Open app on phone
> 2. Navigate to check-in
> 3. Fill in streams, revenue, priority action, blocking note
> 4. Submit
> 5. See confirmation
>
> Walk through this flow in the code. Flag any step that has a small touch
> target, unclear input, or confusing state.
>
> **Flow B — Reading a weekly report (regular mobile use):**
> 1. Open app on phone
> 2. Navigate to dashboard or reports
> 3. Find and open latest weekly report
> 4. Read the full coaching content
>
> Check: is the report readable at mobile width? Do long sections collapse or
> require horizontal scrolling?
>
> **Flow C — Checking the diagnostic result (occasional):**
> 1. Open app on phone
> 2. Navigate to Diagnose tab
> 3. Read the full diagnostic output
>
> Check: does the diagnostic output reflow for mobile? Can a user read the
> full coaching narrative without awkward line breaks or overflow?

### CHECK 6 — Forms on Mobile
*Do inputs work well with a mobile keyboard?*

Find every form in the app (recurring updates, questionnaires, settings,
onboarding intake — *example: check-in, diagnostic questionnaire*). Check:
- Do number inputs use `type="number"` or `inputmode="numeric"` to trigger
  the number keyboard?
- Do text areas for long-form input resize correctly as the user types on mobile?
- When the keyboard appears, does it cover important UI (submit button, field labels)?
- Are placeholder texts large enough to read before the user taps into a field?

### CHECK 7 — Performance on Mobile Networks
*Does the app feel fast enough on a phone connection?*

Look for:
- Are there any large assets (images, PDFs) loaded inline that would be slow
  on mobile data?
- Are API calls made one at a time (waterfall) that could be parallelized?
- Is the main frontend bundle (`<frontend-file>`) unusually large?
  Check its file size — above 500KB is worth flagging for mobile.
- Are reports and PDFs loaded lazily (only when requested) or eagerly?

### CHECK 8 — Offline / Connection Loss Handling
*What happens when a user loses connection mid-action?*

Mobile users are often in places with variable connectivity. Check:
- If the connection drops while submitting a form, does the form data get
  lost or does the UI hold it?
- Is there any feedback when an API call fails due to network loss?
- Does the front end give any indication if the connection is lost and data
  isn't saving?

---

## Reporting Format

**evidence:** every finding carries one, in plain English — what you actually
opened, tapped, or walked through. "Opened the settings form, tapped save, no
spinner until the response returned" is evidence; it is the difference between
having looked and having assumed. Not a technical trace, and it does not change
how the finding itself is worded. A finding with an empty evidence line is a
hypothesis.

**An absence needs a negative check.** "This flow works fine on mobile" or "no
small touch targets" cannot point at a broken screen, so say where you looked and
how far — which screens, at what width, which flows you actually walked.

For each finding, include:
- **Screen / Flow:** where this occurs
- **The problem:** what the user experiences on mobile
- **Severity:** Critical (breaks the flow), Friction (makes it harder), Polish
- **Suggested fix:** what change would address it

End with a **Mobile Readiness Score** — a plain-English summary:
- Which flows work well on mobile today?
- Which flows are usable but uncomfortable?
- Which flows need real work before a mobile-primary user could rely on them?
