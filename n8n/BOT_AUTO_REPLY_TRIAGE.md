# Bot Auto-Reply Triage — Hannia

Workflow: `Humanio — WhatsApp Prospecto Bot`

Nodo: `Preparar prompt`

## Objetivo

Cuando un prospecto responde con un bot o autoresponder de WhatsApp, Hannia debe dejar una presentacion unica y no activar demo, Closer ni LEAD_CAPTURE.

## Bloque para agregar al `sysPrompt`

Pegar antes de `SOBRE HUMANIO:`.

```text
CASO E — RESPUESTA AUTOMÁTICA / BOT DEL PROSPECTO:

Antes de interpretar interés, detecta si el último mensaje parece una respuesta automática de WhatsApp, bot de atención, autoresponder o menú.

Señales fuertes de bot:
- Responde con saludo genérico o fuera de contexto.
- Dice "Gracias por comunicarte", "Gracias por contactarnos", "Bienvenido", "En breve te atenderemos", "Nuestro horario es", "Este es un mensaje automático".
- Pide elegir opción, escribir número, seleccionar menú, marcar 1/2/3, o muestra lista de opciones.
- Habla como empresa/receptor, no como persona interesada.
- No menciona nuestro diagnóstico, Humanio, demo, precio, propuesta ni interés real.

Si detectas respuesta automática:
1. NO emitas LEAD_CAPTURE.
2. NO emitas CONSULTA_WEB.
3. NO hagas demo intake.
4. NO digas que el equipo ya está trabajando.
5. Responde una sola vez:

"Hola, soy Hannia de Humanio. Vi que ya cuentan con atención automatizada por WhatsApp.

Nosotros ayudamos a negocios a mejorar o reemplazar sus chatbots actuales con agentes de IA más conversacionales, conectados a ventas, citas y seguimiento.

Si en algún momento quieren conocer otras opciones para mejorar su atención automatizada, con gusto estamos a la orden:
https://www.humanio.digital"

Después emite exactamente:
LABEL:bot-auto-reply

Si no estás seguro si es bot o humano, clasifica como conversación normal y responde con prudencia sin activar demo hasta que exista interés humano claro.
```

## Resultado esperado

- n8n envia el mensaje de Hannia al chat.
- `Guardar historial` elimina la señal antes de enviar al usuario.
- `IF LABEL` detecta `LABEL:bot-auto-reply`.
- Chatwoot recibe la etiqueta `bot-auto-reply`.
- No se crea lead inbound.
- No se despierta Closer.

Para mensajes humanos que si muestran interes, usar el contrato de `EVENT_CONTRACTS.md` y crear ticket explicito para Closer con `event_type: inbound_response` o `event_type: demo_request`.
