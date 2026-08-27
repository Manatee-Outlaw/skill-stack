---
name: verify-before-versioning
description: >
  Before editing or publishing any skill, work from its CURRENT state — never a
  remembered or older local copy — and never create a version-suffixed copy of a file.
  Every skill now lives in git and is edited IN PLACE; git history is the version log.
  Also run the privacy triage before publishing anything to the public repo or uploading
  it to the claude.ai account store. Trigger automatically, every time, before any skill
  file is created, edited, or published — no trigger phrase needed.
metadata:
  tier: universal
  plugin: skill-core
---

# Verify Before Versioning

## Why this skill exists

Two separate sessions, six days apart, each independently created a new file named
"engineering-v1.5.md" — identical filenames, completely different content, neither aware
the other existed. Both sat live in the same Google Drive folder for six days, silently
conflicting, until a routine scan happened to notice two files with the same name and
different modification dates.

That was a symptom of a deeper problem: **Drive cannot edit a file in place, so every
update had to become a NEW file** — and new files collide, drift, and break any link that
pointed at the old name.

**That root cause is now fully removed.** Every skill — public and private — lives in a
git repo and is edited in place. The `-vN.N` convention is retired completely; it was
always a Drive workaround, never a practice. What survives is the discipline: work from
the current state, don't fork versions, don't break references, don't leak.

## The core rules

**1. Skills are edited IN PLACE. Never version-suffix them.**
Every skill in every repo is edited directly. Git history IS the version log — run
`git log --follow <path>` to see every change. NEVER create a `-vN.N` copy, and never add
a version suffix to a filename. A renamed skill folder changes the skill's identity: the
plugin no longer resolves it, and any skill that references it by name breaks.

**2. Before editing, read the CURRENT file from the repo — not a memory of it.**
Read the live file before changing it. Never edit from a remembered copy, an older local
checkout, or what you think the file said last session. Confirm the real current content
first, then edit in place. If another session may have touched it, `git pull` first.

**3. Private skills live in `skill-stack-private`, in git — same rules, no exceptions.**
Private skills are no longer in Google Drive. They live in a local git repo that is never
pushed to GitHub. They are edited in place exactly like public ones, and the `-vN.N`
convention does NOT apply to them any more. There is now one rule for every skill,
everywhere.

*(Historical note: rule 3 previously required a live Drive search for the current highest
version number. That was correct while Drive was the private store and could not edit in
place. Moving the private set into git removed the constraint. If you find a skill still
instructing a Drive version search, it is stale — fix it.)*

**4. Before publishing ANY new or edited skill, run the privacy triage.**
Two destinations are irreversible, and both need this check:

- **The public repo** — indexed, mirrored, cloned and scraped within hours; deleting later
  recalls nothing.
- **The claude.ai account store** (universal tier) — a cloud store outside your machines.

Test the file against all three:

- **TEST 1 — CREDENTIALS:** tokens, API keys, passwords, .env contents, signing keys,
  private URLs with embedded auth, session IDs, connection strings.
- **TEST 2 — BUSINESS INTERNALS:** roster names/handles, revenue, pricing, bonus
  mechanics, vetting criteria, cloud folder IDs, server IPs or filesystem paths,
  private repo names, database/table specifics, any business-tied internal identifier.
- **TEST 3 — PERSONAL:** the board-of-directors profile, health, finances, family,
  relationships, real names — anything about the person rather than the work.

ANY single yes ⇒ the file stays in `skill-stack-private`, and is neither pushed to GitHub
nor uploaded to the account store. DEFAULT TO PRIVATE when uncertain. Re-run this on
EVERY edit, not just at creation — a later edit can introduce something that wasn't there
before. State explicitly that the check was done.

**5. Portability check before committing.**
The library is project-agnostic by design. A skill must contain no project name, no
absolute local path, and no reference to a specific cloud folder. `scripts/validate.sh`
enforces this; run it rather than eyeballing.

## What to do, every time

1. **Editing a skill:** read the current file first; edit in place; commit. Do not rename
   it, do not add a suffix.
2. **Creating a NEW skill:** confirm no skill of that name exists in either repo; use a
   clean suffix-free name matching its folder; run the privacy triage and
   `scripts/validate.sh` before committing.
3. **Publishing to the public repo:** run the three-test triage; default to private on any
   doubt; say the check was done.
4. **Uploading to the account store:** same triage. A universal-tier skill goes to a cloud
   store — treat it with the same care as a public push.

## Relationship to other skills

- **skill-library-audit** is the periodic sweep that catches drift, staleness, and broken
  references after the fact. This skill is the in-the-moment discipline applied the
  instant before a write or a publish.
- **verify-before-claiming** requires execution proof before claiming something works;
  this skill is about working from the real current state and not leaking on publish.
- **trust-the-live-signal** is why rule 2 exists: a remembered file is a stored signal,
  and the file on disk is the live one.

## Trigger this skill

- Automatically, every time — before creating, editing, or publishing any skill file, in
  either repo or to the account store.
- No trigger phrase needed; always-on, the same way `verify-before-claiming` is.
