# Supabase Staging Apply Report

## Fecha y Hora

2026-05-26T15:17:24.4747440-07:00

## Commit Aplicado

No aplicado.

Commit base verificado en el repositorio local:

```text
a02393a Add Supabase implementation prep layer
```

## Proyecto Supabase Confirmado Como Staging

No confirmado.

El conector de Supabase mostro un unico proyecto disponible:

| Campo | Valor |
| --- | --- |
| Project ref | `nloytkdjbhoozjrhrpxq` |
| Nombre visible | `Paperclip` |
| Region | `us-west-2` |
| Estado | `ACTIVE_HEALTHY` |
| Postgres | `17.6.1.104` |

El proyecto no tiene nombre, metadata visible, ref, ni etiqueta que confirme que sea STAGING. Por la restriccion critica de no tocar produccion, la aplicacion se detuvo antes de ejecutar cualquier SQL.

No se registraron keys ni secretos.

## Backup / Restore Path

No verificado.

Motivo: al no poder confirmar que el proyecto disponible sea STAGING, no se avanzo al paso de backup/restore ni a ninguna operacion de escritura.

## Migraciones Aplicadas

No aplicadas.

Pendientes:

- `supabase/migrations/001_operating_core.sql`
- `supabase/migrations/002_operating_completion.sql`
- `supabase/seeds/001_humanio_company.sql`

## Resultado del Seed

No ejecutado.

## Resultado del Smoke Test

No ejecutado.

No se insertaron datos de prueba y no se ejecuto:

```text
supabase/tests/001_operating_core_smoke.sql
```

## Resultado de RLS

No verificado.

La consulta del runbook no se ejecuto porque no se confirmo entorno STAGING.

## Resultado de Tablas

No verificado.

Tablas esperadas pendientes de validacion:

- `contacts`
- `prospects`
- `events`
- `outreach_attempts`
- `demo_requests`
- `proposals`
- `handoffs`
- `companies`
- `conversations`
- `messages`
- `agent_runs`
- `agent_outputs`
- `approvals`
- `outreach_log`
- `demo_assets`
- `followups`
- `dead_letter_events`
- `audit_log`
- `metrics_snapshots`

## Resultado de Indices

No verificado.

Indices esperados pendientes de validacion:

- `events_idempotency_key_uidx`
- `messages_idempotency_uidx`
- `agent_runs_idempotency_uidx`
- `agent_outputs_idempotency_uidx`
- `approvals_idempotency_uidx`
- `outreach_log_idempotency_uidx`
- `demo_assets_idempotency_uidx`
- `followups_idempotency_uidx`
- `dead_letter_events_idempotency_uidx`
- `metrics_snapshots_idempotency_uidx`

## Errores Encontrados

Bloqueo de seguridad: no se pudo confirmar explicitamente que el proyecto Supabase disponible sea STAGING.

Evidencia:

- El repositorio local esta en `mangoex/paperclip_codex`.
- La rama local esta en `codex/import-readiness-audit`.
- El commit local verificado es `a02393a`.
- El conector de Supabase lista un unico proyecto llamado `Paperclip`, ref `nloytkdjbhoozjrhrpxq`.
- Ese nombre visible no permite distinguir STAGING vs produccion.

Accion tomada:

- No se aplicaron migraciones.
- No se ejecuto seed.
- No se ejecuto smoke test.
- No se cambio n8n, WhatsApp, Chatwoot, workers, secretos, PRs, mensajes ni demos.

## Decision Final

STAGING_SCHEMA_FAILED

La decision es `STAGING_SCHEMA_FAILED` por falta de confirmacion inequivoca de entorno STAGING, no por error de schema.
