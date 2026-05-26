# Smoke Test Fix Notes

## Cause

The staging smoke test failed with:

```text
ERROR: 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification
```

The test used `ON CONFLICT(idempotency_key)` on tables that define idempotency through partial unique indexes, for example:

```text
CREATE UNIQUE INDEX agent_runs_idempotency_uidx
ON public.agent_runs USING btree (idempotency_key)
WHERE (idempotency_key IS NOT NULL)
```

Postgres cannot infer that partial unique index from a plain `ON CONFLICT(idempotency_key)` clause.

## Why The Schema Was Not Changed

The schema is already applied in Humanio Staging and the idempotency indexes exist as designed. The failure is in the smoke test upsert syntax, not in the operating schema.

Changing migrations would be unnecessary risk. The smoke test runs inside `BEGIN ... ROLLBACK`, so it does not need upsert behavior.

## Test Correction

The smoke test now uses direct inserts with fixed UUIDs and fixed idempotency keys. The Humanio company setup uses an insert guarded by `where not exists`, without `ON CONFLICT`. The final `ROLLBACK` keeps the database clean after verification.

The test still keeps:

- fixed UUIDs using the `10000000-0000-4000-8000-...` prefix;
- metadata/test flags;
- verification `SELECT`s;
- final rollback.

## Rerun

After explicit authorization, rerun:

```sql
supabase/tests/001_operating_core_smoke.sql
```

Then verify:

- rows are returned for `companies`, `contacts`, `prospects`, `events`, `agent_runs`, `agent_outputs`, `approvals`, and `dead_letter_events`;
- the script reaches final `rollback`;
- no rows remain with UUID prefix `10000000-0000-4000-8000-`.
