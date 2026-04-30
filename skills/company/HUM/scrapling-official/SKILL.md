---
name: "scrapling-official"
description: "Scraping web avanzado con Scrapling (StealthyFetcher, DynamicFetcher, Fetcher) — bypass anti-bot, SPAs y extracción resiliente. Con fallback a Firecrawl."
slug: "scrapling-official"
title: "Scrapling — Scraping Web Avanzado | Humanio"
metadata:
  paperclip:
    slug: "scrapling-official"
    skillKey: "company/HUM/scrapling-official"
  paperclipSkillKey: "company/HUM/scrapling-official"
key: "company/HUM/scrapling-official"
---

# Scrapling — Scraping Web Avanzado | Humanio

## Identidad

Esta skill te enseña a usar **Scrapling** (librería Python open-source de D4Vinci) como herramienta principal para extraer información de sitios web. Scrapling es resiliente a cambios de DOM, bypasea la mayoría de sistemas anti-bot (Cloudflare, Datadome, PerimeterX) y maneja SPAs con JavaScript.

Úsala siempre antes que Firecrawl. Firecrawl queda como **fallback** cuando Scrapling falla.

## Cuándo usar cada fetcher

Scrapling expone tres fetchers. Elige según el sitio:

| Fetcher | Cuándo usarlo | Anti-bot | Velocidad |
|---|---|---|---|
| `Fetcher` | Sitios estáticos normales (sin JS, sin protección) | Básico | Muy rápida |
| `StealthyFetcher` | Sitios con Cloudflare / Datadome / bot detection | Alto (Camoufox + fingerprint real) | Media |
| `DynamicFetcher` | SPAs (React/Vue/Angular) — requiere esperar JS | Medio (Playwright) | Lenta |

**Regla práctica:**
1. Prueba `Fetcher` primero (es el más rápido).
2. Si recibes 403, 503, o captcha → cambia a `StealthyFetcher`.
3. Si el HTML viene vacío o sin los datos (SPA) → cambia a `DynamicFetcher`.
4. Si los 3 fallan → fallback a Firecrawl MCP (si la env var `FIRECRAWL_API_KEY` está configurada).

## Configuración del fetcher por defecto

La variable de entorno `SCRAPLING_DEFAULT_FETCHER` define cuál usar cuando no especifiques:

- `Fetcher` (default)
- `StealthyFetcher`
- `DynamicFetcher`

## Instalación (ya debe estar en el contenedor)

```bash
pip install scrapling
scrapling install   # descarga los navegadores necesarios para Stealthy/Dynamic
```

Verifica con:

```bash
python -c "from scrapling import Fetcher, StealthyFetcher, DynamicFetcher; print('OK')"
```

## Uso — Ejemplos canónicos

### 1. Fetcher básico (sitios estáticos)

```python
from scrapling import Fetcher

page = Fetcher.get("https://example.com", stealthy_headers=True)

# Selectores resilientes (CSS o XPath)
title = page.css_first("h1").text
links = page.css("a::attr(href)")
price = page.css_first(".price").re_first(r"\$([\d,]+)")
```

### 2. StealthyFetcher (bypass anti-bot)

```python
from scrapling import StealthyFetcher

page = StealthyFetcher.fetch(
    "https://sitio-protegido.com",
    headless=True,
    network_idle=True,      # espera a que termine el tráfico de red
    block_images=True,      # más rápido
    humanize=True,          # simula movimientos de mouse humanos
)

emails = page.css("a[href^='mailto:']::attr(href)")
```

### 3. DynamicFetcher (SPAs con JavaScript)

```python
from scrapling import DynamicFetcher

page = DynamicFetcher.fetch(
    "https://app-react.com/dashboard",
    headless=True,
    wait_selector="[data-loaded='true']",   # espera a que aparezca un selector
    network_idle=True,
)

items = page.css(".card-item")
for item in items:
    print(item.css_first(".card-title").text)
```

### 4. Auto-match (selectores resilientes a cambios de DOM)

Scrapling guarda un "fingerprint" del elemento. Si el sitio cambia la clase CSS, Scrapling lo vuelve a encontrar:

```python
# Primera vez: identifica el elemento y guarda el fingerprint
page = Fetcher.get("https://site.com", auto_match=True)
button = page.css_first("button.buy-now", auto_save=True)

# Semanas después: si la clase cambió a "btn-purchase", igual lo encuentra
page = Fetcher.get("https://site.com", auto_match=True)
button = page.css_first("button.buy-now", auto_match=True)  # ✓ funciona
```

## Patrones recomendados para prospección (Scout/Qualifier)

### Buscar emails en una web de empresa

```python
from scrapling import StealthyFetcher
import re

def extract_emails(url: str) -> list[str]:
    page = StealthyFetcher.fetch(url, network_idle=True, block_images=True)
    # Busca en body + atributos mailto
    text = page.html_content
    mailto = [a.attrib.get("href", "").replace("mailto:", "")
              for a in page.css("a[href^='mailto:']")]
    regex_emails = re.findall(r"[\w\.-]+@[\w\.-]+\.\w+", text)
    return list(set(mailto + regex_emails))
```

### Detectar stack tecnológico (frontend/CMS)

```python
page = Fetcher.get(url)
html = page.html_content.lower()

stack = {
    "wordpress": "wp-content" in html or "wp-includes" in html,
    "shopify": "cdn.shopify.com" in html,
    "next.js": "__next_data__" in html or "_next/static" in html,
    "react": "react" in html and "root" in html,
    "webflow": "webflow.com" in html,
}
```

### Auditar SEO básico

```python
page = Fetcher.get(url)

seo = {
    "title": page.css_first("title").text if page.css_first("title") else None,
    "meta_description": page.css_first("meta[name='description']::attr(content)"),
    "h1_count": len(page.css("h1")),
    "og_image": page.css_first("meta[property='og:image']::attr(content)"),
    "canonical": page.css_first("link[rel='canonical']::attr(href)"),
    "lang": page.css_first("html::attr(lang)"),
}
```

## Rate limits y buenas prácticas

- **Pausa entre requests al mismo dominio:** 2-5 segundos mínimo
- **Nunca** hagas scraping en paralelo al mismo dominio (usa una cola secuencial)
- **User-Agent rotativo:** Scrapling ya lo hace con `stealthy_headers=True` / `StealthyFetcher`
- **Respeta `robots.txt`** (revísalo antes con `Fetcher.get("https://sitio.com/robots.txt")`)
- **Cachea localmente** resultados para no re-scrapear el mismo sitio dentro de la misma sesión

## Errores comunes y cómo resolverlos

| Error | Causa | Solución |
|---|---|---|
| `403 Forbidden` | Anti-bot te detectó | Cambia a `StealthyFetcher` con `humanize=True` |
| `503 Service Unavailable` | Cloudflare challenge | `StealthyFetcher` + `network_idle=True` |
| HTML vacío / sin datos | SPA que carga con JS | Cambia a `DynamicFetcher` con `wait_selector` |
| `TimeoutError` | Sitio lento | Sube `timeout` a 60s y usa `network_idle=False` |
| Selectores rotos cada semana | DOM cambia seguido | Usa `auto_match=True` + `auto_save=True` |
| Captcha bloquea todo | reCAPTCHA v2/v3 | Fallback a Firecrawl MCP (maneja captchas internamente) |

## Fallback a Firecrawl

Si Scrapling falla en los 3 fetchers, cae a Firecrawl MCP:

```python
# Pseudocódigo del patrón fallback
try:
    page = Fetcher.get(url)
    if len(page.html_content) < 500: raise ValueError("HTML vacío")
except Exception:
    try:
        page = StealthyFetcher.fetch(url, network_idle=True)
    except Exception:
        try:
            page = DynamicFetcher.fetch(url, network_idle=True)
        except Exception:
            # Aquí invocas Firecrawl MCP (firecrawl_scrape)
            result = firecrawl_scrape(url=url, formats=["markdown"])
```

## Cuándo NO usar Scrapling

- **Contenido detrás de login:** usa credenciales explícitas del usuario, no bypass
- **APIs privadas con rate limit estricto:** consulta su documentación oficial
- **Contenido pagado o con copyright fuerte:** respeta ToS del sitio
- **Redes sociales con API oficial** (LinkedIn, X, Meta): usa la API, no scraping

## Referencias

- Repo oficial: https://github.com/D4Vinci/Scrapling
- Docs: https://github.com/D4Vinci/Scrapling#readme
- Env var relacionada: `SCRAPLING_DEFAULT_FETCHER`
- Fallback relacionado: Firecrawl MCP (`FIRECRAWL_API_KEY` opcional)
