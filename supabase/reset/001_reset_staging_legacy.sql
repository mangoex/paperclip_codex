-- WARNING: STAGING ONLY.
-- This script intentionally removes known legacy Humanio staging objects so the
-- canonical operating schema can be rebuilt from migrations 001 and 002.
--
-- Do not run against production.
-- Do not run if n8n, WhatsApp, Chatwoot, workers, dashboards, or client-facing
-- systems depend on these legacy staging tables.
--
-- Required manual guard in the same SQL session:
--
--   set app.environment = 'staging';
--
-- The script fails unless current_setting('app.environment', true) = 'staging'.
-- Scope is limited to known legacy objects in public. It does not touch auth,
-- storage, schemas outside public, functions, secrets, or unknown objects.
--
-- Optional preflight:
--
-- select
--   n.nspname as schema_name,
--   c.relname as object_name,
--   c.relkind as object_kind
-- from pg_class c
-- join pg_namespace n on n.oid = c.relnamespace
-- where n.nspname = 'public'
--   and c.relname in (
--     'pipeline_events',
--     'pipeline_funnel',
--     'outreach_log',
--     'proposals',
--     'prospects'
--   )
-- order by c.relname;
--
-- Expected relkind values:
--   r = table
--   v = view
--   m = materialized view

do $$
declare
  unexpected_object record;
begin
  if coalesce(current_setting('app.environment', true), '') <> 'staging' then
    raise exception
      'Refusing to reset: app.environment must be set to staging in this SQL session.';
  end if;

  select c.relname, c.relkind
  into unexpected_object
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and (
      (c.relname in ('pipeline_events', 'outreach_log', 'proposals', 'prospects') and c.relkind <> 'r')
      or (c.relname = 'pipeline_funnel' and c.relkind <> 'v')
    )
  order by c.relname
  limit 1;

  if found then
    raise exception
      'Refusing to reset: public.% has unexpected relkind %. Expected tables (r) for pipeline_events/outreach_log/proposals/prospects and view (v) for pipeline_funnel.',
      unexpected_object.relname,
      unexpected_object.relkind;
  end if;
end;
$$;

-- Drop the known view first, then child/event tables, then base tables.
-- If dependencies exist, this script should fail and force a reviewed reset plan.
drop view if exists public.pipeline_funnel;
drop table if exists public.pipeline_events;
drop table if exists public.outreach_log;
drop table if exists public.proposals;
drop table if exists public.prospects;
