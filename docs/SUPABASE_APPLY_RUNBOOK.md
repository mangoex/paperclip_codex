# Supabase Apply Runbook

## Scope

This runbook prepares the Humanio operating schema. It does not wire production workflows, move secrets, create workers, or send WhatsApp messages.

Apply these steps in staging first. Production should wait until the event validator, event writer, and shadow-mode webhook path are reviewed.

## Preflight

1. Confirm the target Supabase project and environment.
2. Confirm you have service-role access in a secure server-side context.
3. Confirm no secrets are being copied into SQL files or commit history.
4. Confirm the current Git commit and branch.
5. Read the migrations before applying them:
   - `supabase/migrations/001_operating_core.sql`
   - `supabase/migrations/002_operating_completion.sql`
   - `supabase/seeds/001_humanio_company.sql`

## Backup Before Changes

Before applying anything to an existing Supabase project:

1. Export a database backup from Supabase.
2. Save the migration history or note that this is the first manual application.
3. Export existing table definitions if any Humanio operating tables already exist.
4. Record the backup timestamp, environment, and operator in a private operations note.

Do not continue without a restore path.

## Apply 001

Apply:

```sql
supabase/migrations/001_operating_core.sql
```

Verify that these tables exist:

- `contacts`
- `prospects`
- `events`
- `outreach_attempts`
- `demo_requests`
- `proposals`
- `handoffs`

Verify RLS is enabled on each table.

## Staging Reset Path When Legacy Drift Is Detected

Use this path only for the confirmed staging project:

```text
Humanio Staging / nloytkdjbhoozjrhrpxq
```

Do not use this path in production.

If staging contains the legacy tables `outreach_log`, `pipeline_events`, `pipeline_funnel`, `proposals`, and `prospects` with columns that conflict with the new operating model, stop and get manual confirmation from Miguel before resetting.

Manual confirmation must cover:

- the target is `Humanio Staging`;
- the target ref is `nloytkdjbhoozjrhrpxq`;
- existing staging legacy data can be discarded or has been exported;
- no n8n, WhatsApp, Chatwoot, worker, dashboard, or customer-facing flow depends on the legacy staging tables.

In the same SQL session, run:

```sql
set app.environment = 'staging';
```

Then run:

```sql
supabase/reset/001_reset_staging_legacy.sql
```

The reset script refuses to run unless `current_setting('app.environment', true) = 'staging'`. It drops only the known public legacy tables and does not touch `auth`, `storage`, schemas outside `public`, functions, or secrets.

After the reset, apply the rebuild sequence:

```sql
supabase/migrations/001_operating_core.sql
supabase/migrations/002_operating_completion.sql
supabase/seeds/001_humanio_company.sql
supabase/tests/001_operating_core_smoke.sql
```

Then continue with RLS, table, index, seed, and smoke rollback verification in this runbook.

## Apply 002

Apply:

```sql
supabase/migrations/002_operating_completion.sql
```

Verify that these tables exist:

- `companies`
- `conversations`
- `messages`
- `agent_runs`
- `agent_outputs`
- `approvals`
- `outreach_log`
- `demo_assets`
- `followups`
- `dead_letter_events`
- `audit_log`
- `metrics_snapshots`

Verify RLS is enabled on each table.

## Apply Seed

Apply:

```sql
supabase/seeds/001_humanio_company.sql
```

Verify:

```sql
select id, slug, name, domain, status
from companies
where slug = 'humanio';
```

Expected result: one active Humanio company row.

## Run Smoke Test

Run:

```sql
supabase/tests/001_operating_core_smoke.sql
```

The script opens a transaction, inserts test records, runs verification `SELECT`s, and rolls back at the end.

Expected verification rows:

- `companies`
- `contacts`
- `prospects`
- `events`
- `agent_runs`
- `agent_outputs`
- `approvals`
- `dead_letter_events`

Because the script ends with `rollback`, test rows should not remain afterward.

## Verify RLS

Check RLS status:

```sql
select
  schemaname,
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'contacts',
    'prospects',
    'events',
    'outreach_attempts',
    'demo_requests',
    'proposals',
    'handoffs',
    'companies',
    'conversations',
    'messages',
    'agent_runs',
    'agent_outputs',
    'approvals',
    'outreach_log',
    'demo_assets',
    'followups',
    'dead_letter_events',
    'audit_log',
    'metrics_snapshots'
  )
order by tablename;
```

Every row should show `rowsecurity = true`.

## Verify Tables and Indexes

Check table presence:

```sql
select table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in (
    'contacts',
    'prospects',
    'events',
    'outreach_attempts',
    'demo_requests',
    'proposals',
    'handoffs',
    'companies',
    'conversations',
    'messages',
    'agent_runs',
    'agent_outputs',
    'approvals',
    'outreach_log',
    'demo_assets',
    'followups',
    'dead_letter_events',
    'audit_log',
    'metrics_snapshots'
  )
order by table_name;
```

Check key idempotency indexes:

```sql
select indexname
from pg_indexes
where schemaname = 'public'
  and indexname in (
    'events_idempotency_key_uidx',
    'messages_idempotency_uidx',
    'agent_runs_idempotency_uidx',
    'agent_outputs_idempotency_uidx',
    'approvals_idempotency_uidx',
    'outreach_log_idempotency_uidx',
    'demo_assets_idempotency_uidx',
    'followups_idempotency_uidx',
    'dead_letter_events_idempotency_uidx',
    'metrics_snapshots_idempotency_uidx'
  )
order by indexname;
```

## Logical Rollback

If anything fails before production traffic uses the schema:

1. Stop. Do not wire webhooks or workers.
2. Save the error text and the failed SQL statement.
3. If inside a transaction, roll it back.
4. If changes were already committed to the database, restore from the backup or apply a reviewed rollback migration.
5. Do not manually drop tables in production unless a rollback migration has been reviewed.
6. Record the incident in a private operations note.

If the seed was applied incorrectly, fix it with an idempotent seed update instead of editing rows silently.

## Go/No-Go

Go only when:

- migrations 001 and 002 apply cleanly;
- the Humanio seed row exists;
- the smoke test returns expected rows and rolls back;
- RLS is enabled on all base tables;
- no public policies expose base tables;
- no production webhook has been changed.

No-go when:

- any migration fails;
- smoke test inserts cannot satisfy foreign keys;
- RLS is disabled on any base table;
- any secret appears in SQL, logs, or committed files;
- any workflow would send a real WhatsApp message.
