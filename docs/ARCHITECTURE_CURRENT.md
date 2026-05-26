# ARCHITECTURE_CURRENT

## Resumen operativo actual (paperclip_codex)

El sistema actual opera con dos flujos separados:

1. **Outbound cold**
   - CEO → Scout → Qualifier → Outreach → Closer.
   - No se construye sitio ni se publica demo al inicio.

2. **Inbound / demo**
   - WhatsApp/n8n → Closer → DesignPlanner → WebBuilder → WebQA → WebPublisher → Closer/Outreach.
   - Sí construye y publica demo cuando el prospecto expresa interés.

## Mapa real de agentes

| Agente | Rol principal | Trigger principal | Salidas/Handoff |
|---|---|---|---|
| CEO | Orquestación, prioridades, control de volumen | Solicitud del Board | Ticket a Scout o Closer |
| Scout | Prospección | Ticket CEO | Lista prospectos + contexto a Qualifier |
| Qualifier | Diagnóstico y score | Ticket Scout | Hallazgos + paquete recomendado a Outreach |
| Outreach | Primer contacto WhatsApp/email | Ticket Qualifier | msg1 outbound + ticket seguimiento a Closer |
| Closer | Clasificación respuesta, intake demo, cierre | Respuestas inbound/n8n o handoff Outreach | decisión comercial, ticket a DesignPlanner |
| DesignPlanner | Define DESIGN_SPEC para demo | Ticket Closer | DESIGN_SPEC a WebBuilder |
| WebBuilder | Construye propuesta web | PROSPECT_BRIEF + DESIGN_SPEC | build_path + artefactos a WebQA |
| WebQA | Auditoría PASS/FAIL | Entregable WebBuilder | reporte QA + PASS/FAIL a WebPublisher |
| WebPublisher | Publica en Surge.sh | PASS WebQA | URLs publicadas + notificación a Closer/Outreach |
| DataAnalyst | Métricas SaaS/Pipeline | Rutina semanal o ticket CEO | reportes para CEO |

## Skills por agente (declaradas)

- **CEO**: `paperclip`, `para-memory-files`, `paperclip-create-agent`.
- **Scout**: `scrapling-official`, `scout-prospector`, `social-selling` (+ paperclip/memory).
- **Qualifier**: `qualifier-prospect-auditor`, `qualifier-seo`, `qualifier-diagnostic-html`, `package-pricing` (+ paperclip/memory).
- **Outreach**: `outreach-proposals`, `sales-copywriting`, `cold-outreach`, `lead-qualification` (+ paperclip/memory).
- **Closer**: `closer-sales`, `sales-copywriting`, `objection-handling` (+ paperclip/memory).
- **DesignPlanner**: `frontend-design`, `design-styles`, `layout-blueprints`, `web-premier-system` (+ paperclip/memory).
- **WebBuilder**: `web-template-system`, `web-premier-system`, `frontend-ui-dark-ts` (+ paperclip/memory).
- **WebQA**: `web-qa`, `package-pricing` (+ paperclip).
- **WebPublisher**: `paperclip`.
- **DataAnalyst**: `dataanalyst-pipeline`, `saas-metrics`, `retention-playbook`, `dataanalyst-dashboard-html` (+ paperclip/memory).

## Eventos actuales (implícitos en flujo)

- `board_prospecting_request`
- `prospects_discovered`
- `prospects_qualified`
- `outreach_msg1_sent`
- `inbound_response_received` (actualmente por n8n/Chatwoot)
- `demo_requested`
- `design_spec_ready`
- `web_build_ready`
- `web_qa_passed` / `web_qa_failed`
- `demo_published`
- `followup_day3_due`
- `followup_day7_due`

## Variables de entorno críticas (observadas por documentación)

- `SURGE_TOKEN` (deploy WebPublisher/redirect shim)
- `SURGE_LOGIN` (bootstrap redirect shim)
- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`
- `PEXELS_API_KEY` (hero video en template)
- Variables de contacto de prueba (`TEST_PHONE`, `TEST_EMAIL`) cuando aplica override

## Handoffs y side effects

### Outbound
1. CEO crea ticket para Scout con `requested_count/activation_limit`.
2. Scout crea candidatos; Qualifier limita activación.
3. Qualifier produce score, hallazgos, paquete.
4. Outreach envía msg1 (WhatsApp template + email) y crea ticket `Closer: seguimiento`.
5. Closer permanece `blocked` hasta evento de respuesta.

**Side effects outbound**:
- envíos a WhatsApp/email,
- actualización de tickets/estados,
- registros en Supabase (`prospects`, `outreach_log`, `pipeline_events`).

### Demo
1. Evento inbound (n8n/Chatwoot) despierta Closer.
2. Closer crea ticket demo a DesignPlanner (`delivery_mode: premier`).
3. DesignPlanner entrega DESIGN_SPEC a WebBuilder.
4. WebBuilder genera `/tmp/proposal-{slug}`.
5. WebQA audita PASS/FAIL.
6. WebPublisher publica en `humanio.surge.sh/{slug}/...`.
7. Closer/Outreach entregan URL al prospecto.

**Side effects demo**:
- construcción de artefactos HTML,
- publicación en Surge,
- cambios de estado comerciales,
- eventos analíticos para DataAnalyst.

## Dependencias externas actuales

- **n8n**: orquestación de inbound WhatsApp y seguimientos.
- **Chatwoot/WhatsApp**: canal de conversación con prospectos.
- **Supabase**: fuente de verdad para métricas y pipeline.
- **Surge.sh**: hosting de propuestas.
- **Pexels API**: búsqueda de video hero en modo template.

