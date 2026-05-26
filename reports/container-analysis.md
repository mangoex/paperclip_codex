# Análisis de viabilidad: reemplazar n8n por un agente WhatsApp

## Contexto actual observado

- El flujo operativo vigente separa:
  - **Outbound cold**: CEO → Scout → Qualifier → Outreach → Closer.
  - **Inbound/demo**: WhatsApp/n8n → Closer → DesignPlanner → WebBuilder → WebQA → WebPublisher.
- n8n hoy cumple dos funciones clave:
  1. Orquestación de eventos de WhatsApp (mensajes entrantes y seguimientos automáticos).
  2. Disparo de tickets/handoffs al Closer y al flujo demo cuando hay interés.

## ¿Se puede reemplazar n8n por un agente WhatsApp?

Sí, **es viable**, pero requiere cubrir explícitamente las capacidades que n8n ofrece hoy:

1. **Gateway/API de WhatsApp Business** (Meta Cloud API, BSP, o Chatwoot como capa).
2. **Scheduler confiable** para follow-ups (día 3 / día 7), retries y ventanas horarias.
3. **Idempotencia y deduplicación** de eventos inbound (evitar doble envío / doble handoff).
4. **Persistencia transaccional** de conversaciones, estado y auditoría.
5. **Reglas de cumplimiento** (templates, 24h window, opt-out, límites de calidad).

Sin esas cinco piezas, quitar n8n aumenta riesgo operativo.

## Recomendación de arquitectura (sin n8n)

### Opción A — Reutilizar Closer como “agente conversacional”

**No recomendado como primera fase**. Mezcla dos responsabilidades:
- cierre comercial consultivo, y
- operación técnica de mensajería en tiempo real.

Riesgo: sobrecarga de lógica en Closer, loops y acoplamiento fuerte con canal.

### Opción B — Crear un agente nuevo “WhatsApp Concierge” (recomendado)

Separar canal y cierre:

- **WhatsApp Concierge (nuevo)**
  - Recibe y envía mensajes.
  - Clasifica intención inicial (interés, objeción, no interesado, fuera de tema).
  - Ejecuta reglas de plantilla/ventana.
  - Agenda follow-ups automáticos.
  - Genera eventos estructurados para Closer.

- **Closer (actual)**
  - Conserva rol de estrategia comercial, intake, objeciones complejas y disparo de demo.

Esta separación respeta el diseño actual de pipeline y evita romper contratos de rol.

## Estructura propuesta de flujo

1. **Scout/Qualifier/Outreach** generan prospectos y primer contacto (como hoy).
2. **WhatsApp Concierge** toma ownership de conversación inbound/outbound:
   - recibe webhook de WhatsApp,
   - normaliza mensaje,
   - actualiza estado del prospecto,
   - decide acción por política.
3. Si detecta interés real:
   - crea ticket/evento para **Closer** con contexto completo.
4. **Closer** decide:
   - resolver objeción,
   - pedir intake faltante,
   - o disparar **DesignPlanner** para demo.
5. **DataAnalyst** consume eventos para métricas de conversión y tiempos de respuesta.

## Modelo de estados mínimo (reemplazo de n8n)

- `new_lead`
- `msg1_sent`
- `awaiting_reply`
- `replied_positive`
- `replied_objection`
- `replied_negative`
- `followup_day3_scheduled`
- `followup_day3_sent`
- `followup_day7_scheduled`
- `followup_day7_sent`
- `handoff_to_closer`
- `demo_requested`
- `closed_won` / `closed_lost`

## Componentes técnicos sugeridos

1. **WhatsApp Adapter Service**
   - Endpoint webhook (inbound).
   - Sender API (outbound template/free-form).
2. **Conversation Store** (ej. Supabase)
   - tabla `conversations`
   - tabla `messages`
   - tabla `conversation_events`
3. **Scheduler/Queue**
   - jobs de follow-up, retry con backoff, DLQ.
4. **Policy Engine**
   - reglas de ventana 24h, template permitido, opt-out.
5. **Agent Runtime Hook**
   - dispara al agente WhatsApp Concierge y al Closer vía eventos.

## Plan de migración por fases

1. **Fase 0 (shadow mode)**
   - n8n sigue activo, nuevo agente solo observa y clasifica eventos.
2. **Fase 1 (inbound first)**
   - nuevo agente responde inbound; n8n mantiene follow-ups.
3. **Fase 2 (follow-ups)**
   - mover día 3 / día 7 al scheduler nuevo.
4. **Fase 3 (full cutover)**
   - apagar flujos n8n de WhatsApp.
5. **Fase 4 (hardening)**
   - SLAs, alertas, auditoría, pruebas de resiliencia.

## Riesgos y mitigaciones

- **Riesgo**: pérdida de mensajes por caídas.
  - **Mitigación**: cola persistente + reintentos + DLQ.
- **Riesgo**: doble envío por eventos duplicados.
  - **Mitigación**: idempotency keys por `message_id`.
- **Riesgo**: incumplir políticas de WhatsApp.
  - **Mitigación**: policy engine centralizado y validación previa al envío.
- **Riesgo**: degradación comercial por handoffs pobres.
  - **Mitigación**: payload estructurado obligatorio al Closer.

## Conclusión ejecutiva

- **Sí se puede** reemplazar n8n por agentes.
- **Mejor estructura**: crear **WhatsApp Concierge** dedicado y mantener **Closer** como cerrador.
- Hacerlo de forma **gradual por fases** para no romper continuidad comercial.
