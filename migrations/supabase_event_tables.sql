-- Migration: event-sourcing support tables for runtime modernization
-- Scope: additive only (no destructive changes)

create table if not exists public.events (
  id bigserial primary key,
  event_id text not null unique,
  event_type text not null,
  prospect_id text not null,
  correlation_id text not null,
  source text,
  payload jsonb not null,
  occurred_at timestamptz not null,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  status text not null default 'received' check (status in ('received','processed','failed')),
  error_message text
);

create index if not exists idx_events_type on public.events(event_type);
create index if not exists idx_events_prospect on public.events(prospect_id);
create index if not exists idx_events_correlation on public.events(correlation_id);
create index if not exists idx_events_status on public.events(status);

create table if not exists public.agent_runs (
  id bigserial primary key,
  run_id text not null unique,
  agent_name text not null,
  input_event_id text,
  output_contract_type text,
  output_payload jsonb,
  status text not null check (status in ('started','succeeded','failed','timeout','cancelled')),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  latency_ms integer,
  model text,
  token_usage jsonb,
  error_message text
);

create index if not exists idx_agent_runs_agent on public.agent_runs(agent_name);
create index if not exists idx_agent_runs_status on public.agent_runs(status);

create table if not exists public.dead_letter_events (
  id bigserial primary key,
  original_event_id text not null,
  event_type text not null,
  payload jsonb not null,
  failure_reason text not null,
  retry_count integer not null default 0,
  first_failed_at timestamptz not null default now(),
  last_failed_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists idx_dead_letter_resolved on public.dead_letter_events(resolved_at);

create table if not exists public.approvals (
  id bigserial primary key,
  approval_id text not null unique,
  prospect_id text,
  request_type text not null,
  requested_by text not null,
  approver text,
  status text not null check (status in ('pending','approved','rejected','expired')),
  reason text,
  context jsonb,
  requested_at timestamptz not null default now(),
  decided_at timestamptz
);

create index if not exists idx_approvals_status on public.approvals(status);

create table if not exists public.audit_log (
  id bigserial primary key,
  actor_type text not null check (actor_type in ('agent','service','human','system')),
  actor_id text not null,
  action text not null,
  entity_type text not null,
  entity_id text not null,
  before_state jsonb,
  after_state jsonb,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_entity on public.audit_log(entity_type, entity_id);
create index if not exists idx_audit_created_at on public.audit_log(created_at desc);
