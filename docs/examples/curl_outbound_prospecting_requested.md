# curl outbound_prospecting_requested

Usar solo contra el endpoint STAGING de `event-ingestion`.

## Health

```text
curl https://<event-ingestion-staging-host>/health
```

## Insert

```text
curl -X POST "https://<event-ingestion-staging-host>/events" \
  -H "Content-Type: application/json" \
  --data '{
    "event_type": "outbound_prospecting_requested",
    "source": "manual_shadow_curl",
    "idempotency_key": "manual-shadow-curl:outbound_prospecting_requested:001",
    "occurred_at": "2026-05-27T17:00:00.000Z",
    "actor": "miguel",
    "summary": "Manual curl staging test.",
    "payload": {
      "request_id": "manual-shadow-curl-001",
      "vertical": "dentistas",
      "city": "Culiacan",
      "country": "Mexico",
      "requested_count": 3,
      "requested_by": "miguel",
      "external_ids": {
        "environment": "staging",
        "source": "curl"
      }
    }
  }'
```

Respuesta esperada en primer envio:

```json
{
  "status": "inserted",
  "idempotency_key": "manual-shadow-curl:outbound_prospecting_requested:001",
  "event_type": "outbound_prospecting_requested"
}
```

Enviar exactamente el mismo payload otra vez debe devolver:

```json
{
  "status": "replayed",
  "idempotency_key": "manual-shadow-curl:outbound_prospecting_requested:001",
  "event_type": "outbound_prospecting_requested"
}
```

Cambiar el payload manteniendo la misma `idempotency_key` debe devolver:

```json
{
  "status": "conflict",
  "idempotency_key": "manual-shadow-curl:outbound_prospecting_requested:001",
  "event_type": "outbound_prospecting_requested",
  "message": "idempotency_key already exists with a different payload"
}
```

## Limpieza

```sql
delete from public.events
where idempotency_key = 'manual-shadow-curl:outbound_prospecting_requested:001';
```

No usar contra produccion. No conectar WhatsApp, Chatwoot, workers, mensajes ni demos.
