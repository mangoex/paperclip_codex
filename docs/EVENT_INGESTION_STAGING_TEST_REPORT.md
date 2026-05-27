# Event Ingestion Staging Test Report

## Fecha y Hora

2026-05-27T10:23:35.3870548-07:00

## Commit Probado

```text
5611045 Add local env loading for event ingestion
```

## Proyecto Supabase Confirmado

Confirmado por conector Supabase:

| Campo | Valor |
| --- | --- |
| Project ref | `nloytkdjbhoozjrhrpxq` |
| Nombre visible | `Humanio Staging` |
| Region | `us-west-2` |
| Estado | `ACTIVE_HEALTHY` |
| Postgres | `17.6.1.104` |

No se registraron keys ni secretos.

## Entorno Local Seguro

`runtime/event-ingestion/.env.local` existe localmente, esta ignorado por git y contiene las variables requeridas para staging.

Verificacion sin imprimir valores:

| Variable | Estado |
| --- | --- |
| `SUPABASE_URL` | disponible |
| `SUPABASE_URL` coincide con ref `nloytkdjbhoozjrhrpxq` | si |
| `SUPABASE_SERVICE_ROLE_KEY` | disponible |

No se commiteo `.env.local` ni se imprimieron secretos.

## Idempotency Key Usada

```text
manual-shadow-test:outbound_prospecting_requested:20260527172312-0b65a8
```

## Resultado `npm install`

Resultado: correcto.

```text
up to date, audited 49 packages
found 0 vulnerabilities
```

## Resultado `npm test`

Resultado: correcto.

```text
tests 7
pass 7
fail 0
```

Cobertura local verificada:

- evento valido `outbound_prospecting_requested`;
- evento invalido por campo faltante;
- `event_type` desconocido;
- duplicate `idempotency_key` con mismo payload;
- duplicate `idempotency_key` con payload distinto;
- payload preparado para `dead_letter_events` en error simulado.

## Resultado `npm run validate:sample`

Resultado: correcto.

```text
VALID outbound_prospecting_requested local:outbound-prospecting:dentistas-culiacan:001
```

## Prueba 1 Insert

Resultado: correcto.

```text
insert_status = inserted
```

Fila creada en `public.events` durante la prueba:

| Campo | Valor |
| --- | --- |
| `event_id` | `be2fec6d-b3bd-4fd0-9e70-a71fd2819ebf` |
| `event_type` | `outbound_prospecting_requested` |
| `source` | `manual_shadow_test` |
| `idempotency_key` | `manual-shadow-test:outbound_prospecting_requested:20260527172312-0b65a8` |

## Prueba 2 Replay

Resultado: correcto.

```text
replay_status = replayed
```

Se ejecuto el mismo evento con la misma `idempotency_key` y el mismo payload. El writer lo trato como replay seguro.

## Prueba 3 Conflict

Resultado: correcto.

```text
conflict_status = conflict
```

Se ejecuto un evento con la misma `idempotency_key` y un cambio inocuo en `payload.requested_count`. El writer devolvio conflicto y no modifico la fila original.

Verificacion:

```text
original_payload_unchanged = true
```

## Verificacion de Una Sola Fila Durante Prueba

Resultado: correcto.

```text
row_count_during_test = 1
```

Solo existio una fila en `public.events` para la `idempotency_key` de prueba durante los tres pasos.

## Verificacion de No Side Effects

Resultado: correcto.

No se crearon filas relacionadas para esta prueba:

| Tabla | Filas |
| --- | ---: |
| `messages` | 0 |
| `outreach_log` | 0 |
| `demo_assets` | 0 |
| `followups` | 0 |
| `agent_runs` | 0 |
| `agent_outputs` | 0 |
| `approvals` | 0 |
| `dead_letter_events` | 0 |

No se activo ningun canal externo.

## Limpieza Realizada

Resultado: correcto.

Se elimino solo la fila de prueba de `public.events` usando la `idempotency_key`:

```text
cleanup_deleted_idempotency_key = manual-shadow-test:outbound_prospecting_requested:20260527172312-0b65a8
remaining_event_rows_after_cleanup = 0
```

Verificacion read-only posterior:

```text
remaining_event_rows = 0
```

No se borro ningun otro dato.

El script temporal usado para la prueba fue eliminado y no se commiteo.

## Restricciones Confirmadas

No se tocaron:

- produccion;
- n8n;
- WhatsApp;
- Chatwoot;
- workers de agentes;
- mensajes;
- demos;
- secretos en repo;
- PRs;
- migraciones;
- SQL nuevo;
- RLS;
- policies.

## Errores Encontrados

No hubo errores en el reintento con `.env.local`.

## Decision Final

EVENT_INGESTION_STAGING_READY

La prueba fue exitosa porque:

- `insert = inserted`;
- `replay = replayed`;
- `conflict = conflict`;
- solo hubo una fila para la `idempotency_key` durante la prueba;
- la fila de prueba fue eliminada;
- no hubo side effects en tablas operativas;
- no se activo ningun canal externo.
