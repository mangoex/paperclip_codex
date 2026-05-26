# Humanio Paperclip Migration Plan

## Objective

Move the Humanio operating package from a Paperclip-importable bundle into a stable runtime that can run the commercial workflows with explicit ownership, durable data, and reversible rollout steps.

The migration keeps the current business rules:

- Outbound by city and vertical runs `CEO -> Scout -> Qualifier -> Outreach -> Closer`.
- Cold outbound does not create a demo site until the prospect shows explicit interest.
- Inbound or interested prospects run `Closer -> DesignPlanner -> WebBuilder -> WebQA -> WebPublisher -> Closer/Outreach`.
- Web agents remain paused until the demo flow wakes them directly.
- Supabase stores operational state; models interpret and write notes, but deterministic status changes stay in code or workflow logic.

## Target State

| Layer | Target owner | Purpose |
| --- | --- | --- |
| Repository | GitHub branch `codex/import-readiness-audit` | Versioned package, docs, migrations, and contracts |
| Runtime | VPS/EasyPanel | n8n, webhook workers, and agent service deployment |
| Database | Supabase Postgres | Contacts, prospects, events, demo requests, proposals, and handoffs |
| Messaging | WhatsApp Cloud API + Chatwoot | Inbound, outbound, quick replies, and human handoff |
| Web delivery | Surge now, replaceable later | Demo proposal publishing and legacy redirect support |

## Migration Phases

### Phase 0: Freeze and Backup

1. Export the current Paperclip company/package.
2. Export all active n8n workflows that touch Humanio sales, WhatsApp, Chatwoot, Surge, or Supabase.
3. Snapshot environment variables without committing secrets.
4. Confirm the current branch, remote, and latest commit before applying changes.

Exit criteria:

- The package can be re-imported from GitHub.
- The current Paperclip setup can be restored from exports.
- No production workflow has been changed yet.

### Phase 1: Data Foundation

1. Apply `supabase/migrations/001_operating_core.sql` to the Supabase project.
2. Create service-role access only for trusted automation runtimes.
3. Keep browser/client access read-restricted until public views are intentionally designed.
4. Backfill only verified contacts and prospects. Do not seed generic demo data into production.

Exit criteria:

- Tables exist in Supabase.
- A service-role smoke test can insert and read one internal test record.
- RLS is enabled and anonymous access cannot read operating tables.

### Phase 2: Event Contract

1. Use `contracts/events.schema.json` as the canonical event envelope.
2. Make n8n emit events for prospect qualification, outreach, replies, demo requests, proposal publishing, and handoff.
3. Validate payload shape before writing to Supabase.
4. Store raw source IDs for Chatwoot, WhatsApp, n8n, and Surge where available.

Exit criteria:

- Every workflow transition creates one durable event.
- Invalid events fail closed and are visible in workflow logs.
- Re-running a workflow does not duplicate events with the same `idempotency_key`.

### Phase 3: Runtime Cutover

1. Deploy the runtime on VPS/EasyPanel using the operating model in `docs/VPS_EASYPANEL_RUNTIME.md`.
2. Load secrets from the platform UI, not from committed files.
3. Point only one test webhook to the new runtime first.
4. Run a contact override test with Miguel's number before sending real outreach.
5. Move production webhooks one by one after successful tests.

Exit criteria:

- Health checks pass.
- WhatsApp inbound reaches Chatwoot and creates an event.
- Outbound test logs the event and does not contact real prospects unless override is disabled deliberately.

### Phase 4: Paperclip Retirement

1. Keep Paperclip read-only during the first production week.
2. Compare Supabase events with Paperclip logs daily.
3. Stop Paperclip heartbeats only after replacement workflows cover the same responsibilities.
4. Follow `docs/PAPERCLIP_RETIREMENT_PLAN.md` for final shutdown.

Exit criteria:

- No active production webhook depends on Paperclip.
- No agent heartbeat is required to continue the Humanio sales flow.
- Rollback instructions have been tested once.

## Rollback Rules

- If inbound WhatsApp fails, restore the previous webhook endpoint immediately.
- If Supabase writes fail, keep customer-facing responses running and queue events for replay.
- If proposal publishing fails, do not send a broken URL; keep the prospect in `demo_requested`.
- If a model-generated response violates business rules, silence automation and hand off to Miguel.

## Manual Checklist

- [ ] Supabase migration applied.
- [ ] Environment variables loaded in EasyPanel.
- [ ] n8n workflow exports stored outside the repo.
- [ ] Contact override test passed.
- [ ] Inbound quick reply test passed.
- [ ] Proposal publish test passed.
- [ ] Paperclip read-only observation window completed.
