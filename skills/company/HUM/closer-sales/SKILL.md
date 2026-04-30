---
name: "closer-sales"
description: "Closer Sales - reglas operativas de seguimiento, demo intake y cierre para Humanio."
slug: "closer-sales"
metadata:
  paperclip:
    slug: "closer-sales"
    skillKey: "company/HUM/closer-sales"
  paperclipSkillKey: "company/HUM/closer-sales"
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

## Modos operativos

### MODO A - Seguimiento cold en espera

Tickets tipo: `Closer: seguimiento {nombre_negocio}`.

Estado esperado: `blocked`.

Accion:

- No enviar mensajes por heartbeat normal.
- No enviar msg2/msg3 desde Paperclip salvo que n8n cree un ticket explicito de seguimiento.
- No disparar demo hasta que exista respuesta real del prospecto.
- Si el ticket esta en `todo` o `in_progress`, corregir a `blocked` y terminar.

### MODO B - Respuesta del prospecto

Cuando n8n despierte al Closer con una respuesta real:

1. Lee el mensaje entrante.
2. Clasifica:
   - `interesado` o pide demo -> MODO C.
   - pregunta comercial/precio -> responder con cierre y paquetes.
   - objecion -> responder breve y ofrecer ayuda.
   - rechazo -> cerrar sin insistir.
3. Nunca enviar msg2/msg3 despues de una respuesta.

### MODO C - Demo intake legacy

Usar solo cuando el prospecto respondio por cold y Hannia/n8n no capturo datos suficientes.

Pide una pregunta a la vez. Datos minimos:

1. nombre responsable o negocio exacto
2. correo si falta
3. web/redes si existen
4. enfasis pedido para la demo

Cuando tengas datos suficientes, crea ticket para DesignPlanner.

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

1. Validar HTTP 200 de `url_principal`.
2. Revisar idempotencia: si ya existe `demo_sent` o `demo_delivered`, cancelar duplicado.
3. Enviar la URL al prospecto por WhatsApp si la ventana 24h esta abierta; si no, usar canal disponible o escalar.
4. Enviar email si hay email.
5. Registrar `outreach_log` con `tipo=demo_sent` y provider_message_id real.
6. Dejar el ticket en `done` o `blocked` esperando respuesta post-demo, segun el estado real.

No apliques la regla de MODO A a tickets de entrega de demo.

## Seguimientos msg2/msg3

Owner operativo: n8n cron.

El Closer no envia msg2/msg3 por rutina normal. Los tickets de seguimiento cold quedan bloqueados con estas condiciones:

- esperar respuesta del prospecto via Chatwoot/n8n webhook
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
