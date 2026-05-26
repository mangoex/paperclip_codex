# VPS and EasyPanel Runtime

## Purpose

This runtime hosts the automation layer that connects Humanio workflows with WhatsApp, Chatwoot, Supabase, and proposal publishing. EasyPanel is used as the deployment and secrets surface; GitHub remains the source of truth.

## Recommended Services

| Service | Role |
| --- | --- |
| n8n | Workflow orchestration, webhooks, retries, and integrations |
| Humanio worker/API | Small server-side adapter for validation, Supabase writes, and shared helpers |
| Postgres/Supabase | Managed outside the VPS unless a local staging database is required |
| Reverse proxy | Managed by EasyPanel for HTTPS and routing |

## Runtime Principles

- One public webhook path per production workflow family.
- Secrets live in EasyPanel environment variables.
- Logs must not include access tokens, service role keys, or full message bodies when avoidable.
- Workflows should fail closed for invalid events and open a human handoff when customer communication is at risk.
- Deployments should be reversible by image/tag or previous Git commit.

## Environment Variables

Load these through EasyPanel, not committed files:

```text
SUPABASE_URL
SUPABASE_SERVICE_KEY
WHATSAPP_PHONE_NUMBER_ID
WHATSAPP_CLOUD_API_TOKEN
CHATWOOT_API_URL
CHATWOOT_API_TOKEN
CHATWOOT_ACCOUNT_ID
CHATWOOT_INBOX_ID
CHATWOOT_WHATSAPP_INBOX_ID
SURGE_TOKEN
SMTP_HOST
SMTP_PORT
SMTP_USER
SMTP_PASS
FROM_EMAIL
FROM_NAME
TELEFONO_MIGUEL
TELEFONO_MIGUEL_DISPLAY
```

Optional keys such as Firecrawl, Pexels, and 21st.dev should be loaded only for services that need them.

## Deployment Checklist

1. Connect the GitHub repository to EasyPanel.
2. Select the branch `codex/import-readiness-audit` for migration testing.
3. Add all required environment variables.
4. Configure a health endpoint for each deployed service.
5. Deploy staging first.
6. Run a contact override test before enabling real outbound.
7. Point one webhook to the new runtime.
8. Monitor Supabase events and Chatwoot conversations.
9. Move remaining webhooks only after the first path is stable.

## Health Checks

Minimum health checks:

- Runtime process is up.
- Supabase can be reached with server credentials.
- Event schema is loadable.
- n8n webhook endpoint responds.
- Chatwoot API token can read account metadata.

Health checks should not send WhatsApp messages, publish sites, or mutate production data.

## Logging

Each workflow execution should log:

- `workflow_name`
- `execution_id`
- `event_type`
- `idempotency_key`
- `contact_id` or external source ID
- `status`
- Short error message when failed

Avoid logging:

- Full Supabase service key
- WhatsApp Cloud token
- Full prospect phone number when not needed
- Full customer message body in infrastructure logs

## Rollback

Keep the previous webhook URL and deployment tag available during cutover.

Rollback steps:

1. Restore the previous webhook endpoint in WhatsApp, Chatwoot, or n8n.
2. Pause new outbound workflow executions.
3. Confirm inbound messages are visible in Chatwoot.
4. Record a rollback event in Supabase.
5. Diagnose from logs and replay queued events only after fixing the root cause.

## Production Guardrails

- Do not disable contact override until Miguel explicitly approves live outreach.
- Do not send proposal URLs until WebQA has passed the artifact.
- Do not let cold outbound wake DesignPlanner, WebBuilder, WebQA, or WebPublisher.
- Do not retire Paperclip until no production webhook or heartbeat depends on it.
