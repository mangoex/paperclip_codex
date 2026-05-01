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

## Precio internacional y moneda local

Precio base oficial: USD.

Checkout: Hotmart desde `https://www.humanio.digital/#paquetes`.

Hotmart muestra el monto final, moneda local y métodos disponibles según el país/ubicación del comprador. No prometas un método específico por país.

Si el prospecto pide moneda local, puedes dar equivalencias aproximadas solo como orientación:

| Paquete  | USD | MXN (~) | COP (~)   | PEN (~) | ARS (~)  |
|----------|-----|---------|-----------|---------|----------|
| Starter  | $27 | $540    | $108,000  | S/100   | $27,000  |
| Pro      | $47 | $940    | $188,000  | S/175   | $47,000  |
| Business | $97 | $1,940  | $388,000  | S/360   | $97,000  |

*Equivalencias referenciales, no cotización final. Hotmart calcula el monto final al momento de pago.*

## Pasarela de pago

- **Página de pago:** `https://www.humanio.digital/#paquetes`
- **Procesador:** Hotmart
- **Precio base:** USD
- **Moneda y métodos:** Hotmart los adapta según país/ubicación del comprador
- **Regla:** no prometas depósito, cuotas, transferencia, OXXO, PSE, Yape/Plin ni métodos locales salvo que el checkout vigente lo muestre.

## Formato de recomendación

Al incluir la recomendación en un ticket, usar este formato:

```
## Recomendación de paquete

**Paquete:** {Starter/Pro/Business}
**Precio base:** ${precio} USD/mes
**Moneda local:** Hotmart mostrará el monto final y métodos disponibles según tu país.
**Razón:** {justificación en 1-2 líneas basada en hallazgos reales}
**Link de pago:** https://www.humanio.digital/#paquetes
```

## Upselling path

Siempre mencionar la ruta de crecimiento:
- Starter → Pro: "Cuando quiera automatizar la atención por WhatsApp"
- Pro → Business: "Cuando necesite agendar citas automáticamente"
- Business → Servicios premium: "Automatizaciones avanzadas, tiendas en línea, agentes de IA personalizados"
