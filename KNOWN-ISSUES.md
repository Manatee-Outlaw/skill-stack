# Known issues

Tracked deliberately rather than bodged. `scripts/validate.py` fails on 1 and 2 by design —
that failure is the reminder.

## 1. `skill-library-audit` — needs a rewrite, not a patch

Built end-to-end on the retired `bundles/` system:

- Step 0 loads skills from `raw.githubusercontent.com/.../vibecraft-skills/main/<bundle>/`
- The orphan check is defined as "a skill in the repo named in NO bundle"
- The dead-link check is "a bundle names a skill that does not exist"
- Reporting counts "skills in active bundles"

**Both checks are now structurally impossible** — there are no bundles to fall off. The
replacement concept is different: a skill is unreachable not when it is unlisted but when
its *description* is too vague to trigger. That is a genuinely harder audit and deserves
designing, not patching.

Also still references Google Drive as the private-skill home. Private skills now live in
`skill-stack-private`.

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
