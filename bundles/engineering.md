# Bundle: Engineering Project
# Versioning: this file is edited IN PLACE. Git history is the version log —
# run `git log --follow bundles/engineering.md` to see every change. Do NOT add a
# -vN.N suffix to any file in this repo; that convention existed only because Google
# Drive could not edit files in place, and suffixed filenames break the raw URLs that
# project instructions point at.
# Last substantive change: 2026-07-24 — registered engineering/adhd.md and
# improve-system/skill.md. Both existed in the repo but were named in NO bundle, so no
# session ever loaded them; adhd was missed on the exact request it was built for. An
# unreferenced skill file fails silently — it looks identical to one that loaded and
# simply did not trigger. Closed the loop in three places: push-to-git now refuses to
# finish a commit that adds a skill file without a bundle entry, skill-library-audit and
# session-cold-start now both run an orphan/dead-link check, and the load receipt is now
# mandatory so a skipped load is visible to the user instead of silent.
# Last substantive change: 2026-07-23 — added engineering/backlog-reconciliation.md
# after two items independently flagged as the backlog's highest-risk open work
# (TD-1, TD-34) turned out to already be fully done weeks earlier, with nothing
# marking them closed. Also added Check 11 (control reachability) to ux-review.md
# and broadened its scope to explicitly cover manager/scout/owner tooling, not just
# the streamer-facing product, after a real bug where a working, tested delete
# button was unreachable from the one state a real user was actually in.
# Also 2026-07-23 (post-audit fixes): registered engineering/re-verify-carried-claims.md
# into the load list + always-on set (it existed and was referenced by
# comprehensive-audit.md but was never actually loaded by this bundle); corrected
# ponytail-audit's authorship — it is a REAL third-party MIT plugin by DietrichGebert
# (github.com/DietrichGebert/ponytail), installed here as ponytail@ponytail; an
# intermediate edit wrongly called it Anthropic-authored, which was also false; and
# replaced hardcoded governing-standard/discipline
# counts here and in several skills with references to the actual lists, so they
# stop drifting out of sync as the lists change.

Load these skills at the start of any software/coding project conversation.

## Skills to load (in order)

1. engineering/grill-with-docs.md
2. engineering/diagnose.md
3. engineering/to-prd.md
4. engineering/improve-codebase-architecture.md
5. engineering/flow-test.md
6. engineering/holistic-code-audit.md
7. engineering/verify-before-claiming.md
8. engineering/task-authoring.md
9. engineering/verify-before-versioning.md
10. engineering/trust-the-live-signal.md
11. engineering/no-assumed-memory.md
12. engineering/re-verify-carried-claims.md
13. engineering/propagate-the-fix.md
14. engineering/propagate-the-lesson.md
15. engineering/close-known-gaps.md
16. engineering/no-dead-ends.md
17. engineering/hostile-environment-testing.md
18. engineering/anticipate-user-mistakes.md
19. engineering/ponytail-audit.md
20. engineering/push-to-git.md
21. engineering/engineering-review.md
22. engineering/architecture-review.md
23. engineering/database-hygiene.md
24. engineering/ux-review.md
25. engineering/mobile-ux.md
26. engineering/cross-project-audit.md
27. engineering/external-integration-audit.md
28. engineering/security-audit.md
29. engineering/production-drift.md
30. engineering/skill-library-audit.md
31. engineering/session-cold-start.md
32. engineering/version-management.md
33. engineering/comprehensive-audit.md
34. engineering/discord-announcements.md
35. engineering/hermes-upload.md
36. engineering/backlog-reconciliation.md
37. engineering/respect-settled-decisions.md
38. engineering/adhd.md
39. improve-system/skill.md

(copy-review, database-review and board-of-directors are intentionally absent — see the PRIVATE section below.)

(`legal-paralegal.md` at the repo root is the ONE file intentionally left unbundled — it
is loaded by hand when legal drafting is needed. Every other skill file in this repo must
appear in at least one bundle. A file that is in the repo but in no bundle is an ORPHAN:
it never loads, and nothing announces that it didn't. Register it or delete it.)

## What each skill does (plain English)

- **grill-with-docs** — Before building anything, interview the user to nail down exactly what they want and why.
- **diagnose** — When something is broken, follow a disciplined 6-step process to find and fix it properly rather than guessing.
- **to-prd** — Turn a conversation into a formal written spec so there is a clear record of what was agreed before work starts.
- **improve-codebase-architecture** — Periodically survey the codebase for tangles and structural problems before they become expensive bugs.
- **flow-test** — Walk through the product as a real user would, checking every journey works end-to-end. Now the canonical home for the "integration seam check" technique (data-handoff tracing), also referenced by holistic-code-audit rather than duplicated there. Phase 3 requires opening a real, recent output artifact (report, PDF, email, export) and reading it as the recipient — "it generated without an error" is not "it is correct".
- **holistic-code-audit** — The full multi-discipline code audit (runs in chat; see its own "Audit Disciplines" list for the current set). Discipline 6 now points to flow-test's Phase 0 for the integration seam check instead of repeating it. Use engineering-review for deeper Claude Code audits.
- **verify-before-claiming** — Requires real execution proof before any report says "fixed," "working," "deployed," or "verified" — and the same proof before any report says "clean," "no hits," or "all tests passed," because a scan that aborted or never ran reports identically to a real pass. Prove a check can fail before trusting that it didn't — then check what it was pointed at, because a live instrument with the wrong pattern returns the same clean zero as a right one. Names two anti-patterns literally: `echo "EXIT: $?"` (captures echo's status) and `gh api /user` (Git Bash rewrites it to a filesystem path); both hand back a plausible empty result instead of crashing. Always-on.
- **task-authoring** — Governs how task files are written for an implementer. Every task.md opens with an ASSUMPTIONS block (each factual dependency, its source, verified or not); in any domain the author cannot see — code, server, database, target OS — state the GOAL, never the mechanism. The implementer enforces it: no assumptions block, or a mechanism the author couldn't have verified, gets called out and the goal followed instead. Always-on.
- **verify-before-versioning** — Before creating any new skill file, or a new version of an existing skill/bundle, always do a fresh, live search of the actual Drive folder right now. Always-on.
- **trust-the-live-signal** — When a stored value, documentation, or a surface-level observation disagrees with a live, directly-checkable signal, trust the live signal. Always-on.
- **no-assumed-memory** — Never assume a fresh session shares memory with a different conversation. Always-on whenever work crosses a session boundary.
- **re-verify-carried-claims** — Before repeating a specific figure, date, named example, or count carried from an earlier report/handoff/task, re-verify it live — a real saved report satisfies no-assumed-memory and can still be stale, and repeating it unchecked launders the error into a fresh document with fresh authority. Sibling of no-assumed-memory (that covers claims remembered from conversation; this covers claims READ from a saved report and repeated). Always-on.
- **propagate-the-fix** — Whenever a bug is fixed, actively search the codebase for the same underlying pattern elsewhere. Always-on.
- **propagate-the-lesson** — Whenever a genuinely general-purpose lesson or fix is identified, check every bundle for the same applicability, and check comprehensive-audit's own registration lists. Always-on.
- **close-known-gaps** — Once a real, known issue has been surfaced, the default is to fix it now rather than narrowing scope. Always-on.
- **no-dead-ends** — Whenever something can enter a "not working" state, prove there's a real path back to working. Always-on for error states, reconnect cycles, and user-triggered stops.
- **hostile-environment-testing** — Before trusting any installer, launcher, or scheduled script, test it against messy real-world conditions.
- **anticipate-user-mistakes** — For every user-facing control, imagine the most natural mistake and check the real consequence. Distinct from ux-review's Check 11: this asks "what happens when they misuse a control they found," not "can they find it at all."
- **ponytail-audit** — Runs the `ponytail:ponytail-audit` / `/ponytail-audit` over-engineering scan for structural cleanup opportunities (reinvented stdlib, unneeded deps, dead/superseded files, drifted duplication). ponytail is a real third-party MIT plugin by DietrichGebert (github.com/DietrichGebert/ponytail), installed here as `ponytail@ponytail` — not Anthropic's, not exclusive to Claude Code.
- **push-to-git** — Full deploy in one command. Trigger: "push to git [message]", "deploy", "ship it".
- **engineering-review** — Full 8-check bug hunt via Claude Code. Trigger: "engineering review", "code audit".
- **architecture-review** — Deep structural analysis. Trigger: "architecture review".
- **database-hygiene** — Design principles for SQLite tables and INSERT logic, plus the arrival audit: whether data is actually landing in a column, not just whether its absence can break anything. Empty or uniform is a finding; write-only columns have no consumer to notice they broke.
- **ux-review** — Heuristic evaluation of the interface, covering both the streamer-facing product and manager/scout/owner tooling. Includes Check 11: whether a control is actually reachable from the real state a user will be in, not just present somewhere in the DOM. Trigger: "UX review".
- **mobile-ux** — Reviews the interface for mobile use. Trigger: "mobile review".
- **respect-settled-decisions** — Before any review-type skill flags a finding, check whether it was already deliberately reviewed and kept as-is (a `REVIEWED <date>` marker) — a settled decision isn't a fresh finding. Built after a copy-review pass re-flagged a decision that was already recorded in a code comment the same day. Always-on for every review-type skill.
- **cross-project-audit** — Audits how multiple Claude project chats interact. Trigger: "cross-project audit".
- **external-integration-audit** — Audits implementation against vendor documentation. Mandatory Step 0: confirm real, current docs were used. Trigger: "integration audit".
- **security-audit** — Focused security review. Trigger: "security audit".
- **production-drift** — Compares GitHub vs live production server. Trigger: "production drift".
- **skill-library-audit** — Audits the skill library itself. Trigger: "audit our skills".
- **session-cold-start** — Loads all context to start a working session. Trigger: "start the session", "cold start".
- **version-management** — Checklist for bumping version constants. Trigger: "bump the version".
- **comprehensive-audit** — Runs the full engineering audit via concurrent subagents. All governing standards are baked into the skill itself and apply automatically. Trigger: "comprehensive audit", "full audit", "audit everything."
- **discord-announcements** — Drafts Discord announcements. Trigger: "draft a Discord announcement".
- **hermes-upload** — Generates a handoff document and uploads to Drive. Every number in the handoff carries its provenance — sample or population, measured or estimated, by whom — because the handoff is the one document every cold start trusts and never re-derives, so a denominator dropped here becomes a false statistic downstream. Trigger: "hermes upload".
- **backlog-reconciliation** — Determines the REAL current status of every tracked backlog item (TD-/DF-/BUG-/PE- numbered or otherwise) by combining a git log sweep with a full documentation cross-reference, rather than trusting an existing document's claimed status. Built after TD-1 and TD-34 both sat on the active backlog for weeks after already being finished. Trigger: "reconcile the backlog", "audit our backlog", "is this still open".
- **adhd** — Parallel divergent ideation for open-ended, high-stakes decisions. Spawns 5 isolated Agent branches under different cognitive frames (regulator, biology, speedrunner, 10-year-old, $0-budget), then scores, clusters, flags traps, and deepens the top 3. Role-neutral by design — works on architecture, schema, public API surface and fuzzy no-root-cause bugs, and equally on pricing, positioning, naming and go-to-market. Costs ~10 Agent calls (5–10x a single answer), so it self-gates: skip for lookups, syntax, known answers, or closed phrasing ("quick", "standard", "canonical"). Trigger: "/adhd", "brainstorm", "let's figure out", "help me think through", "explore options", "what are my options", "ideate".
- **improve-system** — End-of-session review that folds what actually happened back into the skill library: updates skill files that were iterated on, saves lessons and decisions to the knowledge folder, flags stale or duplicated content. Complements hermes-upload — hermes records what happened, improve-system changes the system because of it. Trigger: "/improve-system".

## PRIVATE — not in this repo; load from Google Drive

These load from Google Drive, not this repo. **Drive files are still version-suffixed**
(Drive cannot edit in place) — always search Drive for the highest-numbered version
rather than assuming a filename. The private set is exactly:

- **copy-review** — Reviews product-specific interface copy. Private: it is written against one product's voice and names a real person. Trigger: "copy review".
- **database-review** — Operational database audit against a live production database. Private: saturated with live operational internals. The generic half is covered by the public database-hygiene. Trigger: "database review".
- **board-of-directors** — the skill AND its profile (`board-of-directors-default-profile-*.md`). Both private. The skill was public until 2026-07-15, when it turned out to hardcode a roster of real, named people and a domain taxonomy calibrated to one person's circumstances — the profile was never the only sensitive half.

## When to run each review

- engineering-review: before any significant release, after a bug-heavy session
- architecture-review: quarterly, or before a major new feature
- ux-review + mobile-ux: before any public-facing release, and before shipping any
  significant change to manager/scout/owner tooling (Check 11 applies to both)
- flow-test: before releasing any new feature — also run alongside holistic-code-audit discipline 6 for the full integration-seam treatment
- production-drift: after every major sprint, and before any hosting migration
- skill-library-audit: after every major sprint, or when a production failure reveals a skill gap
- session-cold-start: at the beginning of every session
- hermes-upload: at the end of every session
- verify-before-claiming, task-authoring, verify-before-versioning, trust-the-live-signal, no-assumed-memory, re-verify-carried-claims, propagate-the-fix, propagate-the-lesson, close-known-gaps, no-dead-ends: always-on, every time, no exceptions.
- respect-settled-decisions: always-on specifically for any review-type skill (copy-review, ux-review, holistic-code-audit, security-audit, database-review, production-drift, comprehensive-audit) — check for a `REVIEWED` marker before flagging anything on the surface being reviewed.
- hostile-environment-testing: before shipping any installer/launcher/scheduled-script change.
- anticipate-user-mistakes: before shipping any new user-facing control, and inside every comprehensive audit.
- ponytail-audit: periodically as part of a comprehensive audit, or after a long stretch of active feature development.
- adhd: at decision points where the obvious answer is expensive to be wrong about — architecture, public API surface, schema, pricing, positioning, naming, launch angle, or a bug with no clear root cause. Not for routine implementation.
- improve-system: at the end of any session where something was genuinely built, iterated, or learned — run it alongside hermes-upload, not instead of it.
- backlog-reconciliation: before writing any new comprehensive backlog document; every 4-6 weeks as standing hygiene; and immediately whenever a supposedly high-risk or blocking item turns out, on investigation, to already be resolved.

## Comprehensive audit — self-contained, no manual steps needed

Say "comprehensive audit" and the comprehensive-audit skill handles everything —
concurrent subagents, with the full set of governing standards (the list in
comprehensive-audit.md's GOVERNING STANDARDS section) applied automatically to
every finding. Nothing needs to be manually re-specified. (backlog-reconciliation
is deliberately NOT part of this automatic set — it's periodic hygiene, not a
per-change code-quality check, and runs on its own cadence.)

## Note on this update — the skill-library read-through

A full, deliberate read of every file in this skill library (not just
filenames/versions) was done to check for genuine content overlap, not
just naming collisions. One real finding: holistic-code-audit's
integration-seam check and flow-test's Phase 0 had independently grown to
teach nearly the same technique, in nearly the same words, in two
unconnected files. Fixed by trimming holistic-code-audit and pointing it
at flow-test as the canonical source. Everything else checked (roughly 25
files read in full) was confirmed to be deliberately, explicitly
separated with a stated reason — no other redundancy found in the
engineering skill set specifically.
