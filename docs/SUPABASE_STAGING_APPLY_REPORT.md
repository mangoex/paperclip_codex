# Supabase Staging Apply Report

## Fecha y Hora

2026-05-26T15:40:01.7673955-07:00

## Commit Aplicado

No aplicado.

Commit base verificado en el repositorio local:

```text
6383842 Handle staging reset legacy view
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

No se registraron keys ni secretos.

## Segundo Reset Controlado

Autorizacion recibida para ejecutar el segundo intento de reset controlado solo en Supabase STAGING, usando el script corregido que trata `pipeline_funnel` como view.

Se ejecuto el reset con la senal requerida en la misma sesion SQL:

```sql
set app.environment = 'staging';
```

Luego se ejecuto:

```text
supabase/reset/001_reset_staging_legacy.sql
```

Resultado: RESET_COMPLETED.

El script corregido:

- valido `current_setting('app.environment', true) = 'staging'`;
- valido tipos esperados antes de borrar;
- trato `pipeline_funnel` como view;
- no uso `CASCADE`;
- no toco `auth`;
- no toco `storage`;
- no toco schemas fuera de `public`;
- no toco funciones ajenas;
- no toco secretos.

## Verificacion Posterior al Reset

Se ejecuto una consulta de solo lectura sobre `pg_class` para los objetos legacy:

```sql
select n.nspname as schema_name, c.relname as object_name, c.relkind as object_kind
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname in (
    'pipeline_events',
    'pipeline_funnel',
    'outreach_log',
    'proposals',
    'prospects'
  )
order by c.relname;
```

Resultado: `[]`.

Conclusion: los cinco objetos legacy ya no existen en `public`.

## Backup / Restore Path

No se avanzo a migraciones ni seed en esta autorizacion.

El reset fue ejecutado en staging confirmado. Si hiciera falta revertir datos legacy, se requiere restaurar desde export o backup de staging; no se hizo ningun cambio productivo.

## Migraciones Aplicadas

No aplicadas en esta autorizacion.

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

No verificado como schema objetivo.

Motivo: las migraciones nuevas no se aplicaron en esta autorizacion.

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

Ningun error en el segundo reset controlado.

Accion tomada:

- Se ejecuto reset corregido solo en `Humanio Staging`.
- Se verifico que los objetos legacy ya no existen.
- No se aplicaron migraciones.
- No se ejecuto seed.
- No se ejecuto smoke test.
- No se cambio n8n, WhatsApp, Chatwoot, workers, secretos, PRs, mensajes ni demos.
- No se hicieron cambios productivos.

## Recomendacion

STAGING_RESET_COMPLETED_APPLY_PENDING

Siguiente paso recomendado: aplicar migraciones `001`, `002`, seed y smoke test en staging, con una autorizacion explicita para esa fase.

## Decision Final

STAGING_SCHEMA_READY_WITH_FIXES

El reset staging quedo completado, pero el schema operativo completo todavia no esta aplicado.
