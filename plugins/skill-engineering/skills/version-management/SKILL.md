---
name: version-management
description: >
  Checklist for bumping version constants in a project that has multiple
  separate version numbers that can drift out of sync. Use whenever bumping
  a version number anywhere in the codebase — even a simple one-constant
  change can silently break things if related files aren't updated in lockstep.
  Trigger phrases: "bump the version", "update the version", "increment version",
  "new version", "version bump", "release version X". Also trigger proactively
  when someone asks "what version are we on?" and the answer is unclear or
  inconsistent across files — that itself is a drift symptom.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Version Management

A checklist for version bumps in projects with multiple version constants.
The goal: every file that knows about a version number agrees on it after
the bump. Silent version drift causes real bugs.

---

## Why this matters

Projects often have more than one version number. Examples:
- A plugin version (what the `<host-app>`/the client sees)
- A bridge/script version (what the installer reports)
- A manifest version (what the host app displays in its UI)
- An API version in a changelog or reference document

When you bump one and forget the others, you get:
- A host app showing the wrong version in its UI (even though the code updated)
- An installer reporting stale version numbers
- Documentation that contradicts the running code
- Auto-update logic that fires unnecessarily or never fires

These bugs are hard to diagnose because everything "works" — just incorrectly.

---

## Step 1 — Audit: find every version reference before touching anything

Before bumping anything, run a search for the current version string across
all project files:

```bash
grep -r "CURRENT_VERSION_STRING" . --include="*.py" --include="*.js" --include="*.json" --include="*.md" --include="*.txt" --include="*.bat" --include="*.sh"
```

Replace CURRENT_VERSION_STRING with the actual current version (e.g., "1.7.1").

List every file that contains the version string. This is your checklist.
Do not proceed until you have the complete list.

---

## Step 2 — Categorize each reference

For each file found in Step 1, answer:
- Is this the **source of truth** (the Python/JS constant that other code reads)?
- Is this a **derived file** (generated from the source of truth at build time)?
- Is this **documentation** (README, changelog, technical reference)?
- Is this a **manifest** (package.json, manifest.json, plugin manifest)?

Source of truth files must be updated manually.
Derived files should be regenerated, not manually edited.
Documentation and manifests must be updated alongside the source of truth.

---

## Step 3 — Check for auto-update logic

Does this version constant drive any auto-update behavior?

If yes:
- Understand exactly what triggers the update check
- Understand what the update logic does when it detects a mismatch
- Verify the update logic reads from the source of truth, not a cached value
- Plan a test to verify the auto-update fires correctly after the bump

Common failure modes:
- Auto-update only writes one file (e.g., index.js) but not a related
  manifest (e.g., manifest.json) that the host app reads for display
- Auto-update fires but the host app caches the old version until restart
- Auto-update bakes the version into a generated artifact that then gets
  out of sync with the constant

---

## Step 4 — Make the bump

Update the source of truth constant. Then update every file in the checklist
from Step 1 in the same commit.

One commit rule: version bumps touch all related files atomically. A version
bump that spans multiple commits creates a window where files disagree.

---

## Step 5 — Verify propagation

After deploying:
1. Check the live version endpoint (if one exists):
   GET <version-endpoint>, <version-endpoint>, etc.
2. Check the host app's displayed version (restart it first if needed)
3. Check that any auto-update logic sees the new version correctly

If the host app shows the old version after restart:
- Check if the manifest file was updated (not just the code file)
- Check if the host app caches the manifest at startup vs per-use
- A second restart after the manifest update sometimes resolves this

---

## Step 6 — Document the bump

Update any changelog, TECHNICAL_REFERENCE.md, or version history document.
Commit message should include: what changed, why the version was bumped,
and any migration notes for users still on the old version.

---
