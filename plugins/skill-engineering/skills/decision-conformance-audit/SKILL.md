---
name: decision-conformance-audit
description: >
  For every recorded owner decision (a decision register, ADRs, "DECIDED" lines
  in a roadmap or spec), find every code path that could violate it and prove
  each one obeys — with a test pinned to the decision. A decision is usually
  implemented in the module where it was discussed, while an older or sibling
  path elsewhere keeps doing the opposite. Run in every comprehensive audit,
  after any decision is recorded or changed, and before a launch that depends
  on one. Trigger phrases: "we decided", "per D-<n>", "the rule is", "is this
  enforced everywhere", "does the code match the decision", "policy",
  "ADR", "decision register".
metadata:
  tier: machine
  produces_findings: true
  plugin: skill-engineering
---

# Decision Conformance Audit

## Why this skill exists

The owner decided: *keep or archive any report with data; never delete one.*
The retention code was rewritten to match — it archived instead of deleting,
had tests, passed review, and was deployed. Meanwhile a **different** function,
the same-week de-duplication that runs every time a report is regenerated,
still issued a hard `DELETE` of the existing report — including one the end
user had already been sent by direct message, whose only link now led to
"Report not found", and one still queued for sending, which then failed
silently while the replacement was blocked by a once-a-week rule. Five
independent auditors found it (recorded 2026-10-03); none of the reviews of the
retention change had, because the violating path was in a file that change
never touched.

Two more from the same week:

- A decision said the owner, not managers, chooses what is visible to an end
  user, and that impersonation must never change a user's identity. The
  email-change route and the "link external account" route were both left off
  the impersonation deny-list: an owner viewing as a user could rebind the
  user's account.
- A decision made a third-party OAuth sign-in the way back into an account. A
  pre-existing staff form let a manager *type* that provider's user ID onto an
  account — harmless when the field only routed messages, a login credential
  once the decision landed.

## What makes this class invisible

- Code review is diff-scoped. The decision's implementation is the diff; the
  violating sibling is not in it.
- Tests are written for the new path. Nothing asserts the decision across every
  path, so the old path's own tests keep passing — often they assert the old
  behaviour.
- The decision is recorded in prose (a register, a roadmap), and nothing links
  the prose to the code.

## The check

### Step 1 — List the decisions

Read the decision register / roadmap / specs. For each decision that constrains
behaviour (not pure business choices), write it as an INVARIANT a program could
violate: "no code path deletes a `<reports_table>` row that has data", "no
endpoint reachable under an impersonation token changes `users.email` or
`users.<external_login_id>`", "only an OAuth-proven or owner-approved path
writes `users.<external_login_id>`", "a user is never messaged while live".

### Step 2 — Enumerate every path that touches the invariant

Search by the DATA, not by the feature: every `DELETE FROM <table>`, every
`UPDATE <table> SET <column>`, every send/post call, every route that writes the
column — across all services, crons, scripts, migrations, admin tools and
bots. Say exactly what you searched and where (a grep pattern and its file set).
An invariant with one path found is suspicious: look again for the old one.

### Step 3 — Prove each path

For each path: does it obey the invariant? Prove by execution where possible —
drive it against a scratch database and assert the invariant afterwards. A path
that violates it is a finding even if no user has hit it yet; say what the user
receives when they do.

### Step 4 — Pin it

Recommend ONE test per decision that asserts the invariant across every path
(not one test per path written by whoever touched it): e.g. run every writer of
`<reports_table>` and assert no row with data disappeared; enumerate every route
in the app's URL map, call each with an impersonation token, and assert none
changed the protected columns. Name the decision ID in the test's docstring so
the next person who changes the decision finds the test.

### Step 5 — Close the loop with the record

If the code shows the decision was quietly superseded (the code is right and the
register is stale, or vice versa), report that as its own finding: one of the
two must change, and it is the owner's call which (see respect-settled-decisions
— do not silently pick a side).

## Output

    DECISION-CONFORMANCE FINDINGS:
    HIGH: D-<n> "<invariant>" violated by <path> | FILE: file:line | USER GETS: <...> | FIX: <...> | PIN: <the cross-path test>
      evidence: <the offending line quoted, or the scratch-DB run and its output> [proven|inferred]
    ...
    ALL CLEAR: D-<n> — <invariant> — paths found: <list, with the search used> — proof: <test/run>

Every finding carries an `evidence:` line tagged **[proven]** (executed) or
**[inferred]** (read from code). "No other path writes this column" is an
absence claim: state where you searched — the grep pattern and the file set,
including crons, scripts, migrations and bots.

A decision marked ALL CLEAR must list the paths you found and how you searched;
"no violations" with no enumeration is not a result.
