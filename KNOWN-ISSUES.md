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

## 2. `improve-system` — needs the Notion lesson log

Writes lessons to `knowledge/me/experiences/` in Google Drive. Target is a Notion database,
one page per lesson, edited in place. Blocked on creating that database.

Notion is already connected at account level — no authorisation needed.

## 3. `hermes-upload` — repoint to Notion

Currently uploads handoffs to Google Drive with `v1`/`v2`/`v3` auto-increment and a
hardcoded folder ID. Both are the sprawl this architecture removes, and Drive is
unreachable from a tablet — which defeats a handoff's whole purpose.

Target: one Notion page per chat title, edited in place, page history as the version log.

**Preserve verbatim** on port — the best line in the skill:

> Every number in the handoff must carry its provenance — sample or population, measured or
> estimated, and by whom — because a figure that loses its denominator in a handoff becomes
> a false statistic in the next session, which has no way to see the qualifier was ever there.

Keep the existing fallback: if the connector is unreachable, print the handoff in chat
rather than failing silently.

*(Exempted in `validate.py`'s allowlist meanwhile, since Drive is legitimately its
destination until the port.)*

## 4. Unresolved from planning

- **`unlazy` is missing.** Not anywhere in `F:\Projects`. Pi or claude.ai account.
- **ADHD duplication** — `UditAkhourii/adhd` upstream vs the local `adhd`. Pick a canonical one.
- **`ponytail-audit`** is a wrapper around `DietrichGebert/ponytail`. Install the real
  plugin and slim the wrapper.
- **Untested:** whether a local-path marketplace re-reads each session or caches. If it
  caches, the scheduled `git pull` needs a refresh step.

## 5. External skills cannot easily go universal

External skills (`impeccable`, `ponytail`, upstream `adhd`) install cleanly as machine-tier
plugins, where no description length limit is documented.

Promoting one to the **universal** tier means the account store's 1,024-character
description cap applies — and you do not control an upstream author's description. Doing so
would require forking the skill, which contradicts the reference-and-pin policy (§2B.3).

**Consequence:** external skills are machine-tier by default. Treat any wish to make one
universal as a decision to fork, and weigh it as such.
