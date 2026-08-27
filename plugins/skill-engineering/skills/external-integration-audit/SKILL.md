---
name: external-integration-audit
description: >
 Audit the implementation of external vendor integrations against their
 official documentation. Use when a project integrates with a third-party
 API, plugin, or event system. Finds unhandled event types, field name
 mismatches, missing data capture, deprecated patterns, and version drift.
 CRITICAL: never proceed on a code comment's claim about vendor behavior —
 locate and read the actual current vendor documentation before comparing
 anything. If real docs cannot be found, stop and say so; do not audit
 against assumptions.
metadata:
  tier: machine
  plugin: skill-engineering
---

# External Integration Audit Skill

## Why Step 0 exists (read this first)

On July 1, 2026, a plugin silently failed to deliver any event, for any
user, ever. The code had a comment claiming "<host-app> docs incorrectly
documented it as context.events — context.eventBus is the real API
(confirmed via diagnostic)." That comment was wrong. It was a past
assumption, never re-checked, treated as settled fact. The real, current
vendor documentation (three separate official <host-app> docs) consistently
showed the opposite. The bug went undetected through multiple audits
because nobody re-opened the actual documentation — they trusted an old
in-code claim about what the documentation said.

Documentation drifts. Vendors correct their own docs. A past developer's
"the docs are wrong, trust me" note is itself a claim that needs
verification, not a fact to build on. This skill exists to compare code
against the real, current external source — every time, not just once.

## When to use
- After significant changes to event handlers or bridge scripts
- When adding a new feature that depends on vendor data
- When a vendor releases a new version or updates their documentation
- When unexplained gaps appear in captured data
- As part of a comprehensive code audit
- Whenever a code comment asserts something about a vendor's API behavior
 that contradicts or overrides the vendor's own documentation — this is
 exactly the pattern that hid the July 1 bug, and is a trigger on its own

---

## Step 0 — Confirm you have real, current documentation (do this first)

Before comparing any code to "the docs," confirm you are actually looking
at the vendor's real, current documentation — not a summary, not a memory,
not a comment in the codebase claiming to describe it.

- Locate the actual documentation files or pages. Check project knowledge
 and project files for vendor PDFs and spec documents — these may exist
 alongside the project even when they are not present in the git
 repository. Check both locations; do not assume "not in the repo"
 means "not available."
- If genuine, current, authoritative documentation cannot be located
 anywhere: STOP. Do not proceed by falling back on code comments, prior
 audit reports, or general knowledge of "how these things usually work."
 Report clearly: "Could not locate current vendor documentation for
 [integration] — this audit cannot verify correctness against a real
 source. Findings below are based on [whatever fallback was used] and
 should be treated as unverified."
- If a code comment claims the documentation is wrong or claims special
 insider knowledge about the real API ("the docs say X but it's actually
 Y, confirmed via Z") — treat this as a claim to test, not a fact to
 build the audit on. Cross-check it explicitly against the real
 documentation you just located. If they disagree, the documentation is
 the default source of truth unless there is verified, current evidence
 (not just an old comment) that the documentation is wrong.
- Note the documentation's own version/date if shown, and flag if it
 looks stale relative to the vendor's current release.

Only proceed to Step 1 once you have confirmed real, current source
material in hand.

---

## Step 1 — Build an integration inventory

List every external integration in the project:
- Vendor name and product
- Integration type (webhook, WebSocket, REST API, plugin, SDK)
- Which files handle this integration (routes, bridge scripts, handlers)
- What documentation exists (URLs, local copies, version numbers) —
 confirmed present per Step 0, not assumed
- Current version in use vs latest available

---

## Step 2 — Event type coverage matrix

For each event-driven integration, build a matrix:

| Event Type (from docs) | Do we receive it? | Do we handle it? | Do we store it? | Do we use it? |
|------------------------|------------------|-----------------|-----------------|---------------|

"Handle" means we have explicit code for it (not just a pass or ignore).
"Store" means we write it to the database or a file.
"Use" means it influences behavior, analytics, or reports.

Flag any event the vendor sends that we receive but silently discard.
Flag any event the vendor sends that we don't receive at all.
Flag any event we handle that the vendor documentation doesn't mention.

---

## Step 3 — Field name and API surface verification

For each event type we handle, compare field by field AND compare the
binding/subscription pattern itself:

### What the vendor documentation says the field/method is called
### What our handler actually reads or calls

Look for:
- Field or method names we read/call that don't exist in the current docs
 (we might be reading the wrong field, or binding to the wrong object,
 and getting undefined/null or silent no-ops — this is exactly the shape
 of the July 1 <host-app> bug: activate() succeeded, version-checked
 successfully, and self-updated successfully, while the one specific
 property access it relied on was wrong the entire time)
- Fields in the docs we aren't reading (data we're discarding that could
 be useful)
- Fields where the doc says the type is X but we treat it as Y
 (e.g., doc says integer, we do string comparison)
- Optional vs required status mismatches
 (we assume a field is always present but doc says it's optional)
- Case sensitivity mismatches (e.g. comparing against 'tiktok' when the
 real value might be 'TikTok' or 'Tiktok' — verify the exact casing shown
 in the documented schema, don't assume)

---

## Step 4 — Coverage gap analysis

Answer for each integration:
- What data is the vendor making available that we aren't capturing?
- Is there a business reason we'd want it? (viewer location, device type,
 subscription tier, chat badges, etc.)
- Are we missing any events that would improve analytics?
- Are we missing any events that are signals for a downstream pipeline?

Rate each gap:
- HIGH VALUE: missing data that would directly improve coaching,
 reports, or clip detection
- MEDIUM VALUE: nice-to-have, could improve future features
- LOW VALUE: available but not relevant to current goals

---

## Step 5 — Version and compatibility check

- What version of each SDK/library is installed (check the dependency
 manifest and the installed package list on <production-host>)?
- What version does the vendor currently recommend?
- Are there deprecation warnings in any vendor docs that affect our usage?
- Does our integration depend on any beta or undocumented features?
- Are there known breaking changes between our version and latest?

---

## Step 6 — Auto-update mechanism audit

For any integration that auto-updates itself, walk this checklist once per
self-updating component:

Version check:
- Does the update check call <version-endpoint> correctly, and compare the
 returned version against the right local value?
- Is the comparison type-correct (string vs semver vs integer), and does it
 handle the endpoint being unreachable rather than assuming "up to date"?

Fetch and write:
- On mismatch, does it fetch from <source-endpoint> and write every file
 the update touches — not just the executable one? Where a component has a
 separate metadata/manifest file that declares its version, that file must
 be written too, or the host will keep displaying the old version even
 though the code updated.
- Does it guard the payload before overwriting (e.g. verify the download is
 well-formed and carries the expected header/signature)? An unguarded
 overwrite turns a truncated download into a broken install.
- Does it record the new version locally after a successful download, so
 the next check compares against reality?

Version stamping:
- If a build or download step stamps a version into the artifact, is it
 stamping the constant that component actually reports
 (<client-version-constant> vs <module-version-constant>)? Stamping the
 wrong constant produces a component that updates forever, because the
 version it reports never changes.

Silent-failure modes:
- Does the auto-update path itself have any silent-failure modes?
- Which files are genuinely covered by auto-update, and which are static?
 Installer and launcher scripts, and any "manual start" variants, typically
 do NOT self-update the way the main script does — confirm what does and
 doesn't self-update, and confirm this is documented accurately for anyone
 troubleshooting a stale install.

Rollout:
- On success, does it log or surface the restart prompt correctly? An update
 that lands but never restarts is not rolled out.

---

## Step 7 — Server-side diagnosability of client failures

Steps 1-6 verify the integration handles events correctly when it runs. This
step asks a different question: **when the client half of the integration
fails on the user's machine, does the server side ever find out?**

Client-side components (a bridge process, an in-app plugin, a local agent) run
on hardware you don't control and can't inspect. A failure there — a crash, a
version mismatch, a dead websocket, a rejected token — is invisible by default:
the server just stops receiving data, which looks identical to "the user isn't
using it." In one real deployment, an entire integration path sent NO liveness
signal at all; clients on that path died mid-session for weeks and the only
server-side evidence was traffic stopping cold, indistinguishable from a quiet
day. The gap was structural, not incidental — no mechanism existed that COULD
have surfaced it.

For every client-side component in the Step 1 inventory, fill in this matrix:

| Component | Liveness signal to server? | Version reported? | Local error log reaches server? | Failure looks like... |
|---|---|---|---|---|
| e.g. bridge | heartbeat every N sec | yes, per heartbeat | tail-upload on restart | alert within 10 min |
| e.g. plugin | NONE | download-time only | no | silence — unknowable |

Flag every row where the honest answer to "what does this failure look like
from the server?" is **"nothing."** For each flagged row, also check the
inverse: is there a watchdog that would notice the signal STOPPING (a stale
heartbeat alarm), or does the signal exist but nothing consumes it? A
write-only liveness signal is the arrival-audit trap wearing a different hat.

Rate a structurally-unknowable failure mode on a revenue- or data-bearing
path as HIGH — the cost isn't the failure itself, it's every week of it that
nobody could have noticed.

---

## Output format

### DOCUMENTATION VERIFICATION (Step 0 result)
Confirm real, current documentation was located and used, or flag clearly
that findings are unverified and why.

### INTEGRATION INVENTORY
Complete list of integrations with version and status.

### EVENT COVERAGE MATRIX
For each event-driven integration: table of events with handle/store/use status.

### FIELD & API SURFACE MISMATCHES
Any field name or binding/method discrepancies between docs and
implementation — including anywhere a code comment claims special
knowledge that contradicts current documentation.

### COVERAGE GAPS (by value)
Data available from vendor but not captured, rated HIGH/MEDIUM/LOW value.

### VERSION STATUS
Current vs recommended versions, deprecation warnings.

### AUTO-UPDATE HEALTH
Status of any self-updating mechanisms, including realistic rollout timing
(e.g. restart lag) and what does/doesn't get covered by auto-update.

### RECOMMENDED ACTIONS
Prioritized list of fixes and improvements.
