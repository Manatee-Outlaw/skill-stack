---
name: improve-system
trigger: /improve-system
description: >
  Reviews the current session and updates the Claude Skills system to reflect what happened.
  Updates skill files when outputs were iterated. Saves experiences and lessons to
  knowledge/me/experiences/. Flags stale or duplicated content. Always updates the README
  if anything changed.
last_updated: 2026-05-31
metadata:
  tier: machine
  plugin: skill-engineering
---

# Improve System

This skill runs a structured review of the current session and makes targeted updates to
the Claude Skills folder in Google Drive. Run it at the end of any session where something
meaningful was built, iterated, or learned.

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
| A skill's output was iterated or corrected | Skill update | Rewrite the affected section(s) with version increment |
| User shared a story, lesson, or hard-won insight | Experience | Save to knowledge/me/experiences/ |
| A file path, description, or reference is wrong or outdated | Stale | Flag for user to delete or fix |
| Two files or sections contain overlapping content | Duplicate | Flag and propose consolidation |
| A new preference, working style, or constraint was revealed | User context | Save to knowledge/me/ |
| A new skill or file was created | System change | Update README |

Only save things with durable value — a lesson the user would want to reference in 6 months.
Do not treat casual back-and-forth as an experience.

---

### Step 2 — Skill updates

If a skill produced output that the user pushed back on, corrected, or significantly changed:

1. Identify what was wrong or incomplete in the original instructions
2. Rewrite only the affected section(s) — full rewrites only if the issue is structural
3. Version the file. NOTE: this `-vN.N` filename convention applies ONLY to skills that
   live in Google Drive (which cannot edit files in place). Skills in the public git repo
   are edited IN PLACE with NO suffix — git history is their version log (see
   verify-before-versioning). For a Drive skill:
   - First update to any skill: add `-v1.1` before `.md` (e.g. `diagnose-v1.1.md`)
   - Subsequent updates: increment minor version (`-v1.2`, `-v1.3`)
   - Major rework: bump major version (`-v2.0`)
4. Save to the same folder as the original (Drive); for a repo skill, edit in place and commit
5. Report: "Updated [skill name] → [new version] — [what changed and why]"

---

### Step 3 — Experiences

If the user shared a lesson, story, or experience worth preserving:

1. Save to `Claude Skills/knowledge/me/experiences/`
2. Use this format:

```
# Experience: [Short title]
Date: [YYYY-MM-DD]
Context: [What situation produced this — 1 sentence]

## What happened
[2–4 sentences. Factual. What did they do, decide, or observe?]

## The lesson
[1–2 sentences. What's the durable takeaway?]

## Tags
[2–4 keywords: e.g., sales, agency, systems, decision-making]
```

3. Filename: `[YYYY-MM-DD]-[short-title].md`
4. Report: "Saved experience: [title] → knowledge/me/experiences/[filename]"

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

**Updated skills:**
- [Skill name] → [new version] — [what changed]

**Saved experiences:**
- [Title] → knowledge/me/experiences/[filename]

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
