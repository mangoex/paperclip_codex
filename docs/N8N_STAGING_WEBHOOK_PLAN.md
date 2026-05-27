# n8n Staging Webhook Plan

## Objetivo

Preparar un workflow aislado de n8n STAGING que reciba una solicitud interna de prospeccion outbound y la envie al runtime `event-ingestion` en shadow mode.

El objetivo del workflow staging es probar la ruta:

```text
n8n staging webhook -> event-ingestion -> Supabase public.events
```

No debe enviar mensajes, tocar Chatwoot, conectar WhatsApp, publicar demos ni modificar workflows existentes.

## Arquitectura

Componentes:

- n8n STAGING webhook aislado;
- `runtime/event-ingestion` como runtime de validacion y escritura;
- Supabase Staging `Humanio Staging / nloytkdjbhoozjrhrpxq`;
- tabla destino `public.events`.

Flujo:

```text
POST /webhook/humanio/staging/outbound-prospecting
  -> normalizar payload n8n
  -> n8nOutboundProspectingToEvent
  -> event-validator
  -> event-writer
  -> public.events
```

## Endpoint Esperado

Endpoint propuesto para staging:

```text
POST https://<n8n-staging-host>/webhook/humanio/staging/outbound-prospecting
```

Este endpoint es nuevo y aislado. No debe reutilizar webhooks productivos ni workflows existentes.

## Payload de Entrada Esperado Desde n8n

```json
{
  "request_id": "n8n-staging-shadow-dentistas-culiacan-001",
  "vertical": "dentistas",
  "city": "Culiacan",
  "country": "Mexico",
  "requested_count": 3,
  "requested_by": "miguel",
  "source": "n8n_staging_webhook",
  "actor": "n8n_staging",
  "summary": "Staging-only outbound prospecting request from n8n.",
  "environment": "staging",
  "external_ids": {
    "n8n_workflow": "staging-event-ingestion-shadow",
    "n8n_execution_id": "manual-shadow-sample"
  }
}
```

Sample local:

```text
runtime/event-ingestion/samples/n8n_outbound_prospecting_requested.valid.json
```

## Transformacion a Evento

El runtime transforma el payload n8n a:

```text
event_type = outbound_prospecting_requested
source = n8n_staging_webhook
payload.request_id = request_id
payload.vertical = vertical
payload.city = city
payload.country = country
payload.requested_count = requested_count
payload.requested_by = requested_by
payload.external_ids.environment = staging
```

La transformacion vive en:

```text
runtime/event-ingestion/src/n8n-transformer.ts
```

## Generacion de Idempotency Key

Si n8n envia `idempotency_key`, se respeta.

Si no la envia, el runtime genera:

```text
n8n-staging:outbound_prospecting_requested:<request_id>
```

Ejemplo:

```text
n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001
```

## Manejo de Resultados

`inserted`:

- el evento se inserto en `public.events`;
- responder `200` o `201` en staging;
- registrar solo metadatos seguros.

`replayed`:

- la `idempotency_key` ya existia con el mismo payload;
- responder `200`;
- no crear filas adicionales.

`conflict`:

- la `idempotency_key` ya existia con payload distinto;
- responder `409`;
- no modificar la fila original;
- escalar manualmente.

`validation_error`:

- el payload no cumple el contrato;
- responder `400`;
- devolver errores legibles sin secretos.

`dead_letter_prepared`:

- el writer no pudo insertar;
- responder `500` o registrar error controlado en staging;
- no activar canales externos.

## Prueba Con curl o Postman

Cuando exista el webhook staging aislado:

```text
curl -X POST "https://<n8n-staging-host>/webhook/humanio/staging/outbound-prospecting" \
  -H "Content-Type: application/json" \
  --data @runtime/event-ingestion/samples/n8n_outbound_prospecting_requested.valid.json
```

Antes de conectar n8n, el runtime puede probarse localmente con:

```text
cd runtime/event-ingestion
npm run validate:sample
```

Escritura manual a Supabase Staging queda reservada para autorizacion explicita:

```text
npm run write:staging
```

## Verificar en Supabase

Buscar la `idempotency_key` esperada:

```sql
select
  id,
  event_type,
  source,
  idempotency_key,
  occurred_at,
  created_at
from public.events
where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
```

Confirmar que no hubo side effects:

```sql
select count(*) from public.messages where idempotency_key = '<idempotency_key>';
select count(*) from public.outreach_log where idempotency_key = '<idempotency_key>';
select count(*) from public.demo_assets where idempotency_key = '<idempotency_key>';
select count(*) from public.followups where idempotency_key = '<idempotency_key>';
select count(*) from public.agent_runs where idempotency_key = '<idempotency_key>';
```

## Limpiar Eventos de Prueba

Eliminar solo la fila de prueba por `idempotency_key`:

```sql
delete from public.events
where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
```

Confirmar limpieza:

```sql
select count(*) as remaining_event_rows
from public.events
where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
```

## Riesgos

- usar por error un host productivo de n8n;
- reutilizar un webhook productivo existente;
- filtrar service role en logs, docs o variables versionadas;
- disparar workflows de outreach reales desde el evento;
- no limpiar eventos de prueba;
- confundir replay seguro con conflicto real.

## Prohibiciones Explicitas

- no WhatsApp;
- no Chatwoot;
- no produccion;
- no workflows existentes;
- no webhooks productivos;
- no workers de agentes;
- no mensajes;
- no demos;
- no secretos al repo.
