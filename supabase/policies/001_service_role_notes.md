# Service Role and RLS Notes

## Current Policy Position

All operating tables keep Row Level Security enabled. This is intentional: base tables should not be exposed directly to browser clients, anonymous users, public dashboards, or unauthenticated API consumers.

Server-side operations use the Supabase service role from trusted runtimes only:

- n8n server-side workflows
- VPS/EasyPanel worker services
- internal event writer services
- controlled admin scripts run by Miguel or an operator

The service role key must never be committed, logged, sent to the browser, pasted into static sites, or included in generated artifacts.

## No Public Policies Yet

This package does not create public `select`, `insert`, `update`, or `delete` policies yet.

That is safer for the preparation phase because:

- no production runtime has been wired;
- no dashboard access model has been approved;
- PII may exist in contacts, conversations, messages, and outreach logs;
- event payloads may contain provider IDs or operational details;
- exposing base tables before views are designed would make later cleanup harder.

## Future Dashboard Access

Dashboard access should be added through a separate reviewed change. Prefer one of these patterns:

1. Create read-only SQL views that expose only non-sensitive columns.
2. Create server-side API endpoints that query with service role and return filtered results.
3. Create materialized reporting tables or `metrics_snapshots` rows with aggregate data only.

Do not grant public access to base tables such as:

- `contacts`
- `conversations`
- `messages`
- `events`
- `outreach_log`
- `agent_runs`
- `agent_outputs`
- `dead_letter_events`
- `audit_log`

## Future Policy Checklist

- Define who can see the dashboard.
- Decide whether access is internal-only, authenticated, or customer-facing.
- Remove phone numbers, raw message text, provider IDs, and service metadata from public views.
- Test RLS as anonymous, authenticated user, and service role.
- Document every policy with its intended consumer.

Until that review happens, the intended access model is: RLS on, no public policies, service-role-only writes and reads from trusted server-side code.
