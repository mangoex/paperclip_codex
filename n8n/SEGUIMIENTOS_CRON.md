# Seguimientos cold msg2/msg3

Owner operativo: n8n cron.

Los tickets `Closer: seguimiento {negocio}` creados por Outreach deben quedar en `blocked`.

El Closer NO envia msg2/msg3 por heartbeat normal. Solo participa en seguimiento si n8n crea un ticket explicito de follow-up con `event_type: followup_due` y status `todo`.

- prospect_id
- nombre_negocio
- telefono/email
- tipo de mensaje: `msg2` o `msg3`
- evidencia de que no hubo respuesta
- evidencia de que ya vencio la fecha

## Contrato del ticket explicito

Titulo:

```text
Closer: enviar {msg2|msg3} a {nombre_negocio}
```

Cuerpo:

```yaml
event_type: followup_due
source: n8n
prospect_id: "{id}"
nombre_negocio: "{nombre}"
telefono: "{telefono_o_null}"
email: "{email_o_null}"
chatwoot_conversation_id: "{id_o_null}"
followup_type: "{msg2|msg3}"
due_at: "{ISO}"
msg1_sent_at: "{ISO}"
no_response_evidence:
  checked_chatwoot_until: "{ISO}"
  checked_outreach_log_until: "{ISO}"
  last_inbound_at: null
allowed_channels:
  whatsapp_template: true
  email_smtp: true
```

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

## Estado operativo requerido

Este documento define la propiedad y las reglas. Antes de una corrida real, valida en n8n que exista un workflow activo que:

1. Consulte `outreach_log` para mensajes `msg1` sin respuesta.
2. Calcule vencimientos de dia 3 y dia 7.
3. Revise que no exista respuesta en Chatwoot/n8n.
4. Cree el ticket explicito anterior en Paperclip.
5. Nunca despierte el ticket `Closer: seguimiento...` bloqueado sin crear evento estructurado.
