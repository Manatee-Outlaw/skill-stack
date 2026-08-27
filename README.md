# skill-stack

A project-agnostic skill library for Claude. Authored once in git, delivered to two tiers.

## Layout

```
.claude-plugin/marketplace.json   marketplace definition
plugins/skill-core/               always-on disciplines + adhd  (install everywhere)
plugins/skill-engineering/        code, architecture, security, release
plugins/skill-creative/           design, generative art, theming
plugins/skill-productivity/       planning, coaching, decisions
plugins/skill-enterprise/         brand, comms, legal
scripts/validate.py               run before every commit
scripts/build-zips.sh             build universal-tier uploads into dist/
CLAUDE.md                         always-on standing instructions
```

Each skill is a folder containing `SKILL.md`. Capitalisation is significant.

## Two tiers

| Tier | Where it lives | Reaches | Updates |
|---|---|---|---|
| **universal** (23) | claude.ai account store | any device, incl. tablets | manual zip upload |
| **machine** (25) | this repo, as plugins | Claude Code / Cowork | scheduled `git pull` |

Tier is recorded per skill in `metadata.tier`. The universal tier exists because plugins
cannot reach a device with no filesystem.

## Install (machine tier)

```
/plugin marketplace add F:\Projects\skill-stack
/plugin install skill-core@skill-stack
/plugin install skill-engineering@skill-stack
```

Local path, not the GitHub URL — that makes `git pull` the update mechanism, so a scheduled
pull keeps every machine current with no command to remember.

## Publish (universal tier)

```
python3 scripts/validate.py
./scripts/build-zips.sh
```

Then upload the changed zips from `dist/` at claude.ai → Customize → Skills.
`SKILL.md` sits at the zip root; nesting it in a folder makes the upload fail silently.

## Operational gotchas

**Never remove a marketplace to refresh it.**

```
claude plugin marketplace update skill-stack     # refresh - safe
claude plugin marketplace remove skill-stack     # DESTRUCTIVE
```

Removing a marketplace from its last remaining scope **also uninstalls every plugin
installed from it.** To pick up new work, always `update`. There is no reason to `remove`
unless you are retiring the library.

**Every slash command has a CLI form — prefix it with `claude`.**

| Where | Command |
|---|---|
| PowerShell / terminal | `claude plugin marketplace add F:\Projects\skill-stack` |
| Inside Claude Code, or Cowork chat | `/plugin marketplace add F:\Projects\skill-stack` |

They are equivalent. `/plugin` typed at a shell prompt fails with
`CommandNotFoundException` — the shell has no idea what it is.

**The marketplace serves whatever is checked out.** A local-path marketplace reads the
working tree in that folder, not GitHub. Check out an older branch there and it silently
serves the old skills.

**Verify, do not assume.** Installing is not loading. After installing, start a fresh
session and confirm the skills are actually listed. A skill that failed to load is
indistinguishable from one that loaded and did not trigger.

## Before every commit

```
python3 scripts/validate.py
```

Checks structure, name and description limits, duplicates, and the portability gate
(no project names, no absolute paths, no cloud-folder coupling, no raw GitHub self-links).

## Related

- `skill-stack-private` — sensitive skills. Local only. Never pushed, never uploaded.
- `EXTERNALS.md` — every third-party dependency, pinned. Referenced, never copied.
  Includes `adhd`, which is a **declared managed fork** with a documented re-sync procedure.
