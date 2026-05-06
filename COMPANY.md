---
name: Humanio
schema: agentcompanies/v1
slug: humanio
---

# Humanio — Inteligencia Artificial para negocios

Consultora de Inteligencia Artificial que acompaña a pymes en su transformación digital. Operamos dos rutas comerciales coordinadas: prospección outbound por giro y ciudad, e inbound por WhatsApp cuando un prospecto pide una propuesta. Trabajamos en México, Colombia, Perú y Argentina.

> Humanio es una consultora de IA, NO una agencia de marketing. La web y el SEO son el punto de entrada (lead magnet), pero el negocio real es automatización, agentes de IA y chatbots.

## Modelo de negocio

Vendemos paquetes de suscripción mensual desde `https://www.humanio.digital/#paquetes`. El checkout se procesa con Hotmart: el precio base es USD y Hotmart muestra el monto final, moneda local y métodos disponibles según el país/ubicación del comprador.

| Paquete | Precio | Incluye |
|---------|--------|---------|
| **Starter** | $27 USD/mes | Página web profesional + enlace WhatsApp + formulario contacto |
| **Pro** | $47 USD/mes | Todo Starter + Chatbot WhatsApp con info del negocio |
| **Business** | $97 USD/mes | Todo Pro + Chatbot IA con agendamiento automático de citas |

Regla internacional: no prometas un método de pago específico por país. Di que Hotmart mostrará las opciones disponibles en el checkout.

## Pipeline

### 1. Outbound por giro y ciudad

Se activa cuando el Board/CEO pide algo como: "prospecta 10 dentistas en Guadalajara".

```text
CEO → Scout → Qualifier → Outreach → Closer
                              ↘ DataAnalyst
```

En esta ruta NO se construye sitio ni se publica demo al inicio. Outreach envía WhatsApp/email con 3-4 hallazgos reales del Qualifier y un CTA hacia Humanio. En piloto, Outreach puede pedir a ConversationManager que ejecute o prepare el contacto con `event_type: outbound_contact_request`. Si el prospecto responde con interés, ConversationManager o n8n despierta al CEO/Closer para intake y demo.

### 2. Inbound o demo solicitada por WhatsApp

Se activa cuando un prospecto contacta por WhatsApp, responde a un mensaje, o el bot Hannia/n8n crea un ticket urgente porque el prospecto quiere propuesta.

```text
WhatsApp/n8n → ConversationManager (piloto) → CEO/Closer → DesignPlanner → WebBuilder → WebQA → WebPublisher → Closer/Outreach
                                                                                         ↘ DataAnalyst
```

En esta ruta no trabaja Scout salvo que Closer necesite enriquecer información nueva. La demo se marca como `premier`, se construye una propuesta web, se publica, y Closer/Outreach entregan la URL y programan seguimiento comercial.

## Equipo de agentes

| Agente | Rol | Responsabilidad |
|--------|-----|-----------------|
| CEO | Coordinador | Asigna tareas, aprueba propuestas, monitorea pipeline |
| Scout | Prospectador | Encuentra negocios sin presencia digital en LATAM |
| Qualifier | Analista SEO | Califica prospectos (score 1-10), recomienda paquete óptimo |
| DesignPlanner | Dirección creativa | Planifica demos solicitadas; no participa en cold sin interés |
| WebBuilder | Constructor web | Construye demos/propuestas cuando Closer dispara el flujo |
| WebQA | Auditor web | Valida propuesta, URLs, marca y contenido antes de publicar |
| WebPublisher | Publicador | Publica demos aprobadas en Surge.sh y registra estado |
| Outreach | Comercial | Envía primer contacto outbound y puede apoyar entrega/follow-up |
| ConversationManager | Conversaciones | Atiende Chatwoot/WhatsApp, captura datos, enruta al CEO y ejecuta contacto en piloto seguro |
| Closer | Cerrador de ventas | Manejo de respuestas, demo intake, seguimiento y cierre consultivo |
| DataAnalyst | Analista de datos | Monitorea MRR, churn, LTV, conversión por paquete/país/giro |

## Flujo de trabajo

1. CEO recibe solicitud outbound: "prospectar {giro} en {ciudad}, {país}"
2. Scout investiga y genera lista de prospectos con datos de contacto
3. Qualifier analiza presencia digital, genera score, paquete recomendado y hallazgos textuales
4. Outreach envia primer contacto por WhatsApp/email con hallazgos y CTA; en piloto puede delegar el envio a ConversationManager
5. ConversationManager/n8n detecta respuesta y la convierte en evento para CEO/Closer
6. Closer espera respuesta, maneja objeciones y solicita datos si el prospecto quiere demo
7. Si hay demo o inbound urgente, CEO/Closer despierta a DesignPlanner y empieza el flujo web
8. WebBuilder/WebQA/WebPublisher construyen, validan y publican la propuesta
9. Closer/Outreach/ConversationManager entregan la URL y programan seguimiento
10. DataAnalyst genera reportes semanales de MRR, churn, conversion y recomendaciones

## Mercado objetivo

Pymes en Latinoamérica (México, Colombia, Perú, Argentina) que no tienen presencia digital o la tienen deficiente: estéticas, dentistas, restaurantes, abogados, inmobiliarias, veterinarias, consultorios, gimnasios, coaches, etc.

## Firma oficial

> Humanio — Inteligencia Artificial para negocios
