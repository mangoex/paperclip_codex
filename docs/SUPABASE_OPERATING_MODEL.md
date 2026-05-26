# Supabase Operating Model

## Purpose

Supabase is the durable operating ledger for Humanio sales and delivery flows. It stores facts that workflows and agents can trust: contacts, prospects, outreach attempts, replies, demo requests, proposal publishing, handoffs, and event history.

The model is intentionally conservative. AI agents may draft text and interpret context, but status transitions and commercial metrics must be recorded as structured data.

## Core Tables

| Table | Purpose |
| --- | --- |
| `contacts` | People or businesses reached through WhatsApp, email, Chatwoot, or manual entry |
| `prospects` | Qualification record for a contact in a specific city, country, and vertical |
| `events` | Append-only activity log for workflow transitions and external callbacks |
| `outreach_attempts` | Messages sent to a prospect by WhatsApp, email, or manual action |
| `demo_requests` | Explicit requests for a proposal/demo |
| `proposals` | Built and published demo assets |
| `handoffs` | Transfers between agents or from automation to a human operator |

## Status Ownership

| Field | Allowed owner |
| --- | --- |
| Prospect score | Qualifier logic or reviewed import |
| Prospect status | Workflow code or Miguel |
| Outreach status | Outreach workflow code |
| Demo status | Closer and demo workflow code |
| Proposal status | WebQA/WebPublisher workflow code |
| Handoff status | Chatwoot/n8n workflow code or Miguel |

Models can recommend a status change, but the runtime should apply the change only after validating the triggering event.

## Required Event Practices

Every meaningful transition should create an `events` row with:

- `event_type`
- `source`
- `idempotency_key`
- `contact_id` or `prospect_id` when known
- Raw source identifiers in `payload`
- Human-readable `summary`

Use the JSON Schema in `contracts/events.schema.json` before inserting from workflow code.

## Security Model

- Enable Row Level Security on all operating tables.
- Use the Supabase service role only from trusted server-side runtimes.
- Do not expose service keys in browser code, static sites, screenshots, logs, or committed files.
- Prefer views or API endpoints for read-only dashboards instead of opening base tables to anonymous users.
- Keep PII minimization in mind: store only the contact fields needed for outreach, support, and compliance.

## Idempotency

External systems retry webhooks. Each workflow should create a deterministic `idempotency_key` from the source system and source event ID, for example:

```text
whatsapp:{message_id}
chatwoot:{conversation_id}:{message_id}
n8n:{execution_id}:{node_name}
surge:{slug}:{published_at}
```

The `events.idempotency_key` constraint prevents duplicate event rows. Workflow code should treat duplicate-key failures as successful replays, not fatal errors.

## Environments

| Environment | Purpose | Notes |
| --- | --- | --- |
| Local | Schema work and dry-run payload validation | No real outbound messages |
| Staging | Contact override tests | Use Miguel's test number only |
| Production | Real prospects and clients | Requires explicit credential review |

Keep separate Supabase projects or schemas when possible. If a single project must be shared, add a strict `environment` value in event payloads and dashboards.

## Operational Reports

Useful reports should be built from structured tables, not free-text logs:

- Prospects by vertical, city, country, score, and package recommendation.
- Outreach attempts by channel, template, status, and response state.
- Demo requests by source and package.
- Proposal publish status and delivery URL.
- Handoffs waiting for Miguel.
- Conversion from outbound contact to interested reply to demo to close.

## Maintenance

- Review failed workflow writes daily during rollout.
- Keep schema changes in versioned migrations.
- Never edit production rows manually without recording the reason in `events`.
- Before deleting or merging contacts, preserve external IDs and write an audit event.
