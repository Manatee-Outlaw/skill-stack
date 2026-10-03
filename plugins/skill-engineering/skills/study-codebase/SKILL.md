---
name: study-codebase
description: >
  Reverse-engineer a well-built piece of software inside and out, deeply document it,
  and add it to the team's knowledge vault — mining reusable patterns, dependencies,
  and opportunities for our own products as it goes. Use when the user says
  "reverse-engineer this", "study this software/codebase", "document how X works internally",
  "add this to the vault", "dig into this program", or points at an app/repo to
  understand deeply. Handles open-source (real source) and closed/bundled apps
  (extract asar, decompile) behind a legality gate.
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---


# study-codebase

Turn any well-built software into documentation AND education: a line-verified
account of how it works, plus reusable engineering knowledge mined for our own
builds. This is our compounding "programming education." The vault lives at
`<knowledge-vault>` — the folder the team keeps for studied software and its mined
library; if none exists yet, Step 3 creates the scaffolding.

Pair with **unlazy** (completion discipline for the deep pass) and **adhd** (at
genuinely ambiguous mechanisms — test alternative hypotheses, don't take the
first read). This is not ponytail work — depth is the deliverable.

## Step 0 — Legality / authorization gate (ALWAYS FIRST)

Before touching anything, confirm we may study it:
- **Open-source** with a license permitting study → proceed (note the license).
- **Ours**, or the user has a contractual right to the source → proceed.
- **Otherwise authorized** (pentest scope, the user owns it) → proceed.
- **Refuse or limit** if it would mean circumventing a license/DRM/anti-tamper
  check (DMCA §1201 is a separate statute from any source-rights), targeting a
  hostile third party, or violating ToS in a way the user hasn't authorized.
  State the concern in a sentence and ask, or scope down to what's allowed.

Reverse-engineering to understand/interoperate is generally fine; circumventing
protection or redistributing others' code is not. When unsure, flag it and let
the user decide.

## Step 1 — Fingerprint the runtime

Decide the extraction path. Look at the install dir + main binary:
- **Electron** (`resources/app.asar`, chromium `.pak`s, `ffmpeg.dll`) → extract
  the asar (Step 2a). Best case: readable JS.
- **.NET / Java / Python `.pyc` / Android** → decompile (near-original source).
- **Go / Swift / Delphi** → readable structure, mangled names.
- **Native C/C++** → assembly → messy pseudo-C; a rewrite is often cheaper than
  full RE. Set expectations.
The runtime decides how much you recover. Report the bucket before budgeting.

## Step 2 — Obtain the source

- **Open-source:** `git clone --depth 1` into `_sources/<name>/` (gitignored).
  Real `.ts`/source beats any reconstruction.
- **2a. Electron asar extraction** (the gotchas — get these right):
  - Data offset = `8 + <pickle payload size>` (read `UInt32LE` at byte 4), NOT
    `16 + <json string len>` — the header is padding-aligned.
  - **Unpacked entries** (`"unpacked": true`) have NO bytes in the archive — copy
    them from the sibling `app.asar.unpacked/` dir; reading `size` bytes from the
    archive yields garbage.
  - Check for a shipped **`.tsbuildinfo`** — it lists every original source path
    (recover the original module tree even from a flattened bundle).
  - A non-minified bundle (comments/JSDoc intact) IS effectively the source.
- Keep clones/extracts under `_sources/<name>/` (read-only, gitignored).

## Step 3 — Set up the vault subject

`programs/<name>/` for docs. Confirm `_sources/` is gitignored. If this is the
first study in a fresh vault, ensure the vault scaffolding exists (README, INDEX,
`library/`, `standards/`).

## Step 4 — Map the architecture (the spine)

Write `programs/<name>/01-architecture.md`: what it is, process/module model,
entry point + boot sequence, the service/module graph, the central data flow, IPC
contract, where state lives, external dependencies, cryptographic/trust
touchpoints. Everything else hangs off this. Verify against code (entry file,
handler registration), cite `file:line`.

## Step 5 — Deep-read each subsystem (verify, don't assume)

For each subsystem, read the actual implementation and document exact mechanisms,
protocols, data shapes, state machines, retry/reconnect logic, edge cases, and
error handling. Rules:
- **Cite every claim** to the location it was verified from.
- **Don't assume the docs (or names) match the code** — verify. If the code
  disagrees with a comment/rules-doc, the code wins; note the discrepancy.
- **ADHD at the traps:** where a mechanism is non-obvious AND getting it wrong is
  costly (how it *really* connects to an external service; whether an AI is
  *trained* vs. inference; a security/safety model), test alternative hypotheses
  and record why the losing ones were cut. Running a 10-frame swarm on a
  canonical "what does this code do" question is theater — apply the *rigor*, not
  the ceremony, and reserve formal ADHD for genuinely open/interpretive questions.
- **Correct your own earlier claims** plainly when a deeper read overturns them.

## Step 6 — Mine into the library AS YOU GO (the point)

This is what makes it education, not just documentation. For every subsystem, ask
"what can WE reuse, cut, adopt, or avoid?" and write it into the cross-software
layers, tagged 🟢 adopt / ✂️ cut-simplify / ⚠️ avoid:
- `library/reuse-and-opportunities.md` — concrete moves tied to our products.
- `library/patterns.md` — reusable architectural patterns.
- `library/dependencies.md` — adopt/own/avoid (also our third-party-solution index).
- `library/best-practices.md` — techniques + hard-won rules.
- `library/anti-patterns.md` — traps (dead-server deps, shipped secrets, façade
  gates, etc.).
Promote anything strong enough into `standards/` (what we stand by).

## Step 7 — Surface consequence-carrying findings immediately

Security holes, hidden/dead external dependencies, shipped secrets, safety
mechanisms, dead-man's-switch servers — surface these to the user as you hit them
(consequence-ranked), don't bury them in docs. This is where the real value lands.

## Host / environment-migration drift (a standing audit lens)

When software was sized/tuned for one environment but now runs in another — a host move
(in one measured case, a home single-board computer to a cloud VM, 2026-08-12), a VM resize, a container change, a runtime
bump — the dangerous bugs are the assumptions **nobody re-derived**. They pass every test on
the OLD box and fail silently on the new one. Run this lens on any codebase that has changed
where it runs (and it's the audit half of "verify, don't assume"):

- **Resource sizing** — worker/thread/pool counts, request-size caps, buffer/queue/cache
  sizes chosen against the OLD RAM/cores. Do the math on the NEW box (e.g. body-cap ×
  worker-threads vs available RAM) and **MEASURE live RSS** rather than guessing. `free`'s
  "free" column reads low because of reclaimable buff/cache — use **`available`**.
- **Swap / OOM** — a box with no swap turns a spike the old box absorbed into a hard
  OOM-kill; note any in-process state (session dicts, caches, open file handles) a kill
  vaporizes, and whether a recycle valve (`max_requests`) is even usable given that state.
- **CPU count** — anything scaled to the old core count (concurrency, parallelism).
- **Runtime/language version** — features that work on the old interpreter and break on the
  new one (Python 3.11 `datetime.fromisoformat('…Z')` / `tomllib` / `except*` on 3.10, etc.).
  The old version MASKS these — grep + read, don't assume.
- **Timezone / clock** — host-local `now()` vs UTC; cron hour-fields vs the new host TZ (the
  classic: jobs firing N hours early after a UTC move). Prefer UTC end-to-end.
- **Hardcoded paths / IPs / hostnames** from the old host; SD-card / disk-size assumptions.
- **Perf-tuned constants** — timeouts/retries/sleeps tuned for old-hardware speed.

For each: is it **ACTIVELY wrong** on the new box, or a stale comment? Verify at `file:line`,
rank by consequence, and where the answer is "depends on headroom," **measure on the live
host and record the measurement** so the finding is CLOSED, not left as "NEEDS A CALL."

## Step 8 — Index, commit, report

Update `INDEX.md` + the "software studied" table. Commit the vault. Report a
consequence-ranked findings summary + the top reuse opportunities.

Every finding in that summary carries an `evidence:` line — the `file:line` it was
verified at, tagged **[proven]** (you read or ran it) or **[inferred]** (reasoned from
names, docs or structure). An absence ("no telemetry", "no licence check", "nothing
phones home") cannot point at a line: state where you searched — which files, which
pattern, how much of the source tree was actually recovered.

## Standards while doing this

Apply our defaults to any tooling you write here: **persist-and-restore** (clean
up `_sources`/temp, don't leave orphaned state), secure subprocess, etc. If a
build-vs-buy question arises mid-study, use the `find-existing-solution` skill —
and note that *studying competitors' code is itself a discovery method for it*
(EulerStream was found by studying a competitor's desktop tool).
