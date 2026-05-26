-- Manual smoke test for Humanio operating schema.
-- Run only after migrations 001 and 002 are applied.
-- This script rolls back at the end, so it should not leave test data behind.

begin;

insert into companies (
  slug,
  name,
  domain,
  status,
  metadata
)
values (
  'humanio',
  'Humanio',
  'humanio.digital',
  'active',
  '{"test": true, "source": "001_operating_core_smoke"}'::jsonb
)
on conflict (slug) do update
set
  name = excluded.name,
  domain = excluded.domain,
  status = excluded.status,
  metadata = companies.metadata || excluded.metadata,
  updated_at = now();

insert into contacts (
  id,
  display_name,
  business_name,
  phone_e164,
  email,
  country,
  city,
  channel,
  metadata
)
values (
  '10000000-0000-4000-8000-000000000001',
  'Smoke Test Contact',
  'Smoke Test Business',
  '+15550100100',
  'smoke-test@humanio.digital',
  'Mexico',
  'Culiacan',
  'manual',
  '{"test": true, "source": "001_operating_core_smoke"}'::jsonb
)
on conflict (id) do update
set
  display_name = excluded.display_name,
  business_name = excluded.business_name,
  metadata = contacts.metadata || excluded.metadata,
  updated_at = now();

insert into prospects (
  id,
  contact_id,
  business_name,
  vertical,
  country,
  city,
  source,
  score,
  recommended_package,
  status,
  findings,
  owner_agent,
  metadata
)
values (
  '10000000-0000-4000-8000-000000000002',
  '10000000-0000-4000-8000-000000000001',
  'Smoke Test Business',
  'dentistas',
  'Mexico',
  'Culiacan',
  'manual_smoke_test',
  8,
  'Business',
  'qualified',
  '["No agenda online", "WhatsApp visible"]'::jsonb,
  'qualifier',
  '{"test": true, "source": "001_operating_core_smoke"}'::jsonb
)
on conflict (id) do update
set
  score = excluded.score,
  recommended_package = excluded.recommended_package,
  status = excluded.status,
  findings = excluded.findings,
  metadata = prospects.metadata || excluded.metadata,
  updated_at = now();

insert into events (
  id,
  occurred_at,
  event_type,
  source,
  idempotency_key,
  contact_id,
  prospect_id,
  actor,
  summary,
  payload
)
values (
  '10000000-0000-4000-8000-000000000003',
  now(),
  'outbound_prospecting_requested',
  'manual_smoke_test',
  'smoke:outbound_prospecting_requested:001',
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  'smoke_test',
  'Smoke test outbound prospecting request',
  jsonb_build_object(
    'test', true,
    'request_id', 'smoke-request-001',
    'vertical', 'dentistas',
    'city', 'Culiacan',
    'country', 'Mexico',
    'requested_count', 1,
    'requested_by', 'smoke_test'
  )
)
on conflict (idempotency_key) do update
set
  payload = excluded.payload;

insert into agent_runs (
  id,
  company_id,
  event_id,
  contact_id,
  prospect_id,
  event_type,
  agent_name,
  run_type,
  status,
  idempotency_key,
  input,
  started_at,
  finished_at
)
values (
  '10000000-0000-4000-8000-000000000004',
  (select id from companies where slug = 'humanio'),
  '10000000-0000-4000-8000-000000000003',
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  'outbound_prospecting_requested',
  'Scout',
  'smoke_test',
  'succeeded',
  'smoke:agent_run:001',
  '{"test": true, "goal": "verify agent_runs insert"}'::jsonb,
  now(),
  now()
)
on conflict (idempotency_key) do update
set
  status = excluded.status,
  input = excluded.input,
  updated_at = now();

insert into agent_outputs (
  id,
  company_id,
  agent_run_id,
  event_id,
  contact_id,
  prospect_id,
  event_type,
  output_type,
  status,
  idempotency_key,
  summary,
  content
)
values (
  '10000000-0000-4000-8000-000000000005',
  (select id from companies where slug = 'humanio'),
  '10000000-0000-4000-8000-000000000004',
  '10000000-0000-4000-8000-000000000003',
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  'outbound_prospecting_requested',
  'prospect_list',
  'created',
  'smoke:agent_output:001',
  'Smoke test output created',
  '{"test": true, "prospects_found": 1}'::jsonb
)
on conflict (idempotency_key) do update
set
  status = excluded.status,
  content = excluded.content,
  updated_at = now();

insert into approvals (
  id,
  company_id,
  event_id,
  requester_run_id,
  contact_id,
  prospect_id,
  event_type,
  approval_type,
  status,
  idempotency_key,
  requested_by,
  reason,
  request_payload
)
values (
  '10000000-0000-4000-8000-000000000006',
  (select id from companies where slug = 'humanio'),
  '10000000-0000-4000-8000-000000000003',
  '10000000-0000-4000-8000-000000000004',
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  'human_approval_required',
  'smoke_test_review',
  'pending',
  'smoke:approval:001',
  'smoke_test',
  'Verify pending approval insert',
  '{"test": true, "risk_level": "low"}'::jsonb
)
on conflict (idempotency_key) do update
set
  status = excluded.status,
  request_payload = excluded.request_payload,
  updated_at = now();

insert into dead_letter_events (
  id,
  company_id,
  original_event_id,
  contact_id,
  prospect_id,
  failed_event_type,
  source,
  idempotency_key,
  status,
  error_message,
  retry_count,
  payload
)
values (
  '10000000-0000-4000-8000-000000000007',
  (select id from companies where slug = 'humanio'),
  '10000000-0000-4000-8000-000000000003',
  '10000000-0000-4000-8000-000000000001',
  '10000000-0000-4000-8000-000000000002',
  'outbound_prospecting_requested',
  'manual_smoke_test',
  'smoke:dead_letter:001',
  'open',
  'Intentional smoke test dead letter',
  0,
  '{"test": true, "original_payload": {"example": true}}'::jsonb
)
on conflict (idempotency_key) do update
set
  status = excluded.status,
  error_message = excluded.error_message,
  payload = excluded.payload,
  updated_at = now();

select 'companies' as check_name, count(*) as row_count
from companies
where slug = 'humanio';

select 'contacts' as check_name, id, display_name, metadata->>'test' as test_flag
from contacts
where id = '10000000-0000-4000-8000-000000000001';

select 'prospects' as check_name, id, business_name, status, score
from prospects
where id = '10000000-0000-4000-8000-000000000002';

select 'events' as check_name, id, event_type, idempotency_key
from events
where id = '10000000-0000-4000-8000-000000000003';

select 'agent_runs' as check_name, id, agent_name, status
from agent_runs
where id = '10000000-0000-4000-8000-000000000004';

select 'agent_outputs' as check_name, id, output_type, status
from agent_outputs
where id = '10000000-0000-4000-8000-000000000005';

select 'approvals' as check_name, id, approval_type, status
from approvals
where id = '10000000-0000-4000-8000-000000000006';

select 'dead_letter_events' as check_name, id, failed_event_type, status
from dead_letter_events
where id = '10000000-0000-4000-8000-000000000007';

-- Keep the database clean after manual verification.
rollback;
