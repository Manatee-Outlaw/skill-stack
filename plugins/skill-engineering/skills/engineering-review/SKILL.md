---
name: engineering-review
description: >
  Hunt SPECIFIC DEFECT CLASSES in a codebase via Claude Code — database
  association errors, undefined variables, token limits, silent failures, auth
  gaps, missing routes, dead code, and git hygiene. An 8-check sweep for concrete
  bugs, not a structural or correctness review.
  Trigger on "engineering review", "bug hunt", "find bugs in the codebase",
  "undefined variables", "silent failures", "dead code".
  Do NOT trigger on a bare "audit", "code audit", "run an audit" or "check the
  codebase" — those belong to comprehensive-audit, which dispatches this skill as
  one of its subagents. Use this directly only when this defect-class sweep is
  what is actually wanted. For the nine-discipline correctness sweep in chat, use
  holistic-code-audit; for structure, architecture-review.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Engineering Review

Runs 8 targeted checks against the live codebase using Claude Code. Produces a
prioritized findings report grouped by severity. Does not fix anything — report only.

**This skill vs holistic-code-audit:**
- holistic-code-audit: runs in this chat, interactive, good for a quick pass or
  when Claude Code isn't available
- engineering-review: runs via Claude Code task.md, deeper automated checks,
  takes 10-15 minutes, better for pre-release audits

## Triggers
`engineering review` / `code audit` / `run audit` / `bug hunt` / `check the codebase` / `audit the code`

---

## Execution — Run All Steps in Order

### Step 1 — Create task.md

Use bash_tool to write `/mnt/user-data/outputs/task.md` with this exact content:

```
Perform a full engineering review of this codebase. Read <server-file>, <frontend-file>, <report-generator>, and <shared-module> before starting. Then run every check below and produce a prioritized findings report.

CHECK 1 - Database Association Audit

Read the actual schema by running:

python3 -c "
import os; [os.environ.setdefault(k.strip(),v.strip()) for line in open('.env') for k,_,v in [line.strip().partition('=')] if line.strip() and not line.startswith('#')]
from your_shared_db_module import get_db
with get_db() as conn:
    tables = [t[0] for t in conn.execute(\"SELECT name FROM sqlite_master WHERE type='table'\").fetchall()]
    print('TABLES:', tables)
    for t in tables:
        cols = [c[1] for c in conn.execute(f'PRAGMA table_info({t})').fetchall()]
        print(f'{t}: {cols}')
"

Then scan every SQL query in <server-file> and <report-generator>. Flag any query referencing a table or column not in the actual schema.

CHECK 2 - Undefined Variable References

Scan <server-file> for every variable used in a function that is not defined in scope, not a parameter, and not a module-level constant. Pay special attention to constants used in route handlers.

CHECK 3 - API Token Limits

Find every Claude API call. Check whether max_tokens is sufficient for the JSON structure expected. Flag any where the response schema could realistically exceed the limit.

CHECK 4 - Silent Failure Patterns

Find every empty error handler in JavaScript and bare except with no logging in Python. Flag each one noting whether intentionally silenced or a genuine gap.

CHECK 5 - Auth Pattern Consistency

Find every fetch() call in <frontend-file> hitting an @require_auth endpoint. Verify each includes Authorization Bearer header. Flag any using credentials:'include' or missing auth entirely.

Also find every endpoint gated by <scoped-token>. Verify the overlay pages pass ?token= correctly.

CHECK 6 - Frontend to Backend Route Verification

Find every fetch('/api/...') in the frontend. Verify the @app.route exists in <server-file> with correct HTTP method. Flag any pointing to missing or wrong-method routes.

CHECK 7 - Dead Code

Find functions defined but never called, routes unreachable, JS functions with no callers, and orphaned code blocks after return statements.

CHECK 8 - Git Hygiene

Run: git status
Run: git ls-files -s *.sh | grep -v 100755
Flag untracked files that should be committed or added to .gitignore.
Flag any .sh file with mode 100644 (non-executable) as CRITICAL.

---

Output Format - group by severity:

CRITICAL - Will cause production errors (wrong table/column, undefined variable, broken route, non-executable cron script)
WARNING - May cause errors under specific conditions (token limits, silent failures, missing auth)
NOTE - Code quality issues that will not break things

For each finding: file, line number, what is wrong, one-sentence fix.

Do not fix anything. Save report as engineering-review-[today's date].md and present it.
```

---

### Step 2 — Present task.md for download

Present the file and tell the user:

> "Save this to `<projects-dir>\<your-repo>\task.md`, then in Claude Code type:
> `read task.md and execute all the checks`
>
> This will take 5-10 minutes. Paste the report back here when done."

---

### Step 3 — Interpret the report

When the user pastes back the findings:

1. Review all CRITICAL items — these need fixing before any other work
2. Review WARNING items — flag any that match known failure patterns from this project:
   - Wrong table/column names (hit multiple times)
   - Missing auth headers on fetch calls
   - Token limits too low for response schemas
   - Undefined module-level constants
   - .sh scripts with 100644 mode (cron silent failure)
3. Group fixes by file so Claude Code can handle them in batches
4. Recommend which items to fix now vs defer

Present a plain-English summary of findings before diving into individual fixes.
Ask the user which items to tackle first.

---

## Hard Rules

- Never skip Step 3 — the report is only useful if interpreted, not just delivered
- Always check if any CRITICAL items match active user-reported bugs before prioritizing
- Do not start fixing until the user confirms which items to address
- After fixes: trigger push-to-git to deploy
- For a faster in-chat audit without Claude Code, use holistic-code-audit
