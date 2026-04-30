---
name: "package-pricing"
description: "Asignador de paquetes de suscripción Humanio. Analiza el perfil del prospecto y recomienda el paquete óptimo (Starter $27, Pro $47 o Business $97 USD/mes) según las necesidades detectadas."
slug: "package-pricing"
metadata:
  paperclip:
    slug: "package-pricing"
    skillKey: "company/HUM/package-pricing"
    paperclipSkillKey: "company/HUM/package-pricing"
  skillKey: "company/HUM/package-pricing"
  key: "company/HUM/package-pricing"
key: "company/HUM/package-pricing"
---

# Package Pricing — Asignador de Paquetes | Humanio

## Paquetes de suscripción

| Paquete | Precio USD | Incluye | Perfil ideal |
|---------|-----------|---------|--------------| 
| **Starter** | $27/mes | Web profesional + enlace WhatsApp + formulario contacto | Negocio sin presencia digital |
| **Pro** | $47/mes | Todo Starter + Chatbot WhatsApp con info del negocio | Negocio con web básica, necesita atención automatizada |
| **Business** | $97/mes | Todo Pro + Chatbot IA con agendamiento de citas | Negocio basado en citas y consultas |

## Reglas de asignación

### Starter ($27 USD/mes)
Asignar cuando:
- El negocio NO tiene página web
- Tiene web pero está caída, abandonada o es solo un perfil de Facebook
- No tiene presencia digital profesional
- Negocio pequeño que necesita empezar desde cero

### Pro ($47 USD/mes)
Asignar cuando:
- El negocio YA tiene web (básica o funcional)
- Recibe muchas preguntas repetitivas (horarios, precios, ubicación)
- No tiene WhatsApp Business activo o lo usa manualmente
- Vende productos o servicios que no requieren cita
- Restaurantes, tiendas, comercios en general

### Business ($97 USD/mes)
Asignar cuando:
- El negocio se basa en **citas y consultas**
- Giros típicos: dentistas, doctores, abogados, psicólogos, coaches, salones de belleza, veterinarias, consultores
- Necesita agenda automática
- El tiempo del profesional es el recurso más valioso

### No prioritario
Marcar cuando:
- El negocio ya tiene web profesional + chatbot activo + agenda online
- Score < 6 en la evaluación del Qualifier
- No se detecta necesidad clara de los servicios de Humanio

## Equivalencia en moneda local

Al presentar precios, siempre incluir equivalencia aproximada:

| Paquete  | USD | MXN (~) | COP (~)   | PEN (~) | ARS (~)  |
|----------|-----|---------|-----------|---------|----------|
| Starter  | $27 | $540    | $108,000  | S/100   | $27,000  |
| Pro      | $47 | $940    | $188,000  | S/175   | $47,000  |
| Business | $97 | $1,940  | $388,000  | S/360   | $97,000  |

*Tipo de cambio referencial: 1 USD ≈ 20 MXN ≈ 4,000 COP ≈ 3.7 PEN ≈ 1,000 ARS. Actualizar esta tabla si el FX se mueve >5%.*

## Pasarela de pago

- **Página de pago:** `https://www.humanio.digital/#paquetes`
- **Medios:** tarjeta de crédito, tarjeta de débito, depósito bancario
- Multi-país, multi-moneda
- El prospecto selecciona paquete y medio de pago en la página

## Formato de recomendación

Al incluir la recomendación en un ticket, usar este formato:

```
## Recomendación de paquete

**Paquete:** {Starter/Pro/Business}
**Precio:** ${precio} USD/mes (~{equivalencia} {moneda local})
**Razón:** {justificación en 1-2 líneas basada en hallazgos reales}
**Link de pago:** https://www.humanio.digital/#paquetes
```

## Upselling path

Siempre mencionar la ruta de crecimiento:
- Starter → Pro: "Cuando quiera automatizar la atención por WhatsApp"
- Pro → Business: "Cuando necesite agendar citas automáticamente"
- Business → Servicios premium: "Automatizaciones avanzadas, tiendas en línea, agentes de IA personalizados"
