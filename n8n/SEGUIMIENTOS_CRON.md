# Seguimientos cold msg2/msg3

Owner operativo: n8n cron.

Los tickets `Closer: seguimiento {negocio}` creados por Outreach deben quedar en `blocked`.

El Closer NO envia msg2/msg3 por heartbeat normal. Solo participa en seguimiento si n8n crea un ticket explicito de follow-up con:

- prospect_id
- nombre_negocio
- telefono/email
- tipo de mensaje: `msg2` o `msg3`
- evidencia de que no hubo respuesta
- evidencia de que ya vencio la fecha

## Cadencia

- msg2: dia 3 despues de msg1, template Meta `humanio_seguimiento_1`.
- msg3: dia 7 despues de msg1, template Meta `humanio_seguimiento_2`.

## Preflight obligatorio

Antes de enviar cualquier seguimiento:

1. Confirmar que el prospecto no respondio en Chatwoot/n8n.
2. Confirmar que `prospects.etapa` no esta en `demo_solicitada`, `en_negociacion`, `cerrado_ganado` o `cerrado_perdido`.
3. Confirmar que no hay otro `outreach_log` para el mismo prospecto en las ultimas 24 horas.
4. Confirmar que no existe ya un log del mismo tipo (`msg2` o `msg3`) con provider_message_id real.

## Canales

- WhatsApp fuera de ventana 24h: usar solo template aprobado.
- Email: SMTP directo. No usar Chatwoot API para email saliente.
- Chatwoot: solo notas privadas/CRM.

## Registro

Todo envio real debe registrar `outreach_log` con `provider_message_id` real.

Para WhatsApp, si Meta devuelve `messages[0].id`, registrar la fila segun el enum de Supabase y conservar la semantica real como:

```json
{"provider_semantic_status":"accepted_by_meta","delivery_status":"pending_webhook"}
```

## Pendiente de implementacion

Este documento define la propiedad y las reglas. El workflow n8n de cron debe existir y estar activo antes de que llegue el primer dia 3 de una corrida real.
