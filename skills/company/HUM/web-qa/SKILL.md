---
name: "web-qa"
description: "Valida HTML (sitios y emails) antes de publicar: estructura, links, placeholders, consistencia de marca."
slug: "web-qa"
title: "Web QA — Validación de HTML antes de publicar | Humanio"
metadata:
  paperclip:
    slug: "web-qa"
    skillKey: "company/HUM/web-qa"
  paperclipSkillKey: "company/HUM/web-qa"
key: "company/HUM/web-qa"
---

# Web QA — Validación de HTML antes de publicar | Humanio

Identidad
Eres el módulo de control de calidad de los sitios web que genera el DesignPlanner para prospectos de Humanio. Tu trabajo es revisar TODOS los archivos HTML antes de que se publiquen en surge.sh, y detectar errores que arruinen la primera impresión con el prospecto.

Cuándo se ejecuta
SIEMPRE después de que DesignPlanner genera el HTML del sitio y ANTES de publicar en surge.sh.
También se ejecuta sobre los emails HTML (draft-email.html, seguimiento-2-email.html, seguimiento-3-email.html).

Checklist de validación

1. ESTRUCTURA HTML BÁSICA
- [ ] DOCTYPE declarado
- [ ] <html lang="es"> presente
- [ ] <meta charset="UTF-8"> en el head
- [ ] <meta name="viewport"> para responsive
- [ ] <title> presente y descriptivo (no genérico)
- [ ] Todos los tags abiertos están cerrados
- [ ] No hay tags anidados incorrectamente

2. HERO / ENCABEZADOS (CRÍTICO)
- [ ] El contenido del h1 NO contiene <span class="..."> si hay animación JS por palabras
  - RAZÓN: El JS de animación hace split(' ') del innerHTML del h1 y envuelve cada palabra en un nuevo span. Si hay spans internos con class="accent" o class="dim", se destruyen y el código se renderiza como texto visible.
  - SOLUCIÓN: Usar <em> o <i> para estilizar partes del h1, o aplicar CSS con ::first-line, text gradients, o envolver en <strong> (que no se rompe al hacer split por espacios de una sola palabra).
  - ALTERNATIVA: Si necesitas colores diferentes dentro del h1, separa en múltiples elementos h1/p en lugar de spans dentro de un solo h1.
- [ ] Los h2 tampoco deben tener spans internos si hay animación JS que manipule el innerHTML
- [ ] Verificar visualmente que NO aparece texto como: class="accent">, class="dim">, style="color:

3. COUNTERS / ESTADÍSTICAS
- [ ] Cada elemento con clase .cnt tiene un atributo data-target con valor numérico
- [ ] El valor de data-target coincide con el dato real (ej: 5 sucursales = data-target="5", no data-target="0")
- [ ] La función countUp() está conectada al IntersectionObserver
- [ ] Verificar que los números se renderizan correctamente (no muestran "0" permanentemente)

4. ENCODING UTF-8
- [ ] Todos los archivos guardados en UTF-8
- [ ] Caracteres especiales del español se renderizan correctamente: á é í ó ú ñ ü ¿ ¡
- [ ] NO hay caracteres corruptos como: Ã³ Ã© Ã¡ Ã± ï¿½ péra
- [ ] El símbolo de estrella es ★ (U+2605), no ⅋ (U+214B) ni otros caracteres rotos
- [ ] Los emojis (si se usan) se renderizan correctamente

5. LINKS Y URLS
- [ ] Todas las URLs son válidas y accesibles
- [ ] Los links de WhatsApp usan formato correcto: https://wa.me/52XXXXXXXXXX?text=...
- [ ] El texto del parámetro ?text= está URL-encoded correctamente
- [ ] Los links internos (#servicios, #contacto, etc.) apuntan a IDs que existen en la página
- [ ] El link "Ver propuesta" desde la página principal apunta a /propuesta/ y existe
- [ ] No hay links rotos ni 404s

6. RESPONSIVE
- [ ] Media queries presentes para pantallas < 768px
- [ ] Grids de 2+ columnas colapsan a 1 columna en móvil
- [ ] Textos no se desbordan del viewport en móvil
- [ ] Botones y CTAs tienen tamaño táctil adecuado (mínimo 44x44px)
- [ ] El navbar funciona en móvil (hamburger menu o collapse)

7. INTEGRACIÓN PROPUESTA + REPORTE EN SITIO
- [ ] La propuesta comercial está accesible como sección del sitio o como /propuesta/
- [ ] El reporte SEO está accesible como sección del sitio o como /reporte/
- [ ] Ambas secciones están en el navbar como links
- [ ] El estilo visual de propuesta y reporte es consistente con el sitio principal
- [ ] La propuesta incluye los 3 paquetes canonicos vigentes: Starter (USD 27/mes), Pro (USD 47/mes), Business (USD 97/mes)

8. JAVASCRIPT
- [ ] Librería AOS cargada correctamente (CDN link válido)
- [ ] VanillaTilt cargada correctamente (si se usa)
- [ ] No hay errores de consola al cargar la página
- [ ] Las animaciones de scroll funcionan
- [ ] El cursor personalizado (si existe) no interfiere con la usabilidad
- [ ] El parallax no causa layout shifts
- [ ] En demos inbound/premier, el hero conserva video Pexels o fallback premium documentado
- [ ] En `futuristic-v1`, existen `.scroll-progress`, `.cursor-spotlight` y `assets/scroll-video.js`
- [ ] Si `visual_degraded: true`, el resultado sigue teniendo suficiente calidad visual; si se ve plano, FAIL

9. EMAILS HTML
- [ ] <span style="..."> NO escrito como <style="..."> (error común)
- [ ] El email se renderiza correctamente sin hojas de estilo externas
- [ ] Max-width de 600px para compatibilidad con clientes de email
- [ ] Links funcionan y apuntan a URLs correctas
- [ ] La firma incluye "Humanio — Inteligencia Artificial para negocios" (no "Humanio")
- [ ] El charset es UTF-8

10. CONTENIDO Y COPY
- [ ] El nombre del negocio está escrito correctamente en TODAS las instancias
- [ ] La ciudad es correcta
- [ ] Los datos de contacto (teléfono, dirección) son reales
- [ ] El horario de atención es correcto
- [ ] Los precios en la propuesta son coherentes entre sí (tier 1 < tier 2 < tier 3)
- [ ] El tier 3 incluye servicios de IA (chatbot, automatización, agente)
- [ ] No hay texto placeholder visible ({VARIABLE_NAME}, Lorem ipsum, TODO, etc.)
- [ ] No hay código fuente visible como texto en la página renderizada

Proceso de validación

Paso 1: Validación automática
Ejecutar estas verificaciones programáticamente sobre cada archivo HTML:

```bash
# Verificar encoding
file -bi archivo.html  # debe incluir "charset=utf-8"

# Buscar tags rotos o código visible como texto
grep -n 'class="accent">' archivo.html | grep -v '<'  # no debería encontrar matches fuera de tags
grep -n 'class="dim">' archivo.html | grep -v '<'
grep -n '<style="' archivo.html  # error común: <style= en lugar de <span style=

# Buscar caracteres corruptos
grep -Pn '[\x80-\xff]' archivo.html | grep -v 'charset\|utf-8\|á\|é\|í\|ó\|ú\|ñ\|ü\|★'

# Buscar placeholders sin reemplazar
grep -n '{[A-Z_]*}' archivo.html

# Verificar que data-target no sea 0 en counters
grep -n 'data-target="0"' archivo.html  # sospechoso si debería tener un valor real

# Verificar que el símbolo de estrella es correcto
grep -n '⅋' archivo.html  # NO debe existir
```

Paso 2: Revisión visual
Abrir la página en un navegador y verificar:
- El hero se renderiza sin código visible
- Los counters muestran números reales (no 0)
- Los links funcionan
- Se ve bien en móvil (simular con DevTools)
- La propuesta y el reporte son accesibles desde el navbar

Paso 3: Reporte de errores
Si se encuentran errores, generar reporte estructurado:

```
== QA REPORT — {NOMBRE_NEGOCIO} ==
Fecha: {FECHA}
Archivos revisados: {LISTA}

ERRORES CRÍTICOS (bloquean publicación):
1. [archivo:línea] Descripción del error
   → Corrección sugerida

ADVERTENCIAS (publicar pero corregir):
1. [archivo:línea] Descripción
   → Sugerencia

PASÓ VALIDACIÓN:
✅ Estructura HTML
✅ Encoding UTF-8
✅ Links válidos
...

RESULTADO: ✅ LISTO PARA PUBLICAR / ❌ REQUIERE CORRECCIÓN
```

Errores conocidos y sus correcciones

Error: class="accent"> visible como texto en el hero
Causa: <span class="accent"> dentro de h1 que tiene animación JS por palabras
Fix: Cambiar <span class="accent">texto</span> por <em>texto</em> y estilizar em con CSS:
  h1 em { color: var(--accent); font-style: normal; }

Error: Counters muestran 0
Causa: data-target no definido o el IntersectionObserver no encuentra .stats
Fix: Verificar que los elementos con .cnt tienen data-target="N" con el valor correcto
     Verificar que el contenedor tiene clase .stats

Error: <style="color:..." en lugar de <span style="color:..."
Causa: Typo al generar HTML del email
Fix: Buscar y reemplazar <style=" por <span style="

Error: Caracteres ⅋ en lugar de ★
Causa: Encoding incorrecto al generar el archivo
Fix: Reemplazar ⅋ por ★ (U+2605)

Error: Caracteres corruptos (Ã³, péra)
Causa: Archivo generado sin encoding UTF-8 correcto
Fix: Regenerar el archivo asegurando UTF-8, o convertir: iconv -f ISO-8859-1 -t UTF-8

Error: Propuesta y reporte no accesibles desde navbar
Causa: DesignPlanner no los integró como secciones del sitio
Fix: Agregar links en el navbar que apunten a /propuesta/ y /reporte/ o a secciones #propuesta #reporte dentro de la misma página
