---
name: cross-project-audit
description: >
  Audit how multiple Claude project chats interact through shared
  infrastructure. Use when two or more project chats share a database,
  API endpoints, file paths, or data conventions. Finds conflicting
  assumptions, schema drift, data ownership gaps, and integration
  fragility before they become bugs.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Cross-Project Audit Skill

## When to use
- After significant work has been done in two or more parallel project chats
- Before a major feature that touches shared infrastructure
- When a bug appears that could have originated in either project
- Periodically as a health check (quarterly or after major releases)

---

## Step 1 — Map all shared infrastructure

List every resource that is read or written by more than one project:

### Databases and tables
- Which tables does each project write to?
- Which tables does each project read from?
- Are there tables that both projects write to? (Highest conflict risk)
- Are there tables one project assumes it exclusively owns but another touches?

### API endpoints
- Which HTTP routes does each project call that are defined in another project?
- Does each caller's expected request format match the actual route definition?
- Does each caller's expected response format match what the route returns?

### File system paths
- Are any files or directories written by one project and read by another?
- Are naming conventions consistent across projects?

### Shared constants / identifiers
- Are any IDs, handles, or keys used as connectors between projects?
  Document the exact field name and format each project uses.

---

## Step 2 — Verify API contracts

For every cross-project API call, compare:

### On the server (producer) side:
- Route path and method
- Auth decorator
- Required and optional fields in the request body
- Response shape (field names, types, nullability)
- Error response format (does it return JSON on error? What status codes?)

### On the client (consumer) side:
- What URL is it calling? Does it match exactly?
- What auth does it send? Does it match what the server requires?
- What fields does it read from the response? Are they all present?
- How does it handle errors? Does it handle every status the server can return?

Flag any mismatch as a CONTRACT GAP.

---

## Step 3 — Check schema assumptions

For each project that has a SCHEMA.md or equivalent documentation:
- Does the documented schema match the live database?
- Do the field names in one project's documentation match the field names
  used by the other project when accessing shared tables?
- Are there fields one project documents that the other project is unaware of?
- Are there migrations one project has run that the other project hasn't
  accounted for?

---

## Step 4 — Map data ownership

For every shared table, answer:
- Which project is the authoritative OWNER (writes primary data)?
- Which projects are CONSUMERS (read or conditionally write)?
- Is there any table where both projects write as primary owners?
  (This is a conflict — there should be one owner.)
- Is there any table that's documented in one project but undocumented
  in the other? (Knowledge gap — the undocumented project may make
  wrong assumptions.)

---

## Step 5 — Naming and convention consistency

Compare across projects:
- Do they use the same names for the same concepts?
  (e.g., "handle" vs "tiktok_handle" vs "username" for the same value)
- Do they use the same formats for shared identifiers?
  (e.g., handles lowercased in one project but not the other)
- Do they use the same role names and values?
- Do they use the same status values for shared records?
- Do they use the same date/time formats?

Flag inconsistencies as NAMING DRIFT.

---

## Step 6 — Breaking change risk assessment

For each cross-project dependency, ask:
- If project A renames this field, does project B break silently?
- If project A changes the auth requirement on this endpoint, does
  project B get locked out silently?
- If project A adds a NOT NULL constraint, does project B's writes fail?
- Is there any shared constant (version string, config key, status value)
  that if changed in one project would silently corrupt the other?

Rate each dependency:
- HIGH: a change in one project would silently corrupt data or cause a
  runtime error that's hard to diagnose
- MEDIUM: a change would cause visible errors that are easy to diagnose
- LOW: a change would require deliberate coordination but would fail loudly

---

## Output format

Produce a report with these sections:

### SHARED INFRASTRUCTURE MAP
List all shared resources with producer/consumer roles.

### CONTRACT GAPS
Each API mismatch: which project, which endpoint, what the mismatch is,
and what would happen at runtime.

### SCHEMA DRIFT
Each case where documentation or assumptions don't match live state.

### DATA OWNERSHIP CONFLICTS
Tables with unclear or contested ownership.

### NAMING DRIFT
Field names, formats, or conventions that differ across projects.

### BREAKING CHANGE RISKS
Ranked HIGH/MEDIUM/LOW with specific scenario descriptions.

### RECOMMENDATIONS
Ordered by severity. For each: which project should make the fix.
