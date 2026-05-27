# Next Implementation Phase

## Current Status

Supabase Staging is ready.

- Reset legacy drift: completed in staging only.
- Operating schema: applied in staging.
- Humanio seed: applied in staging.
- Smoke test: corrected, rerun, and passing.
- Final schema decision: `STAGING_SCHEMA_READY`.

The current implementation step is the local event ingestion runtime:

```text
runtime/event-ingestion/
```

It includes `event-validator`, `event-writer`, local samples, a validation script, and unit tests. It is not deployed.

## Objective

Build the first safe runtime path around the Supabase operating schema without touching production behavior.

This phase is shadow mode only. It should prove that events can be validated, written, read, and processed without sending real WhatsApp messages or changing live customer state.

## Scope

The next phase includes:

- event validator
- event writer
- first n8n webhook emitting a structured event
- first worker reading that event
- shadow-mode logging and reporting

The next phase excludes:

- real WhatsApp sends
- Chatwoot customer replies
- n8n production workflow changes
- production webhook cutover
- public dashboard policies
- secret movement into committed files
- automatic customer-facing responses
- retiring Paperclip

## Step 1: Event Validator

Status: initial local runtime created.

Create a small server-side validator that loads:

```text
contracts/events.schema.json
```

Responsibilities:

- validate the base envelope;
- validate payload requirements by `event_type`;
- reject unknown event types;
- return actionable validation errors;
- never mutate Supabase directly.

Initial validation target:

```text
outbound_prospecting_requested
```

## Step 2: Event Writer

Status: initial local runtime created, with tests using a simulated Supabase client.

Create a server-side event writer that receives already-validated events and inserts into `events`.

Responsibilities:

- use service role only from the trusted runtime;
- create deterministic `idempotency_key` values;
- treat duplicate idempotency keys as safe replays when payloads match;
- write failures to `dead_letter_events`;
- avoid logging secrets or full customer message bodies.

The event writer should not send WhatsApp messages, publish demos, or update customer-visible systems.

## Step 3: First n8n Staging Webhook

Next step: create a staging-only n8n webhook that emits:

```text
outbound_prospecting_requested
```

The webhook should:

- accept a small internal request payload;
- normalize fields into the event contract;
- call the validator;
- call the event writer only after validation passes;
- tag payloads with `environment=staging` or `environment=local`;
- never trigger real outreach.

This must not modify n8n production.

## Step 4: First Worker

Create one worker that reads new `outbound_prospecting_requested` events and records a shadow `agent_run`.

Responsibilities:

- read events by `event_type`;
- create an `agent_runs` row with `status=succeeded` or `failed`;
- create an `agent_outputs` row with a summary of what would happen;
- never contact prospects;
- never create `outreach_log` provider evidence unless a real provider send happened.

## Step 5: Shadow Mode Rules

Shadow mode means:

- no real WhatsApp sends;
- no SMTP sends;
- no Chatwoot customer replies;
- no demo publication;
- no production webhook changes;
- no customer-visible status changes;
- no public dashboard exposure.

Allowed actions:

- validate event JSON;
- insert `events`;
- insert `agent_runs`;
- insert `agent_outputs`;
- insert `dead_letter_events`;
- create internal logs;
- run manual smoke tests.

## Verification

The phase is successful when:

- invalid events are rejected with clear errors;
- valid `outbound_prospecting_requested` events write once;
- replayed events do not create duplicates;
- the worker creates one shadow `agent_run`;
- the worker creates one shadow `agent_output`;
- failures produce `dead_letter_events`;
- no message provider receives a send request.

## Exit Criteria

Move beyond shadow mode only after Miguel reviews:

- validator behavior;
- event writer idempotency;
- dead-letter behavior;
- worker output shape;
- logs with secrets redacted;
- Supabase rows created during staging tests;
- confirmation that no real WhatsApp sends occurred.
