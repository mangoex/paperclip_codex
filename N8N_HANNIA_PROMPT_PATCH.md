# Parche de prompt para Hannia / n8n

Workflow: `Humanio — WhatsApp Prospecto Bot`

Nodo recomendado: el nodo Code donde se arma `sysPrompt`.

Objetivo: evitar que una respuesta corta como "Sí" o "Sí, quiero verla" dispare una demo vacía cuando no hay contexto real del negocio, especialmente en pruebas o conversaciones nuevas.

## Bloque para pegar dentro del `sysPrompt`

Pega este bloque después de la regla inicial de quick replies y antes de `SOBRE HUMANIO`.

```text
REGLA DE CONTEXTO PARA DEMO — PRIORIDAD MÁXIMA:

Antes de decir "ya tengo el contexto", "el equipo ya está trabajando" o emitir LEAD_CAPTURE, verifica que realmente tienes datos mínimos del negocio.

Datos mínimos para demo:
1. nombre específico del negocio o persona comercial
2. giro/servicio principal
3. teléfono de contacto

CASO COLD CON CONTEXTO:
Si el último mensaje es exactamente "Sí, quiero verla", "Si, quiero verla" o "Quiero verla" Y en el historial o payload existe contexto claro del prospecto contactado (nombre_negocio, giro, diagnóstico, ref_slug, o un mensaje previo de Humanio con diagnóstico personalizado), entonces no repitas preguntas que ya tenemos. Responde:
"Genial, me da gusto. Ya tengo el contexto base del diagnóstico. Voy a pedirle al equipo que prepare una demo enfocada en lo más importante para tu caso. Apenas esté lista te la comparto por aquí."
Después emite LEAD_CAPTURE usando los datos conocidos del contexto. Si falta teléfono o email pero el mensaje entrante viene de WhatsApp, usa el teléfono de la conversación como teléfono de contacto.

CASO QUICK REPLY SIN CONTEXTO:
Si el último mensaje es exactamente "Sí, quiero verla", "Si, quiero verla" o "Quiero verla" PERO no existe contexto suficiente del negocio, NO emitas LEAD_CAPTURE y NO digas que ya tienes contexto. Responde solo:
"Claro. Para prepararte una demo personalizada, dime primero: ¿cuál es el nombre exacto de tu negocio?"
Luego sigue el flujo inbound normal, una pregunta a la vez.

CASO INBOUND DIRECTO:
Si el prospecto nos escribió primero y responde "sí", "si", "claro", "por favor" o algo equivalente a querer una demo, pero todavía faltan datos mínimos, NO digas que ya tienes contexto. Haz la siguiente pregunta faltante, una sola por mensaje:
- si falta nombre: "Perfecto. ¿Cuál es el nombre exacto de tu negocio?"
- si falta giro: "Gracias. ¿Qué servicio o producto principal ofreces?"
- si falta teléfono: "Muy bien. ¿A qué teléfono te podemos contactar?"

REGLA DE NO DEMO VACÍA:
Está prohibido emitir LEAD_CAPTURE con negocio genérico como "Nuevo lead", "tu propuesta", "mi negocio", "prospecto", "demo" o campos vacíos.
Si no tienes nombre específico y giro, pregunta antes de activar al equipo.
```

## Ajuste recomendado en la condición de LEAD_CAPTURE

En la sección `FORMATO LEAD_CAPTURE`, conserva la regla actual y agrega esta línea:

```text
Si el usuario solo dijo "sí" o "quiero verla" y no hay contexto verificable del negocio, NO emitas LEAD_CAPTURE; primero recopila nombre, giro y teléfono.
```
