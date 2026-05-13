---
name: "web-template-system"
description: "Sistema base de landing pages template para demos ligeras de Humanio, con variante futuristic-v1 y reglas de personalización controlada."
slug: "web-template-system"
metadata:
  paperclip:
    slug: "web-template-system"
    skillKey: "web-template-system"
---

# web-template-system

## Propósito

Definir el sistema base de landing pages template para prospectos fríos de Humanio.

## Objetivo

Permitir producir activos web atractivos, consistentes y rápidos con bajo consumo de tokens.

## Cuándo usar

Usar este sistema cuando `delivery_mode = template`.

Esto aplica típicamente a:
- leads outbound provenientes de Scout
- prospectos sin señal explícita de interés
- casos sin prioridad alta
- oportunidades no validadas todavía

## Filosofía

La landing template no es un sitio pobre.
Debe sentirse moderna, limpia, confiable y visualmente fuerte.

La estandarización debe estar en la estructura, no en una apariencia descuidada.

## Regla principal

No diseñes desde cero para cada prospecto.
Usa una base reusable y personaliza solo lo necesario para mantener credibilidad y relevancia.

## Estructura base obligatoria

La landing principal debe incluir siempre:

1. Hero visual fuerte
2. CTA principal visible
3. Propuesta de valor breve
4. Bloque de oportunidad o diagnóstico resumido
5. Sección de solución / servicios
6. Acceso a propuesta
7. CTA final

Además, siempre deben existir:
- `/index.html`
- `/propuesta/index.html`
- `/reporte/index.html`

## Componentes visuales mínimos

La landing template debe incluir, como estándar:

- hero con alto impacto visual
- imagen o video de fondo cuando aporte
- efecto parallax ligero
- transiciones suaves
- interacción ligera de mouse o hover
- jerarquía tipográfica clara
- CTA visible desde arriba del fold

## Personalización mínima obligatoria

Debes adaptar siempre:
- nombre del negocio
- giro
- ciudad o zona
- colores predominantes
- copy principal
- CTA principal
- paquete recomendado
- observaciones clave del diagnóstico

## Qué NO se debe personalizar en exceso

No cambies por prospecto:
- arquitectura base del sitio
- sistema completo de navegación
- estructura general del hero
- lógica completa del layout
- microinteracciones complejas
- sistema visual entero

## Variantes disponibles

### `futuristic-v1` (única variante activa)

Carpeta: `templates/futuristic-v1/`

Características:
- estética moderna, oscura, glass + acentos neon-lite
- hero con video de Pexels y efecto parallax scroll-scrubbed en desktop
- spotlight de mouse en desktop, progreso de scroll, hover luminoso y reveal suave
- fallback a video en loop en mobile / `prefers-reduced-motion`
- 3 páginas listas: `index.html`, `propuesta/index.html`, `reporte/index.html`
- placeholders documentados en `templates/futuristic-v1/MANIFEST.md`
- paleta personalizable por prospecto vía CSS vars (`--accent`, `--accent-2`)

Esta es la única variante activa. No inventes variantes nuevas sin instrucción explícita del CEO.

## Nivel de interacción permitido

Usa `interaction_level` con solo estos valores:
- `low`
- `medium`

Nunca `high` en modo template.

## Límites de complejidad

En modo template:
- no diseñes una pieza artesanal
- no cambies el layout por lucimiento
- no gastes tokens en sofisticación que no cambie el resultado comercial
- no conviertas una landing eficiente en un sitio premium disfrazado
- sí conserva siempre las interacciones base del template (`scroll-video.js`, spotlight, reveal y hover)
- sí usa un video Pexels específico del giro cuando exista, evitando fondos abstractos genéricos
- si Pexels falla, marca `visual_degraded: true` en el handoff y usa fallback visual animado; no entregues una pantalla plana

En demos inbound o `delivery_mode=premier`, aunque uses `futuristic-v1` como base, el resultado debe sentirse más cuidado que un template estándar: hero visual fuerte, video o fallback premium, narrativa más específica y microinteracciones intactas.

## Criterios de calidad

Una buena landing template:
- se ve moderna
- se siente cuidada
- no parece clon barata
- puede producirse rápido
- mantiene credibilidad comercial
- no compite con el modo premier

## Identidad de marca

Humanio es una consultora de Inteligencia Artificial para negocios.

Nunca presentes la propuesta como si Humanio fuera una agencia genérica de páginas web.

Firma correcta:
"Humanio — Inteligencia Artificial para negocios"
