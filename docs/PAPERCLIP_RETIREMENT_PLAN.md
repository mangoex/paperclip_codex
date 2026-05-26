# Paperclip Retirement Plan

## Goal

Retire Paperclip only after Humanio's workflows can run from the new GitHub, Supabase, and VPS/EasyPanel operating model without losing inbound messages, prospect state, or proposal delivery history.

This is a controlled retirement, not a hard cutover.

## What Must Stay True

- Cold outbound remains a research and outreach flow, not an automatic website-building flow.
- A demo/proposal starts only after explicit interest or inbound request.
- Human handoff stays available for risky conversations.
- Supabase becomes the durable source of operational truth.
- GitHub remains the source of versioned instructions, migrations, contracts, and docs.

## Retirement Stages

### Stage 1: Read-Only Observation

Keep Paperclip running but do not add new responsibilities.

Checks:

- New runtime writes events to Supabase.
- Chatwoot still receives inbound WhatsApp messages.
- Miguel can identify which system handled each conversation.
- Paperclip logs and Supabase events match for active test cases.

Minimum duration: one production week or a full set of successful end-to-end tests.

### Stage 2: Disable Non-Critical Heartbeats

Pause any Paperclip heartbeat that is not required for live customer communication.

Recommended order:

1. WebPublisher
2. WebQA
3. WebBuilder
4. DesignPlanner
5. DataAnalyst
6. Outreach
7. Qualifier
8. Scout
9. Closer
10. CEO

Closer and CEO should be last because they are most likely to touch live customer state.

### Stage 3: Move Webhooks

Move production webhooks one by one:

1. Inbound WhatsApp callback.
2. Chatwoot conversation events.
3. Quick reply handlers.
4. Demo request trigger.
5. Proposal publish callback.
6. Follow-up scheduler.

After each move, run one contact override test and inspect Supabase events.

### Stage 4: Archive Paperclip State

Before final shutdown:

- Export agents, skills, tasks, projects, and company metadata.
- Export relevant conversation or run logs if available.
- Store workflow IDs, webhook URLs, and environment variable names in a private operations note.
- Confirm no committed file contains real secrets.

### Stage 5: Shutdown

1. Pause remaining Paperclip agents.
2. Remove production webhook targets that point to Paperclip.
3. Keep the account/package accessible for historical review.
4. Record the shutdown date and final commit SHA in Supabase `events`.

## Rollback Plan

Rollback is allowed until Stage 5 is complete.

If the new runtime fails:

1. Repoint webhooks to the last known Paperclip endpoint.
2. Pause new outbound sends.
3. Replay missed Supabase events only after deduplication by `idempotency_key`.
4. Mark affected conversations for human review in Chatwoot.

## Retirement Completion Criteria

- No production webhook points to Paperclip.
- No Paperclip heartbeat is required for inbound, outbound, demo, proposal, or handoff flows.
- Supabase contains a complete event record for the final test path.
- Miguel has a documented way to pause automation and take over manually.
