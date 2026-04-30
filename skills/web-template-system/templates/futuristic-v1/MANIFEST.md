# futuristic-v1 — MANIFEST

Template moderno con hero de video Pexels (parallax scroll-scrubbed en desktop, loop en móvil), spotlight de mouse, progreso de scroll y revelado suave de secciones.

## Archivos

```
futuristic-v1/
  index.html              # Landing principal con hero de video
  propuesta/index.html    # Paquetes Starter/Pro/Business
  reporte/index.html      # Diagnóstico digital
  assets/
    styles.css            # Sistema visual completo
    scroll-video.js       # Scroll-scrub del video + mouse/scroll/reveal effects
  MANIFEST.md             # Este archivo
```

## Cómo instanciar

WebBuilder copia toda la carpeta a `/tmp/proposal-{slug}/` y reemplaza los placeholders `{{...}}` en los 3 HTML por los valores del `TEMPLATE_SPEC` y del `PROSPECT_BRIEF`.

## Placeholders — globales (los 3 archivos)

| Placeholder | Origen | Ejemplo |
|---|---|---|
| `{{NOMBRE_NEGOCIO}}` | brief.nombre_negocio | "Meza Dental" |
| `{{NOMBRE_NEGOCIO_URL}}` | nombre_negocio URL-encoded | "Meza%20Dental" |
| `{{CIUDAD}}` | brief.ciudad | "Culiacán" |
| `{{PAIS}}` | brief.pais | "México" |
| `{{GIRO}}` | brief.giro | "Clínica dental" |
| `{{PAQUETE_RECOMENDADO_NOMBRE}}` | brief.paquete_recomendado capitalizado | "Pro" |
| `{{PALETTE_ACCENT}}` | spec.palette.accent (HEX) | "#2dd4bf" |
| `{{PALETTE_ACCENT_2}}` | spec.palette.accent_2 (HEX) | "#818cf8" |
| `{{PALETTE_ACCENT_GLOW_RGB}}` | accent → "R, G, B" sin '#' | "45, 212, 191" |
| `{{TELEFONO_MIGUEL_E164}}` | env TELEFONO_MIGUEL o número comercial de Humanio | "5216671234567" |

## Placeholders — index.html (landing)

| Placeholder | Descripción |
|---|---|
| `{{HERO_VIDEO_URL}}` | URL directa del MP4 de Pexels (campo `video_files[*].link` filtrado por `quality=hd` y `width<=1920`) |
| `{{HERO_POSTER_URL}}` | URL del poster (campo `image` del video Pexels) |
| `{{HERO_HEADLINE_PRE}}` | Texto antes del span con gradiente — ej: "El próximo cliente de" |
| `{{HERO_HEADLINE_ACCENT}}` | Texto con gradiente — ej: "{{NOMBRE_NEGOCIO}}" |
| `{{HERO_HEADLINE_POST}}` | Texto después del span — ej: "ya está buscando en Google." |
| `{{HERO_SUBHEAD}}` | 1–2 líneas con la propuesta de valor breve |
| `{{DIAGNOSTIC_LEAD}}` | Párrafo de intro al diagnóstico (1–2 líneas) |
| `{{STAT_1_VALUE}}` `{{STAT_1_LABEL}}` | ej: "8,400" / "búsquedas mensuales" |
| `{{STAT_2_VALUE}}` `{{STAT_2_LABEL}}` | ej: "#7" / "posición actual en Google Maps" |
| `{{STAT_3_VALUE}}` `{{STAT_3_LABEL}}` | ej: "4.8★" / "promedio de reseñas" |
| `{{HALLAZGOS_INTRO}}` | 1 línea de intro a la lista |
| `{{FINDING_1}}` `{{FINDING_2}}` `{{FINDING_3}}` | Hallazgos cortos, 1 frase cada uno |
| `{{SOL_1_TITLE}}` `{{SOL_1_DESC}}` | Solución 1 — derivada del paquete |
| `{{SOL_2_TITLE}}` `{{SOL_2_DESC}}` | Solución 2 |
| `{{SOL_3_TITLE}}` `{{SOL_3_DESC}}` | Solución 3 |

## Placeholders — propuesta/index.html

| Placeholder | Descripción |
|---|---|
| `{{PROPUESTA_LEAD}}` | 1–2 líneas que conectan diagnóstico ↔ solución |
| `{{PAQUETE_RECOMENDADO_RAZON}}` | Por qué ese paquete específicamente |
| `{{PKG_STARTER_FEATURED_CLASS}}` | ` pkg--featured` si Starter es el recomendado, vacío si no |
| `{{PKG_PRO_FEATURED_CLASS}}` | ídem para Pro |
| `{{PKG_BUSINESS_FEATURED_CLASS}}` | ídem para Business |

> Solo UNO de los 3 lleva `pkg--featured`. Los otros dos quedan vacíos.

## Placeholders — reporte/index.html

| Placeholder | Descripción |
|---|---|
| `{{FECHA_REPORTE}}` | Fecha del reporte, formato "24 de abril de 2026" |
| `{{REPORTE_RESUMEN}}` | Resumen ejecutivo, 2–3 líneas |
| `{{KEYWORD_PRINCIPAL}}` | ej: "dentista en Culiacán" |
| `{{METRIC_BUSQUEDAS}}` | ej: "8,400" |
| `{{METRIC_POSICION}}` | ej: "#7" o "No aparece" |
| `{{METRIC_POSICION_NOTE}}` | Texto debajo del valor |
| `{{METRIC_POSICION_CLASS}}` | `bad` o `good` |
| `{{METRIC_RESENAS_VALUE}}` | ej: "4.8★" |
| `{{METRIC_RESENAS_NOTE}}` | ej: "114 reseñas" |
| `{{METRIC_RESENAS_CLASS}}` | `bad` o `good` |
| `{{METRIC_PRESENCIA_SCORE}}` | ej: "4/10" |
| `{{METRIC_PRESENCIA_NOTE}}` | ej: "tienen GMB pero sin web" |
| `{{METRIC_PRESENCIA_CLASS}}` | `bad` o `good` |
| `{{ANALISIS_GOOGLE}}` | Párrafo |
| `{{ANALISIS_SITIO}}` | Párrafo |
| `{{ANALISIS_REDES}}` | Párrafo |
| `{{ANALISIS_REPUTACION}}` | Párrafo |
| `{{OPORTUNIDAD_LEAD}}` | 1–2 líneas |
| `{{OPORTUNIDAD_1}}` `{{OPORTUNIDAD_2}}` `{{OPORTUNIDAD_3}}` | Items |

## Pexels — selección de video del hero

WebBuilder llama a `https://api.pexels.com/videos/search` con header `Authorization: $PEXELS_API_KEY`.

Query: derivado del giro del prospecto (ej: "dental clinic", "hair salon", "restaurant kitchen", "city street", "advisor meeting"). DesignPlanner provee `hero_video_query` en el TEMPLATE_SPEC.

La query debe favorecer video real y útil para el negocio, no fondos genéricos. Buenas queries:
- restaurante: `restaurant kitchen`, `tacos cooking`, `waiter serving`
- seguros/servicios profesionales: `business consultation`, `city business`, `advisor meeting`
- salud: `modern clinic`, `dental clinic`, `doctor consultation`
- belleza: `beauty salon`, `makeup studio`, `hair stylist`

Evita queries demasiado vagas como `technology`, `business`, `abstract`, salvo que el giro realmente no tenga imagen directa.

Filtros recomendados:
- `orientation=landscape`
- `size=medium` (lo suficientemente fluido sin pesar mucho)
- Del JSON resultante, tomar el primer video con `duration <= 12`
- De `video_files[]`, elegir el que tenga `quality="hd"` y `width<=1920`

**Importante**: `<video preload="metadata">` para que el scroll-scrub no descargue todo de inmediato. El navegador descarga solo lo necesario al ir scrolleando.

## Interacciones incluidas

`scroll-video.js` activa:
- progreso superior de scroll
- spotlight suave siguiendo el mouse en desktop
- hover luminoso en cards y paquetes
- reveal por scroll de secciones principales
- scrub del video hero en desktop
- autoplay loop en móvil, touch y reduced-motion

No agregues texto visible que explique estos efectos. Deben sentirse como parte natural del sitio.

## Paleta — sugerencias por giro

DesignPlanner propone la paleta. Sugerencias rápidas:

| Giro | accent | accent_2 |
|---|---|---|
| Salud / dental / médico | `#2dd4bf` (teal) | `#60a5fa` (blue) |
| Belleza / estética | `#f472b6` (rose) | `#a78bfa` (violet) |
| Restaurante / comida | `#fbbf24` (amber) | `#f87171` (red) |
| Servicios profesionales / legal | `#60a5fa` (blue) | `#818cf8` (indigo) |
| Coaching / consultoría | `#a78bfa` (violet) | `#2dd4bf` (teal) |
| Default / desconocido | `#2dd4bf` | `#818cf8` |

`{{PALETTE_ACCENT_GLOW_RGB}}` se calcula a partir del HEX del accent, ej `#2dd4bf` → `45, 212, 191`.
