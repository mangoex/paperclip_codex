# Supabase Staging Apply Report

## Fecha y Hora

2026-05-26T15:58:12.5046848-07:00

## Commit Aplicado

Commit base verificado en el repositorio local:

```text
e0299bd Fix staging smoke test upserts
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

## Estado Previo

RESET_COMPLETED confirmado antes de aplicar schema.

La consulta de preflight para objetos legacy devolvio `[]`:

- `pipeline_events`
- `pipeline_funnel`
- `outreach_log`
- `proposals`
- `prospects`

## Migraciones Aplicadas

Aplicadas correctamente:

- `supabase/migrations/001_operating_core.sql`
- `supabase/migrations/002_operating_completion.sql`

Migraciones registradas en Supabase despues de aplicar:

- `20260419050703 add_prospect_response_columns`
- `20260419050715 add_enum_checks_and_index`
- `20260422045032 outreach_log_add_provider_status_error`
- `20260526224432 operating_core`
- `20260526224606 operating_completion`

## Resultado del Seed

Ejecutado correctamente:

- `supabase/seeds/001_humanio_company.sql`

Verificacion:

| Campo | Valor |
| --- | --- |
| slug | `humanio` |
| name | `Humanio` |
| domain | `humanio.digital` |
| status | `active` |
| metadata.seed | `001_humanio_company` |

## Resultado del Smoke Test

Ejecutado:

```text
supabase/tests/001_operating_core_smoke.sql
```

Resultado: correcto.

El smoke test corregido se ejecuto en Humanio Staging y llego hasta su ultimo `SELECT`.

```text
dead_letter_events | 10000000-0000-4000-8000-000000000007 | outbound_prospecting_requested | open
```

Nota: el conector de Supabase devolvio solo el ultimo result set. La llegada a `dead_letter_events` confirma que los inserts y selects previos del smoke test completaron sin error antes del `ROLLBACK`.

Fix aplicado antes del rerun:

- `supabase/tests/001_operating_core_smoke.sql` ya no usa `ON CONFLICT`.
- El test usa inserts directos dentro de `BEGIN ... ROLLBACK`.
- La company Humanio se inserta solo si no existe, sin upsert.

## Rollback del Smoke Test

Verificacion posterior: el seed Humanio existe y no quedaron filas de prueba con UUID prefix `10000000-0000-4000-8000-`.

| Tabla | test_rows |
| --- | ---: |
| `companies` slug=`humanio` | 1 |
| `contacts` | 0 |
| `prospects` | 0 |
| `events` | 0 |
| `agent_runs` | 0 |
| `agent_outputs` | 0 |
| `approvals` | 0 |
| `dead_letter_events` | 0 |

## Resultado de RLS

Verificado: `rowsecurity = true` en todas las tablas operativas esperadas.

Tablas verificadas:

- `agent_outputs`
- `agent_runs`
- `approvals`
- `audit_log`
- `companies`
- `contacts`
- `conversations`
- `dead_letter_events`
- `demo_assets`
- `demo_requests`
- `events`
- `followups`
- `handoffs`
- `messages`
- `metrics_snapshots`
- `outreach_attempts`
- `outreach_log`
- `proposals`
- `prospects`

## Resultado de Tablas

Verificado: existen todas las tablas esperadas.

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

Verificado: existen todos los indices de idempotencia esperados.

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

El schema operativo, el seed y el smoke test corregido se validaron correctamente.

Error previo resuelto:

```text
ERROR: 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification
```

El error era del test, no del schema. Se corrigio eliminando `ON CONFLICT` del smoke test y re-ejecutando solo el smoke autorizado.

No se aplicaron migraciones adicionales. No se cambio n8n, WhatsApp, Chatwoot, workers, secretos, PRs, mensajes ni demos.

## Recomendacion

SMOKE_TEST_FIX_APPLIED

Resultado:

- Mantener `docs/SMOKE_TEST_FIX_NOTES.md` como referencia del incidente.
- Usar el smoke test corregido para futuras validaciones manuales de staging.

## Decision Final

STAGING_SCHEMA_READY

Las migraciones, seed, tablas, RLS, indices y smoke test corregido estan aplicados y verificados en STAGING.
