# Import Readiness Notes

## Estado actual

El paquete esta preparado para importarse como organizacion Humanio con dos rutas operativas:

1. **Outbound por giro/ciudad**
   `CEO -> Scout -> Qualifier -> Outreach -> Closer`

   No construye sitio inicial. Outreach envia hallazgos reales y Closer espera respuesta.

2. **Inbound / demo solicitada por WhatsApp**
   `WhatsApp/n8n -> ConversationManager (piloto) -> CEO/Closer -> DesignPlanner -> WebBuilder -> WebQA -> WebPublisher -> Closer/Outreach`

   Se usa cuando el prospecto pide propuesta o llega como urgente por WhatsApp. La demo se trata como `premier`.

## Guardrails aplicados

- Los agentes web estan pausados por heartbeat en `.paperclip.yaml`.
- `.paperclip.yaml` usa adaptador `codex_local` con modelo `openai/gpt-5.4` como base de importacion.
- Qualifier ya no despierta a DesignPlanner en cold.
- Outreach ya no espera sitio publicado para msg1.
- Google Drive quedo fuera del manifiesto de variables.
- `.claude/settings.local.json` fue removido del paquete importable.
- `.env.example` documenta las variables necesarias sin secretos.

## Pendiente despues de importar

- Verificar en Paperclip UI que cada agente quedo en Codex local / OpenAI con el modelo deseado.
- Cargar secretos reales en Paperclip: WhatsApp, Chatwoot, Supabase, Surge y SMTP si se usara email.
- Probar primero con `contact_override` para evitar contactar prospectos reales.
- Activar agentes web solo via mensajes directos del flujo demo.
- Validar que n8n cree tickets explicitos con `event_type` segun `n8n/EVENT_CONTRACTS.md`; no basta con despertar tickets bloqueados del Closer.
- Verificar que el workflow cron de seguimientos cree tickets `Closer: enviar msg2/msg3...` con `event_type: followup_due`.
- Configurar ConversationManager primero en `CONVERSATION_MANAGER_MODE=shadow`, `HUMANIO_ENABLE_OUTBOUND_SEND=false`, `HUMANIO_ENABLE_INBOUND_SEND=false`.
- Probar ConversationManager con tickets internos antes de conectar Chatwoot o apagar cualquier parte de n8n.

## Comando recomendado de importacion

Usa la sintaxis nueva con `--from`. Evita el formato antiguo `paperclipai company import <url>`, porque puede llamar rutas legacy como `/company/import`.

```bash
pnpm paperclipai company import \
  --from https://github.com/mangoex/paperclip_codex/tree/codex/import-readiness-audit \
  --target new \
  --new-company-name "Humanio Codex" \
  --include company,agents,projects,tasks,skills
```

Preview sin escribir:

```bash
pnpm paperclipai company import \
  --from https://github.com/mangoex/paperclip_codex/tree/codex/import-readiness-audit \
  --target new \
  --new-company-name "Humanio Codex" \
  --include company,agents,projects,tasks,skills \
  --dry-run
```
