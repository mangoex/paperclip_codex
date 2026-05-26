# Supabase Staging Apply Report

## Fecha y Hora

2026-05-26T15:25:07.2873374-07:00

## Commit Aplicado

No aplicado.

Commit base verificado en el repositorio local:

```text
4f18708 Document Supabase staging apply blocker
```

## Proyecto Supabase Confirmado Como Staging

Confirmado.

El conector de Supabase mostro el proyecto esperado:

| Campo | Valor |
| --- | --- |
| Project ref | `nloytkdjbhoozjrhrpxq` |
| Nombre visible | `Humanio Staging` |
| Organizacion | `Humanio` |
| Region | `us-west-2` |
| Estado | `ACTIVE_HEALTHY` |
| Postgres | `17.6.1.104` |
| Plan de organizacion | `free` |

No se registraron keys ni secretos.

## Backup / Restore Path

No se ejecuto ninguna escritura.

El proyecto esta en plan `free`, por lo que no se confirmo un mecanismo PITR desde el conector. El rollback razonable para esta fase seria logico y revisado porque las migraciones propuestas son aditivas, pero antes de escribir se detecto incompatibilidad con tablas legacy existentes. Por seguridad, se detuvo la aplicacion antes de ejecutar DDL.

Migraciones ya registradas en el proyecto antes del intento:

- `20260419050703 add_prospect_response_columns`
- `20260419050715 add_enum_checks_and_index`
- `20260422045032 outreach_log_add_provider_status_error`

## Preflight de Schema Existente

Tablas existentes antes de aplicar:

- `outreach_log`
- `pipeline_events`
- `pipeline_funnel`
- `proposals`
- `prospects`

Se detecto que `prospects`, `proposals` y `outreach_log` ya existen con un modelo legacy distinto al modelo esperado por las migraciones nuevas.

Ejemplos de incompatibilidad:

- `prospects` tiene columnas como `negocio`, `giro`, `ciudad`, `pais`, `paquete`, `etapa`.
- `001_operating_core.sql` crea `prospects` solo si no existe, pero despues intenta crear indices sobre columnas esperadas por el nuevo modelo, como `status`, `vertical`, `country`, `city`, `contact_id`.
- Como la tabla legacy ya existe, esas columnas no se crearian y los indices de `001` fallarian.
- `proposals` ya existe con columnas como `url_propuesta`, `url_reporte`, `paquete`, `desplegado_at`, `activo`.
- `001_operating_core.sql` espera columnas como `status` y `demo_request_id` para indices posteriores.
- `outreach_log` ya existe con columnas legacy como `canal`, `enviado_at`, `respondio`, `respondio_at`.
- `002_operating_completion.sql` crea `outreach_log` solo si no existe, pero despues espera columnas nuevas como `contact_id`, `event_type`, `idempotency_key`, `company_id`.

Conclusion de preflight: aplicar las migraciones tal como estan sobre este staging no es seguro porque fallarian por drift de schema y podrian dejar trabajo parcial si el runner no encapsula todo en una transaccion.

## Migraciones Aplicadas

No aplicadas.

Pendientes:

- `supabase/migrations/001_operating_core.sql`
- `supabase/migrations/002_operating_completion.sql`
- `supabase/seeds/001_humanio_company.sql`

## Resultado del Seed

No ejecutado.

Motivo: se detuvo la aplicacion antes de escribir por incompatibilidad de schema existente.

## Resultado del Smoke Test

No ejecutado.

No se insertaron datos de prueba y no se ejecuto:

```text
supabase/tests/001_operating_core_smoke.sql
```

Motivo: el smoke test depende de las migraciones `001` y `002`, que no se aplicaron.

## Resultado de RLS

No verificado como paso final.

Motivo: no se aplicaron las migraciones nuevas. Verificar RLS final despues de un apply fallido no tendria valor para el schema objetivo.

## Resultado de Tablas

No verificado como schema objetivo.

Tablas esperadas pendientes de aplicacion/validacion:

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

No verificado como schema objetivo.

Indices esperados pendientes de aplicacion/validacion:

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

Bloqueo de seguridad por drift de schema en staging.

El proyecto correcto `Humanio Staging` fue confirmado, pero ya contiene tablas legacy incompatibles con el supuesto de las migraciones `001` y `002`: esas migraciones usan `create table if not exists` para tablas que ya existen y despues crean indices o foreign keys que presuponen columnas que no estan en esas tablas legacy.

Accion tomada:

- No se aplicaron migraciones.
- No se ejecuto seed.
- No se ejecuto smoke test.
- No se cambio n8n, WhatsApp, Chatwoot, workers, secretos, PRs, mensajes ni demos.
- No se hicieron cambios productivos.

## Decision Final

STAGING_SCHEMA_FAILED

La decision es `STAGING_SCHEMA_FAILED` porque el proyecto STAGING confirmado tiene drift de schema previo. Se requiere una migracion de compatibilidad o una estrategia de reset/rebuild de staging antes de aplicar el schema operativo completo.

## Recomendacion

STAGING_RESET_RECOMMENDED

No ejecutado todavia.

Se preparo un plan y un script de reset seguro para staging:

- `docs/SUPABASE_STAGING_RESET_PLAN.md`
- `supabase/reset/001_reset_staging_legacy.sql`

El reset requiere confirmacion manual previa de Miguel y una senal explicita en la misma sesion SQL:

```sql
set app.environment = 'staging';
```

No se ejecuto SQL en esta tarea.
