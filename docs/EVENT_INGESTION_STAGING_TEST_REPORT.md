# Event Ingestion Staging Test Report

## Fecha y Hora

2026-05-27T08:42:38.4894688-07:00

## Commit Probado

```text
ab0f5aa Add shadow event ingestion runtime
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

Bloqueo encontrado antes de escribir en Supabase:

| Variable | Estado |
| --- | --- |
| `SUPABASE_URL` | no disponible en la sesion local |
| `SUPABASE_SERVICE_ROLE_KEY` | no disponible en la sesion local |

Por esta razon no se ejecuto `event-writer` contra Supabase Staging. No se intento improvisar credenciales, no se escribieron secretos en el repo y no se creo `.env` versionado.

## Idempotency Key Usada

No se uso ninguna `idempotency_key` en Supabase porque la prueba de escritura fue detenida antes de crear el script temporal y antes de llamar al writer.

## Resultado `npm install`

Resultado: correcto.

```text
up to date, audited 48 packages
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

No ejecutada.

Motivo: faltan `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` en el entorno local seguro.

Resultado esperado pendiente: `inserted`.

## Prueba 2 Replay

No ejecutada.

Motivo: la prueba de insercion fue detenida antes de escribir en Supabase.

Resultado esperado pendiente: `replayed`.

## Prueba 3 Conflict

No ejecutada.

Motivo: la prueba de insercion fue detenida antes de escribir en Supabase.

Resultado esperado pendiente: `conflict`.

## Verificacion de Una Sola Fila Durante Prueba

No ejecutada porque no se inserto ninguna fila de prueba.

## Verificacion de No Side Effects

No se ejecuto ninguna escritura contra Supabase Staging, por lo que no se crearon filas por esta prueba en:

- `messages`
- `outreach_log`
- `demo_assets`
- `followups`
- `agent_runs`
- `agent_outputs`
- `approvals`
- `dead_letter_events`

No se activo ningun canal externo.

## Limpieza Realizada

No hubo fila de prueba que limpiar porque la escritura se detuvo antes de llamar a `event-writer`.

No se creo script temporal versionado ni `.env`.

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

La prueba manual contra Supabase Staging quedo bloqueada por entorno local incompleto:

```text
SUPABASE_URL_SET=False
SUPABASE_SERVICE_ROLE_KEY_SET=False
```

El runtime local esta sano, pero la prueba staging de escritura no puede considerarse ejecutada.

## Decision Final

EVENT_INGESTION_STAGING_FAILED

La decision es `FAILED` porque no se validaron los tres comportamientos requeridos contra Supabase Staging. El bloqueo es de credenciales locales ausentes, no de codigo del runtime.
