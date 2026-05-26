-- Humanio operating completion schema.
-- This migration is additive. It does not remove or rename tables from 001_operating_core.sql.

create extension if not exists pgcrypto;

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  name text not null,
  domain text,
  status text not null default 'active' check (status in ('active', 'paused', 'archived')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint companies_slug_uidx unique (slug)
);

create index if not exists companies_status_idx on companies (status);
create index if not exists companies_created_at_idx on companies (created_at desc);

create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  source text not null default 'chatwoot',
  channel contact_channel not null default 'chatwoot',
  status text not null default 'open' check (status in ('open', 'pending', 'snoozed', 'resolved', 'closed', 'archived')),
  event_type text,
  chatwoot_conversation_id text,
  whatsapp_thread_id text,
  inbox_id text,
  assigned_owner text,
  last_message_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists conversations_status_idx on conversations (status);
create index if not exists conversations_contact_idx on conversations (contact_id);
create index if not exists conversations_prospect_idx on conversations (prospect_id);
create index if not exists conversations_event_type_idx on conversations (event_type);
create index if not exists conversations_created_at_idx on conversations (created_at desc);
create unique index if not exists conversations_chatwoot_uidx on conversations (chatwoot_conversation_id) where chatwoot_conversation_id is not null;
create unique index if not exists conversations_whatsapp_thread_uidx on conversations (whatsapp_thread_id) where whatsapp_thread_id is not null;

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  conversation_id uuid references conversations(id) on delete cascade,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  event_type text,
  channel contact_channel not null,
  direction text not null check (direction in ('inbound', 'outbound', 'internal', 'system')),
  status text not null default 'received' check (status in ('draft', 'queued', 'sent', 'accepted_by_provider', 'delivered', 'read', 'received', 'failed', 'skipped')),
  idempotency_key text,
  provider text,
  provider_message_id text,
  chatwoot_message_id text,
  sender text,
  recipient text,
  message_text text,
  payload jsonb not null default '{}'::jsonb,
  sent_at timestamptz,
  received_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists messages_status_idx on messages (status);
create index if not exists messages_contact_idx on messages (contact_id);
create index if not exists messages_prospect_idx on messages (prospect_id);
create index if not exists messages_event_type_idx on messages (event_type);
create index if not exists messages_created_at_idx on messages (created_at desc);
create index if not exists messages_conversation_created_idx on messages (conversation_id, created_at desc);
create unique index if not exists messages_idempotency_uidx on messages (idempotency_key) where idempotency_key is not null;
create unique index if not exists messages_provider_message_uidx on messages (provider, provider_message_id) where provider is not null and provider_message_id is not null;

create table if not exists agent_runs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  demo_request_id uuid references demo_requests(id) on delete set null,
  event_type text,
  agent_name text not null,
  run_type text not null default 'workflow',
  status text not null default 'queued' check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled', 'blocked')),
  idempotency_key text,
  input jsonb not null default '{}'::jsonb,
  error_message text,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists agent_runs_status_idx on agent_runs (status);
create index if not exists agent_runs_contact_idx on agent_runs (contact_id);
create index if not exists agent_runs_prospect_idx on agent_runs (prospect_id);
create index if not exists agent_runs_event_type_idx on agent_runs (event_type);
create index if not exists agent_runs_created_at_idx on agent_runs (created_at desc);
create unique index if not exists agent_runs_idempotency_uidx on agent_runs (idempotency_key) where idempotency_key is not null;

create table if not exists agent_outputs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  agent_run_id uuid references agent_runs(id) on delete cascade,
  event_id uuid references events(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  event_type text,
  output_type text not null,
  status text not null default 'created' check (status in ('created', 'accepted', 'rejected', 'superseded', 'failed')),
  idempotency_key text,
  summary text,
  content jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists agent_outputs_status_idx on agent_outputs (status);
create index if not exists agent_outputs_contact_idx on agent_outputs (contact_id);
create index if not exists agent_outputs_prospect_idx on agent_outputs (prospect_id);
create index if not exists agent_outputs_event_type_idx on agent_outputs (event_type);
create index if not exists agent_outputs_created_at_idx on agent_outputs (created_at desc);
create unique index if not exists agent_outputs_idempotency_uidx on agent_outputs (idempotency_key) where idempotency_key is not null;

create table if not exists approvals (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  requester_run_id uuid references agent_runs(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  event_type text,
  approval_type text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'expired', 'cancelled')),
  idempotency_key text,
  requested_by text not null,
  decided_by text,
  reason text not null,
  request_payload jsonb not null default '{}'::jsonb,
  decision_payload jsonb not null default '{}'::jsonb,
  requested_at timestamptz not null default now(),
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists approvals_status_idx on approvals (status);
create index if not exists approvals_contact_idx on approvals (contact_id);
create index if not exists approvals_prospect_idx on approvals (prospect_id);
create index if not exists approvals_event_type_idx on approvals (event_type);
create index if not exists approvals_created_at_idx on approvals (created_at desc);
create unique index if not exists approvals_idempotency_uidx on approvals (idempotency_key) where idempotency_key is not null;

create table if not exists outreach_log (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  prospect_id uuid not null references prospects(id) on delete cascade,
  contact_id uuid references contacts(id) on delete set null,
  conversation_id uuid references conversations(id) on delete set null,
  message_id uuid references messages(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  event_type text,
  channel contact_channel not null,
  tipo text not null,
  status outreach_status not null default 'queued',
  idempotency_key text,
  provider text,
  provider_message_id text,
  template_name text,
  subject text,
  body_preview text,
  error_detail text,
  sent_at timestamptz,
  responded_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists outreach_log_status_idx on outreach_log (status);
create index if not exists outreach_log_contact_idx on outreach_log (contact_id);
create index if not exists outreach_log_prospect_idx on outreach_log (prospect_id);
create index if not exists outreach_log_event_type_idx on outreach_log (event_type);
create index if not exists outreach_log_created_at_idx on outreach_log (created_at desc);
create unique index if not exists outreach_log_idempotency_uidx on outreach_log (idempotency_key) where idempotency_key is not null;
create unique index if not exists outreach_log_provider_message_uidx on outreach_log (provider, provider_message_id) where provider is not null and provider_message_id is not null;

create table if not exists demo_assets (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  demo_request_id uuid references demo_requests(id) on delete set null,
  proposal_id uuid references proposals(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  event_type text,
  asset_type text not null default 'site' check (asset_type in ('site', 'proposal', 'report', 'design_spec', 'qa_report', 'handoff_note', 'other')),
  slug text,
  status proposal_status not null default 'draft',
  idempotency_key text,
  url_principal text,
  url_propuesta text,
  url_reporte text,
  storage_path text,
  qa_status text,
  qa_summary text,
  published_at timestamptz,
  delivered_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists demo_assets_status_idx on demo_assets (status);
create index if not exists demo_assets_contact_idx on demo_assets (contact_id);
create index if not exists demo_assets_prospect_idx on demo_assets (prospect_id);
create index if not exists demo_assets_event_type_idx on demo_assets (event_type);
create index if not exists demo_assets_created_at_idx on demo_assets (created_at desc);
create index if not exists demo_assets_demo_request_idx on demo_assets (demo_request_id);
create unique index if not exists demo_assets_idempotency_uidx on demo_assets (idempotency_key) where idempotency_key is not null;
create unique index if not exists demo_assets_slug_uidx on demo_assets (slug) where slug is not null;

create table if not exists followups (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  prospect_id uuid not null references prospects(id) on delete cascade,
  contact_id uuid references contacts(id) on delete set null,
  conversation_id uuid references conversations(id) on delete set null,
  outreach_log_id uuid references outreach_log(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  event_type text,
  followup_type text not null,
  status text not null default 'pending' check (status in ('pending', 'due', 'sent', 'skipped', 'cancelled', 'failed')),
  idempotency_key text,
  due_at timestamptz not null,
  completed_at timestamptz,
  no_response_evidence jsonb not null default '{}'::jsonb,
  allowed_channels jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists followups_status_idx on followups (status);
create index if not exists followups_contact_idx on followups (contact_id);
create index if not exists followups_prospect_idx on followups (prospect_id);
create index if not exists followups_event_type_idx on followups (event_type);
create index if not exists followups_created_at_idx on followups (created_at desc);
create index if not exists followups_due_at_idx on followups (due_at);
create unique index if not exists followups_idempotency_uidx on followups (idempotency_key) where idempotency_key is not null;

create table if not exists dead_letter_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  original_event_id uuid references events(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  failed_event_type text not null,
  source text not null,
  idempotency_key text,
  status text not null default 'open' check (status in ('open', 'retrying', 'replayed', 'ignored', 'resolved')),
  error_message text not null,
  retry_count integer not null default 0 check (retry_count >= 0),
  next_retry_at timestamptz,
  resolved_at timestamptz,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists dead_letter_events_status_idx on dead_letter_events (status);
create index if not exists dead_letter_events_contact_idx on dead_letter_events (contact_id);
create index if not exists dead_letter_events_prospect_idx on dead_letter_events (prospect_id);
create index if not exists dead_letter_events_event_type_idx on dead_letter_events (failed_event_type);
create index if not exists dead_letter_events_created_at_idx on dead_letter_events (created_at desc);
create unique index if not exists dead_letter_events_idempotency_uidx on dead_letter_events (idempotency_key) where idempotency_key is not null;

create table if not exists audit_log (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  event_id uuid references events(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  event_type text,
  actor text not null,
  action text not null,
  table_name text not null,
  record_id uuid,
  reason text,
  old_values jsonb,
  new_values jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_log_contact_idx on audit_log (contact_id);
create index if not exists audit_log_prospect_idx on audit_log (prospect_id);
create index if not exists audit_log_event_type_idx on audit_log (event_type);
create index if not exists audit_log_created_at_idx on audit_log (created_at desc);
create index if not exists audit_log_table_record_idx on audit_log (table_name, record_id);

create table if not exists metrics_snapshots (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  source_event_id uuid references events(id) on delete set null,
  generated_by_run_id uuid references agent_runs(id) on delete set null,
  event_type text,
  snapshot_type text not null,
  status text not null default 'generated' check (status in ('generated', 'superseded', 'failed')),
  idempotency_key text,
  period_start date,
  period_end date,
  metrics jsonb not null default '{}'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists metrics_snapshots_status_idx on metrics_snapshots (status);
create index if not exists metrics_snapshots_event_type_idx on metrics_snapshots (event_type);
create index if not exists metrics_snapshots_created_at_idx on metrics_snapshots (created_at desc);
create index if not exists metrics_snapshots_period_idx on metrics_snapshots (period_start, period_end);
create unique index if not exists metrics_snapshots_idempotency_uidx on metrics_snapshots (idempotency_key) where idempotency_key is not null;

drop trigger if exists set_companies_updated_at on companies;
create trigger set_companies_updated_at before update on companies for each row execute function set_updated_at();

drop trigger if exists set_conversations_updated_at on conversations;
create trigger set_conversations_updated_at before update on conversations for each row execute function set_updated_at();

drop trigger if exists set_messages_updated_at on messages;
create trigger set_messages_updated_at before update on messages for each row execute function set_updated_at();

drop trigger if exists set_agent_runs_updated_at on agent_runs;
create trigger set_agent_runs_updated_at before update on agent_runs for each row execute function set_updated_at();

drop trigger if exists set_agent_outputs_updated_at on agent_outputs;
create trigger set_agent_outputs_updated_at before update on agent_outputs for each row execute function set_updated_at();

drop trigger if exists set_approvals_updated_at on approvals;
create trigger set_approvals_updated_at before update on approvals for each row execute function set_updated_at();

drop trigger if exists set_outreach_log_updated_at on outreach_log;
create trigger set_outreach_log_updated_at before update on outreach_log for each row execute function set_updated_at();

drop trigger if exists set_demo_assets_updated_at on demo_assets;
create trigger set_demo_assets_updated_at before update on demo_assets for each row execute function set_updated_at();

drop trigger if exists set_followups_updated_at on followups;
create trigger set_followups_updated_at before update on followups for each row execute function set_updated_at();

drop trigger if exists set_dead_letter_events_updated_at on dead_letter_events;
create trigger set_dead_letter_events_updated_at before update on dead_letter_events for each row execute function set_updated_at();

drop trigger if exists set_metrics_snapshots_updated_at on metrics_snapshots;
create trigger set_metrics_snapshots_updated_at before update on metrics_snapshots for each row execute function set_updated_at();

alter table companies enable row level security;
alter table conversations enable row level security;
alter table messages enable row level security;
alter table agent_runs enable row level security;
alter table agent_outputs enable row level security;
alter table approvals enable row level security;
alter table outreach_log enable row level security;
alter table demo_assets enable row level security;
alter table followups enable row level security;
alter table dead_letter_events enable row level security;
alter table audit_log enable row level security;
alter table metrics_snapshots enable row level security;
