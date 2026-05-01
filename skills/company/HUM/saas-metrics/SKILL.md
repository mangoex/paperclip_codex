---
name: "saas-metrics"
description: "Calculador de métricas SaaS para el modelo de suscripción de Humanio. Calcula MRR, churn rate, LTV, CAC, ARPU y genera dashboards de revenue para los paquetes Starter/Pro/Business."
slug: "saas-metrics"
metadata:
  paperclip:
    slug: "saas-metrics"
    skillKey: "company/HUM/saas-metrics"
    paperclipSkillKey: "company/HUM/saas-metrics"
  skillKey: "company/HUM/saas-metrics"
  key: "company/HUM/saas-metrics"
key: "company/HUM/saas-metrics"
---

# SaaS Metrics — Métricas de Suscripción | Humanio

## Modelo de negocio

| Paquete | Precio bruto | Ingreso neto* |
|---------|-------------|-------------|
| Starter | $27 USD/mes | ~$26.19 |
| Pro | $47 USD/mes | ~$45.59 |
| Business | $97 USD/mes | ~$94.09 |

*Neto aproximado solo para modelado cuando no exista reporte real. El checkout se procesa con Hotmart desde `www.humanio.digital/#paquetes`; usa comisiones reales de Hotmart cuando estén disponibles.*

## Métricas clave

### 1. MRR (Monthly Recurring Revenue)
MRR = (clientes_starter x $27) + (clientes_pro x $47) + (clientes_business x $97)
MRR_neto_estimado = MRR - comisiones_reales_hotmart

Usa `MRR_neto_estimado` solo cuando tengas reporte real de Hotmart. Si no existe reporte real, reporta MRR bruto y marca net revenue como "pendiente de conciliacion". No inventes comisiones, numero de transacciones ni metodos de pago.

### 2. Churn Rate (Tasa de cancelación)
Churn Rate = clientes_perdidos_mes / clientes_inicio_mes x 100

Benchmarks LATAM:
- Excelente: < 5%
- Aceptable: 5-8%
- Promedio LATAM: 8.2%
- Alerta: > 10%
- Crítico: > 15%

### 3. LTV (Lifetime Value)
LTV = ARPU / Churn Rate

Ejemplo con churn 8%:
- LTV Starter = $27 / 0.08 = $337.50
- LTV Pro = $47 / 0.08 = $587.50
- LTV Business = $97 / 0.08 = $1,212.50

### 4. CAC (Customer Acquisition Cost)
CAC = costo_total_adquisicion / nuevos_clientes_mes
Target: CAC < LTV/3 para ser sostenible

### 5. ARPU (Average Revenue Per User)
ARPU = MRR / total_clientes_activos

### 6. Net Revenue Retention (NRR)
NRR = (MRR_inicio + upgrades - downgrades - churn) / MRR_inicio x 100
Target: NRR > 100%

## Dashboard semanal

El reporte semanal debe incluir:
- MRR bruto y neto
- Clientes por paquete (activos, nuevos, churn)
- Churn rate vs benchmark
- ARPU y LTV promedio
- Upgrades/Downgrades
- Revenue por país
- Alertas y recomendaciones

## Proyecciones

### Escenario conservador (mes 1-6)
- Mes 1: 5 clientes (3 Starter, 2 Pro)
- Mes 3: 15 clientes (8 Starter, 5 Pro, 2 Business)
- Mes 6: 40 clientes (20 Starter, 13 Pro, 7 Business)

### Meta de madurez
- 175 clientes (100 Starter + 50 Pro + 25 Business)
- MRR bruto: $7,475 USD/mes
- MRR neto estimado: pendiente de conciliacion con Hotmart

## Reglas

- Nunca inventes números — si no hay datos suficientes, proyecta con assumptions claras
- Siempre marca las estimaciones como tales
- Si el churn supera 10%, genera alerta inmediata al CEO
- Reporta métricas en USD siempre
