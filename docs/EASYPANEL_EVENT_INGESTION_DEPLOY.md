# Easypanel Event Ingestion Deploy

## Estado

Este documento prepara el despliegue HTTP de `runtime/event-ingestion` para STAGING.

No desplegar todavia en produccion. No conectar WhatsApp, Chatwoot, workers, mensajes ni demos.

## Servicio

Runtime:

```text
runtime/event-ingestion/
```

Servidor:

```text
runtime/event-ingestion/src/server.ts
```

Endpoints:

```text
GET /health
POST /events
```

## Crear Servicio en Easypanel

1. Crear una nueva app/servicio para STAGING.
2. Conectar el repo `mangoex/paperclip_codex`.
3. Usar la rama:

```text
codex/import-readiness-audit
```

4. Configurar build con Dockerfile:

```text
runtime/event-ingestion/Dockerfile
```

5. Usar como build context la raiz del repo, no solo `runtime/event-ingestion`, porque el runtime necesita copiar:

```text
contracts/events.schema.json
```

## Variables de Entorno

Configurar en Easypanel STAGING, no en el repo:

```text
PORT=3000
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
```

No commitear secretos. No registrar service role en logs, docs, samples ni screenshots.

## Exponer Endpoint

Exponer el servicio con una URL staging, por ejemplo:

```text
https://<event-ingestion-staging-host>
```

No usar dominio productivo todavia.

## Probar Health

```text
curl https://<event-ingestion-staging-host>/health
```

Respuesta esperada:

```json
{
  "status": "ok",
  "service": "event-ingestion",
  "mode": "staging"
}
```

## Probar POST /events

Usar un evento `outbound_prospecting_requested` valido:

```text
curl -X POST "https://<event-ingestion-staging-host>/events" \
  -H "Content-Type: application/json" \
  --data @runtime/event-ingestion/samples/outbound_prospecting_requested.valid.json
```

Estados esperados:

- `inserted`: evento creado;
- `replayed`: misma `idempotency_key` y mismo payload;
- `conflict`: misma `idempotency_key` y payload distinto;
- `validation_error`: contrato invalido;
- `dead_letter_prepared`: fallo de escritura controlado.

## Conectar Luego n8n Staging

Cuando Miguel autorice:

1. Configurar en n8n STAGING:

```text
HUMANIO_EVENT_INGESTION_URL=https://<event-ingestion-staging-host>
```

2. Importar el workflow staging aislado:

```text
n8n/workflows/humanio_event_ingestion_staging.json
```

3. Probar solo con webhook test/staging.
4. Confirmar `inserted`, `replayed` y `conflict`.
5. Limpiar eventos de prueba por `idempotency_key`.

## Verificar en Supabase

```sql
select
  id,
  event_type,
  source,
  idempotency_key,
  occurred_at,
  created_at
from public.events
where idempotency_key = '<idempotency_key>';
```

## Limpiar Evento de Prueba

```sql
delete from public.events
where idempotency_key = '<idempotency_key>';
```

Confirmar:

```sql
select count(*) as remaining_event_rows
from public.events
where idempotency_key = '<idempotency_key>';
```

## Advertencias

- NO produccion todavia.
- NO WhatsApp.
- NO Chatwoot.
- NO workers de agentes.
- NO mensajes.
- NO demos.
- NO secretos al repo.
- NO PR automatico.
- NO activar workflows productivos.
