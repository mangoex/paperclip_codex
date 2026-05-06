# Humanio ![Org Chart](images/org-chart.png)

## What's Inside

> This is an [Agent Company](https://agentcompanies.io) package from [Paperclip](https://paperclip.ing)

| Content | Count |
|---------|-------|
| Agents | 11 |
| Projects | 1 |
| Skills | 41 |
| Tasks | 2 |

### Agents

| Agent | Role | Reports To | Active in flow |
|-------|------|------------|---|
| CEO | CEO | — | both |
| Scout | general | ceo | cold + demo enrichment |
| Qualifier | general | ceo | cold |
| Outreach | general | ceo | cold |
| ConversationManager | general | ceo | Chatwoot/WhatsApp pilot |
| Closer | general | ceo | cold + demo trigger |
| DesignPlanner | general | ceo | demo only (paused heartbeat) |
| WebBuilder | general | ceo | demo only (paused heartbeat) |
| WebQA | general | ceo | demo only (paused heartbeat) |
| WebPublisher | general | ceo | demo only (paused heartbeat) |
| DataAnalyst | researcher | ceo | metrics |

### Business Model

| Package | Price | Includes |
|---------|-------|----------|
| Starter | $27 USD/mo | Professional website + WhatsApp link + contact form |
| Pro | $47 USD/mo | All Starter + WhatsApp Chatbot with business info |
| Business | $97 USD/mo | All Pro + AI Chatbot with appointment scheduling |

## Pipeline — dos flujos separados

### 1. OUTBOUND por giro y ciudad

```
CEO → Scout → Qualifier → Outreach → Closer (espera respuesta)
```

Se activa cuando el Board/CEO pide prospectar un giro en una ciudad.

NO se construye sitio. NO se publica nada en Surge. El Outreach manda WhatsApp template + email con 3-4 hallazgos del Qualifier y CTA hacia Humanio. Si el piloto esta habilitado, Outreach puede crear `event_type: outbound_contact_request` para que ConversationManager ejecute o prepare el contacto sin duplicar n8n. Si el prospecto muestra interés, una respuesta programada de WhatsApp/n8n o ConversationManager despierta al CEO/Closer para intake y demo.

### 2. INBOUND / DEMO solicitada por WhatsApp

Se activa cuando un cliente contacta directamente por WhatsApp, o cuando un prospecto outbound responde que quiere ver una propuesta.

```
WhatsApp/n8n → ConversationManager (piloto) → CEO/Closer → DesignPlanner → WebBuilder → WebQA → WebPublisher → Closer/Outreach
```

Esto SÍ construye propuesta web. Scout no participa salvo enriquecimiento explícito de URLs/datos nuevos. La demo se trata como `premier`, se publica, se entrega al prospecto, y se programa seguimiento comercial. Los 4 agentes web tienen heartbeat **paused** — solo se activan por mensaje directo del Closer o del agente anterior en la cadena demo.

## WhatsApp Templates aprobados por Meta

| Template | Uso | Variables body | Botón URL | Quick replies |
|---|---|---|---|---|
| `humanio_diagnostico_v1` | msg1 outbound (Outreach) | {{1}}=Nombre, {{2}}=Negocio, {{3}}=Hallazgo, {{4}}=Oportunidad | `https://www.humanio.digital` (estático) | `Sí, quiero verla` / `Después` |
| `humanio_seguimiento_1` | msg2 día 3 (n8n cron; Closer solo si n8n crea ticket explícito) | {{1}}=Nombre, {{2}}=Empresa, {{3}}=Objetivo | `https://humanio.surge.sh/{{1}}` | — |
| `humanio_seguimiento_2` | msg3 día 7 (n8n cron; Closer solo si n8n crea ticket explícito) | {{1}}=Nombre, {{2}}=Empresa | `https://humanio.surge.sh/{{1}}` | — |

> **Migración pendiente**: los templates de seguimiento (`humanio_seguimiento_1`, `humanio_seguimiento_2`) todavía apuntan a `humanio.surge.sh/{slug}`. El redirect shim en `scripts/surge-redirect/` cubre esos clicks rebotando a `humanio.digital/?ref={slug}`. Cuando se aprueben versiones v2 con URL directa a `humanio.digital`, el shim queda como respaldo.
>
> **Owner operativo de seguimientos**: n8n debe ejecutar la cadencia de dia 3/dia 7. Los tickets `Closer: seguimiento...` quedan `blocked`; el Closer no envia follow-ups por heartbeat normal.
>
> **Contrato anti-bloqueo del Closer**: cuando haya respuesta, seguimiento vencido o demo publicada, n8n/WebPublisher deben crear un ticket explicito con `event_type` y status `todo` en lugar de solo despertar un ticket `blocked`. Ver `n8n/EVENT_CONTRACTS.md`.
>
> **Piloto ConversationManager**: el agente nuevo corre en `CONVERSATION_MANAGER_MODE=shadow` por defecto. En shadow no envia mensajes externos; clasifica, redacta, registra y crea tickets internos. Para activarlo por etapas se requieren `HUMANIO_ENABLE_OUTBOUND_SEND=true` y/o `HUMANIO_ENABLE_INBOUND_SEND=true`.

### Quick reply buttons del msg1 — flujo

| Botón | Acción del prospecto | Lo que pasa en el sistema |
|---|---|---|
| `Conocer Humanio` (URL) | Abre humanio.digital | Tracking pasivo |
| `Sí, quiero verla` (quick reply) | Genera mensaje entrante "Sí, quiero verla" | n8n → Closer MODO B → MODO C (demo intake con 4 preguntas) |
| `Después` (quick reply) | Genera mensaje "Después" | n8n → Closer marca `pendiente_followup`, espera msg2 día 3 |

## Setup inicial — UNA SOLA VEZ

1. Deploy del redirect shim:
   ```bash
   cd scripts/surge-redirect/
   SURGE_LOGIN=mangoex@gmail.com SURGE_TOKEN=$SURGE_TOKEN surge . humanio.surge.sh
   ```
2. Configurar env vars en cada agente del panel de Paperclip — ver `.paperclip.yaml`.
3. Usar `.env.example` como checklist de secretos antes de activar agentes con envío real.

## Skills

41 skills vendorizadas o propias, incluyendo: frontend-design, outreach-proposals, conversation-manager, chatwoot-whatsapp-ops, qualifier-prospect-auditor, qualifier-seo, scout-prospector, frontend-design-review, frontend-ui-dark-ts, closer-sales, sales-copywriting, dataanalyst-pipeline, web-qa, qualifier-diagnostic-html, package-pricing, package-outreach (legacy compatibility), saas-metrics, retention-playbook, ui-ux-pro-max, paperclip-create-agent, paperclip-create-plugin, paperclip, para-memory-files, objection-handling, social-selling, cold-outreach, lead-qualification, web-scraping, web-template-system, web-premier-system, layout-blueprints, design-styles, dataanalyst-dashboard-html.

## Getting Started

```bash
pnpm paperclipai company import \
  --from https://github.com/mangoex/paperclip_codex/tree/codex/import-readiness-audit \
  --target new \
  --new-company-name "Humanio Codex" \
  --include company,agents,projects,tasks,skills
```

Alternative via Agent Companies CLI:

```bash
npx companies.sh add \
  https://github.com/mangoex/paperclip_codex/tree/codex/import-readiness-audit \
  --target new \
  --include company,agents,projects,tasks,skills
```

See [Paperclip](https://paperclip.ing) for more information.

---

> Humanio — Inteligencia Artificial para negocios
