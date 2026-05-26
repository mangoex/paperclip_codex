# Supabase Staging Reset Plan

## Scope

This plan prepares a controlled reset/rebuild of the Humanio Supabase STAGING schema only.

Confirmed staging project:

| Field | Value |
| --- | --- |
| Project ref | `nloytkdjbhoozjrhrpxq` |
| Visible name | `Humanio Staging` |

This plan must not be used against production.

## Legacy Tables Detected

The current staging project already contains these legacy tables:

- `outreach_log`
- `pipeline_events`
- `pipeline_funnel`
- `proposals`
- `prospects`

## Drift Explanation

The staging database has an older Humanio/Paperclip schema. The new operating migrations assume a different canonical model.

Examples:

- Legacy `prospects` has fields such as `negocio`, `giro`, `ciudad`, `pais`, `paquete`, and `etapa`.
- New `001_operating_core.sql` expects fields such as `contact_id`, `business_name`, `vertical`, `country`, `city`, and `status`.
- Legacy `proposals` has fields such as `url_propuesta`, `url_reporte`, `paquete`, `desplegado_at`, and `activo`.
- New `001_operating_core.sql` expects fields such as `demo_request_id`, `status`, `public_url`, and `qa_summary`.
- Legacy `outreach_log` has fields such as `canal`, `enviado_at`, `respondio`, and `respondio_at`.
- New `002_operating_completion.sql` expects `outreach_log` to include fields such as `company_id`, `contact_id`, `event_type`, and `idempotency_key`.

Because the migrations use `create table if not exists`, existing legacy tables would not be rebuilt. Later indexes and foreign keys would then fail because expected columns do not exist.

## Why Reset Is Acceptable Only In Staging

Reset is acceptable only because this project is explicitly confirmed as STAGING and is not connected to live n8n, WhatsApp, Chatwoot, workers, production sends, or demo publishing.

Reset is not acceptable for production because it would remove operational history and could break live workflows.

## Manual Confirmation Checklist

Miguel must confirm all items before the reset script is executed:

- [ ] The target project visible name is `Humanio Staging`.
- [ ] The target project ref is `nloytkdjbhoozjrhrpxq`.
- [ ] This is not production.
- [ ] No production n8n workflow points to this project.
- [ ] No WhatsApp send path depends on this project.
- [ ] No Chatwoot production workflow depends on this project.
- [ ] No worker is reading or writing this project.
- [ ] No client-facing dashboard depends on the legacy tables.
- [ ] Existing staging legacy data can be discarded or has been exported.
- [ ] The operator understands that only the listed public legacy tables are in scope.

## Safe Reset Order

1. Confirm project identity in Supabase UI and connector.
2. Export or screenshot the legacy staging tables if Miguel wants a reference copy.
3. In the same SQL session, set the explicit staging guard:

   ```sql
   set app.environment = 'staging';
   ```

4. Run:

   ```sql
   supabase/reset/001_reset_staging_legacy.sql
   ```

5. Apply the schema in order:

   ```sql
   supabase/migrations/001_operating_core.sql
   supabase/migrations/002_operating_completion.sql
   supabase/seeds/001_humanio_company.sql
   ```

6. Run the smoke test:

   ```sql
   supabase/tests/001_operating_core_smoke.sql
   ```

7. Verify tables, RLS, idempotency indexes, seed row, and smoke rollback using the apply runbook.

## Reset Script Safety Rules

The reset script:

- fails unless `current_setting('app.environment', true) = 'staging'`;
- drops only known legacy tables in `public`;
- does not touch `auth`;
- does not touch `storage`;
- does not touch schemas outside `public`;
- does not touch functions;
- does not touch secrets;
- does not use `cascade`.

If the reset fails because of dependencies or object type mismatches, stop and review. Do not broaden the script casually.

## Logical Rollback

Before reset:

- Export legacy staging data if it must be preserved.
- Keep this Git commit and the reset/apply report as the audit trail.

After reset:

- If migrations fail immediately after reset, stop.
- Do not connect n8n, WhatsApp, Chatwoot, or workers.
- Re-run only reviewed idempotent migrations.
- If legacy data must be restored, restore it manually into a separate review table or from a staging backup/export, not into the new canonical tables without a mapping plan.

## Risks

- Existing staging data in the five legacy tables will be removed.
- If `pipeline_funnel` is a view or has dependencies, the script may fail intentionally.
- If hidden staging tooling depends on legacy tables, that tooling will break until updated.
- Because the organization plan is free, point-in-time restore was not confirmed through the connector.
- The reset does not solve production migration; production requires a separate compatibility/backfill plan.

## Decision

STAGING_RESET_RECOMMENDED

Not executed yet.
