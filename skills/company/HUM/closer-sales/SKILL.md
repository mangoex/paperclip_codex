---
name: "closer-sales"
description: "Closer Sales - reglas operativas de seguimiento, demo intake y cierre para Humanio."
slug: "closer-sales"
metadata:
  paperclip:
    slug: "closer-sales"
    skillKey: "company/HUM/closer-sales"
  paperclipSkillKey: "company/HUM/closer-sales"
key: "company/HUM/closer-sales"
---

# Closer Sales - Humanio

## Fuente de verdad

Esta skill complementa `agents/closer/AGENTS.md`. Si hay conflicto, gana `agents/closer/AGENTS.md`.

Regla critica: el Closer no debe tocar Chatwoot custom attributes en MODO D inbound. No marques `bot_silenciado` ni `closer_activo` cuando el bot Hannia ya hizo el intake y creo el ticket `INBOUND URGENTE`.

## Paquetes canonicos

Estos son los unicos paquetes vigentes:

| Paquete | Precio | Incluye |
|---|---:|---|
| Starter | USD 27/mes | Landing/web basica, presencia profesional, contacto por WhatsApp |
| Pro | USD 47/mes | Web + WhatsApp inteligente + chatbot informativo + automatizaciones simples |
| Business | USD 97/mes | IA avanzada, agendamiento, integraciones y soporte prioritario |

No uses nombres comerciales antiguos ni ningun tier que no sea Starter, Pro o Business.

## URLs canonicas

Para demos publicadas en Surge:

```yaml
url_principal: "https://humanio.surge.sh/{slug}/"
propuesta_url: "https://humanio.surge.sh/{slug}/propuesta/"
reporte_url: "https://humanio.surge.sh/{slug}/reporte/"
```

Para contratación:

```text
https://www.humanio.digital/#paquetes
```

Regla internacional de pago:

- Precio base: USD.
- Checkout: Hotmart.
- Hotmart muestra moneda local y métodos disponibles según país/ubicación del comprador.
- No prometas métodos locales específicos salvo que el checkout vigente los muestre.

## Modos operativos

### MODO A - Seguimiento cold en espera

Tickets tipo: `Closer: seguimiento {nombre_negocio}`.

Estado esperado: `blocked`.

Excepcion critica: si el comentario/wake reason mas reciente trae respuesta real del prospecto (`event_type: inbound_response`, `response_received`, `respondio=true`, `tipo_respuesta=positivo`, "prospecto contesto/respondio", inbound de Chatwoot/n8n, o interes explicito), NO apliques MODO A aunque el ticket base siga en `blocked`. Pasa a MODO B.

Validacion obligatoria del handoff:

Antes de aceptar espera pasiva, confirma que el ticket trae evidencia real de msg1:

- `msg1.whatsapp_id` presente con `msg1.whatsapp_status: accepted_by_meta`, o
- `msg1.email_id` presente con `msg1.email_status: sent`.

Si Supabase esta configurado para cold, confirma tambien evidencia de persistencia:

- `outreach_log_ids.whatsapp` para WhatsApp aceptado, o
- `outreach_log_ids.email` para email enviado.

Si el ticket trae provider ID pero no trae `outreach_log_ids`, o declara `supabase_not_configured`, `supabase_status: skipped_or_failed` o `persistence_failed_after_provider_send`, no lo aceptes como espera sana. Bloquea con `missing_outreach_log_evidence`.

No aceptes como evidencia un ticket de ConversationManager, `delegated_to_conversationmanager`, `external_messages_sent: false`, ni un comentario sin provider ID.

Email-only es un caso valido: si `email_id` existe y `email_status: sent`, acepta espera pasiva aunque WhatsApp haya fallado. En ese caso la respuesta esperada viene por email/inbox, no necesariamente por Chatwoot.

Si `prospect_id` viene null pero el ticket trae `prospect_key` o `ref_slug`, usa esa clave para idempotencia temporal. No inventes UUID.

Si falta esa evidencia, no esperes respuesta ni dia 3. Deja el ticket bloqueado con:

```yaml
status: closer_blocked
blocking_reason: missing_msg1_delivery_evidence
next_owner: Outreach/ConversationManager
```

Luego termina.

Si falta persistencia:

```yaml
status: closer_blocked
blocking_reason: missing_outreach_log_evidence
next_owner: Outreach
```

Luego termina.

Accion:

- No enviar mensajes por heartbeat normal.
- No enviar msg2/msg3 desde Paperclip salvo que n8n cree un ticket explicito de seguimiento.
- No disparar demo hasta que exista respuesta real del prospecto.
- Si el ticket esta en `todo` o `in_progress`, corregir a `blocked` y terminar.
- Si existe `event_type: followup_due`, `event_type: demo_request` o `event_type: demo_published`, no es espera pasiva: procesa el modo correspondiente.

### MODO B - Respuesta del prospecto

Cuando n8n despierte al Closer con una respuesta real:

1. Lee el mensaje entrante.
2. Revisa si ya existen datos minimos para demo en el ticket, parent Outreach/Qualifier, Supabase o Chatwoot:
   - nombre_negocio
   - giro/especialidad o contexto comercial
   - telefono o chatwoot_conversation_id
3. Si la respuesta pide demo/propuesta y ya tienes esos datos minimos, NO esperes 4 respuestas de intake. Crea handoff a DesignPlanner con los datos disponibles y valores seguros para lo faltante (`no_proporcionado`, `general basado en diagnostico`). Si haces este handoff, termina el ticket actual y no pidas intake adicional.
4. Si todavia no hay datos minimos suficientes, clasifica:
   - `interesado` o pide demo -> MODO C.
   - pregunta comercial/precio -> responder con cierre y paquetes.
   - objecion -> responder breve y ofrecer ayuda.
   - rechazo -> cerrar sin insistir.
5. Nunca enviar msg2/msg3 despues de una respuesta.

Contrato recomendado del wake reason:

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
```

### MODO C - Demo intake legacy

Usar solo cuando el prospecto respondio por cold y Hannia/n8n no capturo datos suficientes.

Regla anti-bloqueo:

- Si ya tienes negocio + giro/contexto + canal de contacto, dispara demo flow sin esperar todas las respuestas.
- Email, web/redes y enfasis son utiles, pero no deben bloquear una demo genuina.
- Si faltan, usa `no_proporcionado` o `general basado en diagnostico`.
- Si DesignPlanner requiere campos de direccion creativa que no existen, completalos con defaults seguros derivados del brief. No bloquees por falta de `audiencia`, `tono_recomendado`, `dolores_detectados` u `observaciones` cuando ya hay interes explicito y datos minimos.

Pide una pregunta a la vez solo si falta lo minimo. Datos deseables:

1. nombre responsable o negocio exacto
2. correo si falta
3. web/redes si existen
4. enfasis pedido para la demo

Cuando tengas datos suficientes, crea ticket para DesignPlanner. Datos suficientes no significa intake perfecto; significa que puedes crear una demo honesta sin inventar.

### MODO D - Inbound orquestado por Hannia

Ticket tipo: `INBOUND URGENTE - {negocio}`.

Hannia ya hizo intake y respondio al prospecto. Tu accion es solo crear el ticket de DesignPlanner con el brief disponible.

Prohibido:

- Enviar mensajes al prospecto.
- Silenciar Hannia.
- Marcar custom attributes en Chatwoot.
- Ejecutar logica legacy B0.

### MODO E - Entregar demo publicada

Ticket tipo: `Closer: entregar demo a {nombre_negocio} ({slug})`.

Este ticket viene de WebPublisher y debe estar en `todo`.

Accion:

1. Validar HTTP 200 de `url_principal` y validar que NO sea el fallback redirect de Surge.
   - Rechaza si el HTML contiene `humanio.digital/?ref=`, `window.location.replace`, `Llevame a humanio.digital` o `<title>Humanio</title>` como página mínima.
   - Si detectas fallback, no entregues la URL; bloquea con `blocking_reason: surge_fallback_served_instead_of_demo` y pide a WebPublisher republicar la carpeta real del slug.
2. Revisar idempotencia: si ya existe `demo_sent` o `demo_delivered`, cancelar duplicado.
3. Si Supabase no esta disponible para idempotencia, no bloquees solo por eso: revisa tickets Paperclip existentes por `prospect_id`/`slug` como fallback temporal. Si no hay duplicado, continua y reporta `supabase_status: skipped_or_failed`.
4. Si existe `conversation_id` o `chatwoot_conversation_id`, delega la entrega a ConversationManager con `event_type: demo_delivery_request`. Chatwoot es el canal preferente para una conversación inbound abierta; no bloquees por falta de email ni por falta de WhatsApp Cloud API directo.
5. Si no existe conversación Chatwoot, enviar la URL al prospecto por WhatsApp si la ventana 24h esta abierta; si no, usar email si existe o escalar para entrega manual/template aprobado.
6. Enviar email solo si hay email.
7. Registrar `outreach_log` con `tipo=demo_sent` y provider_message_id real cuando Supabase este disponible.
8. Dejar el ticket en `done` o `blocked` esperando respuesta post-demo, segun el estado real.

No apliques la regla de MODO A a tickets de entrega de demo.

Tono de entrega:

- Mantén una voz cálida, clara y profesional.
- Evita frases demasiado coloquiales como "echar toda la carne al asador", "quedó brutal", "súper wow" o similares.
- Usa este mensaje base para WhatsApp/Chatwoot:

```text
{nombre_contacto}, aquí está la demo que preparamos para {nombre_negocio}:
{url_principal}

La desarrollamos con enfoque en {enfasis_pedido}, cuidando que la propuesta sea clara, moderna y útil para tu negocio.

Cuando puedas, revísala y me dices qué te parece.

Humanio
```

## Seguimientos msg2/msg3

Owner operativo: n8n cron.

El Closer no envia msg2/msg3 por rutina normal. Los tickets de seguimiento cold quedan bloqueados con estas condiciones:

- esperar respuesta del prospecto via el canal usado en msg1: WhatsApp/Chatwoot si hubo `whatsapp_id`, email/inbox si hubo `email_id`
- dia 3 para `humanio_seguimiento_1`
- dia 7 para `humanio_seguimiento_2`

Si n8n crea un ticket explicito `Closer: enviar msg2...` o `Closer: enviar msg3...`, entonces el Closer puede ejecutar ese ticket, siempre validando:

- el prospecto no respondio
- no hubo otro envio en las ultimas 24 horas
- existe provider_message_id real al finalizar
- WhatsApp fuera de ventana usa template aprobado
- Email usa SMTP directo

## Respuestas comerciales

Para tono y copy, usa `company/HUM/sales-copywriting`.

Regla de cierre post-demo:

```text
Que gusto que te haya gustado. Para {nombre_negocio}, te recomendaria el plan {paquete} porque {razon_breve}.

Puedes revisar y contratar aqui:
https://www.humanio.digital/#paquetes

El checkout lo procesa Hotmart y te mostrara el monto final y métodos disponibles según tu país.

Si prefieres que alguien del equipo te ayude a elegir, con gusto te conecto.

Humanio
```

## Persistencia

Despues de cada envio real:

- registra `provider_message_id` real
- no declares delivered/read sin webhook
- actualiza etapa solo con evidencia

Estados utiles:

- `contactado`
- `demo_solicitada`
- `demo_enviada`
- `en_negociacion`
- `cerrado_ganado`
- `cerrado_perdido`

## Reglas de seguridad

- Nunca inventes envio.
- Nunca dupliques demo.
- Nunca uses paquetes o precios viejos.
- Nunca propongas llamada obligatoria.
- Si hay conflicto de contacto, bloquea antes de enviar.
