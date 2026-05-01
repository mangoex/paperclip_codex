# Tools del CEO

## Paperclip API (coordinación de agentes)

Tu herramienta principal. Toda la delegación, seguimiento y comunicación pasa por aquí.

- **Crear tickets**: `POST /api/issues` con `parentId`, `goalId`, y asignación al agente correcto
- **Checkout**: `POST /api/issues/{id}/checkout` — SIEMPRE antes de trabajar un ticket. Nunca reintentar 409.
- **Comentar**: `POST /api/issues/{id}/comments` — Actualiza status, comparte URLs, escala decisiones
- **Mensajes directos**: Para despertar agentes según ruta: Scout→Qualifier→Outreach→Closer en outbound; Closer→DesignPlanner→WebBuilder→WebQA→WebPublisher→Closer/Outreach en inbound/demo.
- **Header obligatorio**: Incluir `X-Paperclip-Run-Id` en toda llamada mutante

## Chatwoot (CRM y comunicación inbound)

Lectura de conversaciones con prospectos que nos contactan directamente.

- **URL**: `$CHATWOOT_API_URL`
- **Inbox de email**: ID 2 (`contacto@humanio.digital`)
- **Listar conversaciones**: `GET /api/v1/accounts/{ACCOUNT_ID}/conversations?inbox_id=2&status=open`
- **Leer mensajes**: `GET /api/v1/accounts/{ACCOUNT_ID}/conversations/{CONV_ID}/messages`
- **Uso**: Solo lectura para triage de inbound. NO enviar emails vía Chatwoot (bug v4.11). Delegar a Closer/Outreach.

## Sistema de Memoria PARA (`para-memory-files`)

Gestión de contexto persistente entre sesiones.

- **Memoria diaria**: `$AGENT_HOME/memory/YYYY-MM-DD.md` — Plan del día, tareas completadas, bloqueos
- **Hechos durables**: `$AGENT_HOME/life/` — Estructura PARA (Projects, Areas, Resources, Archive)
- **Extracción de hechos**: En cada heartbeat, revisa conversaciones nuevas y extrae hechos durables
- **Regla**: Siempre lee el plan del día al inicio. Siempre actualiza antes de salir.

## Supabase (verificación de pipeline)

Todos los agentes escriben a Supabase. Úsalo para ver el estado real del pipeline:

- **URL:** `$SUPABASE_URL`
- **Tablas:** `prospects`, `proposals`, `outreach_log`, `pipeline_events`
- **Auth:** headers `apikey: $SUPABASE_SERVICE_KEY` + `Authorization: Bearer $SUPABASE_SERVICE_KEY`

Ejemplos:
```bash
# Ver prospectos en negociación
curl -s "$SUPABASE_URL/rest/v1/prospects?etapa=eq.en_negociacion&select=*" \
  -H "apikey: $SUPABASE_SERVICE_KEY" -H "Authorization: Bearer $SUPABASE_SERVICE_KEY"

# Ver inbound de las últimas 24h
curl -s "$SUPABASE_URL/rest/v1/prospects?origen=eq.inbound_whatsapp&order=created_at.desc" \
  -H "apikey: $SUPABASE_SERVICE_KEY" -H "Authorization: Bearer $SUPABASE_SERVICE_KEY"
```

> Google Drive quedó **deprecado**. No revisar Drive ni asumir que agentes suben ahí.

## Pagos (verificación)

Los prospectos pagan en `https://www.humanio.digital/#paquetes`. El checkout lo procesa Hotmart: precio base USD, moneda local y métodos disponibles según país/ubicación del comprador.

Cuando Closer escala un cierre exitoso, verifica el pago antes de activar onboarding:
- Revisar Hotmart / procesador configurado en humanio.digital
- No asumir ningún método local específico salvo que Hotmart o el comprobante lo confirme
- Actualizar `prospects.etapa = 'cerrado_ganado'` en Supabase

## Surge.sh (verificación de deploys)

Cuando WebPublisher notifica una URL publicada:
- Verificar que `https://humanio.surge.sh/{slug}` carga correctamente (NO `humanio-{slug}.surge.sh`)
- Verificar que `/propuesta` y `/reporte` son accesibles
- Compartir la URL al Board como comentario en el ticket original
