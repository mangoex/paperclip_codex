---
name: "qualifier-prospect-auditor"
description: "Auditoría SEO profunda para calificación de prospectos locales"
slug: "qualifier-prospect-auditor"
metadata:
  paperclip:
    slug: "qualifier-prospect-auditor"
    skillKey: "company/HUM/qualifier-prospect-auditor"
  paperclipSkillKey: "company/HUM/qualifier-prospect-auditor"
  skillKey: "company/HUM/qualifier-prospect-auditor"
key: "company/HUM/qualifier-prospect-auditor"
---

# Qualifier Prospect Auditor

Skill de auditoría profunda para Qualifier — Humanio.

Produce un diagnóstico SEO detallado con evidencia específica, análisis competitivo con competidores nombrados, keywords reales con intención, hallazgos técnicos y on-page, y un plan de acción priorizado con fases.

**Output objetivo**: un diagnóstico comparable a una auditoría profesional de consultoría SEO, no un pitch deck genérico.

---

## Inputs requeridos

Antes de comenzar, confirma que tienes:

- Nombre del negocio

- URL del sitio (o "sin-web")

- Giro / industria

- Ciudad / zona geográfica

- Redes sociales detectadas (Instagram, Facebook, etc.)

---

## Proceso de auditoría

### PASO 1 — Análisis del sitio web (si existe)

Usa `firecrawl_scrape` en la URL. Si falla, usa `WebFetch`. Extrae:

**A. Metadatos SEO**

```

- Title tag: texto completo y longitud en caracteres

- Meta description: texto completo y longitud

- H1: texto exacto

- H2s: lista completa

- Canonical URL

- Lang attribute

- Open Graph tags (og:title, og:description, og:image)

```

**B. Contenido**

```

- Servicios mencionados explícitamente

- Ciudades/zonas mencionadas

- Datos de contacto visibles (tel, email, dirección)

- Estimado de palabras en la página

- Testimonios o reseñas embebidas

- Nombre de los profesionales / equipo

```

**C. Señales técnicas**

```

- HTTPS (sí/no)

- Diseño responsive (sí/no — revisar viewport meta)

- CMS detectado (WordPress, Wix, Squarespace, custom…)

- Plugin SEO detectado (Yoast, RankMath, AIOSEO…)

- Velocidad percibida: ¿la página es pesada en HTML?

- Schema markup presente (JSON-LD detectado sí/no)

- Imágenes con alt text (sí/no/parcial)

```

Evalúa cada elemento con: ✅ Correcto | ⚠️ Mejorable | ❌ Ausente/Incorrecto

---

### PASO 2 — Análisis de posicionamiento Google

Simula búsquedas clave y documenta lo que encontrarías:

**Búsquedas a evaluar:**

```

1. "{nombre negocio}"                    → ¿aparece en top 3?

2. "{nombre negocio} {ciudad}"           → ¿aparece con ficha de Google?

3. "{giro} {ciudad}"                     → ¿aparece en Local Pack (mapa)?

4. "{giro} en {ciudad}"                  → posición estimada

5. "mejor {giro} {ciudad}"              → ¿aparece?

```

**Evalúa el Local Pack (mapa de 3):**

- ¿Tiene Google Business Profile?

- ¿Ficha completa (horarios, fotos, descripción)?

- ¿Cuántas reseñas? ¿Calificación?

- ¿Responde a reseñas negativas?

- ¿Aparece en el mapa para su giro + ciudad?

---

### PASO 3 — Investigación de keywords locales

Para el giro y ciudad del prospecto, genera la tabla de keywords de mayor valor:

**Patrones de keywords transaccionales (mayor prioridad):**

```

[giro] [ciudad]

[giro] en [ciudad]

mejor [giro] [ciudad]

[giro] cerca de mí

[giro] económico [ciudad]

[giro] urgencias [ciudad]

[servicio específico] [ciudad]

[servicio específico] precio [ciudad]

```

**Tabla de keywords a generar:**

| Keyword | Intención | Volumen estimado | Dificultad | Prioridad |

|---------|-----------|-----------------|------------|-----------|

| [keyword] | Transaccional | Alto/Medio/Bajo | Alta/Media/Baja | 1-5 |

Clasifica por intención:

- **Transaccional** — quiere contratar ahora (prioridad máxima)

- **Comercial** — está comparando opciones

- **Informacional** — está aprendiendo

Identifica las **5 keywords prioritarias** que el prospecto debería rankear en 90 días.

---

### PASO 4 — Análisis competitivo (con nombres reales)

Identifica 3-4 competidores directos que SÍ aparecen en Google para las keywords principales.

Para cada competidor, documenta:

| Competidor | URL | Posición Google | Local Pack | Reseñas | Ventaja detectada |

|------------|-----|----------------|-----------|---------|------------------|

| [nombre] | [url] | #[X] | ✅/❌ | [N] reseñas [X]/5 | [ventaja específica] |

**Brechas de oportunidad vs competencia:**

- ¿Qué hacen ellos que el prospecto no hace?

- ¿En qué puede el prospecto superarlos? (precio, especialización, reputación, ubicación)

---

### PASO 5 — Análisis de redes sociales

| Canal | ¿Existe? | Seguidores | Última publicación | Engagement | Problema detectado |

|-------|---------|-----------|-------------------|-----------|-------------------|

| Instagram | ✅/❌ | [N] | [fecha o "hace X meses"] | Alto/Medio/Bajo/Nulo | [descripción] |

| Facebook | ✅/❌ | [N] | [fecha] | Alto/Medio/Bajo/Nulo | [descripción] |

| TikTok | ✅/❌ | [N] | [fecha] | — | [descripción] |

| WhatsApp Business | ✅/❌ | — | — | — | [sin catálogo/sin auto-respuesta] |

---

### PASO 6 — Calcular score y generar reporte

Una vez completados los pasos 1-5, genera el reporte con el formato siguiente.

---

## Formato de output del diagnóstico

```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DIAGNÓSTICO DE PRESENCIA DIGITAL — [NOMBRE NEGOCIO]

[Giro] | [Ciudad] | [Fecha]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCORE DE OPORTUNIDAD: [X]/10

Desglose del score:

[████░░░░░░] Presencia web       [X]/4 pts

[██░░░░░░░░] Redes sociales      [X]/2 pts

[█░░░░░░░░░] WhatsApp Business   [X]/1 pt

[█░░░░░░░░░] Reputación/Reseñas  [X]/1 pt

[██░░░░░░░░] Posicionamiento     [X]/2 pts (bonus)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 1 — DIAGNÓSTICO WEB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```

**Si tiene web — tabla de hallazgos on-page:**

```

| Elemento SEO       | Estado | Hallazgo específico                  | Impacto |

|--------------------|--------|---------------------------------------|---------|

| Title tag          | ❌/⚠️/✅ | "[título actual encontrado]"         | Alto    |

| Meta description   | ❌/⚠️/✅ | Ausente / "[texto actual]"            | Alto    |

| H1                 | ❌/⚠️/✅ | "[H1 actual]" — no incluye ciudad     | Alto    |

| Contenido          | ❌/⚠️/✅ | ~[N] palabras, sin mencionar [ciudad] | Medio   |

| HTTPS              | ❌/✅   | [sí/no]                               | Crítico |

| Mobile-friendly    | ❌/⚠️/✅ | [observación]                         | Alto    |

| Schema markup      | ❌/✅   | Sin LocalBusiness schema              | Alto    |

| Datos de contacto  | ❌/⚠️/✅ | [teléfono visible / dirección ausente]| Alto    |

| Velocidad percibida| ❌/⚠️/✅ | [observación]                         | Medio   |

| CMS/Plugin SEO     | ⚠️/✅  | [WordPress sin plugin SEO activo]     | Medio   |

```

**Si no tiene web:**

```

Sin página web propia. Score automático +4 pts.

Presencia digital limitada a: [listar canales detectados]

Oportunidad: capturar demanda activa sin competencia web propia.

```

```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 2 — POSICIONAMIENTO GOOGLE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Google Business Profile:   ❌ Sin ficha / ⚠️ Incompleta / ✅ Completa

Aparece en Local Pack:      ❌ No / ✅ Sí — posición [X]

Búsqueda "{giro} {ciudad}": ❌ No aparece en pág. 1

Búsqueda "{nombre}":        ✅ Aparece / ❌ No aparece

QUIÉN DOMINA EL LOCAL PACK AHORA:

1. [Competidor A] — [N] reseñas, [X]/5 ⭐

2. [Competidor B] — [N] reseñas, [X]/5 ⭐

3. [Competidor C] — [N] reseñas, [X]/5 ⭐

→ [Nombre prospecto] NO aparece en ninguna de estas posiciones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 3 — KEYWORDS DE MAYOR OPORTUNIDAD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Top 5 keywords transaccionales para [giro] en [ciudad]:

| # | Keyword                        | Búsquedas/mes | Intención      | Dificultad |

|---|-------------------------------|--------------|----------------|-----------|

| 1 | [keyword 1]                   | ~[N]         | Transaccional  | Media     |

| 2 | [keyword 2]                   | ~[N]         | Transaccional  | Media     |

| 3 | [keyword 3]                   | ~[N]         | Comercial      | Baja      |

| 4 | [keyword 4]                   | ~[N]         | Transaccional  | Alta      |

| 5 | [keyword 5]                   | ~[N]         | Informacional  | Baja      |

Volumen total estimado combinado: ~[N] búsquedas/mes en [ciudad].

[Nombre prospecto] actualmente captura: 0% de este tráfico.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 4 — ANÁLISIS COMPETITIVO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMPETIDORES QUE SÍ APARECEN EN GOOGLE:

| Competidor        | Web | GBP | Reseñas | Pos. Google | Ventaja vs [prospecto] |

|-------------------|-----|-----|---------|-------------|------------------------|

| [Competidor A]    | ✅  | ✅  | [N] ⭐[X]| #1-3        | [ventaja específica]   |

| [Competidor B]    | ✅  | ✅  | [N] ⭐[X]| #4-6        | [ventaja específica]   |

| [Competidor C]    | ❌  | ✅  | [N] ⭐[X]| Local Pack  | Solo por reseñas       |

FORTALEZAS DE [PROSPECTO] vs COMPETENCIA:

• [Fortaleza 1 — específica y real]

• [Fortaleza 2]

BRECHA A CERRAR:

• [Brecha crítica 1 — específica]

• [Brecha crítica 2]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 5 — REDES SOCIALES Y PRESENCIA DIGITAL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Tabla de redes con hallazgos específicos por canal]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 6 — LO QUE ESTÁS PERDIENDO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

En [ciudad], ~[N] personas buscan "[keyword principal]" cada mes.

Sin presencia digital optimizada, el 100% de esas búsquedas van a la competencia.

Estimado de clientes potenciales perdidos por mes:

- Si captura el 3% del tráfico objetivo: ~[N] leads/mes

- Si captura el 10% del tráfico objetivo: ~[N] leads/mes

- Ticket promedio estimado del giro: [MONEDA_LOCAL] [X]

- Valor mensual estimado no captado: [MONEDA_LOCAL] [X] - [Y]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 7 — QUICK WINS (ejecutables en < 7 días)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| # | Acción                                  | Esfuerzo | Impacto | Responsable   |

|---|-----------------------------------------|---------|---------|---------------|

| 1 | Crear/completar Google Business Profile | Bajo    | Alto    | Cliente       |

| 2 | Activar WhatsApp Business               | Bajo    | Alto    | Cliente       |

| 3 | [Quick win específico del diagnóstico]  | Bajo    | Alto    | Humanio/Cliente|

| 4 | [Quick win específico]                  | Bajo    | Medio   | Humanio       |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECCIÓN 8 — PLAN DE ACCIÓN PRIORIZADO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FASE 1 — Fundamentos (Semanas 1-2):

[ ] [Acción específica 1]

[ ] [Acción específica 2]

[ ] [Acción específica 3]

FASE 2 — Visibilidad (Semanas 3-6):

[ ] [Acción específica 4]

[ ] [Acción específica 5]

FASE 3 — Crecimiento (Mes 2-3):

[ ] [Acción específica 6]

[ ] [Acción específica 7]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HANDOFF → QUALIFIER (score y propuesta)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score calculado: [X]/10

Clasificación: [Oportunidad inmediata / Buena oportunidad / Monitorear / No prioritario]

Principal argumento de venta: [1 frase específica basada en los hallazgos]

Servicio de entrada recomendado: [Web / GBP + SEO local / Meta Ads / WhatsApp Bot]

```

---

## Reglas de calidad del diagnóstico

- **Nunca uses frases genéricas** como "la empresa necesita mejorar su presencia digital". Siempre cita el hallazgo específico: "El title tag actual dice '[texto]' y no incluye la ciudad ni el servicio principal."

- **Marca claramente** los datos estimados vs datos verificados: usa "(estimado)" cuando no tengas datos reales

- **Nombra a los competidores** — el análisis sin nombres específicos no tiene valor comercial

- **El volumen de búsquedas** puede estimarse razonablemente para ciudades mexicanas según el giro:

  - Dentistas en ciudad >500k hab: 3,000-10,000 búsquedas/mes para keyword principal

  - Restaurantes en ciudad media: 1,000-5,000 búsquedas/mes

  - Abogados en ciudad >300k hab: 500-2,000 búsquedas/mes

  - Siempre marca como "(estimado)"

- **Si firecrawl falla**, usa WebFetch y nota que el análisis es estático (sin JavaScript renderizado)

- **Si no hay datos suficientes** de competidores, documenta las búsquedas que intentaste y lo que encontraste

---

## Criterios de estimación de volumen de búsqueda

Para estimar búsquedas mensuales en ciudades mexicanas sin herramientas de pago:

| Giro | Ciudad >1M hab | Ciudad 300k-1M | Ciudad <300k |

|------|---------------|----------------|-------------|

| Dentista | 8,000-15,000 | 3,000-8,000 | 500-3,000 |

| Restaurante (categoría) | 10,000-30,000 | 5,000-15,000 | 1,000-5,000 |

| Abogado | 2,000-5,000 | 500-2,000 | 100-500 |

| Mecánico automotriz | 3,000-8,000 | 1,500-4,000 | 300-1,500 |

| Plomero | 2,000-6,000 | 800-2,500 | 200-800 |

| Médico general | 5,000-12,000 | 2,000-6,000 | 400-2,000 |

| Gimnasio/Fitness | 3,000-8,000 | 1,000-4,000 | 200-1,000 |

| Salón de belleza | 4,000-10,000 | 1,500-5,000 | 300-1,500 |

Culiacán tiene ~1M de habitantes — usa la columna de ciudad >1M.

Siempre indica "(estimado — sin herramienta de keywords conectada)".
