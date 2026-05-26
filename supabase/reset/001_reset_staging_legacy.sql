-- WARNING: STAGING ONLY.
-- This script intentionally removes known legacy Humanio staging tables so the
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
-- Scope is limited to known legacy tables in public. It does not touch auth,
-- storage, schemas outside public, functions, secrets, or unknown objects.

do $$
begin
  if coalesce(current_setting('app.environment', true), '') <> 'staging' then
    raise exception
      'Refusing to reset: app.environment must be set to staging in this SQL session.';
  end if;
end;
$$;

-- Drop child/event tables first, then base tables. No CASCADE is used on purpose.
-- If dependencies exist, this script should fail and force a reviewed reset plan.
drop table if exists public.pipeline_events;
drop table if exists public.pipeline_funnel;
drop table if exists public.outreach_log;
drop table if exists public.proposals;
drop table if exists public.prospects;
