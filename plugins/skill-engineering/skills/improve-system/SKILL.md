---
name: improve-system
trigger: /improve-system
description: >
  Reviews the current session and updates the skill library to reflect what happened.
  Edits skill files in place when their output was iterated or corrected, and records
  durable lessons, corrections and preferences to the Notion Lesson Log so a future
  session inherits them. Flags stale or duplicated content. Run at the end of any session
  where something meaningful was built, iterated, or learned. Trigger phrases:
  "/improve-system", "improve the system", "what did we learn", "save that lesson",
  "update the skills with this".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Improve System

Runs a structured review of the current session and makes targeted updates in two places:

- **Skills** — in the git repo, edited IN PLACE.
- **Lessons** — in the Notion **Lesson Log**, one page per lesson, edited in place.

Run it at the end of any session where something meaningful was built, iterated, or learned.

---

## When to run

Run at the end of a session when any of the following happened:
- A skill's output was critiqued, refined, or significantly changed
- The user shared a story, lesson, decision, or experience worth preserving
- A new skill, file, or folder was created
- The system structure changed
- The user revealed a new preference, working pattern, or constraint about how they operate

---

## Process

### Step 1 — Scan the session

Read back through the full conversation. For each meaningful event, classify it:

| What happened | Category | Action |
|---|---|---|
| A skill's output was iterated or corrected | Skill update | Edit the affected section(s) in place |
| User shared a story, lesson, or hard-won insight | Lesson · `experience` | New page in the Lesson Log |
| Claude got something wrong and was corrected | Lesson · `correction` | New page in the Lesson Log |
| A new preference, working style, or constraint was revealed | Lesson · `preference` | New page in the Lesson Log |
| A better way of doing a recurring task emerged | Lesson · `process` | New page in the Lesson Log |
| A file path, description, or reference is wrong or outdated | Stale | Flag for the user to fix |
| Two files or sections contain overlapping content | Duplicate | Flag and propose consolidation |
| A new skill or file was created | System change | Update README |

Only save things with durable value — a lesson the user would want to reference in 6 months.
Do not treat casual back-and-forth as an experience.

---

### Step 2 — Skill updates

If a skill produced output that the user pushed back on, corrected, or significantly changed:

1. Read the current file first — never edit from memory (`verify-before-versioning`)
2. Identify what was wrong or incomplete in the original instructions
3. Rewrite only the affected section(s) — full rewrites only if the issue is structural
4. **Edit IN PLACE. Never add a version suffix.** Git history is the version log. The old
   `-vN.N` convention is retired everywhere: it existed only because the previous cloud
   store could not edit a file in place, and a renamed skill folder breaks its identity so
   the plugin stops resolving it.
5. Run `python scripts/validate.py` before committing
6. Report: "Updated [skill] — [what changed and why]"

---

### Step 3 — Lessons

If something durable was learned, record it in the Notion **Lesson Log**.

**Database:** `collection://80765770-d23c-46b3-92e4-2ada2cf078fc`
(under the *Claude Skill Stack* page)

**First: check whether this lesson already exists.** Query the database before creating.
If a page covers the same ground, **update it in place** — do not create a near-duplicate.
That is the whole reason this lives in Notion rather than dated files.

**Properties**

| Property | Value |
|---|---|
| `Lesson` | Short imperative title — the takeaway, not the anecdote |
| `Type` | `experience` · `correction` · `preference` · `process` · `context` |
| `Learned` | Today's date |
| `Source` | The project or session that produced it |
| `Applies to` | `skills` · `engineering` · `writing` · `business` · `workflow` · `general` |
| `Status` | `active` |

**Page body**

```
## What happened
[2-4 sentences. Factual. What was done, decided, or observed?]

## The lesson
[1-2 sentences. The durable takeaway, stated as guidance.]

## Why it matters
[1-2 sentences. What goes wrong if this is forgotten?]
```

**Superseding.** When a later lesson replaces an earlier one, set the old page's `Status`
to `superseded` and link the new one. **Do not delete it** — the reasoning is the record,
and knowing a rule was reconsidered is worth more than a tidy list.

Report: "Logged lesson: [title] → Notion Lesson Log".

Only record things with durable value — something worth referencing in six months. Casual
back-and-forth is not a lesson.

---

### Step 4 — Stale and duplicate content

For anything flagged as stale or duplicated:

- Do NOT attempt to delete files — flag them only
- Report clearly: what the issue is, which file contains it, what to do

Format each flag as:
🚩 `[filename]` in `[location]` — [issue description] — recommended action: [delete / update / merge with X]

---

### Step 5 — README update

If any skill was updated, created, or removed:

1. Create a new README with the updated Current Versions table (next version number: v6, v7, etc.)
2. Confirm to the user: "Created README (vN - current).md — delete the previous README."

If nothing changed that affects the README, skip this step and say so.

---

### Step 6 — Report

End with a clean summary in this format:

```
## /improve-system complete

**Updated skills:** (edited in place, no version suffixes)
- [Skill name] — [what changed and why]

**Logged lessons:**
- [Title] — [type] — new page / updated existing

**Flagged for cleanup:**
- 🚩 [File] in [location] — [issue] — [recommended action]

**Reviewed, no changes needed:**
- [Anything examined but found to be fine]
```

If nothing needed updating in the session, say plainly:
"Nothing in this session required a system update."

---

## What this skill does NOT do

- Does not rewrite skills that worked correctly — only skills whose output was corrected or iterated
- Does not save every interesting idea as an experience — only durable, referenceable lessons
- Does not make silent changes — every action is reported as it happens
- Does not delete files — flags them for the user to handle
- Does not run automatically — only when explicitly triggered with /improve-system
