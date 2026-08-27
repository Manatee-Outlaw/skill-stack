---
name: ponytail-audit
description: >
  Run the ponytail over-engineering audit against the codebase to find
  structural cleanup opportunities: reinvented standard-library code, unneeded
  dependencies, speculative abstractions, duplicated logic that's drifted apart
  across files, and dead or superseded files nobody deleted. Use periodically as
  part of a comprehensive audit, or whenever the codebase has grown significantly
  since the last run. Trigger phrases: "ponytail audit", "run ponytail",
  "code hygiene audit", "audit for over-engineering", "what can I delete".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Ponytail Audit

## What this is

`ponytail` is a real, third-party, MIT-licensed plugin authored independently by
DietrichGebert — **github.com/DietrichGebert/ponytail**. It is NOT Anthropic's and
NOT exclusive to Claude Code: the repo ships adapters for other agent hosts too
(Codex, Cursor, Windsurf, Gemini/Antigravity, OpenCode, and others — each has its
own config directory in the plugin).

Verified locally 2026-07-23 from the installed plugin: marketplace source
`DietrichGebert/ponytail`; `LICENSE` = MIT © 2026 DietrichGebert; installed here
as the Claude Code plugin `ponytail@ponytail`, v4.7.0 (installed 2026-06-23; check
the repo for the current version).

What it does: it enforces a YAGNI-first "ladder" before code is written — does
this need to exist at all? is it already in the codebase? does the stdlib do it? a
native platform feature? an already-installed dependency? can it be one line? —
and only then the minimum code that works. Its audit commands turn that same lens
on existing code. This is a different category of finding than a security audit or
a bug hunt: not "is this broken," but "has this accumulated mess — a reinvented
helper, a dependency doing what five lines would, an abstraction with one caller,
a dead file beside its thriving replacement — that will cause a bug or a
maintenance tax later."

The plugin exposes several commands; the ones relevant here:

- **`/ponytail-audit`** (skill `ponytail:ponytail-audit`) — audits the WHOLE repo
  for over-engineering and hands back a delete/simplify list. This is the one this
  skill drives.
- **`/ponytail-review`** (skill `ponytail:ponytail-review`) — the same lens on a
  diff rather than the whole repo (use during review of a specific change).
- **`/ponytail-debt`** (skill `ponytail:ponytail-debt`) — harvests deferred
  `ponytail:` marker comments into a ledger so the shortcuts it leaves behind get
  tracked, not forgotten.

## Availability in this session (verified, not assumed)

As of 2026-07-23 the plugin IS installed and active in this Claude Code session
(it started in "PONYTAIL MODE"). The whole-repo audit is invocable both as the
slash command `/ponytail-audit` and as the skill `ponytail:ponytail-audit`.

Do not carry the invocable name forward from memory — a plugin that isn't
installed can't be run, so in a fresh session check the available plugins/skills
first. If it is NOT installed, add it via the marketplace (two prompts):

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

## When to use

- As part of a comprehensive audit, alongside the other engineering skills
- Whenever the codebase has grown significantly since the last run (many
  commits, several new features) and hasn't had a structural cleanup pass
- When something feels harder to maintain than it should, and duplicated or
  drifted code is suspected as the reason

## How to run it

Say "run a ponytail audit" (or `/ponytail-audit`) to trigger the whole-repo scan.
It is an existing capability — your job is to run it and capture the full output.
If generating a task.md for Claude Code, the instruction is simply:

```
Run /ponytail-audit (the ponytail:ponytail-audit skill) against this repository.
Report every finding it produces, in full — do not summarize or filter the list
before showing it back.
```

## How to triage the findings

Ponytail findings are structural cleanup opportunities, not urgent bugs. Land
every finding on exactly one of three outcomes — never leave one unaddressed
with no reasoning either way:

- **RESOLVED** — fix it now if it's small and safe (consolidate a helper that
  drifted into several inline copies; replace a duplicated definition with a
  single import; delete a genuinely dead, fully-superseded file). Per
  verify-before-claiming, prove the fix didn't change behavior for any call site
  that depended on a quirk of the pre-fix duplication — a consolidation that
  silently breaks one caller is worse than the mess it replaced.
- **KEPT AS-IS, WITH REASONING** — a finding that looks like a problem but is
  deliberate (e.g. audit documents flagged as redundant that are intentionally
  kept as historical record). Decline it with the reasoning stated, not silently.
- **DEFERRED** — a genuine finding not worth the complexity or risk to fix now
  (e.g. near-identical builders that are cheaper left separate). Defer with a
  stated trigger condition to revisit ("revisit if a fourth similar builder is
  added").

## Trigger this skill

- "ponytail audit", "run ponytail", "code hygiene audit", "audit for over-engineering"
- As part of a comprehensive audit run, when a full structural pass is warranted
  in addition to the standard checks
- After a long stretch of active feature development, before the codebase
  accumulates too much drift to clean up cheaply
