-- Humanio operating core schema for Supabase.
-- Apply with the Supabase SQL editor or migration runner in the target project.

create extension if not exists pgcrypto;

do $$
begin
  create type contact_channel as enum ('whatsapp', 'email', 'chatwoot', 'manual', 'web');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type prospect_status as enum (
    'new',
    'qualified',
    'outreach_ready',
    'contacted',
    'interested',
    'demo_requested',
    'proposal_sent',
    'won',
    'lost',
    'paused'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type outreach_status as enum ('queued', 'sent', 'delivered', 'failed', 'replied', 'skipped');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type demo_status as enum ('requested', 'intake', 'planning', 'building', 'qa', 'published', 'delivered', 'closed', 'cancelled');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type proposal_status as enum ('draft', 'qa_pending', 'qa_failed', 'published', 'delivered', 'archived');
exception
  when duplicate_object then null;
end $$;

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists contacts (
  id uuid primary key default gen_random_uuid(),
  display_name text,
  business_name text,
  phone_e164 text,
  email text,
  country text,
  city text,
  channel contact_channel not null default 'manual',
  chatwoot_contact_id text,
  whatsapp_wa_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contacts_phone_or_email_chk check (phone_e164 is not null or email is not null or chatwoot_contact_id is not null)
);

create unique index if not exists contacts_phone_e164_uidx on contacts (phone_e164) where phone_e164 is not null;
create unique index if not exists contacts_email_uidx on contacts (lower(email)) where email is not null;
create unique index if not exists contacts_chatwoot_contact_uidx on contacts (chatwoot_contact_id) where chatwoot_contact_id is not null;

create table if not exists prospects (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references contacts(id) on delete set null,
  business_name text not null,
  vertical text,
  country text,
  city text,
  source text not null default 'manual',
  score integer check (score between 1 and 10),
  recommended_package text check (recommended_package in ('Starter', 'Pro', 'Business') or recommended_package is null),
  status prospect_status not null default 'new',
  findings jsonb not null default '[]'::jsonb,
  owner_agent text,
  next_action_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists prospects_status_idx on prospects (status);
create index if not exists prospects_vertical_city_idx on prospects (vertical, country, city);
create index if not exists prospects_contact_idx on prospects (contact_id);

create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null default now(),
  event_type text not null,
  source text not null,
  idempotency_key text not null,
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  actor text,
  summary text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint events_idempotency_key_uidx unique (idempotency_key)
);

create index if not exists events_type_time_idx on events (event_type, occurred_at desc);
create index if not exists events_contact_idx on events (contact_id);
create index if not exists events_prospect_idx on events (prospect_id);

create table if not exists outreach_attempts (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references prospects(id) on delete cascade,
  contact_id uuid references contacts(id) on delete set null,
  channel contact_channel not null,
  template_name text,
  status outreach_status not null default 'queued',
  external_message_id text,
  sent_at timestamptz,
  responded_at timestamptz,
  error_message text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists outreach_attempts_prospect_idx on outreach_attempts (prospect_id);
create index if not exists outreach_attempts_status_idx on outreach_attempts (status);
create unique index if not exists outreach_external_message_uidx on outreach_attempts (external_message_id) where external_message_id is not null;

create table if not exists demo_requests (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid references prospects(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  source text not null,
  status demo_status not null default 'requested',
  requested_package text check (requested_package in ('Starter', 'Pro', 'Business') or requested_package is null),
  intake jsonb not null default '{}'::jsonb,
  requested_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists demo_requests_status_idx on demo_requests (status);
create index if not exists demo_requests_prospect_idx on demo_requests (prospect_id);

create table if not exists proposals (
  id uuid primary key default gen_random_uuid(),
  demo_request_id uuid references demo_requests(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  slug text not null,
  status proposal_status not null default 'draft',
  public_url text,
  qa_summary text,
  published_at timestamptz,
  delivered_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint proposals_slug_uidx unique (slug)
);

create index if not exists proposals_status_idx on proposals (status);
create index if not exists proposals_demo_request_idx on proposals (demo_request_id);

create table if not exists handoffs (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references contacts(id) on delete set null,
  prospect_id uuid references prospects(id) on delete set null,
  conversation_id text,
  from_owner text not null,
  to_owner text not null,
  reason text not null,
  status text not null default 'open' check (status in ('open', 'accepted', 'resolved', 'cancelled')),
  priority text not null default 'normal' check (priority in ('low', 'normal', 'high', 'urgent')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists handoffs_status_idx on handoffs (status, priority);
create index if not exists handoffs_contact_idx on handoffs (contact_id);

drop trigger if exists set_contacts_updated_at on contacts;
create trigger set_contacts_updated_at
before update on contacts
for each row execute function set_updated_at();

drop trigger if exists set_prospects_updated_at on prospects;
create trigger set_prospects_updated_at
before update on prospects
for each row execute function set_updated_at();

drop trigger if exists set_outreach_attempts_updated_at on outreach_attempts;
create trigger set_outreach_attempts_updated_at
before update on outreach_attempts
for each row execute function set_updated_at();

drop trigger if exists set_demo_requests_updated_at on demo_requests;
create trigger set_demo_requests_updated_at
before update on demo_requests
for each row execute function set_updated_at();

drop trigger if exists set_proposals_updated_at on proposals;
create trigger set_proposals_updated_at
before update on proposals
for each row execute function set_updated_at();

drop trigger if exists set_handoffs_updated_at on handoffs;
create trigger set_handoffs_updated_at
before update on handoffs
for each row execute function set_updated_at();

alter table contacts enable row level security;
alter table prospects enable row level security;
alter table events enable row level security;
alter table outreach_attempts enable row level security;
alter table demo_requests enable row level security;
alter table proposals enable row level security;
alter table handoffs enable row level security;
