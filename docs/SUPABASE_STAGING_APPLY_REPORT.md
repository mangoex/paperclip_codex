# Supabase Staging Apply Report

## Fecha y Hora

2026-05-26T15:33:38.7095113-07:00

## Commit Aplicado

No aplicado.

Commit base verificado en el repositorio local:

```text
8e6ab46 Add Supabase staging reset plan
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

## Reset Controlado

Autorizacion recibida para ejecutar reset controlado solo en Supabase STAGING.

Se ejecuto el reset con la senal requerida en la misma sesion SQL:

```sql
set app.environment = 'staging';
```

Luego se ejecuto:

```text
supabase/reset/001_reset_staging_legacy.sql
```

Resultado: fallo seguro antes de completar el reset.

Error devuelto por Supabase:

```text
ERROR: 42809: "pipeline_funnel" is not a table
HINT: Use DROP VIEW to remove a view.
```

El script no usa `CASCADE` y no incluye `DROP VIEW`, por lo que se detuvo como estaba previsto ante un objeto no contemplado.

## Estado Tras el Fallo del Reset

Se hizo una consulta de solo lectura para confirmar si hubo cambios parciales.

Objetos legacy detectados despues del fallo:

| Objeto | Tipo |
| --- | --- |
| `outreach_log` | table |
| `pipeline_events` | table |
| `pipeline_funnel` | view |
| `proposals` | table |
| `prospects` | table |

Conclusion: no se observaron drops parciales; los objetos legacy siguen presentes.

## Backup / Restore Path

No se avanzo a migraciones ni seed.

El proyecto esta en staging, pero el reset fallo antes de reconstruir el schema. No se intento restauracion porque no se observaron drops parciales.

## Migraciones Aplicadas

No aplicadas.

Pendientes:

- `supabase/migrations/001_operating_core.sql`
- `supabase/migrations/002_operating_completion.sql`
- `supabase/seeds/001_humanio_company.sql`

Motivo: el reset controlado fallo por `pipeline_funnel` siendo una vista, no una tabla.

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

Motivo: no se aplicaron las migraciones nuevas.

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

El reset controlado fallo porque `pipeline_funnel` es una vista (`relkind = v`), no una tabla.

Accion tomada:

- Se detuvo el proceso.
- No se uso `CASCADE`.
- No se uso `DROP VIEW`.
- No se aplicaron migraciones.
- No se ejecuto seed.
- No se ejecuto smoke test.
- No se cambio n8n, WhatsApp, Chatwoot, workers, secretos, PRs, mensajes ni demos.
- No se hicieron cambios productivos.

## Recomendacion

RESET_SCRIPT_FIX_REQUIRED_FOR_VIEW_PIPELINE_FUNNEL

El reset plan debe actualizarse para tratar explicitamente `pipeline_funnel` como vista, con aprobacion manual previa, o para excluirla si no bloquea el rebuild. No se debe improvisar este cambio en ejecucion.

Actualizacion preparada en el repositorio:

- `supabase/reset/001_reset_staging_legacy.sql` distingue tablas y vista legacy.
- `docs/SUPABASE_STAGING_RESET_PLAN.md` documenta el preflight de `relkind`.
- No se ejecuto reset corregido todavia.

## Decision Final

STAGING_SCHEMA_FAILED

La decision es `STAGING_SCHEMA_FAILED` porque el reset controlado fallo antes de aplicar el schema operativo.
