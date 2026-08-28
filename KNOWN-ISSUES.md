# Known issues

Tracked deliberately rather than bodged. `scripts/validate.py` fails on item 2 by design —
that failure is the reminder.

## 1. ~~`skill-library-audit`~~ — RESOLVED, rewritten

Rewritten around reachability rather than list membership. The orphan and dead-link checks
were structurally impossible without bundles; they are replaced by seven checks —
reachability, trigger collision, tier correctness, cross-reference integrity, staleness,
redundancy, coverage gaps.

The `comprehensive-audit` AUDIT SKILLS list is the one place the old dead-link check still
genuinely applies, and Check 4 covers it.

## 2. ~~`improve-system`~~ — RESOLVED

Repointed to the Notion **Lesson Log** — `collection://80765770-d23c-46b3-92e4-2ada2cf078fc`,
under the *Claude Skill Stack* page. One page per lesson, edited in place, with a
`superseded` status so a replaced lesson is retained rather than deleted (the reasoning is
the record). The `-vN.N` skill-versioning branch is gone; every skill is edited in place now.

## 3. ~~`hermes-upload`~~ — RESOLVED

Repointed to the Notion **Hermes Handoffs** database —
`collection://0a0836e0-289d-4398-9168-52bfca8f4a70`. One page per chat, keyed on the exact
chat title, **searched before writing** and updated in place. The `v1`/`v2`/`v3`
auto-increment and the hardcoded folder ID are both gone.

The provenance rule survived verbatim, as required:

> Every number in the handoff must carry its provenance — sample or population, measured or
> estimated, and by whom — because a figure that loses its denominator becomes a false
> statistic in the next session, which has no way to see the qualifier was ever there.

Fallback preserved: if Notion is unreachable, print the handoff in chat rather than failing
silently. Added a failure mode that did not exist before — if two pages match the same chat
title, report and ask rather than guessing, because a duplicate means the one-page rule was
already broken and guessing compounds it.

Its portability exemption was removed; it no longer needs one.

## 4. ~~Unresolved from planning~~ — mostly RESOLVED

- **`unlazy`** — found: `Leonxlnx/unlazy` (MIT). Not marketplace-installable; installs via
  `npx skills add`. Pinned in `EXTERNALS.md`, machine-tier. **RESOLVED.**
- **ADHD duplication** — bodies were identical; only the description diverged. Kept local as
  a **declared managed fork** with a quarterly re-sync procedure in `EXTERNALS.md`.
  Deleting it would have lost the business triggers that make it universal-tier. **RESOLVED.**
- **`ponytail-audit`** — inspected and already a correct thin wrapper. Records ownership,
  source and relevant commands; does not restate upstream logic. **No slimming needed.**
  Install `DietrichGebert/ponytail` upstream and leave the wrapper alone. **RESOLVED.**
- **`push-to-git`** — its bundle-orphan gate was obsolete; replaced with `validate.py`.
  The "why this gate exists" story is preserved, extended to explain how the failure
  changed shape rather than disappearing. **RESOLVED.**

### Still open

- **Untested:** whether a local-path marketplace re-reads each session or caches. If it
  caches, the scheduled `git pull` needs a refresh step. Testable only after first install.

## 5. External skills cannot easily go universal

External skills (`impeccable`, `ponytail`, upstream `adhd`) install cleanly as machine-tier
plugins, where no description length limit is documented.

Promoting one to the **universal** tier means the account store's 1,024-character
description cap applies — and you do not control an upstream author's description. Doing so
would require forking the skill, which contradicts the reference-and-pin policy (§2B.3).

**Consequence:** external skills are machine-tier by default. Treat any wish to make one
universal as a decision to fork, and weigh it as such.
