---
name: session-cold-start
description: >
  Actively load all context needed to start a working session from scratch.
  Finds and reads the most recent Hermes handoff, loads the project brief,
  loads skill bundles, and checks the current git/production state.
  Trigger immediately when the user says "start the session", "load context",
  "cold start", "what's our current state", "catch me up", "let's get started",
  or when a new conversation begins on a project with no context loaded yet.
  This skill does the loading — it does not just describe what to load.
---

# Session Cold Start

Actively loads all context needed to begin work. Run at the start of every
session before doing anything else. Takes 2-3 minutes and prevents the most
common session failure: working from stale or missing context.

---

## Step 1 — Load the Project Brief

Find and read the project brief from the Claude Skills root folder.

Search for a file named "Project Brief" or "[Project Name] Project Brief" in
the Claude Skills root folder (ID: <drive-folder-id>).

Download and read it in full. This gives you:
- Who the user is and how they work
- What the project is trying to achieve
- The technology stack and key constraints
- Working style rules and preferences
- Key Drive folder IDs for this project

If no project brief exists: note the gap and continue. Offer to create one
at the end of the session.

---

## Step 2 — Load the most recent Hermes handoff

Find the most recent Hermes handoff for this project.

Search the Hermes Handoffs folder for files matching the current chat title.
Sort by creation date descending. Download and read the most recent version.

The Hermes Handoffs folder ID is in the Project Brief (or use the default:
<drive-folder-id> configured for your projects).

The handoff gives you:
- Exact current HEAD commit and branch
- What was built or changed last session
- Decisions made and their rationale
- Open bugs, deferred features, and backlog items
- Architecture gotchas and critical operational notes

If no handoff exists for this chat: note it and continue with available
context. This is a new project or a first session.

If multiple versions exist: read the most recent only. Older versions are
archived context.

---

## Step 3 — Load skill bundles (from the GitHub repo, not Drive)

Find and read the bundle files for this project. Bundles list which skills
are active for this project type.

Since the 2026-07-15 skills-repo migration the bundles live in the GitHub repo,
NOT Drive — the Drive copy is a known fossil (it went stale within days and lost
later rules). Fetch each bundle fresh and cache-busted from
`raw.githubusercontent.com/Manatee-Outlaw/vibecraft-skills/main/bundles/<bundle>.md`
with `curl`, NOT WebFetch (WebFetch summarises through a small model; a bundle
must be read from exact text). For engineering projects read bundles/engineering.md;
for creative projects bundles/creative.md; read all that apply. If you have a
local clone, reading the freshly-pulled file is equivalent to repo HEAD and avoids
raw-CDN caching lag right after a commit.

The PRIVATE skills a bundle lists (e.g. copy-review, database-review,
board-of-directors) still load from Google Drive — the bundle's own PRIVATE
section names which and why.

For each skill listed in the active bundles:
- Note its name and trigger phrases
- You do NOT need to read each skill file in full at cold start
- Skills are loaded on demand when triggered

Report which bundles are active and how many skills are available.

**Orphan check.** If you have a local clone or pull, also confirm no skill file
is missing from every bundle — an unreferenced file never loads and nothing says so:

```bash
comm -23 \
  <(find . -name '*.md' -not -path './bundles/*' -not -path './.git/*' | sed 's|^\./||' | sort) \
  <(grep -ohE '[a-z0-9-]+/[a-z0-9.-]+\.md' bundles/*.md | sort -u)
```

Expect exactly one line, `legal-paralegal.md`. Anything else is an orphan —
surface it in the ready report as a flag, do not silently continue.

---

## Step 4 — Check production state (code projects only)

If this is a code project with a deployment host:

Run a quick state check:
```bash
ssh <user>@<production-server> "cd <project-dir> && git log --oneline -3 && git status && echo 'Service:' && sudo systemctl is-active <service>"
```

Report:
- Current HEAD commit (compare to Hermes handoff — should match)
- Working tree state (should be clean)
- Service status (should be active)

Flag any mismatch between Hermes handoff HEAD and the actual deployed HEAD. This means
something was deployed or changed outside of a tracked session.

For non-code projects: skip this step.

---

## Step 5 — Report ready state

**The receipt is mandatory and it is not optional formatting.** The first
substantive answer of any session must be preceded by the block below. A session
that skipped loading entirely produces output that looks exactly like a session
that loaded correctly — confident, plausible, and missing every skill. The
receipt is the only thing that makes the difference visible to the user, and the
user is the only one positioned to catch it. No receipt = the load did not happen.

If you find yourself answering a substantive question and no receipt has been
printed this session, stop, load, and print it before answering.

Produce a compact session brief:

```
=== SESSION READY ===

Project: [name]
Who: [one line about the user from the Project Brief]
Goal: [current sprint goal from Hermes handoff]

Current state:
- HEAD: [commit hash and message]
- Service: [active/inactive]
- Working tree: [clean/dirty]

Last session ([date]):
- Built: [3-5 bullet summary from Hermes]
- Deferred: [count] items

Immediate priorities from last session:
1. [top item]
2. [second item]
3. [third item]

Skills loaded: [N skills across X bundles]
Bundles read: [names, from GitHub HEAD]
Orphans: [none | list]
Ready to work.
```

If any step failed (handoff not found, host unreachable, etc.), report what
loaded successfully and what was missing. Partial context is better than none.

---

## Step 6 — Surface any critical flags

Before declaring ready, scan the Hermes handoff for:
- CRITICAL bugs noted as unresolved
- Time-sensitive items (deadlines, pending approvals)
- Anything marked "IMPORTANT" or "WARNING" in the handoff

If found, surface them before the session begins — not buried in the brief.

---

## Notes on project portability

This skill works on any project, not just the one it was written for. To adapt:
- The Project Brief file name follows the pattern: "[Project Name] Project Brief.md"
- The Hermes Handoffs folder ID comes from the Project Brief
- The git check command adapts to whatever server the project uses
- If no deployment host exists, skip Step 4 entirely

The skill finds the Project Brief first, then uses the folder IDs from it.
This makes the skill self-configuring for any project that has a Project Brief.
