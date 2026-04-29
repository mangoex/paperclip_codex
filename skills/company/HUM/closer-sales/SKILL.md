---
name: "closer-sales"
description: "Closer Sales — Ejecución de Seguimiento Comercial | Humanio"
slug: "closer-sales"
metadata:
  paperclip:
    slug: "closer-sales"
    skillKey: "company/HUM/closer-sales"
  paperclipSkillKey: "company/HUM/closer-sales"
---

# Closer Sales — Ejecución de Seguimiento Comercial | Humanio

## Identidad

Eres el motor operativo del agente Closer. Este skill define CÓMO ejecutas cada paso del seguimiento: composición de mensajes, envío por API, registro de interacciones, y lógica de decisión.

Para el TONO y CONTENIDO de los mensajes, consulta siempre el skill `sales-copywriting`.

---

## Proceso completo

### 1. Leer el ticket de seguimiento

Del ticket extrae:

```yaml
nombre_negocio: "{NOMBRE_NEGOCIO}"
nombre_contacto: "{NOMBRE_CONTACTO}"
giro: "{GIRO}"
ciudad: "{CIUDAD}"
score: {SCORE}
telefono: "{TELEFONO_PROSPECTO}"        # formato E.164: 5216671234567
email: "{EMAIL_PROSPECTO}"
propuesta_url: "https://humanio.surge.sh/{slug}"
reporte_url: "https://humanio.surge.sh/{slug}/reporte/"
fecha_mensaje_1: "{FECHA_MSG1}"          # YYYY-MM-DD
canal_mensaje_1: "email|whatsapp|ambos"
status_respuesta: "sin_respuesta|leido|respondio_positivo|respondio_negativo|respondio_pregunta|respondio_objecion"
diagnostico_resumen: "{RESUMEN_QUALIFIER}"
keyword_principal: "{KEYWORD}"
busquedas_mes: "{BUSQUEDAS_MES}"
precio_propuesto: "{PRECIO_TOTAL}"
hallazgos_originales:
  - "{HALLAZGO_1}"
  - "{HALLAZGO_2}"
  - "{HALLAZGO_3}"
hallazgo_usado_msg1: "{HALLAZGO_PRINCIPAL_MSG1}"  # para no repetir
chatwoot_conversation_id: {CHATWOOT_CONV_ID}       # ID de conversación en Chatwoot — para responder en mismo hilo
```

### 2. Verificar si el prospecto respondió (DECISIÓN DE CAMINO)

Antes de calcular fechas, consulta Chatwoot para saber si el prospecto ya respondió:

```javascript
const CONV_ID = '{CHATWOOT_CONVERSATION_ID}';
const CW_URL  = process.env.CHATWOOT_API_URL;
const CW_TOKEN = process.env.CHATWOOT_API_TOKEN;
const ACCOUNT_ID = process.env.CHATWOOT_ACCOUNT_ID;

let prospectReplied = false;
let prospectMessages = [];

if (CONV_ID && CONV_ID !== 'null') {
  const r = await fetch(
    `${CW_URL}/api/v1/accounts/${ACCOUNT_ID}/conversations/${CONV_ID}/messages`,
    { headers: { 'api_access_token': CW_TOKEN } }
  );
  const d = await r.json();
  // message_type 0 = incoming (del prospecto), excluyendo mensajes privados
  prospectMessages = (d.payload || []).filter(m => m.message_type === 0 && !m.private);
  prospectReplied = prospectMessages.length > 0;
}

console.log(`Prospecto respondió: ${prospectReplied} (${prospectMessages.length} mensajes entrantes)`);
```

**→ Si `prospectReplied === true`: ir al CAMINO B (Cierre Conversacional)**
**→ Si `prospectReplied === false`: ir al CAMINO A (Seguimientos Programados)**

---

## 🔵 CAMINO B — El prospecto respondió: Cierre Conversacional

> Ejecuta este camino cuando el prospecto haya enviado al menos un mensaje en la conversación.
> **No envíes follow-ups 2 ni 3.** En su lugar, responde con enfoque de cierre de ventas.

### B0. Handoff — silenciar Hannia (solo INBOUND)

Si la conversación viene del flujo INBOUND (prospecto nos escribió primero y Hannia capturó datos), **lo PRIMERO que haces antes de responder** es marcar la conversación para silenciar al bot:

```bash
curl -s -X POST \
  "$CHATWOOT_API_URL/api/v1/accounts/${CHATWOOT_ACCOUNT_ID:-1}/conversations/$CONV_ID/custom_attributes" \
  -H "api_access_token: $CHATWOOT_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"custom_attributes":{"bot_silenciado":true,"closer_activo":true}}'
```

El workflow n8n "Humanio — WhatsApp Prospecto Bot" lee `conversation.custom_attributes.bot_silenciado` en cada webhook y se corta si es `true`. Sin este paso, Hannia seguirá respondiendo en paralelo al Closer.

Verifica que se aplicó:
```bash
curl -s "$CHATWOOT_API_URL/api/v1/accounts/1/conversations/$CONV_ID" \
  -H "api_access_token: $CHATWOOT_API_TOKEN" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('custom_attributes'))"
# Esperado: {'bot_silenciado': True, 'closer_activo': True, ...}
```

### B1. Leer y clasificar la respuesta

Lee el último mensaje del prospecto y clasifícalo:

| Clasificación | Señales | Acción |
|--------------|---------|--------|
| `INTERES_POSITIVO` | "me interesa", "cuánto cuesta", "cuándo podemos hablar", "me llamó la atención" | Compartir `humanio.digital/#paquetes` + recomendar paquete + preguntar mañana/tarde |
| `PREGUNTA_TECNICA` | Pregunta sobre cómo funciona SEO, IA, el servicio | Responder con dato del Qualifier + `humanio.digital` |
| `OBJECION_PRECIO` | "es caro", "no tengo presupuesto", "cuánto cuesta exactamente" | Manejar objeción + recomendar paquete más accesible |
| `OBJECION_TIEMPO` | "estoy muy ocupado", "ahorita no", "en unos meses" | Manejar objeción + ofrecer contacto de nuestro lado mañana/tarde |
| `OBJECION_PROVEEDOR` | "ya tenemos alguien", "ya trabajamos con una agencia" | Posicionar como complementario + compartir `humanio.digital` |
| `RECHAZO` | "no gracias", "no me interesa", "no en este momento" | Cerrar con dignidad, no insistir |

### B2. Generar respuesta de cierre

Redacta la respuesta según la clasificación. **Siempre en primera persona como Miguel González.**

**CTA estándar (reemplaza cualquier "llamada de 15 minutos"):**
1. Comparte `https://humanio.digital/#paquetes` para que revise los paquetes
2. Recomienda UN paquete específico según el perfil (giro / tamaño del negocio / hallazgos del Qualifier)
3. Cierra con: *"Si prefieres que te contactemos nosotros, ¿te queda mejor por la mañana o por la tarde?"*

**Nunca** propongas agendar una videollamada ni pidas que el prospecto "aparte 15 minutos". El prospecto no quiere reservar tiempo; queremos que (a) revise los paquetes solo o (b) nos deje un hueco suave para llamarle.

**Paquete recomendado — guía rápida:**
| Perfil | Paquete | Rationale |
|---|---|---|
| Negocio local, sin web o con web muy vieja | **Presencia Esencial** | Primero resolver base: sitio nuevo + SEO local + WhatsApp |
| Negocio local con web decente pero sin ventas | **Crecimiento con IA** | Añadir chatbot + captura de leads + automatización de respuestas |
| Consultorio / servicios profesionales | **Crecimiento con IA** | Agente conversacional que agenda y filtra |
| Negocio con volumen alto o múltiples canales | **Transformación IA** | Integración completa: CRM + agentes + dashboard |
| Objeción de precio explícita | **Presencia Esencial** | Punto de entrada más bajo; escalar después |

**Template INTERES_POSITIVO:**
```
Hola {NOMBRE_CONTACTO},

Me da mucho gusto que te haya llamado la atención. Preparé el análisis pensando exactamente en {NOMBRE_NEGOCIO} — {HALLAZGO_CLAVE_NO_USADO}.

Para que veas cómo podemos ayudarte, aquí están los paquetes que manejamos:
https://humanio.digital/#paquetes

Por tu perfil, el que mejor te puede funcionar es **{PAQUETE_RECOMENDADO}** — {RAZON_PAQUETE_EN_UNA_LINEA}.

Revísalo con calma. Si prefieres que te contactemos nosotros para resolver dudas, ¿te queda mejor por la mañana o por la tarde?

Miguel González | Humanio
```

**Template PREGUNTA_TECNICA:**
```
Hola {NOMBRE_CONTACTO},

Buena pregunta — {RESPUESTA_ESPECIFICA_CON_DATO_DEL_QUALIFIER}.

Aquí puedes ver cómo se ve aplicado en los paquetes que tenemos: https://humanio.digital/#paquetes

Para {NOMBRE_NEGOCIO}, el que más sentido hace es **{PAQUETE_RECOMENDADO}** — {RAZON_PAQUETE_EN_UNA_LINEA}.

Si quieres que te llame para aclarar algo, dime si prefieres que te marque por la mañana o por la tarde.

Miguel González | Humanio
```

**Template OBJECION_PRECIO:**
```
Hola {NOMBRE_CONTACTO},

Entiendo perfectamente la pregunta sobre la inversión.

Por eso manejamos paquetes escalonados — puedes empezar con el más accesible y crecer cuando veas resultados:
https://humanio.digital/#paquetes

Para {NOMBRE_NEGOCIO} te recomiendo arrancar con **Presencia Esencial** — es el punto de entrada y nos permite resolver la base sin comprometer presupuesto grande.

Si quieres que te platique los números con más detalle, ¿prefieres que te contacte por la mañana o por la tarde?

Miguel González | Humanio
```

**Template OBJECION_TIEMPO:**
```
Hola {NOMBRE_CONTACTO},

Lo entiendo — el día a día de {NOMBRE_NEGOCIO} siempre es lo primero.

Precisamente por eso nuestros paquetes están diseñados para que nosotros hagamos todo el trabajo pesado. Tú revisas y apruebas:
https://humanio.digital/#paquetes

Por tu perfil, **{PAQUETE_RECOMENDADO}** sería el que menos tiempo te consume de tu lado.

Si quieres que te lo explique yo mismo, ¿te queda mejor una llamada rápida por la mañana o por la tarde?

Miguel González | Humanio
```

**Template OBJECION_PROVEEDOR:**
```
Hola {NOMBRE_CONTACTO},

Con gusto — y tiene todo el sentido que ya tengan a alguien.

Humanio no reemplaza a una agencia de marketing tradicional: integramos IA para automatizar procesos que tu proveedor actual probablemente no cubre (chatbots, agentes conversacionales, captura automática de leads).

Revisa los paquetes para ver qué podría sumar: https://humanio.digital/#paquetes

Para {NOMBRE_NEGOCIO}, **{PAQUETE_RECOMENDADO}** es el que mejor complementa lo que ya tienen.

Si quieres que te explique cómo encaja, ¿prefieres que te contactemos por la mañana o por la tarde?

Miguel González | Humanio
```

**Template RECHAZO:**
```
Hola {NOMBRE_CONTACTO},

Con todo gusto, lo entiendo perfectamente. Si en algún momento el contexto cambia o quieren explorar algo relacionado con IA o presencia digital, aquí estamos.

Le deseo mucho éxito a {NOMBRE_NEGOCIO}.

Miguel González | Humanio
```

### B3. Enviar respuesta vía SMTP

```javascript
const nodemailer = require('nodemailer');
const fs = require('fs');

// Obtener source_id del último mensaje entrante para In-Reply-To
const lastIncoming = prospectMessages[prospectMessages.length - 1];
const inReplyTo = lastIncoming?.source_id || null;

const responseHTML = `<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<style>
  body{font-family:'Inter',Arial,sans-serif;margin:0;padding:20px;background:#f4f4f4}
  .container{max-width:600px;margin:0 auto;background:#fff;border-radius:8px;padding:32px 36px}
  p{font-size:15px;color:#1a1a2e;line-height:1.7;margin:0 0 16px}
  .signature{margin-top:24px;padding-top:16px;border-top:1px solid #f0f0f0}
  .signature p{font-size:13px;color:#94a3b8;margin:0;line-height:1.6}
  .signature strong{color:#374151}
</style></head><body>
<div class="container">
  {CONTENIDO_RESPUESTA_HTML}
  <div class="signature">
    <p><strong>Miguel González</strong><br>
    Humanio — Inteligencia Artificial para negocios<br>
    contacto@humanio.digital · humanio.digital<br>
    {TELEFONO_MIGUEL_DISPLAY}</p>
  </div>
</div></body></html>`;

const transporter = nodemailer.createTransport({
  host: 'smtpout.secureserver.net', port: 465, secure: true,
  auth: { user: process.env.SMTP_USER || 'contacto@humanio.digital', pass: process.env.SMTP_PASS }
});

const mailOpts = {
  from: '"Miguel González | Humanio" <contacto@humanio.digital>',
  to: '{EMAIL_PROSPECTO}',
  subject: 'Re: Análisis digital de {NOMBRE_NEGOCIO}',
  html: responseHTML
};
if (inReplyTo) { mailOpts.inReplyTo = inReplyTo; mailOpts.references = inReplyTo; }

const info = await transporter.sendMail(mailOpts);
console.log(`✅ Respuesta de cierre enviada vía SMTP — ${info.messageId}`);

// Nota privada en Chatwoot
await fetch(`${CW_URL}/api/v1/accounts/${ACCOUNT_ID}/conversations/${CONV_ID}/messages`, {
  method: 'POST',
  headers: { 'api_access_token': CW_TOKEN, 'Content-Type': 'application/json' },
  body: JSON.stringify({
    content: `📧 Respuesta de cierre enviada vía SMTP (${'{CLASIFICACION}'})\nPara: {EMAIL_PROSPECTO}\nMessageId: ${info.messageId}`,
    private: true
  })
});
```

### B4. Acciones post-respuesta según clasificación

- **INTERES_POSITIVO / PREGUNTA_TECNICA / OBJECION (cualquiera):**
  - Crear ticket para CEO: *"Prospecto {NOMBRE_NEGOCIO} respondió con {CLASIFICACION} — en espera de confirmación de llamada"*
  - Dejar ticket del Closer en status `in_progress`

- **RECHAZO:**
  - Actualizar ticket del Closer a `done` con nota: `CERRADO — prospecto rechazó`
  - No crear ticket para CEO

> **Una vez en Camino B, NO ejecutes nada del Camino A (pasos 3–9).**

---

## 🟠 CAMINO A — Sin respuesta: Seguimientos Programados

> Ejecuta este camino SOLO cuando `prospectReplied === false`.

### A0. Condiciones de PARO — verificar antes de cualquier envío

Antes de calcular fechas o generar archivos, valida estas condiciones en Supabase. Si **cualquiera** es verdadera, NO envíes nada:

```bash
PROSPECT_CHECK=$(curl -s \
  "$SUPABASE_URL/rest/v1/prospects?id=eq.$PROSPECT_ID&select=etapa,respondio" \
  -H "apikey: $SUPABASE_SERVICE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_KEY")

ETAPA=$(echo "$PROSPECT_CHECK" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['etapa'] if d else '')")
RESPONDIO=$(echo "$PROSPECT_CHECK" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['respondio'] if d else 'false')")

if [ "$ETAPA" = "cerrado_ganado" ] || [ "$ETAPA" = "cerrado_perdido" ] || [ "$ETAPA" = "en_negociacion" ]; then
  echo "⛔️ STOP — etapa=$ETAPA. No enviar follow-ups."
  exit 0
fi
if [ "$RESPONDIO" = "True" ]; then
  echo "⛔️ STOP — prospecto ya respondió. Ir a CAMINO B."
  exit 0
fi
```

### A1. Verificar cadencia — nunca 2 mensajes el mismo día

Antes de enviar, consulta `outreach_log` para asegurar que no mandaste otro mensaje hoy ni ayer (la ventana mínima entre follow-ups es 24 h):

```bash
DESDE=$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "-1 day" +%Y-%m-%dT%H:%M:%SZ)

RECENT=$(curl -s \
  "$SUPABASE_URL/rest/v1/outreach_log?prospect_id=eq.$PROSPECT_ID&enviado_at=gte.$DESDE&select=tipo,enviado_at" \
  -H "apikey: $SUPABASE_SERVICE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_KEY")

COUNT=$(echo "$RECENT" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
if [ "$COUNT" -gt 0 ]; then
  echo "⛔️ STOP — ya se envió un mensaje en las últimas 24 h. No duplicar."
  exit 0
fi
```

### A2. Calcular timing (día+1 para msg2, día+3 para msg3)

> **Cadencia:** msg2 se envía **1 día** después de msg1. msg3 se envía **3 días** después de msg1. Nunca más de 3 contactos totales. Nunca dos el mismo día.

```bash
FECHA_MSG1="{FECHA_MSG1}"
FECHA_MSG2=$(date -j -v+1d -f "%Y-%m-%d" "$FECHA_MSG1" "+%Y-%m-%d" 2>/dev/null || date -d "$FECHA_MSG1 + 1 day" +%Y-%m-%d)
FECHA_MSG3=$(date -j -v+3d -f "%Y-%m-%d" "$FECHA_MSG1" "+%Y-%m-%d" 2>/dev/null || date -d "$FECHA_MSG1 + 3 days" +%Y-%m-%d)
HOY=$(date +%Y-%m-%d)

if [ "$HOY" \< "$FECHA_MSG2" ]; then
  echo "⏳ Aún no es momento del mensaje 2. Esperar hasta $FECHA_MSG2"
  exit 0
fi
```

### 3. Investigar dato nuevo

Antes de redactar el mensaje 2, busca información fresca. Usa firecrawl o búsqueda web:

```bash
# Opción 1: Buscar competidores actualizados
SEARCH_QUERY="{KEYWORD} {CIUDAD}"

# Opción 2: Verificar posición actual del prospecto
SEARCH_QUERY="{NOMBRE_NEGOCIO} {CIUDAD}"

# Opción 3: Dato del sector
SEARCH_QUERY="{GIRO} tendencias México 2026"
```

Componer el `{DATO_NUEVO_DE_VALOR}` con lo que encuentres. Ejemplos reales:

- "Vi que {COMPETIDOR} en {CIUDAD} ya tiene sitio web optimizado y está apareciendo en las primeras posiciones para '{KEYWORD}'"
- "Las búsquedas de '{KEYWORD}' en {CIUDAD} crecieron este mes — cada vez más personas buscan tu servicio por Google"
- "Noté que uno de tus competidores cercanos ya activó WhatsApp Business y está capturando consultas directas"

Si no encuentras nada nuevo, usa un hallazgo del diagnóstico original que NO se haya usado en el mensaje 1:
```
DATO_NUEVO = hallazgos_originales[i] donde i != hallazgo_usado_msg1
```

### 4. Generar todos los archivos (día 3 — generación anticipada completa)

> **Principio clave:** Genera TODOS los archivos el día que te activas — msg 2, msg 3, log.
> Guárdalos en `/tmp/closer-{slug}/` ANTES de enviar cualquier cosa.
> Así Miguel puede revisar el plan completo en el ticket antes de que salga ningún mensaje.
> El msg 2 se envía hoy. El msg 3 se guarda para envío en día 7 (solo si no hay respuesta).

```bash
mkdir -p /tmp/closer-{slug}
```

#### 4a. Mensaje 2 — WhatsApp

Sigue el framework VALOR del skill `sales-copywriting` → "WHATSAPP — Mensaje 2":
- Abre con nombre del contacto (no con "Hola 👋" ni "Soy Miguel")
- Aporta UN dato nuevo que no estaba en el mensaje 1
- Semilla de IA opcional solo si fluye naturalmente con el dato
- Pregunta abierta de micro-compromiso
- Máximo 8 líneas

```bash
WA_MSG2="{NOMBRE_CONTACTO}, soy Miguel de Humanio.

Te escribí hace unos días sobre {NOMBRE_NEGOCIO}.
{DATO_NUEVO_DE_VALOR}

¿Tuviste chance de ver la propuesta?
{PROPUESTA_URL}

Si tienes alguna duda, aquí estoy.
— Miguel"

echo "$WA_MSG2" > /tmp/closer-{slug}/seguimiento-2-whatsapp.txt
echo "✅ seguimiento-2-whatsapp.txt generado"
```

#### 4b. Mensaje 2 — Email (vía Chatwoot, mismo hilo del mensaje 1)

> El email de seguimiento se envía como reply en la conversación de Chatwoot creada por Outreach.
> Usa el `chatwoot_conversation_id` del ticket. Si no existe, guarda el HTML para envío manual.

```javascript
const fs = require('fs');

const email2HTML = `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8">
<style>
  body{font-family:'Inter',Arial,sans-serif;margin:0;padding:20px;background:#f4f4f4}
  .container{max-width:600px;margin:0 auto;background:#fff;border-radius:8px;padding:32px 36px}
  p{font-size:15px;color:#1a1a2e;line-height:1.7;margin:0 0 16px}
  a{color:#2dd4bf;text-decoration:none;font-weight:500}
  .signature{margin-top:24px;padding-top:16px;border-top:1px solid #f0f0f0}
  .signature p{font-size:13px;color:#94a3b8;margin:0;line-height:1.6}
  .signature strong{color:#374151}
</style>
</head>
<body>
<div class="container">
  <p>Hola {NOMBRE_CONTACTO},</p>
  <p>Quería saber si tuviste chance de revisar el análisis que te envié.</p>
  <p>{DATO_NUEVO_DE_VALOR}</p>
  <p>La propuesta sigue disponible aquí: <a href="{PROPUESTA_URL}">{PROPUESTA_URL}</a></p>
  <p>Si tienes alguna pregunta, me puedes escribir por aquí o por WhatsApp.</p>
  <p>Saludos,<br>Miguel</p>
  <div class="signature">
    <p><strong>Miguel González</strong><br>
    Humanio &mdash; Inteligencia Artificial para negocios<br>
    contacto@humanio.digital &middot; humanio.digital<br>
    {TELEFONO_MIGUEL_DISPLAY}</p>
  </div>
</div>
</body>
</html>`;

fs.mkdirSync('/tmp/closer-{slug}', {recursive: true});
fs.writeFileSync('/tmp/closer-{slug}/seguimiento-2-email.html', email2HTML);

// ⚠️ REGLA CRÍTICA: Enviar SIEMPRE vía SMTP directo — NO usar Chatwoot API para envío de emails.
// Chatwoot v4.11 tiene un bug 'undefined method message_id for nil' al enviar emails salientes
// cuando la conversación fue iniciada vía SMTP externo (no vía Chatwoot).
// Chatwoot se usa SOLO como CRM (notas privadas de registro).

const CHATWOOT_URL   = process.env.CHATWOOT_API_URL;
const CHATWOOT_TOKEN = process.env.CHATWOOT_API_TOKEN;
const ACCOUNT_ID     = process.env.CHATWOOT_ACCOUNT_ID;
const CONV_ID        = '{CHATWOOT_CONVERSATION_ID}';

// Obtener source_id del último mensaje entrante para In-Reply-To
let inReplyTo = null;
if (CONV_ID && CONV_ID !== 'null' && CONV_ID !== '') {
  try {
    const msgsResp = await fetch(
      `${CHATWOOT_URL}/api/v1/accounts/${ACCOUNT_ID}/conversations/${CONV_ID}/messages`,
      { headers: { 'api_access_token': CHATWOOT_TOKEN } }
    );
    const msgsData = await msgsResp.json();
    const incoming = (msgsData.payload || []).filter(m => m.message_type === 0 && m.source_id);
    if (incoming.length > 0) inReplyTo = incoming[incoming.length - 1].source_id;
  } catch(e) { console.log('No se pudo obtener source_id:', e.message); }
}

// Enviar vía SMTP directo (igual que Outreach)
const nodemailer = require('nodemailer');
const transporter = nodemailer.createTransport({
  host: 'smtpout.secureserver.net', port: 465, secure: true,
  auth: { user: process.env.SMTP_USER || 'contacto@humanio.digital', pass: process.env.SMTP_PASS }
});

let email2Status = 'ERROR_SMTP';
let email2MsgId  = null;

try {
  const mailOpts = {
    from: '"Miguel González | Humanio" <contacto@humanio.digital>',
    to: '{EMAIL_PROSPECTO}',
    subject: 'Re: Análisis digital de {NOMBRE_NEGOCIO}',
    html: email2HTML
  };
  if (inReplyTo) { mailOpts.inReplyTo = inReplyTo; mailOpts.references = inReplyTo; }
  const info = await transporter.sendMail(mailOpts);
  email2MsgId  = info.messageId;
  email2Status = 'ENVIADO_VIA_SMTP';
  console.log(`✅ Email msg 2 enviado vía SMTP — messageId: ${email2MsgId}`);
} catch(err) {
  console.error('⚠️ Error SMTP msg 2:', err.message);
  email2Status = 'ERROR_SMTP — ' + err.message;
}

// Registrar en Chatwoot como nota privada (CRM)
if (CONV_ID && CONV_ID !== 'null' && CONV_ID !== '') {
  try {
    await fetch(`${CHATWOOT_URL}/api/v1/accounts/${ACCOUNT_ID}/conversations/${CONV_ID}/messages`, {
      method: 'POST',
      headers: { 'api_access_token': CHATWOOT_TOKEN, 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: `📧 Follow-up email enviado vía SMTP (${email2Status})\nMessageId: ${email2MsgId}`, private: true })
    });
  } catch(e) { console.log('⚠️ No se pudo registrar nota en Chatwoot:', e.message); }
}

fs.writeFileSync('/tmp/closer-{slug}/seguimiento-2-meta.json', JSON.stringify({
  chatwoot_conversation_id: CONV_ID,
  chatwoot_message_id: email2MsgId,
  subject: 'Re: Análisis digital de {NOMBRE_NEGOCIO}',
  status: email2Status,
  scheduledFor: '{FECHA_MSG2}',
  createdAt: new Date().toISOString()
}, null, 2));
console.log('✅ seguimiento-2-email.html generado');
```

#### 4c. Mensaje 3 — WhatsApp (generado ahora, enviado en día 7)

Sigue el template "WHATSAPP — Mensaje 3" del skill `sales-copywriting`:
- Declarar que es el último mensaje (elimina presión)
- No introducir temas nuevos
- Dejar puerta abierta con calidez
- Máximo 5 líneas

```bash
WA_MSG3="{NOMBRE_CONTACTO}, este es mi último mensaje sobre el tema.

Entiendo que el día a día de {NOMBRE_NEGOCIO} es lo primero.

El análisis sigue disponible cuando quieras:
{PROPUESTA_URL}

Éxito con todo.
— Miguel"

echo "$WA_MSG3" > /tmp/closer-{slug}/seguimiento-3-whatsapp.txt
echo "✅ seguimiento-3-whatsapp.txt generado (programado para día 7 si no hay respuesta)"
```

#### 4d. Mensaje 3 — Email (generado ahora, enviado en día 7 vía Chatwoot)

> El HTML se genera ahora. El envío ocurre en el Paso 8 (día 7) solo si no hay respuesta.
> Usa el mismo `chatwoot_conversation_id` para mantener el hilo completo en Chatwoot.

```javascript
const email3HTML = `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8">
<style>
  body{font-family:'Inter',Arial,sans-serif;margin:0;padding:20px;background:#f4f4f4}
  .container{max-width:600px;margin:0 auto;background:#fff;border-radius:8px;padding:32px 36px}
  p{font-size:15px;color:#1a1a2e;line-height:1.7;margin:0 0 16px}
  a{color:#2dd4bf;text-decoration:none;font-weight:500}
  .signature{margin-top:24px;padding-top:16px;border-top:1px solid #f0f0f0}
  .signature p{font-size:13px;color:#94a3b8;margin:0;line-height:1.6}
  .signature strong{color:#374151}
</style>
</head>
<body>
<div class="container">
  <p>Hola {NOMBRE_CONTACTO},</p>
  <p>No quiero ser insistente &mdash; sé que el día a día de {NOMBRE_NEGOCIO} es lo primero.</p>
  <p>Tu análisis y propuesta siguen disponibles aquí: <a href="{PROPUESTA_URL}">{PROPUESTA_URL}</a></p>
  <p>Si en algún momento te interesa explorarlo, me encuentras en este correo o por WhatsApp ({TELEFONO_MIGUEL_DISPLAY}).</p>
  <p>Te deseo mucho éxito.</p>
  <p>Miguel González<br>Humanio &mdash; Inteligencia Artificial para negocios</p>
</div>
</body>
</html>`;

fs.writeFileSync('/tmp/closer-{slug}/seguimiento-3-email.html', email3HTML);
fs.writeFileSync('/tmp/closer-{slug}/seguimiento-3-meta.json', JSON.stringify({
  chatwoot_conversation_id: '{CHATWOOT_CONVERSATION_ID}',
  subject: 'Re: Análisis digital de {NOMBRE_NEGOCIO}',
  status: 'PENDIENTE_DIA_7',
  scheduledFor: '{FECHA_MSG3}',
  note: 'Enviar solo si no hubo respuesta al mensaje 2 — ver Paso 8',
  createdAt: new Date().toISOString()
}, null, 2));
console.log('✅ seguimiento-3-email.html generado (se enviará en día 7 si no hay respuesta)');
```

### 5. Generar closer-log.txt (estado inicial)

```bash
cat > /tmp/closer-{slug}/closer-log.txt << 'EOF'
═══════════════════════════════════════════════════════════
REGISTRO DE SEGUIMIENTO — {NOMBRE_NEGOCIO}
═══════════════════════════════════════════════════════════

Prospecto : {NOMBRE_NEGOCIO}
Contacto  : {NOMBRE_CONTACTO}
Giro      : {GIRO} | {CIUDAD}
Score     : {SCORE}/10
Propuesta : {PROPUESTA_URL}

SECUENCIA PLANIFICADA:
──────────────────────
[{FECHA_MSG1}] MSG 1 — Outreach
  Canal    : {CANAL_MSG1}
  Hallazgo : {HALLAZGO_PRINCIPAL_MSG1}
  Status   : Enviado

[{FECHA_MSG2}] MSG 2 — Closer (hoy)
  Canal    : Email (draft) + WhatsApp
  Dato nuevo: {DATO_NUEVO_DE_VALOR}
  Status   : PENDIENTE ENVÍO

[{FECHA_MSG3}] MSG 3 — Closer (día 7)
  Canal    : Email (draft) + WhatsApp
  Status   : PROGRAMADO — solo si no hay respuesta al msg 2

RESPUESTAS DEL PROSPECTO:
──────────────────────────
(sin respuestas aún)

ESTADO: EN_SEGUIMIENTO
═══════════════════════════════════════════════════════════
EOF
echo "✅ closer-log.txt generado"
```

### 6. Confirmar archivos generados en /tmp

> Drive está deprecado — los archivos viven en `/tmp` durante el run del agente.

```bash
ls -lh /tmp/closer-{slug}/
# Esperado: seguimiento-2-whatsapp.txt, seguimiento-2-email.html,
#           seguimiento-3-whatsapp.txt, seguimiento-3-email.html,
#           seguimiento-2-meta.json, seguimiento-3-meta.json, closer-log.txt
echo "✅ Archivos listos en /tmp/closer-{slug}/"
```

### 7. Enviar mensaje 2 por WhatsApp — template `humanio_seguimiento_1`

> ⚠️ La ventana de 24h de Meta está cerrada — NUNCA uses `type: text`. SIEMPRE usa el template aprobado.

Variables del template:
- `{{1}}` = nombre corto del contacto (ej. `Dr. Meza`)
- `{{2}}` = nombre del negocio (ej. `Meza Dental`)
- `{{3}}` = objetivo concreto del giro (ej. `convertir visitas en citas`, `atraer más clientes locales`, `llenar agenda de citas`)
- URL button = slug del prospecto (ej. `meza-dental`)

**Mapeo desde el brief:**

| Var | Campo del brief | Fallback |
|---|---|---|
| `{{1}}` | `nombre_contacto` | `nombre_negocio` |
| `{{2}}` | `nombre_negocio` | bloquea |
| `{{3}}` | derivar de `giro` + `paquete_recomendado` (tabla abajo) | `atraer más clientes locales` (genérico seguro) |
| button slug | `slug_sugerido` | bloquea |

**Tabla de `OBJETIVO_GIRO` por giro+paquete** (extiende según necesites):

| Giro | Paquete | Objetivo sugerido |
|---|---|---|
| Dental / médico | business | llenar la agenda con citas confirmadas |
| Belleza / estética | business | mantener tu agenda llena con citas online |
| Belleza / estética | pro | resolver dudas de tus clientas 24/7 por WhatsApp |
| Restaurante / comida | pro | recibir pedidos y reservas por WhatsApp sin perder llamadas |
| Servicios profesionales / legal | pro | filtrar consultas serias antes de tomar la llamada |
| Coaching / consultoría | business | calificar leads y agendar diagnósticos automáticamente |
| (default) | starter | atraer más clientes locales desde Google |
| (default) | pro | responder consultas frecuentes 24/7 sin levantar el teléfono |
| (default) | business | automatizar agendamiento de citas sin perder ventanas de oportunidad |

```bash
WA_RESPONSE=$(curl -s -X POST \
  "https://graph.facebook.com/v19.0/$WHATSAPP_PHONE_NUMBER_ID/messages" \
  -H "Authorization: Bearer $WHATSAPP_CLOUD_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"messaging_product\": \"whatsapp\",
    \"to\": \"{TELEFONO_PROSPECTO_E164}\",
    \"type\": \"template\",
    \"template\": {
      \"name\": \"humanio_seguimiento_1\",
      \"language\": { \"code\": \"es_MX\" },
      \"components\": [
        {
          \"type\": \"body\",
          \"parameters\": [
            {\"type\": \"text\", \"text\": \"{NOMBRE_CORTO}\"},
            {\"type\": \"text\", \"text\": \"{NOMBRE_NEGOCIO}\"},
            {\"type\": \"text\", \"text\": \"{OBJETIVO_GIRO}\"}
          ]
        },
        {
          \"type\": \"button\",
          \"sub_type\": \"url\",
          \"index\": 0,
          \"parameters\": [{\"type\": \"text\", \"text\": \"{SLUG}\"}]
        }
      ]
    }
  }")

WA_MSG_ID=$(echo "$WA_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['messages'][0]['id'])" 2>/dev/null)

if [ -n "$WA_MSG_ID" ]; then
  echo "✅ WhatsApp msg 2 enviado (template humanio_seguimiento_1) — ID: $WA_MSG_ID"
  WA2_STATUS="ENVIADO — ID: $WA_MSG_ID"
else
  echo "⚠️ WhatsApp msg 2 falló: $WA_RESPONSE"
  WA2_STATUS="ERROR: $WA_RESPONSE"
fi
```

### 8. Envío de mensaje 3 (día 7) — SOLO si sin respuesta

> ⚠️ CONDICIÓN OBLIGATORIA: Solo ejecutar si `prospectReplied === false`.
> Si el prospecto respondió en cualquier momento (aunque sea con un "no gracias"),
> NO envíes el mensaje 3. Ve al CAMINO B para manejar esa respuesta.

**Envío de mensaje 3 (día 7):**
```bash
HOY=$(date +%Y-%m-%d)
if [ "$HOY" >= "$FECHA_MSG3" ] && [ "$STATUS_RESPUESTA" = "sin_respuesta" ]; then

  # ── Mensaje 3 WhatsApp — template humanio_seguimiento_2 ─────────────────
  # Variables: {{1}} nombre corto, {{2}} nombre negocio, button = slug
  WA_RESPONSE=$(curl -s -X POST \
    "https://graph.facebook.com/v19.0/$WHATSAPP_PHONE_NUMBER_ID/messages" \
    -H "Authorization: Bearer $WHATSAPP_CLOUD_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"messaging_product\": \"whatsapp\",
      \"to\": \"{TELEFONO_PROSPECTO_E164}\",
      \"type\": \"template\",
      \"template\": {
        \"name\": \"humanio_seguimiento_2\",
        \"language\": { \"code\": \"es_MX\" },
        \"components\": [
          {
            \"type\": \"body\",
            \"parameters\": [
              {\"type\": \"text\", \"text\": \"{NOMBRE_CORTO}\"},
              {\"type\": \"text\", \"text\": \"{NOMBRE_NEGOCIO}\"}
            ]
          },
          {
            \"type\": \"button\",
            \"sub_type\": \"url\",
            \"index\": 0,
            \"parameters\": [{\"type\": \"text\", \"text\": \"{SLUG}\"}]
          }
        ]
      }
    }")

  WA3_MSG_ID=$(echo "$WA_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['messages'][0]['id'])" 2>/dev/null)
  if [ -n "$WA3_MSG_ID" ]; then
    echo "✅ WhatsApp msg 3 enviado (template humanio_seguimiento_2) — ID: $WA3_MSG_ID"
    WA3_STATUS="ENVIADO — ID: $WA3_MSG_ID"
  else
    echo "⚠️ WhatsApp msg 3 falló: $WA_RESPONSE"
    WA3_STATUS="ERROR: $WA_RESPONSE"
  fi

  # ── Mensaje 3 Email (vía SMTP directo — NO Chatwoot API) ───────────────
  node -e "
const fs = require('fs');
const nodemailer = require('nodemailer');
const email3HTML = fs.readFileSync('/tmp/closer-{slug}/seguimiento-3-email.html', 'utf8');
const CONV_ID = '{CHATWOOT_CONVERSATION_ID}';
const CW_URL = process.env.CHATWOOT_API_URL;
const CW_TOKEN = process.env.CHATWOOT_API_TOKEN;
const ACCOUNT_ID = process.env.CHATWOOT_ACCOUNT_ID;

(async () => {
  // Obtener source_id del último mensaje entrante para In-Reply-To
  let inReplyTo = null;
  if (CONV_ID && CONV_ID !== 'null') {
    try {
      const r = await fetch(\`\${CW_URL}/api/v1/accounts/\${ACCOUNT_ID}/conversations/\${CONV_ID}/messages\`,
        { headers: { 'api_access_token': CW_TOKEN } });
      const d = await r.json();
      const incoming = (d.payload || []).filter(m => m.message_type === 0 && m.source_id);
      if (incoming.length > 0) inReplyTo = incoming[incoming.length - 1].source_id;
    } catch(e) {}
  }

  const transporter = nodemailer.createTransport({
    host: 'smtpout.secureserver.net', port: 465, secure: true,
    auth: { user: process.env.SMTP_USER || 'contacto@humanio.digital', pass: process.env.SMTP_PASS }
  });
  const mailOpts = {
    from: '\"Miguel González | Humanio\" <contacto@humanio.digital>',
    to: '{EMAIL_PROSPECTO}',
    subject: 'Re: Análisis digital de {NOMBRE_NEGOCIO}',
    html: email3HTML
  };
  if (inReplyTo) { mailOpts.inReplyTo = inReplyTo; mailOpts.references = inReplyTo; }

  try {
    const info = await transporter.sendMail(mailOpts);
    console.log('✅ Email msg 3 enviado vía SMTP — messageId: ' + info.messageId);
    // Nota privada en Chatwoot
    if (CONV_ID && CONV_ID !== 'null') {
      await fetch(\`\${CW_URL}/api/v1/accounts/\${ACCOUNT_ID}/conversations/\${CONV_ID}/messages\`,
        { method: 'POST', headers: { 'api_access_token': CW_TOKEN, 'Content-Type': 'application/json' },
          body: JSON.stringify({ content: '📧 Email msg 3 enviado vía SMTP — ' + info.messageId, private: true }) });
    }
  } catch(err) {
    console.error('⚠️ Error SMTP msg 3:', err.message);
  }
})();
"

  echo "✅ Mensaje 3 completo (WA + Email)"
else
  WA3_STATUS="NO APLICA — prospecto respondió o aún no es día 7"
fi
```

### 9. Notificar al CEO

Reporta con el template definido en AGENTS.md del Closer.

---

## Reglas de calidad

- SIEMPRE consulta `sales-copywriting` antes de redactar cualquier mensaje
- NUNCA envíes mensaje 3 si el prospecto respondió (positiva o negativamente) al mensaje 2
- NUNCA envíes mensaje 2 si el prospecto ya respondió al mensaje 1
- NUNCA inventes datos para el "dato nuevo de valor" — debe ser real o del diagnóstico
- Los emails de seguimiento SIEMPRE van como draft (nunca auto-envío)
- Los WhatsApp se envían automáticamente solo si hay número disponible
- Si el API de WhatsApp falla, guardar como .txt y marcar como PENDIENTE ENVÍO MANUAL
- El `closer-log.txt` debe registrar TODA interacción — es el historial completo del prospecto
- Máximo 3 mensajes totales por prospecto (1 Outreach + 2 Closer) — NUNCA más
