---
name: "package-outreach"
description: "LEGACY: skill conservado solo por compatibilidad de import. No debe usarse para cold outreach ni para cierre activo; usa outreach-proposals, package-pricing, sales-copywriting y closer-sales."
slug: "package-outreach"
metadata:
  paperclip:
    slug: "package-outreach"
    skillKey: "company/HUM/package-outreach"
    paperclipSkillKey: "company/HUM/package-outreach"
  skillKey: "company/HUM/package-outreach"
  key: "company/HUM/package-outreach"
key: "company/HUM/package-outreach"
---

# Package Outreach — Legacy Compatibility

Esta skill queda en el paquete solo para no romper imports antiguos que todavia la referencien por `company/HUM/package-outreach`.

## Estado

**DEPRECATED — NO USAR EN PRODUCCION.**

El flujo comercial vigente de Humanio usa estas fuentes:

- `outreach-proposals`: primer contacto cold con hallazgos reales y CTA hacia Humanio.
- `package-pricing`: tabla canonica de paquetes.
- `sales-copywriting`: textos comerciales seguros con paquetes actuales.
- `closer-sales`: cierre posterior a interes real o demo entregada.

## Reglas de Seguridad

- NO digas que una pagina o propuesta ya esta lista durante cold outreach.
- NO incluyas links de demo en cold salvo que WebPublisher ya haya verificado una publicacion real.
- NO propongas llamadas como cierre principal. El cierre normal es autoservicio en `https://www.humanio.digital/#paquetes` o escalamiento humano si el prospecto lo pide.
- NO uses paquetes comerciales retirados ni nombres legacy. Los unicos vigentes son Starter, Pro y Business.
- NO uses precios antiguos en MXN.
- NO mandes msg2/msg3 desde esta skill. Los seguimientos dia 3 y dia 7 pertenecen al workflow n8n documentado en `n8n/SEGUIMIENTOS_CRON.md`.

## Paquetes Canonicos

| Paquete | Precio | Uso recomendado |
|---|---:|---|
| Starter | USD 27/mes | Landing + chatbot basico como lead magnet |
| Pro | USD 47/mes | Web + WhatsApp inteligente + automatizaciones basicas |
| Business | USD 97/mes | IA avanzada, integraciones y soporte prioritario |

Para cualquier copy nuevo, consulta `package-pricing` y `sales-copywriting`.
