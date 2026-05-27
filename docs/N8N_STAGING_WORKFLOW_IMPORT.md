# n8n Staging Workflow Import

## Estado

Workflow exportable creado:

```text
n8n/workflows/humanio_event_ingestion_staging.json
```

No fue importado, activado ni ejecutado.

## Importar Manualmente en n8n Staging

1. Abrir n8n STAGING, no produccion.
2. Crear un workflow nuevo o usar la opcion `Import from file`.
3. Seleccionar:

```text
n8n/workflows/humanio_event_ingestion_staging.json
```

4. Confirmar que el workflow queda inactivo.
5. Revisar que el Webhook path sea:

```text
humanio/staging/outbound-prospecting-requested
```

6. Confirmar que no existen nodos de WhatsApp, Chatwoot, email, Supabase directo, mensajes, demos ni workers.

## Variable de Entorno Requerida en n8n

n8n STAGING debe tener:

```text
HUMANIO_EVENT_INGESTION_URL
```

Ese valor debe apuntar al endpoint staging futuro del runtime `event-ingestion`.

No guardar secretos en el JSON del workflow. No hardcodear URLs reales en el workflow versionado.

## Probar con curl o Postman

Usar solo el webhook test/staging de n8n.

Payload:

```json
{
  "vertical": "dentistas",
  "city": "Culiacan",
  "country": "Mexico",
  "requested_count": 3,
  "requested_by": "miguel",
  "request_id": "n8n-staging-shadow-dentistas-culiacan-001"
}
```

curl:

```text
curl -X POST "https://<n8n-staging-host>/webhook-test/humanio/staging/outbound-prospecting-requested" \
  -H "Content-Type: application/json" \
  --data '{"vertical":"dentistas","city":"Culiacan","country":"Mexico","requested_count":3,"requested_by":"miguel","request_id":"n8n-staging-shadow-dentistas-culiacan-001"}'
```

El workflow debe responder:

```json
{
  "status": "inserted",
  "idempotency_key": "n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001",
  "event_type": "outbound_prospecting_requested",
  "environment": "staging"
}
```

## Validar inserted, replayed y conflict

`inserted`:

- enviar un `request_id` nuevo;
- confirmar respuesta `status=inserted`.

`replayed`:

- repetir exactamente el mismo payload;
- confirmar respuesta `status=replayed`;
- confirmar que solo hay una fila en `public.events`.

`conflict`:

- repetir el mismo `request_id`;
- cambiar un campo del payload, por ejemplo `requested_count`;
- confirmar respuesta `status=conflict`;
- confirmar que la fila original no cambio.

## Verificar en Supabase

Buscar el evento:

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

Verificar que solo existe una fila:

```sql
select count(*) as event_rows
from public.events
where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
```

## Confirmar Que No Hubo Side Effects

Consultar:

```sql
select count(*) from public.messages where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.outreach_log where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.demo_assets where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.followups where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.agent_runs where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.agent_outputs where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.approvals where idempotency_key = 'n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
select count(*) from public.dead_letter_events where idempotency_key = 'dead-letter:n8n-staging:outbound_prospecting_requested:n8n-staging-shadow-dentistas-culiacan-001';
```

Todos deben devolver `0`.

## Limpiar Evento de Prueba

Borrar solo el evento de prueba por `idempotency_key`:

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

Debe devolver `0`.

## Advertencias

- No importar en n8n produccion.
- No activar sin revision manual.
- No conectar WhatsApp.
- No conectar Chatwoot.
- No conectar email.
- No agregar nodos Supabase directos.
- No activar workflows existentes.
- No usar webhooks productivos.
- No enviar mensajes.
- No publicar demos.
- No commitear secretos ni URLs reales.
