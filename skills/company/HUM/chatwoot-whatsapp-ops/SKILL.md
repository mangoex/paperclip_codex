---
name: chatwoot-whatsapp-ops
description: Procedimientos operativos y contratos de API para Chatwoot, WhatsApp Cloud API, Supabase y Paperclip en Humanio.
---

# Chatwoot y WhatsApp Ops - Humanio

Usa esta skill para operar o preparar acciones entre Chatwoot, WhatsApp Cloud API, Supabase y Paperclip.

No contiene secretos. Todos los tokens, URLs e IDs deben venir de variables de entorno configuradas en Paperclip.

## Variables requeridas para modo activo

### Chatwoot

```yaml
CHATWOOT_API_URL: "https://n8n-humanio-chatwoot.yroec7.easypanel.host"
CHATWOOT_API_TOKEN: "y4ztDTQEjKu9dUsWpHSFaH8C"
CHATWOOT_ACCOUNT_ID: "1"
CHATWOOT_WHATSAPP_INBOX_ID: "3"
CHATWOOT_INBOX_ID: "2"
```

### WhatsApp Cloud API

```yaml
WHATSAPP_PHONE_NUMBER_ID: "1039498685919677"
WHATSAPP_CLOUD_API_TOKEN: "EAF7Id5FLnOcBRHhHYi8b29PjaoXVhcNolPiFYA15oPrZBjKOTJFLzyZAPYVhBir7zMRjBKA0XFO9AaWCZBhCPbPnx4q3oaoC9cMZCEZAfpJvAfH5OFRppyufduRLxVBNHvnrL6TBv6U45FxzxoJ8vOQHYwuyT0S2Uzd1BnZBujaS8CUUCt1AU9zEn0dwt5FQZDZD"
WHATSAPP_GRAPH_VERSION: "v19.0 por defecto"
```

### Paperclip

```yaml
PAPERCLIP_API_URL: "https://paperclip-paperclip-app.yroec7.easypanel.host/"
PAPERCLIP_API_TOKEN: "pcp_0513450378c5e144467f50e5dcdc318b7ff3f47ea309e37f"
COMPANY_ID: "HUMAAAAAAAAAAAAA"
CEO_AGENT_ID: "75773041-c013-4c9b-9dac-4f85908ae47c"
CLOSER_AGENT_ID: "21092e14-eb98-4c26-a5b1-9050bd22db85"
OUTREACH_AGENT_ID: "6e269f8d-513a-4097-9240-5c11aeea2408"
CONVERSATION_MANAGER_AGENT_ID: "05685665-23c0-4a20-a09a-3be97740c02d"
```

### Supabase

```yaml
SUPABASE_URL: "https://nloytkdjbhoozjrhrpxq.supabase.co"
SUPABASE_SERVICE_KEY: "sb_secret_Zn5j6LE1MqUuyfL68HbGew__USpQm6f"
```

### SMTP opcional

```yaml
SMTP_HOST:smtpout.secureserver.net
SMTP_PORT:465
SMTP_USER:contacto@humanio.digital
SMTP_PASS:531698Pa+
FROM_EMAIL:contacto@humanio.digital
FROM_NAME:Humanio-Hannia
```

### Flags de seguridad

```yaml
CONVERSATION_MANAGER_MODE: "shadow|active"
HUMANIO_ENABLE_OUTBOUND_SEND: "false"
HUMANIO_ENABLE_INBOUND_SEND: "false"
HUMANIO_ALLOWED_ADMIN_PHONES: "lista separada por comas"
```

## Endpoints autorizados

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

### Chatwoot API

Base:

```text
{CHATWOOT_API_URL}/api/v1/accounts/{CHATWOOT_ACCOUNT_ID}
```

Operaciones permitidas:

- Leer conversacion.
- Crear nota privada.
- Crear mensaje saliente solo si el modo y flags lo permiten.
- Aplicar labels operativos.
- Actualizar custom attributes solo si el ticket lo pide explicitamente.

No uses Chatwoot para mandar email comercial. El email comercial va por SMTP directo.

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
needs_config: faltan variables o permisos
needs_template_approval: falta template aprobado por Meta
needs_human: excepcion comercial o riesgo
provider_failed: proveedor rechazo o API fallo
duplicate_suppressed: ya se proceso el mismo evento
draft_only: modo shadow o envio deshabilitado
```

Nunca reintentes a ciegas si el error puede duplicar un mensaje al prospecto.
