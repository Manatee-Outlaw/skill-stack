---
name: security-audit
description: >
  Focused security review of a web application. Covers authentication
  inventory, input validation, injection risks, XSS exposure, credential
  handling, session security, file system risks, and rate limiting gaps.
  Produces a prioritized findings report without making any changes.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Security Audit Skill

## When to use
- Before exposing a new endpoint to the public
- After significant feature additions that touch auth or user input
- As part of a comprehensive code audit
- After a security incident or near-miss
- Before onboarding external users to a platform

This skill is read-only. It produces a report. Do not make changes.

---

## Step 1 — Route auth inventory

Read every Flask route (or equivalent) in the application. For each route:

| Route | Method | Auth Decorator | Who Can Call It | Notes |
|-------|--------|---------------|-----------------|-------|

Auth decorators to look for:
- @require_auth (Bearer JWT)
- @require_admin
- @require_session_auth
- @require_<role> (any further role-scoped decorators)
- <scoped-token> (?token= param or a custom token header)
- No decorator (public)

Flag:
- Routes with no auth that serve or modify non-public data (HIGH)
- Routes where the auth level seems wrong for the sensitivity of the data
- Routes that return different data based on role but don't validate role
  on the server (trusts client)
- Admin/debug routes accidentally left public

---

## Step 2 — Input validation audit

For every POST, PUT, and PATCH route, check:
- Is the request body validated before use?
- Are string lengths bounded?
- Are enum fields validated against an allowed list?
- Are integer fields checked for range?
- Are file paths or filenames sanitized before use in filesystem calls?
- Is the handle/username format validated before database writes?
  (Prevents garbage data and potential injection)

Flag:
- Fields accepted without any validation (HIGH if they reach SQL or filesystem)
- Validation that's present on the client but absent on the server (HIGH —
  client validation is convenience, server validation is security)
- Fields that accept arbitrary strings and write them to the database
  without length limits

---

## Step 3 — SQL injection scan

Search for every database query in the application. For each:
- Is it using parameterized queries (?, :name placeholders)?
- Is any user-supplied value concatenated directly into a SQL string?
- Are there any f-strings or format() calls building SQL?

Flag:
- Any string concatenation into SQL as CRITICAL
- Any f-string SQL as CRITICAL
- Even "safe" string operations should be flagged for review — the goal
  is zero string interpolation in SQL

**Note:** SQLite's Python library (sqlite3) uses ? placeholders. Any
deviation from this pattern is a red flag.

---

## Step 4 — XSS (Cross-Site Scripting) scan

Search for every place user-supplied content is rendered into HTML:
- Template strings that include user data without escaping
- innerHTML assignments with user data
- Any use of raw interpolation (${userValue}) in HTML generation
- HTML rendered from database fields without escaping

Flag:
- User-supplied text rendered to HTML without escaping (HIGH)
- Internal-staff-supplied text rendered without escaping (MEDIUM —
  lower risk but still exploitable via compromised accounts)
- Places where escaping is inconsistent (some fields escaped, others not)

---

## Step 5 — Credential and secret handling

Search the codebase for:
- Hardcoded passwords, tokens, or API keys anywhere in source files
- Credentials in comments
- Credentials in log output (check logging calls)
- Credentials in error messages
- Environment variables that should be in .env but might be hardcoded
- .env file committed to git (check .gitignore)
- Old credentials in git history (flag for BFG purge)

**Tooling and IDE configuration files — scan these too, not just application
code.** Developer tooling quietly persists real commands, and real commands
sometimes contain real secrets. A real staff password was found embedded in an
AI-assistant permissions file (`.claude/settings.local.json`) — a `curl -u
user:password ...` command approved once during a debugging session and saved
verbatim into the tool's allowlist, where no secret scanner ever looked.
(It turned out to have been rotated before discovery — but only the live-test
in point 1 below established that; the file itself couldn't say.)
Sweep, at minimum:

```bash
# Assistant/IDE config that records approved or executed commands
grep -rniE "(password|passwd|token|secret|api.?key|Authorization|-u [^ ]+:[^ ]+)"   .claude/ .vscode/ .idea/ .cursor/ 2>/dev/null
# Shell history and rc files on the production host, same pattern
```

For each hit: (1) determine whether the credential is STILL LIVE by testing it
against the real system — a dead credential is cleanup, a live one is an
incident requiring rotation, and the two must not be conflated; (2) check
whether the containing file is protected by the REPO's own .gitignore, not
merely a machine-global ignore that doesn't travel with a clone; (3) remove
the entry either way. These files are re-populated by normal tool use, so this
is a recurring sweep, not a one-time fix.


---

## Step 6 — Session security

Check:
- Cookie flags: httpOnly, SameSite, Secure (for HTTPS deployments)
- JWT: expiry set? Algorithm is HS256 or better (not 'none')?
- Session token entropy: is the session ID cryptographically random?
- Logout: does logout actually invalidate the session server-side,
  or just clear the client cookie?
- Session fixation: is the session regenerated on privilege escalation?
- Remember-me tokens: are they stored safely?

---

## Step 7 — File system security

Check every route that reads from or writes to the filesystem:
- Is any user-supplied value used in a file path without sanitization?
  (Path traversal: ../../etc/passwd)
- Does the route validate that the resolved path is within an allowed
  directory?
- Are file uploads (if any) validated for type and size?
- Does any endpoint that interpolates user input into a filesystem glob
  or path sanitize those parameters before they reach the pattern?
  (Wildcards and separators in user input can widen a glob far beyond
  the intended directory)

---

## Step 8 — Rate limiting and abuse potential

For every unauthenticated or lightly authenticated endpoint:
- Could it be called thousands of times per second without consequence?
- Does it have any rate limiting?
- Does it do expensive computation or database writes on each call?
- Could it be used to enumerate user accounts, file paths, or other
  sensitive information?

Flag:
- Unauthenticated endpoints that write to the database (CRITICAL)
- Login endpoints with no rate limiting (HIGH — brute force risk)
- Enumeration risks (endpoints that return different errors for
  "user exists" vs "wrong password")

---

## Step 9 — Cross-project auth

For any API call made from one project to another:
- Does the caller authenticate to the target?
- Is the credential stored safely (not hardcoded)?
- Does the target validate the credential on every request?
- Is there any inter-service communication that happens without auth
  because "it's internal"?

---

## Output format

**Before finalizing any finding below: grep the flagged surface for a
`REVIEWED` marker first** (see respect-settled-decisions). If one exists and
its stated scope covers what you're about to flag, cite it and treat the
matter as settled rather than a fresh finding — an accepted-risk decision
already recorded is not the same as an undiscovered one.

Produce a report with these sections:

### SEVERITY RATINGS
CRITICAL: exploitable now, data at risk
HIGH: significant risk, fix before next release
MEDIUM: real issue but requires specific conditions or access
LOW: defense-in-depth improvement, no immediate risk
INFO: observation for awareness

### ROUTE AUTH INVENTORY
Complete table of all routes with auth level.

### FINDINGS (by severity)
Each finding: location, description, severity, what an attacker could do,
recommended fix.

### CREDENTIAL EXPOSURE SUMMARY
Any credentials found outside of environment variables.

### KNOWN ACCEPTED RISKS
Issues that are known and deliberately accepted with documented reasoning.

### IMMEDIATE ACTIONS (CRITICAL and HIGH only)
Short list for quick triage.
