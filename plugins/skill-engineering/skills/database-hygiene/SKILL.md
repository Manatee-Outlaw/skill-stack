---
name: database-hygiene
description: >
  Database design and hygiene for SQLite applications. Use when designing schemas,
  writing import/upsert logic, handling multi-source data, preventing duplicates,
  managing data retention, or auditing for ghost/bad data. Also covers the arrival
  audit — whether data is actually landing in a column at all, rather than only
  whether its absence can break something. An empty or uniform column is a finding,
  and a write-only column nothing reads has no consumer to notice it broke.
  Trigger phrases: "duplicate data", "single record of truth", "database hygiene",
  "upsert", "idempotent import", "data source conflict", "schema constraints", "ghost
  data", "orphaned records", "data retention", "clean the database", "empty column",
  "no data arriving", "telemetry isn't populating", "is this field being written".
sources:
  - SQLite best practices (sqliteforum.com, 2025)
  - Idempotency patterns in SQL (dev.to, 2026)
  - Schema management best practices (Medium/firmanbrilian, 2025)
last_updated: 2026-05-28
metadata:
  tier: machine
  plugin: skill-engineering
---

# Database Hygiene Skill

> **Communication note:** The reader may not be a database specialist. Lead with
> business consequences, not database theory. Frame every recommendation as: "what
> breaks if we don't do this" and "what you do once to prevent it forever."

> **On the examples below:** every table and column name here is a generic
> placeholder (`period_totals`, `entity_id`, `some_table`). Substitute your own. The
> rules are what transfer; the names are illustration only.

---

## The Four Pillars

### 1. UNIQUE Constraints — Let the Database Enforce Truth

The single most important hygiene tool. A UNIQUE constraint means the database itself
will reject duplicate data, regardless of what the application code does.

```sql
-- Bad: application code checks for duplicates before inserting
-- (application can crash mid-check, race condition, or have a bug)

-- Good: database enforces uniqueness
CREATE UNIQUE INDEX idx_totals_entity_period
  ON period_totals(entity_id, period_start);

-- Now this INSERT either succeeds or safely fails — no duplicates ever
INSERT OR IGNORE INTO period_totals (...) VALUES (...);
```

**Rule:** Every table that represents a unique business entity should have a UNIQUE
constraint on the columns that define that uniqueness. Not just a primary key — a
semantic unique key that reflects the business logic.

**Worked example:** if a monthly rollup is unique per (entity + month), then
`(entity_id, period_start)` is the semantic key. The database should enforce that,
not the import script. Ask "what combination of columns must never repeat?" — that
combination is your UNIQUE constraint.

**If you are pinned to an older SQLite:** `ON CONFLICT DO UPDATE` (true upsert) only
arrived in SQLite 3.24. On anything older, use `INSERT OR IGNORE` followed by
`UPDATE ... WHERE` instead. Check your runtime's version before relying on upsert.

---

### 2. Idempotent Imports — Run the Same Import Twice, Get the Same Result

An import is idempotent if running it a second time produces no change. This is critical
when the same data might come from multiple sources or when the same file is imported
twice by mistake.

**Three SQLite patterns:**

```sql
-- Pattern A: INSERT OR IGNORE
-- If a record with that unique key already exists, do nothing.
-- Use when: new data should never overwrite old data for the same key.
INSERT OR IGNORE INTO period_totals (entity_id, period_start, amount, ...)
VALUES (?, ?, ?, ...);

-- Pattern B: INSERT OR REPLACE
-- If a record with that unique key exists, delete it and insert the new one.
-- Use when: newer data should always win for the same key.
INSERT OR REPLACE INTO period_totals (entity_id, period_start, amount, ...)
VALUES (?, ?, ?, ...);

-- Pattern C: INSERT OR IGNORE + UPDATE (for SQLite older than 3.24)
-- Insert if new; update specific columns if exists.
-- Use when: you want to update some fields but preserve others (e.g. preserve created_at).
INSERT OR IGNORE INTO some_table (col1, col2, col3) VALUES (?, ?, ?);
UPDATE some_table SET col2 = ?, col3 = ? WHERE col1 = ? AND (col2 != ? OR col3 != ?);
```

**Which pattern to use:**
- Restatable historical data (figures that can be revised): Pattern B or C — update the
  numbers if re-imported
- Append-only event data: Pattern A — never overwrite what already landed
- Configuration/settings: Pattern B — latest always wins

---

### 3. Single Record of Truth — Multi-Source Data Strategy

When multiple sources can provide data for the same business event, you need a strategy
for which source wins and how to track where data came from.

**Add source metadata to any table that might have multi-source data:**

```sql
-- Add to tables that will receive data from multiple sources
ALTER TABLE period_totals ADD COLUMN data_source TEXT DEFAULT 'bulk_import';
ALTER TABLE period_totals ADD COLUMN source_priority INTEGER DEFAULT 10;
-- Higher priority = more authoritative (an official API beats a manual import)
```

**Source priority scale — rank your own sources by how authoritative they are:**
- 100: Official upstream API — ground truth
- 50:  Bulk export from a dashboard — reliable but manual
- 10:  Real-time agent or plugin data — timely but approximate
- 1:   Manual user entry — least authoritative

The numbers matter less than the ordering. The point is to decide, once and explicitly,
which source wins a conflict — rather than letting whichever import ran last decide.

**Simpler approach (usually the right one at small scale):**
Use a single UNIQUE constraint per (entity, period) and INSERT OR REPLACE. When a
higher-quality source eventually provides the same data, its import replaces the
earlier estimate. Add `data_source` as metadata but don't over-engineer the query
until you actually have a conflict to resolve.

---

### 4. Data Retention and Ghost Data Prevention

**Ghost data:** Records that exist in the database but no longer have a valid parent.
Example: a rollup row for an external account that has since been unlinked and no
longer has an owner.

**Prevention — three patterns:**

```sql
-- Pattern A: Foreign key constraints (cascade delete)
-- When a parent is deleted, delete its children automatically
CREATE TABLE period_totals (
    id              INTEGER PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ...
);

-- Pattern B: Soft delete (preserve history)
-- Don't delete — mark as inactive. Data is retained for history.
ALTER TABLE users ADD COLUMN deleted_at TEXT DEFAULT NULL;
-- Queries: WHERE deleted_at IS NULL for active users

-- Pattern C: Periodic cleanup job
-- Scheduled task that finds and removes orphaned records
DELETE FROM period_totals
WHERE entity_id NOT IN (
    SELECT entity_id FROM entity_links WHERE user_id IS NOT NULL
);
```

**Every table needs a retention decision — make it explicit rather than defaulting to
"keep everything forever by accident".** A rough shape:
- User-generated content (submissions, reports): usually keep indefinitely — it's the history
- Domain events: usually keep indefinitely — needed for trend analysis
- High-volume raw samples: purge on a schedule (e.g. after 90 days) — these are the
  tables that quietly become the largest thing in the database
- Bulky raw responses: purge on a schedule (e.g. after 180 days)
- Draft/temp records: clear on session end, or after a few days

Pick the windows that fit your data and write them down. The failure mode is not
choosing a wrong number — it is never choosing at all.

---

## SQLite-Specific Hygiene

### Enable Foreign Keys at Startup

SQLite does NOT enforce foreign key constraints by default. You must enable them per
connection:

```python
# In your get-connection helper — immediately after opening the connection
conn.execute("PRAGMA foreign_keys = ON")
```

Without this, orphaned records accumulate silently.

### Enable WAL Mode for Concurrent Safety

```python
conn.execute("PRAGMA journal_mode = WAL")
conn.execute("PRAGMA synchronous = NORMAL")
```

Prevents corruption when multiple connections write simultaneously. Set it once, at
startup, on every connection.

### Use CHECK Constraints for Data Validation

```sql
-- Reject obviously wrong data at the schema level
CREATE TABLE period_totals (
    amount          REAL CHECK (amount >= 0),
    event_count     INTEGER CHECK (event_count >= 0),
    status          TEXT CHECK (status IN ('active','paused','archived', NULL)),
    ...
);
```

A CHECK constraint is the cheapest possible guard against a whole class of bad data:
it makes the impossible value literally impossible to store.

---

## Deduplication Audit — Finding Existing Duplicates

Run these against your database to identify current hygiene problems:

```sql
-- Find duplicate rollups (same entity, same period_start)
SELECT entity_id, period_start, COUNT(*) as cnt
FROM period_totals
GROUP BY entity_id, period_start
HAVING cnt > 1;

-- Find orphaned rollups (parent unlinked but rows remain)
SELECT t.entity_id, COUNT(*) as row_count
FROM period_totals t
LEFT JOIN entity_links e ON e.entity_id = t.entity_id
WHERE e.entity_id IS NULL
GROUP BY t.entity_id;

-- Find users with no profile row (ghost accounts)
SELECT u.id, u.name, u.role, u.created_at
FROM users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE p.user_id IS NULL AND u.role = 'member';

-- Find pending records created but never activated, older than 30 days
SELECT COUNT(*) FROM pending_records
WHERE user_id IS NULL
AND created_at < datetime('now', '-30 days');
```

---

## Arrival Audit — Is Anything Actually Landing?

A column can be perfectly designed, perfectly constrained, and completely empty.
Hygiene is not only "is this data correct" — it is "is this data HERE at all".

**The trap:** asking whether a column's emptiness can BREAK anything, correctly
answering "no", and moving on. Those are two different questions:

- *"Can NULLs in this column cause an error?"* — a question about harm.
- *"Should these be NULL?"* — a question about whether the thing works.

A column can be completely harmless and completely broken at the same time. If it
was added to answer a question, and it is empty, the question is still unanswered
and nobody has found out.

**Write-only columns are the highest risk, not the lowest.** A column that
something writes but nothing reads has no consumer to notice when it stops
arriving. "Nothing reads it yet — it's forward telemetry for later" is not a
reason to skip it. It is the exact reason it can sit broken for months. That
doesn't automatically make it a HIGH finding — but it does mean it MUST be
checked, because nothing else in the system will.

```sql
-- For any column a live source is supposed to populate:
-- how many rows actually have a value?
SELECT COUNT(*)                        AS total_rows,
       COUNT(some_column)              AS rows_with_value,
       COUNT(*) - COUNT(some_column)   AS rows_null
FROM some_table;

-- Is it uniform? A column where every row holds the same value is often
-- a default that nothing ever overwrote.
SELECT some_column, COUNT(*) FROM some_table GROUP BY some_column;

-- Is it arriving NOW, or did it stop? Compare recent rows against old ones.
SELECT COUNT(*)               AS recent_rows,
       COUNT(some_column)     AS recent_with_value
FROM some_table
WHERE created_at > datetime('now', '-7 days');
```

**Do not explain an anomaly away — test the story.** "Those NULLs are from older
clients", "it hasn't fired yet", "that's expected for new users" are hypotheses,
not findings. Each is usually checkable in one query: if the story is "older
clients", then NEW rows must have values — so check the new rows. A
rationalisation that turns out to be wrong costs more than the anomaly it
dismissed, because it closes the question.

**An empty or uniform column is a FINDING until proven otherwise — not a
footnote.**

---

## Mirror-Read Audit — Is Anyone Reading the Cache Instead of the Truth?

Denormalized mirrors are everywhere: a `users.role` column kept in sync from a
`user_roles` junction table, a cached `last_seen` beside an events table, a
`status` flag summarizing child rows. The mirror exists for one consumer's
convenience — and then other code quietly reads it as if it were the source.

**Why this is a hygiene check and not a code-style nit:** a mirror that
collapses information (one role column for a multi-role user, one status for a
multi-state child set) doesn't just lag — it is WRONG for every row whose truth
doesn't fit the mirror's shape. Every reader of the mirror inherits that
wrongness silently. In one real codebase, a single mirror-read in a report
generator excluded multi-role users from all coaching output; the first fix
found the same read in the health-check watchdog and in six more interactive
routes the same day. Mirror-reads are a CLASS, never a one-off.

**The audit:**

1. Find every mirror. For each table, ask: is any column derivable from
   another table (a junction, a child table, an event log)? The schema doc
   or a comment saying "kept in sync" / "denormalized" / "cached" is the tell.
2. For each mirror, grep every read of it:

```sql
-- Which is authoritative? The one that is WRITTEN at the business event.
-- Then find readers of the other one:
```
```bash
grep -rn "users.role\|u\.role\|\[.role.\]" --include=*.py . | grep -v user_roles
```

3. Classify each reader: the sync/display code that legitimately touches the
   mirror, versus **logic that filters, gates, or joins on it** — every one of
   the latter is a latent wrong-answer for any row where mirror ≠ truth.
4. Report them as one finding with every instance listed
   (propagate-the-fix), plus the recommended authoritative read pattern
   (usually an EXISTS against the junction/child table).

**Rule of thumb:** a mirror may be SELECTed for display. The moment it appears
in a WHERE clause, an eligibility check, or a JOIN condition, it must be the
authoritative source instead — or the finding writes itself.

---

## Migration Pattern — Adding Constraints to Existing Tables

SQLite cannot add a UNIQUE constraint to an existing table directly. The safe migration
pattern for adding constraints to live data:

```python
def _add_unique_constraint_safely(conn, table, constraint_name, columns):
    """
    Adds a UNIQUE constraint to an existing table by:
    1. First deduplicating the data (keeping the most recent row per key)
    2. Then creating the unique index
    This is safe to run on a live database.
    """
    col_list = ', '.join(columns)

    # Step 1: Remove duplicates, keeping the row with the highest id (most recent)
    conn.execute(f"""
        DELETE FROM {table}
        WHERE id NOT IN (
            SELECT MAX(id) FROM {table}
            GROUP BY {col_list}
        )
    """)

    # Step 2: Create the unique index (will succeed since duplicates are gone)
    conn.execute(f"""
        CREATE UNIQUE INDEX IF NOT EXISTS {constraint_name}
        ON {table}({col_list})
    """)
```

---

## The Hygiene Checklist (per table)

When designing or auditing any table, answer:

1. **What makes a row unique?** → Add a UNIQUE constraint on those columns
2. **What happens if the same data is inserted twice?** → Write INSERT OR IGNORE/REPLACE/upsert
3. **Could data come from multiple sources?** → Add `data_source TEXT` and `source_priority INTEGER`
4. **Should deleted parent records delete child records?** → Add `ON DELETE CASCADE` foreign keys
5. **How long should this data be kept?** → Add retention policy to a scheduled cleanup job
6. **Are there currently duplicate or orphaned rows?** → Run deduplication audit queries
7. **Is anything actually arriving in each column?** → Run the arrival audit: count the
   NULLs, check for a uniform value, compare recent rows against old ones. Empty is a
   finding, not a footnote — most of all for write-only columns nothing reads back
8. **Is any code reading a denormalized mirror where an authoritative table exists?** →
   Run the mirror-read audit: mirrors may be displayed, never filtered/gated/joined on.
   Report mirror-reads as a class with every instance, not as one-offs

---
