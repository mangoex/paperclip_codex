# ARCHITECTURE_TARGET

## Objetivo de migración

Definir una arquitectura por capas para migrar progresivamente desde orquestación centrada en n8n hacia un runtime basado en OpenAI + servicios determinísticos, sin cambiar comportamiento productivo en esta fase.

## Arquitectura por capas

## 1) ChatGPT Command Center (Capa de decisión)

Responsabilidades:
- Interpretar intención de negocio (Board/CEO y eventos de canal).
- Seleccionar agente responsable por etapa.
- Aplicar guardrails de routing (cold vs demo).
- Emitir comandos de ejecución con contratos versionados.

No hace:
- envíos directos a APIs externas sin pasar por servicios determinísticos.
- escrituras ad-hoc sin eventos auditables.

## 2) Event Bus (Capa de mensajería)

Responsabilidades:
- Recepción/publicación de eventos tipados (`contracts/events.schema.json`).
- Garantía de orden lógico por `prospect_id` (partition key).
- Idempotencia por `event_id` y `source_message_id`.
- Retry y dead-letter para eventos fallidos.

Canales sugeridos:
- `inbound.chat`
- `pipeline.commands`
- `pipeline.results`
- `followups.schedule`
- `publishing.events`

## 3) API Agents (Capa de agentes)

Cada agente se invoca como consumer de eventos y producer de salidas tipadas:
- Scout → `PROSPECT_BRIEF` parcial.
- Qualifier → `PROSPECT_BRIEF` enriquecido.
- Outreach → `OUTREACH_DRAFT`.
- Closer → `CLOSER_DECISION`.
- DesignPlanner → `DESIGN_SPEC`.
- WebQA → `WEB_QA_REPORT`.

Reglas:
- Entradas/salidas obligatoriamente validadas por schema.
- Timeout y budget por run.
- Resultado siempre persistido en `agent_runs`.

## 4) Deterministic Services (Capa de ejecución confiable)

Servicios no-LLM responsables de side effects:
- **Messaging Service**: envío WhatsApp/email, policy window/templates.
- **Follow-up Scheduler**: day3/day7, retries y cancelaciones.
- **Publishing Service**: fetch/merge/deploy Surge + verificaciones HTTP.
- **Persistence Service**: inserción de eventos y auditoría.
- **Approval Service**: gates humanos cuando el riesgo lo requiera.

## Modelo de flujo target

1. Inbound de Chatwoot/WhatsApp ingresa como `inbound_chatwoot_event`.
2. Command Center enruta a Closer/Outreach según estado.
3. Agentes emiten contratos (`CLOSER_DECISION`, `OUTREACH_DRAFT`, etc.).
4. Servicios determinísticos ejecutan side effects (send/publish/schedule).
5. Se publica evento resultado (`demo_published`, `followup_due`, etc.).
6. DataAnalyst consume eventos para métricas y observabilidad.

## Observabilidad y gobernanza

- Trazabilidad extremo a extremo con `correlation_id`.
- Registro de aprobaciones en tabla `approvals`.
- Bitácora inmutable de cambios en `audit_log`.
- Alarmas: backlog, dead letters, SLA de respuesta, publish failures.

## Estrategia de adopción (sin cambio productivo en esta entrega)

- Fase documental/contratos (esta entrega).
- Fase shadow (publicar eventos en paralelo a n8n).
- Fase cutover parcial (solo inbound o followups).
- Fase full runtime con rollback controlado.

