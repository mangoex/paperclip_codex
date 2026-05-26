# Supabase Operating Model

## Purpose

Supabase is the durable operating ledger for Humanio sales and delivery flows. It stores facts that workflows and agents can trust: contacts, prospects, conversations, messages, outreach evidence, demo requests, demo assets, approvals, handoffs, events, failures, audits, and metric snapshots.

The model is intentionally conservative. AI agents may draft text and interpret context, but status transitions, contact evidence, approval decisions, and commercial metrics must be recorded as structured data.

## Canonical Tables

| Table | Canonical role |
| --- | --- |
| `companies` | Tenant/company record. For this package, the primary row is Humanio. |
| `contacts` | Person or business contact identity: phone, email, Chatwoot contact, and WhatsApp ID. |
| `prospects` | Sales opportunity for a contact in a specific city, country, and vertical. |
| `conversations` | Canonical conversation thread across Chatwoot, WhatsApp, and internal workflow references. |
| `messages` | Canonical inbound/outbound/internal message ledger with provider IDs and delivery state. |
| `events` | Append-only workflow event ledger. Every meaningful transition should have one event. |
| `agent_runs` | Execution record for an agent or workflow step triggered by an event. |
| `agent_outputs` | Structured output from an agent run: briefs, specs, summaries, decisions, or QA results. |
| `approvals` | Human approval gate before risky sends, production changes, or ambiguous customer actions. |
| `outreach_log` | Canonical evidence of real outbound contact attempts and demo delivery sends. |
| `demo_requests` | Explicit request for a proposal/demo, usually from inbound or positive response. |
| `demo_assets` | Canonical built asset record: design spec, site, proposal, report, QA artifact, or published demo. |
| `followups` | Scheduled msg2/msg3/demo follow-up obligations and their no-response evidence. |
| `handoffs` | Transfer between agents or from automation to a human operator. |
| `dead_letter_events` | Failed or invalid events that could not be processed safely. |
| `audit_log` | Append-only record for manual corrections, sensitive changes, and rollback actions. |
| `metrics_snapshots` | Point-in-time metrics used for reports and weekly pipeline analysis. |

## Legacy and Complementary Tables

`outreach_log` is canonical for outbound evidence. Existing instructions in the repo already require `outreach_log_ids` before Closer treats an external wait as healthy.

`outreach_attempts` from `001_operating_core.sql` remains legacy/complementary. It can be kept for compatibility with early workflows, but new send evidence should write to `outreach_log`. If both exist, `outreach_log` wins.

`demo_assets` is canonical for built and published demo artifacts. `proposals` from `001_operating_core.sql` remains legacy/complementary and can be referenced by `demo_assets.proposal_id` during transition. If both exist, `demo_assets` wins for publication state, QA state, and delivery URLs.

## Demo Flow Relationships

`demo_requests` records the explicit request or positive response that authorizes proposal work. It should reference `prospect_id` and `contact_id` when known.

`events` records the transitions around that request:

- `demo_request`
- `design_spec_created`
- `demo_built`
- `webqa_completed`
- `demo_published`

`demo_assets` records the artifacts created by those transitions. A single `demo_request` can have multiple assets: design spec, proposal site, report page, QA report, and final published site.

The expected chain is:

```text
events.demo_request -> demo_requests
events.design_spec_created -> agent_runs -> agent_outputs -> demo_assets(asset_type=design_spec)
events.demo_built -> demo_assets(asset_type=site|proposal|report)
events.webqa_completed -> demo_assets.qa_status / agent_outputs(output_type=webqa_report)
events.demo_published -> demo_assets.status=published
```

## Conversation and Message Relationships

`conversations` maps external threads to the internal ledger:

- Chatwoot conversation ID
- WhatsApp thread or sender ID
- Contact and prospect when known
- Current open/resolved state

`messages` stores individual inbound, outbound, internal, or system messages. It should capture provider IDs such as Meta `messages[0].id`, SMTP message ID, and Chatwoot message ID. Chatwoot and WhatsApp webhooks should first upsert `conversations`, then insert or update `messages`, then create an `events` row such as `inbound_chatwoot_event` or `inbound_response`.

Chatwoot is the CRM/conversation surface. WhatsApp is the provider channel. Supabase is the durable source of truth for whether a message exists, which provider ID proves it, and whether a follow-up is allowed.

## Agent Runs and Outputs

`agent_runs` records that an agent or workflow step executed against an event. Use it for Scout searches, Qualifier scoring, Outreach preparation, Closer intake, DesignPlanner specs, WebBuilder builds, WebQA checks, WebPublisher publishing, and DataAnalyst reports.

`agent_outputs` stores the structured result of a run. Examples:

- `prospect_list`
- `qualification_brief`
- `outreach_copy`
- `conversation_triage`
- `design_spec`
- `build_manifest`
- `webqa_report`
- `metrics_report`

Models can produce `agent_outputs`, but downstream workflow code should validate the output before changing canonical status fields.

## Approvals

Use `approvals` when automation needs a human decision before acting. Typical cases:

- Sending a risky or uncertain outbound message.
- Delivering a demo when QA evidence is incomplete.
- Marking a prospect as won/lost based on ambiguous language.
- Retrying a dead-lettered customer-facing event.
- Changing production webhook or runtime behavior.

An approval should reference the triggering `event_id`, the requesting `agent_run_id` when available, and the relevant `contact_id` or `prospect_id`. The final decision belongs in `approvals`, and a summary should also be recorded in `events` or `audit_log`.

## Dead Letters and Audit Log

Use `dead_letter_events` when an event cannot be processed safely because validation failed, a provider returned an unexpected shape, Supabase rejected a write, or a workflow cannot determine the correct owner. Dead letters should preserve the original payload, error, retry count, and resolution state.

Use `audit_log` for deliberate human or system changes that need a reason. Examples:

- Manual contact merge.
- Manual prospect status correction.
- Rollback after failed webhook cutover.
- Approval override.
- Replay or ignore decision for a dead letter.

`audit_log` is append-only. Do not use it as a mutable task table.

## Status Ownership

| Field | Allowed owner |
| --- | --- |
| Prospect score | Qualifier logic or reviewed import |
| Prospect status | Workflow code or Miguel |
| Outreach evidence | `outreach_log` written after provider proof |
| Message status | Provider webhooks, Chatwoot events, or workflow code |
| Demo request status | Closer and demo workflow code |
| Demo asset status | DesignPlanner/WebBuilder/WebQA/WebPublisher workflow code |
| Approval status | Miguel or explicit human operator |
| Handoff status | Chatwoot/n8n workflow code or Miguel |
| Dead letter status | Workflow recovery code or Miguel |

Models can recommend a status change, but the runtime should apply the change only after validating the triggering event.

## Required Event Practices

Every meaningful transition should create an `events` row with:

- `event_type`
- `source`
- `idempotency_key`
- `contact_id` or `prospect_id` when known
- Raw source identifiers in `payload.external_ids`
- Human-readable `summary`

Use `contracts/events.schema.json` before inserting from workflow code. The schema keeps a base envelope and adds typed payload requirements for the event types used by the Humanio flow.

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
agent:{run_id}:{output_type}
followup:{prospect_id}:{followup_type}:{due_at}
```

The unique idempotency indexes in `events`, `messages`, `agent_runs`, `agent_outputs`, `approvals`, `outreach_log`, `demo_assets`, `followups`, `dead_letter_events`, and `metrics_snapshots` prevent duplicate records. Workflow code should treat duplicate-key failures as successful replays when the existing row is equivalent.

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
- Outreach attempts from canonical `outreach_log` by channel, template, status, and response state.
- Conversations and messages by Chatwoot conversation, WhatsApp sender, and response state.
- Demo requests by source and package.
- Demo assets by build, QA, publish, and delivery status.
- Follow-ups due, sent, skipped, and blocked.
- Handoffs and approvals waiting for Miguel.
- Dead-lettered events by error class and retry state.
- Conversion from outbound contact to interested reply to demo to close.

## Maintenance

- Review failed workflow writes daily during rollout.
- Keep schema changes in versioned migrations.
- Never edit production rows manually without recording the reason in `audit_log`.
- Before deleting or merging contacts, preserve external IDs and write an audit event.
- Do not backfill generic demo data into production.
