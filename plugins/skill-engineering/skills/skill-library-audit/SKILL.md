---
name: skill-library-audit
description: >
  Audit the whole skill library for reachability, overlap, staleness, mis-tiering and
  broken cross-references. Use when the user asks to "audit our skills", "audit the skill
  library", "check the skill library", "are my skills working", "which skills never fire",
  "is anything stale", or after adding several skills at once. The central question is
  reachability: a skill whose description does not match how the user actually speaks is
  unreachable, and looks identical to one that loaded and simply did not trigger. Run
  quarterly, or whenever a skill "should have fired" and didn't.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Skill Library Audit

## What changed, and why this skill was rewritten

The previous version audited a **load-list** system. Skills were listed in bundle files,
and its two headline checks were:

- **Orphan** — a skill exists in the repo but is named in no bundle
- **Dead link** — a bundle names a skill that does not exist

Both checks are now **structurally impossible**. There are no bundles. Every skill in an
installed plugin is available, and each triggers on its own `description`.

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
session, and do not audit from a summary — a description must be assessed as its exact
text (`no-assumed-memory`, `trust-the-live-signal`).

Also load, if present:

- `skill-stack-private/` — the private set. Audited the same way, reported separately, and
  **never** quoted in a report that could be shared.
- The external manifest — pinned third-party skills. Audit whether the pin is current, not
  the skill's content; upstream owns that.

## The seven checks

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

### Check 6 — Overlap and redundancy

Distinct from collision: two skills may trigger cleanly but do substantially the same work.
Flag **REDUNDANT** with a recommendation to merge, and say which should absorb which.

### Check 7 — Coverage gaps

Look at the library as a whole. What does the user do regularly that no skill supports?
Evidence, not speculation: recent work where a skill would have helped and none existed.
This is the only check that produces additions rather than corrections.

## Report format

```
SKILL LIBRARY AUDIT — <date>

Skills audited: N   (universal: N | machine: N)
Private skills audited separately: N
Structural validation: PASS / FAIL (n errors)

UNREACHABLE (n)
  <skill> — <why> — suggested description fix

COLLISIONS (n)
  <skill-a> vs <skill-b> — overlapping phrasing — resolution

TIER ERRORS (n)
  <skill> — declared <tier>, should be <tier> — why

BROKEN REFERENCES (n)
  <skill> references <missing> — <exists? renamed? retired?>

STALE (n)
  <skill> — <what is out of date>

REDUNDANT (n)
  <skill-a> / <skill-b> — merge recommendation

COVERAGE GAPS (n)
  <need> — evidence it exists

FULL INVENTORY
  <name> — <one line> — <plugin> — <tier> — <reachability: OK/WEAK/UNREACHABLE>
```

## Rules for running this audit

- **Read every file.** A skimmed description cannot be judged for reachability.
- **Quote the evidence.** Every finding names the skill and quotes the offending text.
  A finding without a quote is an opinion (`verify-before-claiming`).
- **Do not fix while auditing.** Produce findings; fix in a separate pass. Editing mid-audit
  changes what later checks are reading.
- **A clean check needs proof it could have failed.** Reporting "no collisions" requires
  having actually compared pairs. An audit that silently skipped a check produces output
  identical to one that passed.
- **Never quote private-skill contents** into a report that might be shared.

## Relationship to other skills

- **`validate.py`** is the structural gate — names, limits, duplicates, portability. It runs
  per commit and answers "is this well-formed?" This skill answers "is this *reachable and
  coherent?*", which no script can decide.
- **`verify-before-versioning`** is the in-the-moment discipline before a single write. This
  is the periodic sweep across everything.
- **`comprehensive-audit`** audits a codebase. This audits the skills that do the auditing.
