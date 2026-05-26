# Migration Review

## Reviewed Commit

`ced9166 Add Humanio migration operating docs`

## Completeness Checklist

- [x] `001_operating_core.sql` remains intact.
- [x] `002_operating_completion.sql` adds the missing operating tables without deleting or renaming existing tables.
- [x] New tables use UUID primary keys.
- [x] New tables include reasonable foreign keys to `companies`, `contacts`, `prospects`, `events`, `demo_requests`, `proposals`, and related ledgers.
- [x] New mutable tables include `created_at` and `updated_at`.
- [x] Append-only `audit_log` uses `created_at` and intentionally has no `updated_at`.
- [x] Indexes cover status, contact, prospect, event type, and created date where those columns apply.
- [x] Idempotency keys exist on event-processing tables where retries are expected.
- [x] RLS is enabled on every new table.
- [x] `updated_at` triggers are installed on mutable new tables.
- [x] `SUPABASE_OPERATING_MODEL.md` defines canonical tables and legacy/complementary tables.
- [x] `events.schema.json` keeps the base envelope and adds typed `$defs` for the required event types.
- [x] No workers, production changes, secret movement, or PR creation are included.

## Risks

- The migration assumes `001_operating_core.sql` has already created `contacts`, `prospects`, `events`, `outreach_status`, `proposal_status`, `demo_requests`, and `proposals`.
- RLS is enabled without policies. That is safe for anonymous/client access but requires trusted server-side service-role access for operations.
- The typed event schema intentionally rejects event types that are not listed in the contract. New event types will need schema updates before production use.
- `outreach_attempts` and `proposals` still exist for compatibility, so workflows must be updated deliberately to prefer `outreach_log` and `demo_assets`.
- No data backfill is included. Existing production rows, if any, need a separate reviewed migration.

## Remaining Gaps

- No Supabase policies are defined yet for dashboard or operator read access.
- No views or reporting functions are defined for `metrics_snapshots`.
- No runtime validators or workers have been created to enforce the JSON Schema before inserts.
- No backfill path maps legacy `outreach_attempts` to `outreach_log` or `proposals` to `demo_assets`.
- No seed row creates the canonical `companies` record for Humanio; that should be done in environment-specific setup or a reviewed seed migration.
- No production smoke test has been run, by restriction.

## Final Decision

READY_WITH_FIXES

The schema and contracts are now complete enough for implementation planning, but production implementation still needs policies, validators/workers, environment-specific seed data, and a deliberate backfill/cutover plan.
