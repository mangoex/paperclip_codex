---
name: "Onboarding"
status: "in_progress"
description: "Proyecto operativo para importar, configurar y validar Humanio Codex en Paperclip sin activar flujos peligrosos por accidente."
---

# Onboarding — Humanio Codex

Este proyecto agrupa las tareas iniciales y rutinas de control para la organizacion Humanio Codex.

## Objetivo

Mantener un entorno importable y seguro para dos rutas:

- Cold outbound: CEO -> Scout -> Qualifier -> Outreach -> Closer.
- Demo/inbound: Closer -> DesignPlanner -> WebBuilder -> WebQA -> WebPublisher -> Closer/Outreach.

## Reglas Operativas

- El flujo cold no construye demos ni despierta agentes web.
- Los agentes web trabajan solo cuando hay interes explicito o lead inbound.
- Los env vars reales se configuran en Paperclip UI, no en este repositorio.
- Antes de correr envios reales, revisar WhatsApp, SMTP, Chatwoot, Supabase y locks.
- n8n/WebPublisher deben reactivar al Closer con tickets explicitos `event_type`, no solo con wake de tickets `blocked`.

## Estado Esperado

- Agentes importados en Codex local / OpenAI.
- Skills principales actualizadas manualmente o por import controlado.
- WebPublisher con `CLOSER_AGENT_ID` configurado.
- n8n como owner de seguimientos msg2/msg3.
- Contratos `n8n/EVENT_CONTRACTS.md` probados con un caso de respuesta entrante y un caso de seguimiento vencido.
