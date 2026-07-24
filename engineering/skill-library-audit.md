---
name: skill-library-audit
description: >
  Audit the entire skill library to find gaps, overlaps, stale content, and
  improvement opportunities. Use this skill whenever the user asks to "audit
  our skills", "check the skill library", "what skills are we missing",
  "do a gap analysis on our skills", or "review our skills". Also trigger
  proactively after any major project sprint where new workflows emerged that
  aren't yet captured as skills — if the user just finished a large build
  session and asks "what are we missing?", this is the right skill. The goal
  is to make the skill library a living, accurate reflection of how work
  actually gets done.
---

# Skill Library Audit

A skill for auditing the skill library itself — finding what's missing,
what's stale, what overlaps, and what's never used.

---

## Step 0 — Load the full skill library (hybrid: public GitHub + private Drive)

Before doing any analysis, read every skill file in full. Do not rely on
skills already in context — the full library must be explicitly loaded to
audit it completely.

Since the 2026-07-15 skills-repo migration the library lives in TWO places,
and both must be loaded:

1. **Public skills — the GitHub repo (source of truth).** Fetch each file
   from `raw.githubusercontent.com/Manatee-Outlaw/vibecraft-skills/main/<bundle>/<skill>.md`.
   Use `curl` (cache-busted), NOT WebFetch — WebFetch summarises through a
   small model and a skill must be audited from its exact text. The Drive
   copy of the public skills is a FOSSIL (proven stale on 2026-07-15); never
   audit against it. Enumerate the real file list from the repo, e.g.
   `git ls-files engineering/` in a local clone, or the GitHub API tree
   endpoint — do not trust a hardcoded list here, it will drift.

2. **Private skills — Google Drive (their only home).** A small set was
   hard-walled out of the public repo (2026-07-14/15) because they name real
   people, personal/financial detail, or live operational internals — e.g.
   `engineering/copy-review.md`, `engineering/database-review.md`,
   `productivity/board-of-directors*.md`. These live ONLY in Drive (and the
   local `vibecraft-skills-PRIVATE` mirror, which is NOT a git repo and must
   never become one). Load these via the Google Drive MCP tools
   (`search_files` with parentId filtering, then `download_file_content`) or
   from the local private mirror.

Also load any bundle manifest (`engineering.md`, `enterprise.md`,
`creative.md`) that lists which skills are active — these tell you which
skills are actually loaded vs. just stored.

Build a complete inventory across BOTH sources before proceeding to Step 1.
If a skill file cannot be read, flag it as UNREADABLE and continue — an
unreadable skill is itself a finding. If a private skill's content is
sensitive, audit its classification and freshness without re-surfacing the
sensitive body in the report.

---

## Step 0.5 — Orphan and dead-link check (run before the inventory)

Two failure modes are invisible to every other step in this audit, because both
look exactly like a healthy library from the inside:

- **Orphan** — a skill file exists in the repo but is named in NO bundle. It
  never loads. Nothing announces that it didn't. It is indistinguishable from a
  skill that loaded correctly and simply never triggered.
- **Dead link** — a bundle names a skill file that does not exist. The load
  silently comes up short.

Run both directions mechanically from a fresh clone or pull:

```bash
find . -name '*.md' -not -path './bundles/*' -not -path './.git/*' \
  | sed 's|^\./||' | sort > /tmp/all_skills.txt
grep -ohE '[a-z0-9-]+/[a-z0-9.-]+\.md' bundles/*.md | sort -u > /tmp/referenced.txt

comm -23 /tmp/all_skills.txt /tmp/referenced.txt   # ORPHANS: in repo, in no bundle
comm -13 /tmp/all_skills.txt /tmp/referenced.txt   # DEAD LINKS: in a bundle, not in repo
```

`legal-paralegal.md` is the only expected orphan — it is deliberately unbundled
and loaded by hand. Ignore `bundles/*.md` self-references in the dead-link column.
Everything else in either column is a finding, and both are IMMEDIATE priority:
an orphan means a skill you believe you have is not actually in play.

Also check for **half-registration** — a skill in a bundle's numbered load list
but missing from its description list, trigger list, or "when to run" list. It
loads, but nothing tells the session when to reach for it.

Report all three counts before proceeding, even when zero.

---

## Step 1 — Inventory the skill library

From the files loaded in Step 0, record for each skill:
- Name (from frontmatter)
- Description (the triggering text, from frontmatter)
- What it claims to do (from body)
- Whether it's in an active bundle or standalone
- Whether it's general-purpose or project-specific

Organize into categories:
- Engineering / code quality skills
- Operations / infrastructure skills
- Business / workflow skills
- Meta skills (skills about skills)
- Project-specific skills

Report the full inventory before doing any analysis.

---

## Step 2 — Gap analysis

A gap is a workflow that happens repeatedly but no skill covers it.

Sources for gap detection:
1. **Recent conversation history** — what tasks came up repeatedly that
   required improvisation? Any time Claude had to figure something out
   from scratch that could have been a skill, that's a gap candidate.
2. **Audit findings** — did a recent audit (engineering, security, etc.)
   surface a check that wasn't in any skill? Example: execute permission
   checks on cron-called scripts — found in production but missing from
   the production-drift skill until it caused a real failure.
3. **Recurring fixes** — bugs that were fixed multiple times suggest a
   skill should capture the pattern.
4. **Handoff friction** — anything that required significant re-explanation
   at the start of a new session is a skill gap.
5. **Skills that reference each other** — if skill A frequently leads to
   skill B, there may be a missing skill that combines them.

For each gap identified:
- Name the missing skill
- Describe what it would do
- Give an example trigger phrase
- Rate impact: HIGH / MEDIUM / LOW
- Note whether it's project-specific or general-purpose

---

## Step 3 — Staleness check

A skill is stale when its content references outdated tools, APIs,
versions, patterns, or workflows.

Check each skill for:
- Version numbers (plugin versions, library versions) that may have changed
- API endpoints or field names that have been updated
- Tool names that have been renamed or replaced
- Workflow steps that have been superseded
- Project-specific constants (table names, file paths, config keys) that
  have drifted from reality
- Documentation claims that contradict current known behavior
- Expected counts (e.g. "8 cron jobs" when there are now 12) that have
  grown stale as the project evolved

Flag each as:
- STALE: Content is demonstrably wrong based on current knowledge
- LIKELY STALE: References specifics that may have changed
- REVIEW NEEDED: Hasn't been touched in a long time, may drift

---

## Step 4 — Overlap detection

Two skills overlap when they cover similar territory and a user might
not know which to use, or Claude might load both unnecessarily.

Check for:
- Skills with similar trigger phrases
- Skills that accomplish the same goal via different approaches
- Skills where one is a subset of another (consolidation candidate)
- Skills that should reference each other but don't

For each overlap:
- Name both skills
- Describe the overlap
- Recommend: CONSOLIDATE / KEEP SEPARATE WITH CLEARER TRIGGERS / ADD CROSS-REFERENCE

---

## Step 5 — Trigger quality check

A skill with a poorly written trigger description either never fires
(undertriggering) or fires when it shouldn't (overtriggering).

For each skill, evaluate:
- Does the description clearly state WHEN to use it?
- Does it include example phrases a user would naturally say?
- Is it specific enough to not trigger on unrelated requests?
- Is it "pushy" enough? Skills tend to undertrigger — descriptions
  should actively encourage use in relevant situations.
- Does it accurately describe what the skill produces?

Flag:
- UNDERTRIGGER RISK: Description is too vague or passive
- OVERTRIGGER RISK: Description so broad it might fire inappropriately
- MISMATCH: Description doesn't match what the skill actually does

---

## Step 6 — Completeness check

A complete skill has:
- Clear inputs (what does the user provide?)
- Clear outputs (what does the skill produce?)
- A success criterion (how do you know it worked?)
- Error handling (what if something goes wrong?)
- At least one example or test case

For each skill, flag any missing components.

---

## Step 7 — Generate recommendations

Produce a prioritized action list:

### IMMEDIATE (fix this session)
Skills with critical gaps or staleness that are actively causing problems.

### HIGH PRIORITY (fix next session)
Gaps in frequently-used workflows. Skills stale in ways that could
cause incorrect behavior.

### MEDIUM PRIORITY (fix within a few sessions)
Trigger improvements, overlap consolidation, completeness gaps.

### LOW PRIORITY (nice to have)
Minor improvements, rarely-used skills, polish.

For each new skill recommended, include:
- Suggested name
- One-sentence description
- What gap it fills
- Example trigger phrase

---

## Output format

=== SKILL LIBRARY AUDIT ===
Skills loaded from Drive: N
Skills in active bundles: N
Total unique skills: N

=== INVENTORY ===
[skill name] — [one-line description] — [category] — [bundle/standalone]
...

=== GAPS FOUND ===
[HIGH/MEDIUM/LOW] [Skill name]: [what it would do]
Trigger: "[example phrase]"
Gap source: [where this gap was discovered]
...

=== STALENESS FLAGS ===
[STALE/LIKELY STALE/REVIEW NEEDED] [skill name]: [what's stale]
...

=== OVERLAPS ===
[skill A] + [skill B]: [nature of overlap] → [recommendation]
...

=== TRIGGER QUALITY ===
[UNDERTRIGGER/OVERTRIGGER/MISMATCH] [skill name]: [issue]
...

=== COMPLETENESS GAPS ===
[skill name]: missing [inputs/outputs/success criteria/examples]
...

=== RECOMMENDED ACTIONS ===
IMMEDIATE:
1. [action]

HIGH PRIORITY:
1. [action]

MEDIUM PRIORITY:
1. [action]

LOW PRIORITY:
1. [action]

---

## Notes on project-specific vs. general skills

Some skills are general-purpose (work on any project). Others are
project-specific (reference file paths, table names, API keys).
When auditing:

- General skills should stay generic — flag any project-specific
  hardcoding that crept in
- Project-specific skills should be clearly labeled as such
- If a project-specific skill describes a pattern useful across projects,
  recommend extracting a general version

---

## Notes on the execute permission gap (real example)

In June 2026, a production failure revealed that a `<scheduled-script>` had
mode 100644 (non-executable) in git. Cron fired on schedule, got
"Permission denied", wrote nothing to logs, and no alert fired.
12 days of silent report failures. The production-drift skill existed
but didn't check execute permissions.

This is the canonical example of a skill gap: a real failure pattern
that should have been caught by an existing skill but wasn't because
the skill's scope was too narrow. When doing the gap analysis, look
for similar "the skill existed but missed this" patterns.

The fix: production-drift.md now includes Step 4 (Execute Permission
Audit) as a general-purpose check for any project using cron.
