# Humanio n8n -> Paperclip Event Contracts

Estos contratos evitan que el Closer quede atrapado en tickets `blocked` cuando si hay trabajo real.

## Regla general

n8n no debe solo "despertar" un ticket bloqueado. Cuando exista un evento nuevo, debe crear un ticket explicito con status `todo`, cuerpo YAML y `event_type`.

## Respuesta entrante

Titulo:

```text
Closer: respuesta entrante de {nombre_negocio}
```

Cuerpo:

```yaml
event_type: inbound_response
source: n8n
prospect_id: "{id}"
nombre_negocio: "{nombre}"
chatwoot_conversation_id: "{id}"
message_text: "{texto_real_del_prospecto}"
respondio: true
tipo_respuesta: "{positivo|objecion|no_interesado|pregunta|otro}"
contact_window_open_until: "{ISO_o_unknown}"
parent_followup_ticket: "{ticket_Closer_seguimiento_o_null}"
```

## Lead capture / demo solicitada por Hannia

Titulo:

```text
INBOUND URGENTE - {nombre_negocio}
```

Cuerpo:

```yaml
event_type: demo_request
source: hannia_n8n
lead_capture: true
prospect_id: "{id_o_chatwoot_conversation_id}"
chatwoot_conversation_id: "{id}"
negocio: "{nombre_negocio}"
giro: "{giro}"
telefono: "{telefono}"
correo: "{correo_o_no_proporcionado}"
redes: "{redes_o_no_proporcionado}"
web_actual: "{web_o_no_proporcionado}"
ciudad: "{ciudad_o_unknown}"
pais: "{pais_o_unknown}"
enfasis_pedido: "{texto_o_general}"
```

## Seguimiento vencido

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
followup_type: "{msg2|msg3}"
due_at: "{ISO}"
telefono: "{telefono_o_null}"
email: "{email_o_null}"
chatwoot_conversation_id: "{id_o_null}"
no_response_evidence:
  checked_chatwoot_until: "{ISO}"
  checked_outreach_log_until: "{ISO}"
  last_inbound_at: null
```

## Demo publicada

Este evento normalmente lo crea WebPublisher, no n8n, pero n8n puede usar el mismo contrato si actua como puente.

```yaml
event_type: demo_published
source: webpublisher
prospect_id: "{id}"
nombre_negocio: "{nombre}"
slug: "{slug}"
url_principal: "https://humanio.surge.sh/{slug}/"
url_propuesta: "https://humanio.surge.sh/{slug}/propuesta/"
url_reporte: "https://humanio.surge.sh/{slug}/reporte/"
http_checks:
  principal: 200
  propuesta: 200
  reporte: 200
```
