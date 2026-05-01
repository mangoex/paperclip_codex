---
name: "retention-playbook"
description: "Playbook anti-churn para retención de clientes de Humanio. Define secuencias de retención, señales de riesgo, estrategias de upselling y protocolos de intervención para reducir la tasa de cancelación de suscripciones."
slug: "retention-playbook"
metadata:
  paperclip:
    slug: "retention-playbook"
    skillKey: "company/HUM/retention-playbook"
    paperclipSkillKey: "company/HUM/retention-playbook"
  skillKey: "company/HUM/retention-playbook"
  key: "company/HUM/retention-playbook"
key: "company/HUM/retention-playbook"
---

# Retention Playbook — Anti-Churn | Humanio

## Contexto

El churn promedio en SaaS LATAM para pymes es 8.2% mensual. El objetivo de Humanio es mantenerlo bajo 6% mediante intervención proactiva.

> Humanio es una consultora de Inteligencia Artificial, NO una agencia de marketing. La firma SIEMPRE dice "Humanio — Inteligencia Artificial para negocios".

## Señales tempranas de churn

### Riesgo alto (intervenir en 24h)
- Cliente solicita cancelación
- No ha visitado su web en 30+ días
- Rechazó o falló el cobro recurrente en Hotmart
- Expresó insatisfacción directa
- No respondió a los últimos 2 mensajes

### Riesgo medio (intervenir en 72h)
- No ha interactuado con el chatbot en 14+ días (Pro/Business)
- No ha hecho cambios a su web en 60+ días
- Preguntó sobre funcionalidades no incluidas
- Menciona competidores

### Señales positivas (reforzar)
- Pide actualizaciones a su web (cliente activo)
- Su chatbot tiene alto engagement
- Refiere otros negocios a Humanio
- Pregunta sobre upgrades

## Secuencias de retención

### Semana 1 — Onboarding
- Día 1: Bienvenida por WhatsApp + email con credenciales
- Día 2: Tutorial de cómo editar su página web
- Día 3: Verificar que la web esté activa
- Día 5: Primer seguimiento
- Día 7: Enviar primer reporte de visitas

### Mes 1 — Valor temprano
- Semana 2: Reporte de visitas a su web
- Semana 3: Tip personalizado según giro
- Semana 4: Reporte mensual + sugerencia de upgrade

### Mensual — Valor continuo
- Reporte de métricas de su web
- Reporte de actividad del chatbot (Pro/Business)
- 1 mejora proactiva a su web
- Recordatorio de beneficios activos

## Protocolos de intervención

### Si el cliente quiere cancelar

1. Escuchar — Preguntar la razón real
2. Empatizar — "Entendemos, queremos asegurarnos de que tome la mejor decisión"
3. Ofrecer alternativa según la razón:

| Razón | Respuesta |
|-------|----------|
| "Es muy caro" | Ofrecer descuento temporal (20% x 3 meses) o downgrade |
| "No lo uso" | Ofrecer sesión de capacitación + mejoras proactivas |
| "No veo resultados" | Mostrar métricas reales + plan de mejora 30 días |
| "Encontré algo mejor" | Preguntar qué ofrece el competidor, igualar si es viable |
| "Mi negocio cerró" | Agradecer, ofrecer pausar en vez de cancelar |

4. Si insiste — Respetar la decisión, agradecer, dejar puerta abierta

### Si el cobro falla en Hotmart
- Día 0: Notificación automática por WhatsApp con link al checkout/actualización de pago
- Día 2: Verificar en Hotmart si el pago se recuperó o sigue pendiente
- Día 3: Mensaje personal de ayuda
- Día 5: Tercer intento + email
- Día 7: Último aviso antes de suspensión
- Día 10: Suspensión del servicio
- Día 30: Cancelación definitiva

## Estrategias de upselling

### Starter a Pro ($27 a $47)
Trigger: El negocio recibe muchos mensajes de WhatsApp manualmente
Mensaje: "Con el plan Pro, un chatbot responde automáticamente 24/7"

### Pro a Business ($47 a $97)
Trigger: El negocio agenda citas manualmente
Mensaje: "Con el plan Business, sus clientes agendan directamente desde WhatsApp"

### Business a Servicios premium
Trigger: El negocio quiere más automatización
Mensaje: "Podemos explorar automatizaciones personalizadas y agentes de IA"

## Métricas de retención

- Churn rate mensual — target: < 6%
- Retención a 3 meses — target: > 75%
- Retención a 6 meses — target: > 60%
- Upgrade rate — target: > 5% mensual

## Reglas

- NUNCA seas agresivo con clientes que quieren cancelar
- SIEMPRE respeta la decisión final del cliente
- Personaliza cada interacción
- El mejor anti-churn es entregar valor real
- Escala al CEO cualquier cancelación de cliente Business ($97)
- Documenta cada interacción de retención en el ticket
