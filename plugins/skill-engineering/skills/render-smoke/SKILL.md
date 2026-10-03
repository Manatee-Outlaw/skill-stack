---
name: render-smoke
description: >
  Drives a real browser against seeded NON-PRODUCTION accounts (staging or a seeded local
  instance, one account per role), renders every view with real data, and asserts the
  RENDERED DOM is free of the universal broken-render signatures (undefined / NaN / $0 /
  undefinedh / null% / [object Object] / Invalid Date / a date sliced to one digit) — the
  class that static contract checks and code review structurally cannot see, because it only
  exists in pixels a logged-in user looks at. Optionally clicks success-claiming controls and
  asserts a mutating request actually fired (kills fake-success). Runs as one dedicated
  subagent in a comprehensive audit. Trigger phrases: "render smoke", "does every page
  render", "the page shows undefined", "NaN on the dashboard", "check the screens with real
  data", "click through every view".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# render-smoke

**Why this exists.** A contract check proves the server *could* send a key; a live smoke
test proves it *is* sent; neither proves the screen is right. One pre-launch audit
(2026-07-27) verified contracts and code but never drove the authenticated UI, and missed
four live-only bugs — reports rendering "$0 / undefinedh", a trends axis showing "3" instead
of "Jul 3", a "Download" that printed the page, a dead hover tooltip. Every one only existed
on a rendered page. This skill closes that gap.

## Prerequisites (report as an audit COVERAGE GAP if missing — do not silently pass)

- A reachable **non-production** URL (`SMOKE_BASE`) running the same code as
  `<production-host>` against a separate database — a staging server, or a local instance of
  `<host-app>`. The project's staging/setup doc says how to bring one up. Never run the
  interaction layer against production.
- **Seeded** accounts, one per role, created by the project's seed script (`<seed-script>`).
  An empty state is legitimate and HIDES the drift this catches — an unseeded environment is
  not a pass, it is no data.
- Seed dates must be **relative to now**, not absolute. A seed with fixed dates ages out of
  every "last N days" window the pages read; every view then renders its empty state and the
  smoke run keeps passing (measured — see fixture-realism-audit). Confirm the seeded views
  actually show data before trusting a clean run.
- `playwright` + chromium where the runner executes.

If no seeded non-production environment is up, the honest finding is "render-smoke could not
run: no seeded staging" — a gap in coverage, not ALL CLEAR.

## The runner (`<render-smoke-runner>`)

The project keeps one script that does the browser work. If it does not exist yet, building
it is the first finding. It must:

1. Read `SMOKE_BASE` and the seed credentials from the environment (never hard-code them).
2. Log in once per seeded role.
3. Click through every navigation view that role can reach.
4. Scan each view's `innerText` for the signature list, and print one line per hit:
   `RENDER-SMOKE [role/view] signature '…': …snippet…`.
5. Optionally run an `INTERACTIONS` list of `(role, label, selector, must-hit-endpoint)`
   tuples: click the control, and assert a mutating network request to that endpoint fired
   and resolved.
6. Exit non-zero on any hit, and with a **distinct** code when it could not run (no browser,
   login failed, zero views found) — "could not run" must never read as a pass.

## Steps

1. Confirm the environment is reachable and seeded (`curl -sI $SMOKE_BASE/<login-path>` →
   200; the seed accounts exist; a seeded view shows non-empty data). If not, stop and report
   the coverage gap.
2. Run the engine:
   ```bash
   export SMOKE_BASE=<staging-url>; export SEED_PASSWORD=<seed-password>
   python3 <render-smoke-runner>
   ```
   It logs in per role, clicks through every nav view, and scans each view's innerText for the
   signature list. Exit non-zero + `RENDER-SMOKE [role/view] signature '…': …snippet…` lines
   are your raw findings.
3. For the destructive **interaction-backing** layer (fake-success detection — the
   owner-delete / change-password class), populate the `INTERACTIONS` list in the runner
   with `(role, label, selector, must-hit-endpoint)` tuples and re-run **against
   non-production only**. An unbacked success ("clicked but NO /remove write fired") is a
   HIGH finding.
4. Triage each signature to what the USER receives (a manager reading "+0%" for every user;
   an end user seeing "$0 / undefinedh"): rate by impact, not "the page didn't crash".

## Governing standards (as for every audit subagent)

- **verify-before-claiming**: the runner IS the execution proof — cite the exact
  `RENDER-SMOKE …` line. An ALL CLEAR must show the run actually happened and could have come
  back dirty (environment was seeded, login succeeded, N views scanned) — a run that skipped
  (no playwright / no SMOKE_BASE / empty staging) reports SKIP, never CLEAN.
- **trust-the-live-signal**: the rendered pixel is the signal; a green contract check is not.
- **close-known-gaps**: if a signature appears in one view, grep the codebase for the sibling
  render pattern and check every view, not just the one the browser happened to catch.
- **user-impact rating**: "$0"/"undefined" on a data-bearing view is never LOW.

## Output (audit format)

```
[render-smoke] FINDINGS:
HIGH: manager roster shows "+0%" momentum for every user | FILE: <template-or-view-file> | FIX: server payload drift
  evidence: RENDER-SMOKE [manager/roster] signature '+0%': …snippet… [proven]
...
ALL CLEAR: <views scanned per role, and that staging was seeded + login worked so it could have failed>
SKIP: <why the run could not happen — this is a coverage gap, not a pass>
```

Every finding carries an `evidence:` line: the exact `RENDER-SMOKE` line, tagged
**[proven]**, or **[inferred]** for a sibling view found by grep but not driven. A clean view
is an absence claim: state where it ran — which environment, which roles, how many views.

## Project-agnostic core

The signature list (`undefined`, `NaN`, `$NaN`, `[object Object]`, `undefinedh`, `null%`,
`Invalid Date`, …) and the interaction-backing rule ("a control that toasts success must be
backed by a resolved network write") are universal — only `SMOKE_BASE`, the seed accounts,
and the `INTERACTIONS` tuples are per-project.
