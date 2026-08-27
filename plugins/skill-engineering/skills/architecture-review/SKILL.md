---
name: architecture-review
description: >
  Run a structural architecture review of your codebase via Claude Code.
  Finds async/sync mismatches, duplicated logic, god functions, missing abstractions,
  coupling problems, and single points of failure. Different from engineering-review
  (which finds bugs) — this finds structural problems before they compound. Different
  from improve-codebase-architecture (which is interactive exploration in chat) — this
  produces a full structured report via Claude Code. Run quarterly or before major
  feature builds. Trigger on "architecture review", "structural review", "code structure
  check", "find bottlenecks", "deep architecture audit".
metadata:
  tier: machine
  plugin: skill-engineering
---

# Architecture Review

A deep structural analysis of the codebase. Finds patterns that cause bugs repeatedly,
not individual bugs. Run quarterly or before major feature builds.

**This skill vs improve-codebase-architecture:**
- This skill: structured deep audit via Claude Code task.md, quarterly cadence, full report
- improve-codebase-architecture: interactive exploration in chat, anytime, conversational

## Triggers
`architecture review` / `structural review` / `code structure check` / `find bottlenecks` / `review the architecture` / `deep architecture audit`

---

## Execution — Run All Steps in Order

### Step 1 — Create task.md

Use bash_tool to write /mnt/user-data/outputs/task.md with this content:

```
Perform a structural architecture review of this codebase. Read <server-file>,
<frontend-file>, <report-generator>, <shared-module>, and
<bot-script> before starting. This is NOT a bug hunt — look for structural patterns
that cause repeated failures or will limit future development.

CHECK 1 - Async/Sync Mismatches
Find every place where synchronous blocking code (database calls, file I/O, HTTP
requests) runs inside an async function or event loop without using run_in_executor
or an async library. Flag the file, line, and what the blocking operation is. Note:
this pattern caused the <bot-script> hang and will cause similar issues anywhere else
it exists.

CHECK 2 - Logic Duplication and Drift
Find functions or code blocks that exist in more than one file and do the same or
similar thing. Pay special attention to any logic shared between <server-file> and
<report-generator>. For each duplicate, note which version is more correct/complete
and what the risk is if they continue to drift.

CHECK 3 - God Functions
Find any function longer than 100 lines or that does more than one distinct thing
(e.g. validates input AND queries the database AND formats output AND calls an external
API). List the function name, file, line count, and what distinct responsibilities it has.

CHECK 4 - Missing Shared Abstractions
Look at <shared-module> and identify patterns used in 3+ places across the codebase
that are NOT in <shared-module> but should be. Examples: the .env loading pattern
(repeated in every script), the standard authenticated API call pattern, the standard
error response format.

CHECK 5 - Coupling Problems
Find cases where one module imports from or directly depends on another in a way that
creates fragility. Does <report-generator> import from <server-file>? Does <bot-script>
depend on Flask internals? Are there circular dependency risks?

CHECK 6 - Single Points of Failure
Find operations in the data pipeline where a failure has no fallback and no retry logic.
Examples: Claude API calls with no retry on timeout, database writes with no transaction
rollback, report generation steps where a partial failure leaves the system in an
inconsistent state.

CHECK 7 - Configuration Sprawl
Find values hardcoded in multiple places that should be a single shared constant.
Examples: the <production-host> IP address, token expiry durations, report retention
counts, max_tokens values for different Claude calls.

CHECK 8 - Error Handling Patterns
Survey how errors are surfaced to users across the codebase. Are HTTP error responses
consistent? Are there places where exceptions are caught but the user gets a generic 500?
Are there places where errors are silently swallowed?

Output Format - group by impact:

HIGH IMPACT - Structural problems actively causing or will soon cause production failures
MEDIUM IMPACT - Problems that will slow development or cause bugs as the codebase grows
LOW IMPACT - Code quality issues worth fixing eventually

For each finding: file(s) and line number(s), what the structural problem is, why it
matters, recommended fix approach (direction only, not code).

Do not fix anything. Save the report as architecture-review-[today's date].md and present it.
```

---

### Step 2 — Present task.md for download

Present the file and tell the user:

Save this to `<projects-dir>\<your-repo>\task.md`, then in Claude Code type:
`read task.md and execute all the checks`

This will take 10-15 minutes. Paste the report back here when done.

---

### Step 3 — Interpret the report

When the user pastes back the findings:

1. HIGH IMPACT items first — fix before next major build
2. Group related findings — treat repeated patterns as one theme, not multiple bugs
3. Name the theme — what does this codebase tend to get wrong structurally?
4. Separate quick wins from refactors — flag which need a dedicated session
5. Connect findings to business impact — "this will cause X" not just "this is bad code"

Present plain-English summary of codebase structural health before specifics.
Ask which items to tackle first before starting any fixes.

---

## Hard Rules

- Never start fixing until the user confirms priorities
- Always connect structural findings to business impact
- After fixes: run engineering-review to confirm no bugs were introduced, then push-to-git
- Remind the user at the end: architecture reviews should run quarterly or before major
  feature additions
