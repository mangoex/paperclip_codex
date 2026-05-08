---
name: chatwoot-whatsapp-ops
description: Procedimientos operativos y contratos de API para Chatwoot, WhatsApp Cloud API, Supabase y Paperclip en Humanio.
---

# Chatwoot y WhatsApp Ops - Humanio

Usa esta skill para operar o preparar acciones entre Chatwoot, WhatsApp Cloud API, Supabase y Paperclip.

No contiene secretos. Todos los tokens, URLs e IDs deben venir de variables de entorno configuradas en Paperclip o en el gateway. Nunca hardcodees tokens, keys, contrasenas ni IDs sensibles dentro de skills o agentes.

## Variables requeridas para modo activo

### Chatwoot

```yaml
CHATWOOT_API_URL: "https://<tu-chatwoot>"
CHATWOOT_API_TOKEN: "<token>"
CHATWOOT_ACCOUNT_ID: "<account_id>"
CHATWOOT_WHATSAPP_INBOX_ID: "<inbox_id_whatsapp>"
CHATWOOT_INBOX_ID: "<inbox_id_default_opcional>"
```

### WhatsApp Cloud API

```yaml
WHATSAPP_PHONE_NUMBER_ID: "<phone_number_id>"
WHATSAPP_CLOUD_API_TOKEN: "<token>"
WHATSAPP_GRAPH_VERSION: "v19.0"
```

### Paperclip

```yaml
PAPERCLIP_API_URL: "https://<paperclip-app>"
PAPERCLIP_API_TOKEN: "<token>"
COMPANY_ID: "<company_id>"
CEO_AGENT_ID: "<agent_id>"
CLOSER_AGENT_ID: "<agent_id>"
OUTREACH_AGENT_ID: "<agent_id>"
CONVERSATION_MANAGER_AGENT_ID: "<agent_id>"
```

### Supabase opcional

```yaml
SUPABASE_URL: "https://<project>.supabase.co"
SUPABASE_SERVICE_KEY: "<service_role_key>"
```

### SMTP opcional

```yaml
SMTP_HOST: "<smtp_host>"
SMTP_PORT: "465"
SMTP_USER: "<smtp_user>"
SMTP_PASS: "<smtp_password>"
FROM_EMAIL: "contacto@humanio.digital"
FROM_NAME: "Hannia | Humanio"
```

### Flags de seguridad

```yaml
CONVERSATION_MANAGER_MODE: "shadow|active"
HUMANIO_ENABLE_OUTBOUND_SEND: "false|true"
HUMANIO_ENABLE_INBOUND_SEND: "false|true"
HUMANIO_ALLOWED_ADMIN_PHONES: "lista separada por comas"
```

## Inbound activo: canal y permiso

Para responder un `inbound_chatwoot_event` necesitas:

```yaml
CONVERSATION_MANAGER_MODE: active
HUMANIO_ENABLE_INBOUND_SEND: "true"
conversation_id: presente
message_id: presente
content: presente
sender_phone: presente
```

Canal preferente:

1. **Chatwoot API**. Si el evento llego desde Chatwoot y existe `conversation_id`, este es el canal principal.
2. **WhatsApp Cloud API**. Usalo solo si Chatwoot API no esta disponible y WhatsApp Cloud esta configurado con ventana 24h abierta o template aprobado.

Reglas:

- Para inbound no exijas `HUMANIO_ENABLE_OUTBOUND_SEND=true`.
- Para inbound no exijas email del prospecto.
- Para inbound de Chatwoot no exijas `WHATSAPP_PHONE_NUMBER_ID` ni `WHATSAPP_CLOUD_API_TOKEN` si Chatwoot API esta configurado.
- `credential_flags.whatsapp: false` NO bloquea una respuesta por Chatwoot.
- Si falta un dato comercial, responde con una sola pregunta de intake.
- Si falta Chatwoot API y tampoco hay WhatsApp utilizable, no inventes: crea `needs_config` y deja el borrador exacto.

## Endpoints autorizados

### Chatwoot API

Base:

```text
{CHATWOOT_API_URL}/api/v1/accounts/{CHATWOOT_ACCOUNT_ID}
```

Leer conversacion completa:

```text
GET {CHATWOOT_API_URL}/api/v1/accounts/{CHATWOOT_ACCOUNT_ID}/conversations/{conversation_id}
```

Leer mensajes de una conversacion:

```text
GET {CHATWOOT_API_URL}/api/v1/accounts/{CHATWOOT_ACCOUNT_ID}/conversations/{conversation_id}/messages
```

Responder dentro de una conversacion:

```text
POST {CHATWOOT_API_URL}/api/v1/accounts/{CHATWOOT_ACCOUNT_ID}/conversations/{conversation_id}/messages
```

Headers:

```text
api_access_token: {CHATWOOT_API_TOKEN}
Content-Type: application/json
```

Cuerpo recomendado para responder:

```json
{
  "content": "mensaje visible para el prospecto",
  "message_type": "outgoing",
  "private": false
}
```

Uso obligatorio en inbound:

- Antes de responder, intenta leer mensajes recientes por `conversation_id`.
- Usa mensajes entrantes para reconstruir datos capturados.
- Usa mensajes salientes propios para saber que pregunta hizo Hannia.
- No clasifiques mensajes salientes propios como nuevo interes del prospecto.

Operaciones permitidas:

- Leer conversacion.
- Leer mensajes.
- Crear nota privada.
- Crear mensaje saliente solo si el modo y flags lo permiten.
- Aplicar labels operativos.
- Actualizar custom attributes solo si el ticket lo pide explicitamente.

No uses Chatwoot para mandar email comercial. El email comercial va por SMTP directo.

### WhatsApp Cloud API

Endpoint unico:

```text
POST https://graph.facebook.com/{WHATSAPP_GRAPH_VERSION}/{WHATSAPP_PHONE_NUMBER_ID}/messages
```

Si `WHATSAPP_GRAPH_VERSION` no existe, usa `v19.0`.

Headers:

```text
Authorization: Bearer {WHATSAPP_CLOUD_API_TOKEN}
Content-Type: application/json
```

Templates aprobados actuales:

```yaml
humanio_diagnostico_v1:
  uso: msg1 outbound
  body:
    "1": nombre_contacto
    "2": nombre_negocio
    "3": hallazgo
    "4": oportunidad
humanio_seguimiento_1:
  uso: msg2 dia 3
  body:
    "1": nombre_contacto
    "2": empresa
    "3": objetivo
humanio_seguimiento_2:
  uso: msg3 dia 7
  body:
    "1": nombre_contacto
    "2": empresa
```

No inventes templates. Si se necesita uno nuevo, crea `needs_template_approval`.

## Contratos de entrada

### inbound_chatwoot_event

```yaml
event_type: inbound_chatwoot_event
source: chatwoot
conversation_id:
message_id:
inbox_id:
sender_phone:
sender_name:
content:
attachments:
created_at:
content_hash:
conversation_manager_mode:
humanio_enable_outbound_send:
humanio_enable_inbound_send:
credential_flags:
```

### outbound_contact_request

```yaml
event_type: outbound_contact_request
source: outreach|closer|ceo
prospect_id:
slug:
nombre_negocio:
nombre_contacto:
telefono:
email:
giro:
ciudad:
hallazgo:
oportunidad:
package_recommendation:
contact_override:
```

Contrato de cierre:

- Este evento NO significa que el prospecto ya fue contactado.
- Quien lo procese debe intentar el canal disponible y devolver evidencia real.
- Solo despues de `provider_message_id` real se puede crear Closer.
- Si no hay evidencia, el resultado debe ser `blocked` o `needs_config`, nunca `ready_for_closer_followup`.

Evidencia minima para crear Closer:

```yaml
msg1:
  whatsapp_status: accepted_by_meta
  whatsapp_id: "wamid..."
  delivery_status: pending_webhook
```

o:

```yaml
msg1:
  email_status: sent
  email_id: "<messageId>"
```

### followup_due

```yaml
event_type: followup_due
source: ceo|closer|scheduler|n8n
prospect_id:
slug:
followup_step: msg2|msg3
last_provider_message_id:
last_contact_at:
```

### demo_delivery_request

```yaml
event_type: demo_delivery_request
source: closer|webpublisher|ceo
prospect_id:
slug:
nombre_negocio:
telefono:
email:
url_principal:
url_propuesta:
url_reporte:
conversation_id:
whatsapp_24h_window_open: true|false|unknown
```

## Contratos de salida

### event_to_ceo

```yaml
event_type: demo_request|human_needed|needs_config
source: conversationmanager
priority: urgent|normal|low
conversation_id:
prospect_id:
nombre_negocio:
resumen:
datos_faltantes:
instruccion_sugerida:
```

### event_to_closer

```yaml
event_type: outbound_contact_sent|inbound_response|followup_due|demo_delivery_result
source: conversationmanager
prospect_id:
slug:
waiting_state:
unblock_events:
channel_status:
provider_message_id:
next_step:
```

## Registro en Supabase

Tabla esperada: `outreach_log`.

Campos recomendados:

```yaml
prospect_id:
slug:
canal: whatsapp|email|chatwoot
tipo: msg1|msg2|msg3|inbound_response|demo_sent|demo_delivered|note
status: sent|failed|skipped|blocked
provider_message_id:
conversation_id:
error_detail:
metadata:
created_at:
```

Nota importante: si Meta acepta WhatsApp, guarda `status: sent` por compatibilidad de esquema y explica en `error_detail` o `metadata` que la semantica real es `accepted_by_meta`.

## Deduplicacion

Antes de enviar o crear tickets, revisa:

- `message_id`
- `conversation_id`
- `provider_message_id`
- `prospect_id`
- `slug`
- eventos recientes en `outreach_log`

Si parece duplicado:

```yaml
action_taken: duplicate_suppressed
external_messages_sent: false
next_step: "no enviar; dejar nota privada"
```

## Fallos seguros

Usa estos estados:

```yaml
needs_config: faltan variables o permisos del canal requerido
needs_template_approval: falta template aprobado por Meta
needs_human: excepcion comercial o riesgo
provider_failed: proveedor rechazo o API fallo
duplicate_suppressed: ya se proceso el mismo evento
draft_only: modo shadow o envio deshabilitado
intake_question_sent: se respondio con la siguiente pregunta de intake
```

Nunca reintentes a ciegas si el error puede duplicar un mensaje al prospecto.
