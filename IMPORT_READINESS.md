# Import Readiness Notes

## Estado actual

El paquete esta preparado para importarse como organizacion Humanio con dos rutas operativas:

1. **Outbound por giro/ciudad**
   `CEO -> Scout -> Qualifier -> Outreach -> Closer`

   No construye sitio inicial. Outreach envia hallazgos reales y Closer espera respuesta.

2. **Inbound / demo solicitada por WhatsApp**
   `WhatsApp/n8n -> Closer -> DesignPlanner -> WebBuilder -> WebQA -> WebPublisher -> Closer/Outreach`

   Se usa cuando el prospecto pide propuesta o llega como urgente por WhatsApp. La demo se trata como `premier`.

## Guardrails aplicados

- Los agentes web estan pausados por heartbeat en `.paperclip.yaml`.
- Qualifier ya no despierta a DesignPlanner en cold.
- Outreach ya no espera sitio publicado para msg1.
- Google Drive quedo fuera del manifiesto de variables.
- `.claude/settings.local.json` fue removido del paquete importable.
- `.env.example` documenta las variables necesarias sin secretos.

## Pendiente despues de importar

- Cambiar adaptadores/modelos de `claude_local` a la configuracion Codex/OpenAI que uses en tu instancia de Paperclip.
- Cargar secretos reales en Paperclip: WhatsApp, Chatwoot, Supabase, Surge y SMTP si se usara email.
- Probar primero con `contact_override` para evitar contactar prospectos reales.
- Activar agentes web solo via mensajes directos del flujo demo.
