---
name: skill-library-audit
description: >
  Audit the whole skill library for reachability, trigger quality, overlap, staleness,
  mis-tiering, completeness, coverage gaps and broken cross-references. Use when the user
  asks to "audit our skills", "audit the skill library", "check the skill library", "review
  our skills", "are my skills working", "which skills never fire", "is anything stale",
  "what skills are we missing", "do a gap analysis on our skills", or after adding several
  skills at once. Also trigger proactively after a large build sprint where new workflows
  emerged that no skill captures yet. The central question is reachability: a skill whose
  description does not match how the user actually speaks is unreachable, and looks
  identical to one that loaded and simply did not trigger. Run quarterly, or whenever a
  skill "should have fired" and didn't.
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
  portability_exempt:
    drive-ref: "Names the pattern it must detect during the staleness check."
    raw-github: "Names the pattern it must detect during the staleness check."
---

# Skill Library Audit

A skill for auditing the skill library itself — finding what is unreachable, what is
missing, what is stale, what overlaps, and what is never used. The goal is a library that
is a living, accurate reflection of how work actually gets done.

## What changed, and why this skill was rewritten

The previous version audited a **load-list** system. Skills were listed in bundle files,
and its two headline checks were:

- **Orphan** — a skill exists in the repo but is named in no bundle
- **Dead link** — a bundle names a skill that does not exist

In a plugin library both checks are **structurally impossible**. There are no bundles.
Every skill in an installed plugin is available, and each triggers on its own
`description`. (If you are pointed at a library that still uses a load list, run Step 0.5
below — it is kept for exactly that case.)

**The underlying failure did not go away — it changed shape.** A skill used to be
unreachable because nobody added it to a list. Now it is unreachable because its
description does not match the words the user actually says. Both fail silently, and both
are indistinguishable from a skill that loaded and simply wasn't relevant.

Auditing a load list was mechanical: compare two sets. Auditing reachability is a
judgement call, so most of this skill is about making that judgement well.

## Step 0 — Load the library

```bash
python3 scripts/validate.py            # structural gate; fix failures before auditing
find plugins -name SKILL.md | wc -l    # expected skill count
```

Read every `SKILL.md` **in full from disk**. Do not audit from memory of a previous
session, do not rely on skills already in context, and do not audit from a summary — a
description must be assessed as its exact text (`no-assumed-memory`,
`trust-the-live-signal`). Enumerate the real file list from disk or `git ls-files`; never
trust a hardcoded list, it will drift.

Also load, if present:

- `skill-stack-private/` — the private set. Audited the same way, reported separately, and
  **never** quoted in a report that could be shared. If a private skill's content is
  sensitive, audit its classification and freshness without re-surfacing its body.
- The external manifest — pinned third-party skills. Audit whether the pin is current, not
  the skill's content; upstream owns that.

Build a complete inventory across every source before proceeding. If a skill file cannot
be read, flag it **UNREADABLE** and continue — an unreadable skill is itself a finding.

### Load the full skill library (hybrid: public GitHub + private Drive)

Only for a library split across two homes — a public git repo plus a private cloud
folder or local mirror. Both halves must be loaded:

1. **Public skills — the git repo is the source of truth.** Read the exact text from a
   local clone, or fetch each file with `curl` (cache-busted). **Not WebFetch** — WebFetch
   summarises through a small model, and a skill must be audited from its exact text. A
   cloud-folder copy of the public skills is a fossil (one such copy was proven stale on
   2026-07-15, the day after a repo migration); never audit against a mirror when the repo
   exists.
2. **Private skills — their only home.** Skills hard-walled out of the public repo because
   they name real people, personal or financial detail, or live operational internals.
   Load them from the private folder or mirror (which must never become a public repo) and
   apply the private-skill rules above.

Also load any bundle manifest that lists which skills are active — it tells you which
skills are actually loaded versus merely stored.

## Step 0.5 — Orphan and dead-link check (run before the inventory)

Applies **only to a load-list (bundle) library**. In a plugin library, skip it and rely on
Check 4. Two failure modes are invisible to every other step, because both look exactly
like a healthy library from the inside:

- **Orphan** — a skill file exists in the repo but is named in NO bundle. It never loads.
  Nothing announces that it didn't. It is indistinguishable from a skill that loaded
  correctly and simply never triggered.
- **Dead link** — a bundle names a skill file that does not exist. The load silently comes
  up short.

Run both directions mechanically from a fresh clone or pull:

```bash
find . -name '*.md' -not -path './bundles/*' -not -path './.git/*' \
  | sed 's|^\./||' | sort > /tmp/all_skills.txt
grep -ohE '[a-z0-9-]+/[a-z0-9.-]+\.md' bundles/*.md | sort -u > /tmp/referenced.txt

comm -23 /tmp/all_skills.txt /tmp/referenced.txt   # ORPHANS: in repo, in no bundle
comm -13 /tmp/all_skills.txt /tmp/referenced.txt   # DEAD LINKS: in a bundle, not in repo
```

The only acceptable orphan is a skill documented as deliberately unbundled and loaded by
hand. Ignore `bundles/*.md` self-references in the dead-link column. Everything else in
either column is a finding, and both are IMMEDIATE priority: an orphan means a skill you
believe you have is not actually in play.

Also check for **half-registration** — a skill in a bundle's numbered load list but missing
from its description list, trigger list, or "when to run" list. It loads, but nothing tells
the session when to reach for it.

Report all three counts before proceeding, even when zero.

## Step 1 — Inventory the skill library

From the files loaded in Step 0, record for each skill:
- Name (from frontmatter)
- Description (the triggering text, from frontmatter)
- What it claims to do (from body)
- Which plugin ships it and its declared tier (or, in a load-list library, which bundle
  names it, or standalone)
- Whether it's general-purpose or project-specific

Organize into categories:
- Engineering / code quality skills
- Operations / infrastructure skills
- Business / workflow skills
- Meta skills (skills about skills)
- Project-specific skills

Report the full inventory before doing any analysis.

## The seven checks

The seven checks below are the core of the audit. Each has a detail pass beneath it where
the older step-based audit added depth; run both. A separate completeness pass follows.

### Check 1 — Reachability *(replaces the orphan check)*

For each skill, ask: **if the user described this need in their own words, would this
description match?**

Flag as **UNREACHABLE** when any of these hold:

- Description under ~60 characters — too thin to discriminate
- Describes *what the skill is* but never *when to use it*
- Contains no trigger phrasing a person would actually say out loud
- Uses only internal vocabulary the user never speaks
- The only trigger is a slash command — that requires memorising it, which the
  description-matching system exists to eliminate

**Test properly:** write three sentences a real person would say when they need this
skill. Check each against the description. Fewer than two plausible matches ⇒ UNREACHABLE.

#### Trigger quality check

Reachability is the undertrigger half. A poorly written description can also fire when it
shouldn't, or promise something the skill doesn't do. For each skill, evaluate:
- Does the description clearly state WHEN to use it?
- Does it include example phrases a user would naturally say?
- Is it specific enough to not trigger on unrelated requests?
- Is it "pushy" enough? Skills tend to undertrigger — descriptions should actively
  encourage use in relevant situations.
- Does it accurately describe what the skill produces?

Flag:
- **UNDERTRIGGER RISK** — too vague or passive, but not yet UNREACHABLE (report as WEAK)
- **OVERTRIGGER RISK** — so broad it might fire inappropriately
- **MISMATCH** — the description doesn't match what the skill actually does

### Check 2 — Trigger collision

Two skills whose descriptions cover the same phrasing compete, and which one fires is
unpredictable.

For every pair, flag **COLLISION** when both plausibly match the same request. Report as a
pair, never one skill alone. Resolve by narrowing the descriptions until each owns
distinct territory — or by merging them, if they are genuinely one skill.

Pay attention to audit skills specifically: `engineering-review`, `holistic-code-audit`,
`architecture-review` and `comprehensive-audit` all plausibly match "audit my code."

### Check 3 — Tier correctness

Each skill declares `metadata.tier`. Verify against one test: **does it require a codebase,
git, or local files?**

- `tier: machine` but no filesystem dependency ⇒ **UNDER-REACHING.** It could work on a
  tablet and is being withheld for no reason.
- `tier: universal` but needs a repo ⇒ **MIS-TIERED.** It will be uploaded to the account
  store, appear on a tablet, and fail when invoked there.

Mis-tiering is the more damaging direction: it produces a skill that is present and broken
rather than merely absent.

### Check 4 — Cross-reference integrity *(replaces the dead-link check)*

Skills reference each other by name. Extract every referenced skill name and confirm it
exists. Flag **BROKEN REFERENCE** for any that does not.

Watch particularly for references to retired skills. `session-cold-start` and the four
bundle files were removed; any skill still pointing at them is stale.

`comprehensive-audit` carries its own AUDIT SKILLS list and dispatches one subagent per
entry — that list is a cross-reference set and must be checked against reality. This is
the closest surviving equivalent of the old dead-link check, and the only place it still
genuinely applies.

### Check 5 — Staleness

Flag any skill that:

- References the retired `bundles/` system or instructs "load the X bundle"
- Instructs a Google Drive version search (the `-vN.N` convention is retired everywhere)
- References `raw.githubusercontent.com` into this repo — skills reference by name, not link
- Names a project (`validate.py` catches this; report it here too)
- Describes a workflow that no longer exists

#### Staleness check

A skill is stale when its content references outdated tools, APIs, versions, patterns, or
workflows. Also check each skill for:
- Version numbers (plugin versions, library versions) that may have changed
- API endpoints or field names that have been updated
- Tool names that have been renamed or replaced
- Workflow steps that have been superseded
- Project-specific constants (table names, file paths, config keys) that have drifted from
  reality
- Documentation claims that contradict current known behavior
- Expected counts (e.g. "8 cron jobs" when there are now 12) that have grown stale as the
  project evolved

Grade each:
- **STALE** — content is demonstrably wrong based on current knowledge
- **LIKELY STALE** — references specifics that may have changed
- **REVIEW NEEDED** — hasn't been touched in a long time, may drift

### Check 6 — Overlap and redundancy

Distinct from collision: two skills may trigger cleanly but do substantially the same work.
Flag **REDUNDANT** with a recommendation to merge, and say which should absorb which.

#### Overlap detection

Two skills overlap when they cover similar territory and a user might not know which to
use, or the model might load both unnecessarily. Check for:
- Skills with similar trigger phrases (→ Check 2)
- Skills that accomplish the same goal via different approaches
- Skills where one is a subset of another (consolidation candidate)
- Skills that should reference each other but don't

For each overlap name both skills, describe the overlap, and recommend one of:
**CONSOLIDATE** / **KEEP SEPARATE WITH CLEARER TRIGGERS** / **ADD CROSS-REFERENCE**.

### Check 7 — Coverage gaps

Look at the library as a whole. What does the user do regularly that no skill supports?
Evidence, not speculation: recent work where a skill would have helped and none existed.
This is the only check that produces additions rather than corrections.

#### Gap analysis

A gap is a workflow that happens repeatedly but no skill covers it. Sources for gap
detection:
1. **Recent conversation history** — what tasks came up repeatedly that required
   improvisation? Any time the model had to figure something out from scratch that could
   have been a skill, that's a gap candidate.
2. **Audit findings** — did a recent audit (engineering, security, etc.) surface a check
   that wasn't in any skill? Example: execute-permission checks on cron-called scripts —
   found in production but missing from `production-drift` until it caused a real failure
   (see the note at the end).
3. **Recurring fixes** — bugs that were fixed multiple times suggest a skill should capture
   the pattern.
4. **Handoff friction** — anything that required significant re-explanation at the start
   of a new session is a skill gap.
5. **Skills that reference each other** — if skill A frequently leads to skill B, there may
   be a missing skill that combines them.

Also look for the **"the skill existed but missed this"** pattern: a real failure an
existing skill should have caught but didn't because its scope was too narrow. That is a
gap in an existing skill, not a new skill.

For each gap identified:
- Name the missing skill (or the existing skill whose scope is too narrow)
- Describe what it would do
- Give an example trigger phrase
- Rate impact: HIGH / MEDIUM / LOW
- Note whether it's project-specific or general-purpose

## Completeness check

A complete skill has:
- Clear inputs (what does the user provide?)
- Clear outputs (what does the skill produce?)
- A success criterion (how do you know it worked?)
- Error handling (what if something goes wrong?)
- At least one example or test case

For each skill, flag any missing components.

## Generate recommendations

Produce a prioritized action list from every finding above.

### IMMEDIATE (fix this session)
Skills with critical gaps, staleness or mis-tiering that are actively causing problems;
unreachable skills the user is relying on; orphans and dead links in a load-list library.

### HIGH PRIORITY (fix next session)
Gaps in frequently-used workflows. Skills stale in ways that could cause incorrect
behavior. Collisions between skills that are used often.

### MEDIUM PRIORITY (fix within a few sessions)
Trigger improvements, overlap consolidation, completeness gaps.

### LOW PRIORITY (nice to have)
Minor improvements, rarely-used skills, polish.

For each new skill recommended, include:
- Suggested name
- One-sentence description
- What gap it fills
- Example trigger phrase

## Report format

Every finding carries an indented `evidence:` line. No exceptions — a finding with an empty
evidence line is a hypothesis, not a finding.

### Output format

```
SKILL LIBRARY AUDIT — <date>

Skills audited: N   (universal: N | machine: N)
Private skills audited separately: N
Structural validation: PASS / FAIL (n errors)
Unreadable: N
Load-list checks (bundle libraries only): orphans N | dead links N | half-registered N

UNREACHABLE (n)
  <skill> — <why> — suggested description fix
    evidence: <the description text, quoted> — [proven | inferred]

TRIGGER QUALITY (n)
  [UNDERTRIGGER | OVERTRIGGER | MISMATCH] <skill> — <issue>
    evidence: <the description text and, for MISMATCH, the body text it contradicts> — [proven | inferred]

COLLISIONS (n)
  <skill-a> vs <skill-b> — overlapping phrasing — resolution
    evidence: <both descriptions, quoted> — [proven | inferred]

TIER ERRORS (n)
  <skill> — declared <tier>, should be <tier> — why
    evidence: <the filesystem dependency, quoted, or the check showing none> — [proven | inferred]

BROKEN REFERENCES (n)
  <skill> references <missing> — <exists? renamed? retired?>
    evidence: <the search run for the target, and its scope> — [proven | inferred]

STALE (n)
  [STALE | LIKELY STALE | REVIEW NEEDED] <skill> — <what is out of date>
    evidence: <the outdated text, quoted> — [proven | inferred]

REDUNDANT / OVERLAPS (n)
  <skill-a> / <skill-b> — <nature of overlap> → CONSOLIDATE | KEEP SEPARATE WITH CLEARER TRIGGERS | ADD CROSS-REFERENCE
    evidence: <the overlapping content, quoted from both> — [proven | inferred]

COVERAGE GAPS (n)
  [HIGH | MEDIUM | LOW] <need or skill name> — <what it would do>
    Trigger: "<example phrase>"
    Gap source: <where this gap was discovered>
    evidence: <where you looked for an existing skill, and the scope> — [proven | inferred]

COMPLETENESS GAPS (n)
  <skill> — missing <inputs | outputs | success criterion | error handling | example>
    evidence: <the sections you read and did not find it in> — [proven | inferred]

RECOMMENDED ACTIONS
  IMMEDIATE:      1. <action>
  HIGH PRIORITY:  1. <action>
  MEDIUM PRIORITY: 1. <action>
  LOW PRIORITY:   1. <action>

FULL INVENTORY
  <name> — <one line> — <category> — <plugin> — <tier> — <reachability: OK/WEAK/UNREACHABLE>
```

## Rules for running this audit

- **Read every file.** A skimmed description cannot be judged for reachability.
- **Quote the evidence.** Every finding names the skill and quotes the offending text.
  A finding without a quote is an opinion (`verify-before-claiming`).
- **An absence needs a negative check.** "Not in any repo", "no source", "nothing
  references it", "not under git" cannot quote offending text — which is exactly why
  they slip past the rule above. Name the artifact you opened that would have contained
  it, and the scope you searched: `ls -a <dir>`, `git ls-files <path>`, the grep and
  where it ran. Absence inferred from not having noticed something is not absence.
  (Carried from `comprehensive-audit`'s GOVERNING STANDARDS, which has enforced this
  for negative findings since before this skill existed.)
- **Tag every finding `[proven]` or `[inferred]`.** Proven means you ran something and
  read the result. Inferred means you reasoned from what you read. Both are legitimate;
  blending them into one undifferentiated list is not (`verify-before-claiming`'s
  required report format).

**A proxy check is not a content check.** `ls` and `find` prove a file exists.
`diff -q` and checksums prove bytes differ. `grep -c` and `grep -l` prove a match
count. None of them prove what the file *says*. If the command on your evidence
line is one of those, the finding is `[inferred]` at best — open the file before
it ships. (This is not hypothetical: on 2026-09-09 an `ls` that listed a README
became "no version control", a `diff -q` became "stale, needs re-upload", and a
`grep -c` became "this rule needs writing" — all three wrong, all three one file
read away from correct.)

- **Do not fix while auditing.** Produce findings; fix in a separate pass. Editing mid-audit
  changes what later checks are reading.
- **A clean check needs proof it could have failed.** Reporting "no collisions" requires
  having actually compared pairs. An audit that silently skipped a check produces output
  identical to one that passed. Report every count, even when zero.
- **Never quote private-skill contents** into a report that might be shared.

## Notes on project-specific vs. general skills

Some skills are general-purpose (work on any project). Others are project-specific
(reference file paths, table names, API keys). When auditing:

- General skills should stay generic — flag any project-specific hardcoding that crept in
  (`validate.py`'s portability gate catches the mechanical cases; judge the rest)
- Project-specific skills should be clearly labeled as such
- If a project-specific skill describes a pattern useful across projects, recommend
  extracting a general version

## Notes on the execute permission gap (real example)

In June 2026, a production failure revealed that a `<scheduled-script>` had mode 100644
(non-executable) in git. Cron fired on schedule, got "Permission denied", wrote nothing to
logs, and no alert fired. 12 days of silent report failures. The `production-drift` skill
existed but didn't check execute permissions.

This is the canonical example of a skill gap: a real failure pattern that should have been
caught by an existing skill but wasn't because the skill's scope was too narrow. When doing
the gap analysis, look for similar "the skill existed but missed this" patterns.

The fix: `production-drift` now includes Step 4 (Execute permission audit) as a
general-purpose check for any project using cron.

## Relationship to other skills

- **`validate.py`** is the structural gate — names, limits, duplicates, portability. It runs
  per commit and answers "is this well-formed?" This skill answers "is this *reachable and
  coherent?*", which no script can decide.
- **`verify-before-versioning`** is the in-the-moment discipline before a single write. This
  is the periodic sweep across everything.
- **`comprehensive-audit`** audits a codebase. This audits the skills that do the auditing.
