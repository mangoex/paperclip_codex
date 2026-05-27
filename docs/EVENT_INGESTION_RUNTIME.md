# Event Ingestion Runtime

## Estado

Runtime minimo creado en:

```text
runtime/event-ingestion/
```

Este runtime esta en shadow mode. No esta desplegado y no conecta n8n, WhatsApp, Chatwoot, workers de agentes ni publicacion de demos.

## Arquitectura

La capa inicial tiene dos piezas:

- `event-validator`: carga `contracts/events.schema.json`, valida el envelope base, valida el payload por `event_type` usando `oneOf` y `$defs`, rechaza `event_type` desconocidos y devuelve errores legibles.
- `event-writer`: recibe eventos ya validados e inserta en `events` usando Supabase service role desde variables de entorno.

El validador no escribe en Supabase. El writer no valida de nuevo como fuente de verdad de contrato; asume que recibe un evento validado por `event-validator`.

Flujo previsto:

```text
local sample or staging webhook
  -> event-validator
  -> event-writer
  -> public.events
```

En caso de error de escritura, el writer prepara un payload compatible con `dead_letter_events`. La escritura real del dead letter puede agregarse despues con una decision explicita.

## Variables de Entorno

Para validacion local no se requieren secretos.

Para escritura manual a Supabase Staging se requieren variables fuera del repo:

```text
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
```

No se deben commitear valores reales. No usar anon key para escritura server-side. No guardar service role en samples, docs con valores reales ni archivos `.env` versionados.

## Shadow Mode

Permitido:

- validar JSON local;
- correr tests unitarios;
- escribir eventos manualmente en staging cuando Miguel lo autorice;
- preparar payloads de dead letter ante fallas;
- registrar evidencia en docs.

Prohibido:

- tocar produccion;
- conectar n8n productivo;
- enviar WhatsApp;
- responder en Chatwoot;
- crear workers de agentes;
- enviar mensajes;
- publicar demos;
- mover secretos al repo;
- abrir PR sin autorizacion.

## Validar Local

Instalar dependencias del runtime:

```text
cd runtime/event-ingestion
npm install
```

Validar el sample correcto:

```text
npm run validate:sample
```

Validar otro archivo:

```text
npm run validate:sample -- samples/outbound_prospecting_requested.invalid.json
```

Correr tests unitarios locales:

```text
npm test
```

Los tests no usan Supabase real ni secretos. El writer se prueba con un cliente Supabase simulado.

## Escribir a Staging Manualmente

La escritura manual queda reservada para una autorizacion explicita de Miguel.

Cuando se autorice:

1. Confirmar proyecto visible: `Humanio Staging / nloytkdjbhoozjrhrpxq`.
2. Exportar `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` en el entorno local seguro.
3. Validar el evento con `event-validator`.
4. Pasar solo eventos validados a `event-writer`.
5. Confirmar que no se activaron n8n, WhatsApp, Chatwoot, workers ni demos.

El writer maneja idempotencia asi:

- si `idempotency_key` no existe, inserta en `events`;
- si existe y el payload es igual, devuelve replay seguro;
- si existe y el payload es distinto, devuelve conflicto;
- si falla la escritura, devuelve un payload para `dead_letter_events`.

## Siguiente Paso Hacia n8n Staging Webhook

El siguiente paso no es produccion. Es un webhook nuevo o aislado de n8n staging que:

- reciba una solicitud interna de prueba;
- normalice a `outbound_prospecting_requested`;
- llame al validador;
- llame al writer solo si el evento es valido;
- opere en shadow mode;
- no envie mensajes reales ni publique demos.
