---
name: "qualifier-diagnostic-html"
description: "Genera un reporte de diagnóstico SEO visual en HTML puro — diseño oscuro premium con barras de progreso animadas, scorecard por área, hallazgos con evidencia, quick wins y plan de acción. Se despliega como /reporte en el mismo site del prospecto (Surge.sh)."
slug: "qualifier-diagnostic-html"
metadata:
  paperclip:
    slug: "qualifier-diagnostic-html"
    skillKey: "company/HUM/qualifier-diagnostic-html"
    paperclipSkillKey: "company/HUM/qualifier-diagnostic-html"
  skillKey: "company/HUM/qualifier-diagnostic-html"
key: "company/HUM/qualifier-diagnostic-html"
---

# Qualifier — Generador de Diagnóstico SEO Visual | Humanio

## Cuándo usar este skill

Úsalo DESPUÉS de completar la auditoría SEO con `qualifier-prospect-auditor` y `qualifier-seo`.
Tienes todos los datos del prospecto. Ahora conviertes esos datos en un reporte visual HTML.

El archivo resultante (`reporte.html`) se entrega al DesignPlanner en el brief del ticket,
quien lo incluye en el deploy como `/reporte`.

## Inputs requeridos

Antes de generar el HTML, confirma que tienes:

- `NOMBRE_NEGOCIO` — nombre del negocio
- `GIRO` — tipo de negocio (dentista, restaurante, etc.)
- `CIUDAD` — ciudad
- `SCORE_TOTAL` — puntuación global sobre 100
- `SCORE_TECNICO` — puntuación técnico SEO (0-100)
- `SCORE_ONPAGE` — puntuación on-page (0-100)
- `SCORE_CONTENIDO` — puntuación contenido (0-100)
- `SCORE_LOCAL` — puntuación SEO local (0-100)
- `SCORE_AUTORIDAD` — puntuación autoridad/links (0-100)
- Lista de hallazgos críticos (🔴), importantes (🟡) y positivos (🟢)
- Lista de quick wins con esfuerzo e impacto
- Propuesta de servicios con precios

**Nuevas variables para las secciones 2-7:**
- Keywords: `{KW_1}` a `{KW_5}`, `{VOL_1}` a `{VOL_5}`, `{VOL_TOTAL}`
- Competidores: `{COMP_1_NOMBRE}`, `{COMP_1_WEB}`, `{COMP_1_GBP}`, `{COMP_1_RESENAS}`, `{COMP_1_POS}`, `{COMP_1_VENTAJA}` (repetir para COMP_2 y COMP_3)
- Fortalezas: `{FORTALEZA_1}`, `{FORTALEZA_2}`, `{FORTALEZA_3}`
- Brechas: `{BRECHA_1}`, `{BRECHA_2}`, `{BRECHA_3}`
- Redes: `{EXISTE_IG}`, `{SEG_IG}`, `{ESTADO_IG}`, `{PROBLEMA_IG}` (repetir para FB, WA, TT, GBP2, EMAIL)
- Dinero perdido: `{PERDIDA_MES_MIN}`, `{PERDIDA_MES_MAX}`, `{PERDIDA_ANUAL}`, `{CALCULO_PERDIDA_DETALLE}`
- Posicionamiento: `{ESTADO_GBP_POS}`, `{OBS_GBP}`, `{ESTADO_LOCAL_PACK}`, `{OBS_LOCAL_PACK}`, `{DESCRIPCION_COMPETIDORES_LOCAL_PACK}`
- Técnico: `{ESTADO_WEB}`, `{HALLAZGO_WEB}`, `{IMPACTO_WEB}` (repetir para TITLE, META, H1, CONTENIDO_WEB, HTTPS, MOBILE, SCHEMA, CONTACTO, VELOCIDAD, GBP)

## Proceso

### 1. Calcular nivel global

```
SCORE_TOTAL:
  < 40  → nivel = "⛔ Crítico"     → color_nivel = "#ef4444"
  40-59 → nivel = "⚠️ Necesita Mejoras" → color_nivel = "#f59e0b"
  60-79 → nivel = "📈 En Progreso"  → color_nivel = "#3b82f6"
  ≥ 80  → nivel = "✅ Bueno"        → color_nivel = "#10b981"
```

### 2. Mapear colores por score de categoría

```
score < 45  → class="score-red"   → color "#ef4444"
45-64       → class="score-amber" → color "#f59e0b"
65-79       → class="score-blue"  → color "#3b82f6"
≥ 80        → class="score-green" → color "#10b981"
```

### 3. Generar el HTML

Crea `/tmp/proposal-{slug}/reporte.html` con el template completo a continuación.
Reemplaza TODOS los marcadores `{...}` con datos reales del prospecto.
NO dejes ningún marcador sin reemplazar.

```html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Diagnóstico SEO — {NOMBRE_NEGOCIO}</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
:root{
  --accent:#2dd4bf;
  --accent-rgb:45,212,191;
  --red:#ef4444;
  --amber:#f59e0b;
  --blue:#3b82f6;
  --green:#10b981;
  --bg:#03080f;
  --bg2:#060d17;
  --bg3:#0a1628;
  --text:#e2e8f0;
  --muted:#64748b;
  --border:rgba(255,255,255,.06)
}
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);overflow-x:hidden}

/* SCROLL PROGRESS */
.scroll-progress{position:fixed;top:0;left:0;height:2px;background:var(--accent);z-index:999;transition:width .1s linear;width:0%}

/* NAV */
.diag-nav{position:fixed;top:0;left:0;right:0;z-index:100;padding:1rem 2.5rem;display:flex;justify-content:space-between;align-items:center;background:rgba(3,8,15,.9);backdrop-filter:blur(20px);border-bottom:1px solid var(--border)}
.diag-nav .brand{font-family:'Syne',sans-serif;font-size:.9rem;font-weight:800;color:#fff;letter-spacing:.05em}
.diag-nav .brand span{color:var(--accent)}
.diag-nav .prospect-name{font-size:.8rem;color:var(--muted);font-family:'JetBrains Mono',monospace}
.back-btn{font-size:.8rem;color:var(--accent);text-decoration:none;display:flex;align-items:center;gap:.4rem;transition:opacity .2s}
.back-btn:hover{opacity:.7}
.back-btn svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2}

/* HERO */
.diag-hero{padding:7rem 2.5rem 4rem;position:relative;overflow:hidden;border-bottom:1px solid var(--border)}
.diag-hero::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 70% 60% at 50% 0%,rgba(var(--accent-rgb),.08) 0%,transparent 70%)}
.hero-grid{position:absolute;inset:0;background-image:linear-gradient(rgba(var(--accent-rgb),.025) 1px,transparent 1px),linear-gradient(90deg,rgba(var(--accent-rgb),.025) 1px,transparent 1px);background-size:50px 50px;pointer-events:none}
.hero-inner{max-width:900px;margin:0 auto;position:relative;z-index:1}
.hero-tag{display:inline-flex;align-items:center;gap:.5rem;padding:.35rem 1rem;border:1px solid rgba(var(--accent-rgb),.3);border-radius:100px;font-size:.72rem;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);margin-bottom:1.5rem}
.hero-tag::before{content:'';width:6px;height:6px;background:var(--accent);border-radius:50%;animation:blink 2s infinite}
@keyframes blink{0%,100%{opacity:1}50%{opacity:.2}}
.hero-inner h1{font-family:'Syne',sans-serif;font-size:clamp(2rem,5vw,3.2rem);font-weight:800;line-height:1.05;letter-spacing:-.02em;margin-bottom:.5rem}
.hero-inner h1 span{color:var(--accent)}
.hero-meta{display:flex;gap:2rem;margin-top:1.5rem;flex-wrap:wrap}
.hero-meta-item{font-size:.8rem;color:var(--muted);font-family:'JetBrains Mono',monospace}
.hero-meta-item strong{display:block;color:rgba(255,255,255,.7);font-size:.85rem;margin-bottom:.2rem;font-family:'Inter',sans-serif}

/* GLOBAL SCORE */
.global-score{max-width:900px;margin:2rem auto 0;padding:2rem;background:var(--bg2);border:1px solid var(--border);border-radius:16px;position:relative;overflow:hidden}
.global-score::after{content:'';position:absolute;right:-60px;top:-60px;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,rgba(var(--accent-rgb),.06),transparent 70%)}
.score-header{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.5rem}
.score-number{font-family:'Syne',sans-serif;font-size:4rem;font-weight:800;line-height:1;color:{COLOR_NIVEL}}
.score-number span{font-size:1.5rem;color:var(--muted)}
.score-level{font-size:.85rem;color:{COLOR_NIVEL};font-weight:600;margin-top:.3rem}
.score-label{font-size:.75rem;color:var(--muted);letter-spacing:.1em;text-transform:uppercase}
.summary-text{font-size:.9rem;color:rgba(255,255,255,.5);line-height:1.7;margin-bottom:1.5rem;max-width:600px}
.global-bar-wrap{margin-bottom:.5rem}
.global-bar-label{display:flex;justify-content:space-between;font-size:.78rem;color:var(--muted);margin-bottom:.5rem}
.global-bar{height:10px;background:rgba(255,255,255,.06);border-radius:100px;overflow:hidden}
.global-bar-fill{height:100%;border-radius:100px;background:linear-gradient(90deg,{COLOR_NIVEL}aa,{COLOR_NIVEL});width:0%;transition:width 1.2s cubic-bezier(.4,0,.2,1)}
.badge-row{display:flex;gap:.75rem;flex-wrap:wrap;margin-top:1.5rem}
.badge{display:inline-flex;align-items:center;gap:.4rem;padding:.3rem .8rem;border-radius:100px;font-size:.75rem;font-weight:500}
.badge.red{background:rgba(239,68,68,.1);color:#ef4444;border:1px solid rgba(239,68,68,.2)}
.badge.amber{background:rgba(245,158,11,.1);color:#f59e0b;border:1px solid rgba(245,158,11,.2)}
.badge.green{background:rgba(16,185,129,.1);color:#10b981;border:1px solid rgba(16,185,129,.2)}

/* SECTIONS */
.section{padding:4rem 2.5rem;border-bottom:1px solid var(--border)}
.section-inner{max-width:900px;margin:0 auto}
.section-tag{font-size:.72rem;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);margin-bottom:.6rem}
.section-inner h2{font-family:'Syne',sans-serif;font-size:1.6rem;font-weight:800;color:#fff;margin-bottom:.4rem}
.section-desc{font-size:.9rem;color:var(--muted);margin-bottom:2rem;line-height:1.6}

/* SCORECARD GRID */
.scorecard-grid{display:grid;gap:.75rem}
.scorecard-row{display:grid;grid-template-columns:180px 1fr 80px 100px;align-items:center;gap:1rem;padding:1rem 1.25rem;background:var(--bg2);border:1px solid var(--border);border-radius:10px;transition:border-color .2s}
.scorecard-row:hover{border-color:rgba(var(--accent-rgb),.2)}
.scorecard-row .area-name{font-size:.9rem;font-weight:500;color:rgba(255,255,255,.8)}
.scorecard-bar-wrap{position:relative}
.scorecard-bar{height:6px;background:rgba(255,255,255,.06);border-radius:100px;overflow:hidden}
.scorecard-bar-fill{height:100%;border-radius:100px;width:0%;transition:width 1s cubic-bezier(.4,0,.2,1)}
.scorecard-bar-fill.score-red{background:#ef4444}
.scorecard-bar-fill.score-amber{background:#f59e0b}
.scorecard-bar-fill.score-blue{background:#3b82f6}
.scorecard-bar-fill.score-green{background:#10b981}
.scorecard-score{font-family:'JetBrains Mono',monospace;font-size:.85rem;font-weight:500;text-align:right}
.scorecard-score.score-red{color:#ef4444}
.scorecard-score.score-amber{color:#f59e0b}
.scorecard-score.score-blue{color:#3b82f6}
.scorecard-score.score-green{color:#10b981}
.scorecard-status{font-size:.75rem;padding:.25rem .65rem;border-radius:100px;text-align:center;font-weight:500}
.scorecard-status.score-red{background:rgba(239,68,68,.12);color:#ef4444}
.scorecard-status.score-amber{background:rgba(245,158,11,.12);color:#f59e0b}
.scorecard-status.score-blue{background:rgba(59,130,246,.12);color:#3b82f6}
.scorecard-status.score-green{background:rgba(16,185,129,.12);color:#10b981}

/* FINDINGS */
.finding{margin-bottom:1.5rem;border:1px solid var(--border);border-radius:12px;overflow:hidden}
.finding-header{padding:1rem 1.25rem;display:flex;align-items:center;gap:.75rem;cursor:pointer;transition:background .2s}
.finding-header:hover{background:rgba(255,255,255,.02)}
.finding-sev{width:10px;height:10px;border-radius:50%;flex-shrink:0}
.finding-sev.red{background:#ef4444;box-shadow:0 0 8px #ef444480}
.finding-sev.amber{background:#f59e0b;box-shadow:0 0 8px #f59e0b80}
.finding-sev.green{background:#10b981;box-shadow:0 0 8px #10b98180}
.finding-title{font-size:.95rem;font-weight:600;color:#fff;flex:1}
.finding-tag{font-size:.72rem;padding:.2rem .6rem;border-radius:100px}
.finding-tag.red{background:rgba(239,68,68,.12);color:#ef4444}
.finding-tag.amber{background:rgba(245,158,11,.12);color:#f59e0b}
.finding-tag.green{background:rgba(16,185,129,.12);color:#10b981}
.finding-body{padding:0 1.25rem 1.25rem;border-top:1px solid var(--border)}
.finding-body p{font-size:.88rem;color:rgba(255,255,255,.5);line-height:1.7;margin-top:1rem;margin-bottom:.75rem}
.code-compare{display:grid;grid-template-columns:1fr 1fr;gap:.75rem;margin:.75rem 0}
.code-block{background:rgba(0,0,0,.4);border:1px solid var(--border);border-radius:8px;padding:.75rem 1rem}
.code-block label{display:block;font-size:.68rem;letter-spacing:.1em;text-transform:uppercase;margin-bottom:.5rem}
.code-block label.bad{color:#ef4444}
.code-block label.good{color:#10b981}
.code-block code{font-family:'JetBrains Mono',monospace;font-size:.8rem;color:rgba(255,255,255,.7);line-height:1.6;word-break:break-all}
.finding-list{list-style:none;display:flex;flex-direction:column;gap:.4rem;margin-top:.75rem}
.finding-list li{font-size:.85rem;color:rgba(255,255,255,.45);padding-left:1rem;position:relative;line-height:1.5}
.finding-list li::before{content:'→';position:absolute;left:0;color:var(--muted)}

/* QUICK WINS TABLE */
.qw-table{width:100%;border-collapse:collapse;margin-top:1rem}
.qw-table th{padding:.6rem 1rem;text-align:left;font-size:.72rem;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);border-bottom:1px solid var(--border)}
.qw-table td{padding:.85rem 1rem;font-size:.85rem;border-bottom:1px solid rgba(255,255,255,.03)}
.qw-table tr:last-child td{border-bottom:none}
.qw-table tr:hover td{background:rgba(255,255,255,.015)}
.pill{display:inline-flex;align-items:center;gap:.3rem;padding:.2rem .6rem;border-radius:100px;font-size:.72rem;font-weight:500}
.pill.low{background:rgba(16,185,129,.1);color:#10b981}
.pill.med{background:rgba(245,158,11,.1);color:#f59e0b}
.pill.high{background:rgba(239,68,68,.1);color:#ef4444}
.effort-low::before{content:'🟢 '}
.effort-med::before{content:'🟡 '}
.effort-high::before{content:'🔴 '}

/* ACTION PLAN */
.phase{margin-bottom:2rem}
.phase-header{display:flex;align-items:center;gap:.75rem;margin-bottom:1rem}
.phase-num{width:32px;height:32px;background:rgba(var(--accent-rgb),.1);border:1px solid rgba(var(--accent-rgb),.3);border-radius:8px;display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-size:.9rem;font-weight:800;color:var(--accent)}
.phase-title{font-size:1rem;font-weight:600;color:#fff}
.phase-timeline{font-size:.75rem;color:var(--muted);margin-left:auto;font-family:'JetBrains Mono',monospace}
.action-list{display:flex;flex-direction:column;gap:.5rem;padding-left:2.5rem}
.action-item{display:flex;align-items:flex-start;gap:.75rem;padding:.6rem .75rem;background:var(--bg2);border:1px solid var(--border);border-radius:8px;font-size:.85rem;color:rgba(255,255,255,.6);transition:border-color .2s}
.action-item:hover{border-color:rgba(var(--accent-rgb),.2)}
.action-item::before{content:'[ ]';font-family:'JetBrains Mono',monospace;font-size:.75rem;color:var(--muted);flex-shrink:0;margin-top:.1rem}

/* PROPOSAL BANNER */
.proposal-banner{background:linear-gradient(135deg,var(--bg2),var(--bg3));border:1px solid rgba(var(--accent-rgb),.15);border-radius:16px;padding:2.5rem;margin-top:1rem;position:relative;overflow:hidden}
.proposal-banner::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 60% 80% at 100% 50%,rgba(var(--accent-rgb),.06),transparent 70%)}
.proposal-banner h3{font-family:'Syne',sans-serif;font-size:1.3rem;font-weight:800;color:#fff;margin-bottom:.5rem;position:relative}
.proposal-banner p{font-size:.9rem;color:rgba(255,255,255,.45);line-height:1.7;margin-bottom:1.5rem;position:relative;max-width:500px}
.proposal-services{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:.75rem;margin-bottom:1.5rem;position:relative}
.service-pill{background:rgba(var(--accent-rgb),.06);border:1px solid rgba(var(--accent-rgb),.15);border-radius:10px;padding:.75rem 1rem}
.service-pill h4{font-size:.85rem;font-weight:600;color:var(--accent);margin-bottom:.3rem}
.service-pill p{font-size:.78rem;color:var(--muted);line-height:1.4}
.service-pill .price{font-family:'JetBrains Mono',monospace;font-size:.8rem;color:rgba(255,255,255,.4);margin-top:.4rem}
.proposal-cta{display:inline-flex;align-items:center;gap:.6rem;padding:.85rem 1.75rem;background:var(--accent);color:#03080f;border-radius:100px;font-weight:600;font-size:.9rem;text-decoration:none;transition:opacity .2s,transform .2s;position:relative}
.proposal-cta:hover{opacity:.88;transform:translateY(-2px)}

/* FOOTER */
.diag-footer{padding:2.5rem;border-top:1px solid var(--border);text-align:center}
.diag-footer p{font-size:.78rem;color:rgba(255,255,255,.2)}
.diag-footer strong{color:var(--accent)}
.disclaimer{max-width:700px;margin:.75rem auto 0;font-size:.75rem;color:rgba(255,255,255,.15);line-height:1.6}

/* RESPONSIVE */
@media(max-width:768px){
  .scorecard-row{grid-template-columns:1fr;gap:.5rem}
  .code-compare{grid-template-columns:1fr}
  .proposal-services{grid-template-columns:1fr}
  .diag-hero{padding:6rem 1.5rem 3rem}
  .section{padding:3rem 1.5rem}
  .score-number{font-size:3rem}
}

/* ANIMATE ON SCROLL */
.aos{opacity:0;transform:translateY(20px);transition:opacity .6s ease,transform .6s ease}
.aos.visible{opacity:1;transform:translateY(0)}
</style>
</head>
<body>

<div class="scroll-progress" id="scrollBar"></div>

<nav class="diag-nav">
  <div class="brand">HUMANIO<span>.</span></div>
  <div class="prospect-name">{NOMBRE_NEGOCIO} — Diagnóstico SEO</div>
  <a href="/" class="back-btn">
    <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
    Ver propuesta
  </a>
</nav>

<!-- HERO -->
<div class="diag-hero">
  <div class="hero-grid"></div>
  <div class="hero-inner">
    <div class="hero-tag">Diagnóstico de Presencia Digital</div>
    <h1>{NOMBRE_NEGOCIO}<br><span>Análisis SEO 360°</span></h1>
    <div class="hero-meta">
      <div class="hero-meta-item"><strong>{FECHA_HOY}</strong>Fecha de análisis</div>
      <div class="hero-meta-item"><strong>{GIRO}</strong>Industria</div>
      <div class="hero-meta-item"><strong>{CIUDAD}</strong>Mercado objetivo</div>
      <div class="hero-meta-item"><strong>Humanio</strong>Elaborado por</div>
    </div>

    <!-- GLOBAL SCORE -->
    <div class="global-score" style="margin-top:2rem">
      <div class="score-header">
        <div>
          <div class="score-label">Puntuación General</div>
          <div class="score-number" id="scoreCounter">0<span>/100</span></div>
          <div class="score-level">{NIVEL_TEXTO}</div>
        </div>
      </div>
      <p class="summary-text">{RESUMEN_EJECUTIVO_2_ORACIONES}</p>
      <div class="global-bar-wrap">
        <div class="global-bar-label">
          <span>Presencia digital actual</span>
          <span id="barPct">0%</span>
        </div>
        <div class="global-bar">
          <div class="global-bar-fill" id="globalBarFill" data-target="{SCORE_TOTAL}"></div>
        </div>
      </div>
      <div class="badge-row">
        <span class="badge red">🔴 {N_CRITICOS} críticos</span>
        <span class="badge amber">🟡 {N_IMPORTANTES} importantes</span>
        <span class="badge green">🟢 {N_QUICKWINS} quick wins</span>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 1: SCORECARD -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 1</div>
    <h2>Scorecard por área</h2>
    <p class="section-desc">Evaluación de las 5 dimensiones clave de presencia digital para {GIRO}s en {CIUDAD}.</p>
    <div class="scorecard-grid">
      <div class="scorecard-row aos">
        <div class="area-name">⚙️ Técnico SEO</div>
        <div class="scorecard-bar-wrap">
          <div class="scorecard-bar">
            <div class="scorecard-bar-fill {CLASS_TECNICO}" data-w="{SCORE_TECNICO}"></div>
          </div>
        </div>
        <div class="scorecard-score {CLASS_TECNICO}">{SCORE_TECNICO}/100</div>
        <div class="scorecard-status {CLASS_TECNICO}">{ESTADO_TECNICO}</div>
      </div>
      <div class="scorecard-row aos">
        <div class="area-name">📄 On-Page SEO</div>
        <div class="scorecard-bar-wrap">
          <div class="scorecard-bar">
            <div class="scorecard-bar-fill {CLASS_ONPAGE}" data-w="{SCORE_ONPAGE}"></div>
          </div>
        </div>
        <div class="scorecard-score {CLASS_ONPAGE}">{SCORE_ONPAGE}/100</div>
        <div class="scorecard-status {CLASS_ONPAGE}">{ESTADO_ONPAGE}</div>
      </div>
      <div class="scorecard-row aos">
        <div class="area-name">✍️ Contenido</div>
        <div class="scorecard-bar-wrap">
          <div class="scorecard-bar">
            <div class="scorecard-bar-fill {CLASS_CONTENIDO}" data-w="{SCORE_CONTENIDO}"></div>
          </div>
        </div>
        <div class="scorecard-score {CLASS_CONTENIDO}">{SCORE_CONTENIDO}/100</div>
        <div class="scorecard-status {CLASS_CONTENIDO}">{ESTADO_CONTENIDO}</div>
      </div>
      <div class="scorecard-row aos">
        <div class="area-name">📍 SEO Local</div>
        <div class="scorecard-bar-wrap">
          <div class="scorecard-bar">
            <div class="scorecard-bar-fill {CLASS_LOCAL}" data-w="{SCORE_LOCAL}"></div>
          </div>
        </div>
        <div class="scorecard-score {CLASS_LOCAL}">{SCORE_LOCAL}/100</div>
        <div class="scorecard-status {CLASS_LOCAL}">{ESTADO_LOCAL}</div>
      </div>
      <div class="scorecard-row aos">
        <div class="area-name">🔗 Autoridad</div>
        <div class="scorecard-bar-wrap">
          <div class="scorecard-bar">
            <div class="scorecard-bar-fill {CLASS_AUTORIDAD}" data-w="{SCORE_AUTORIDAD}"></div>
          </div>
        </div>
        <div class="scorecard-score {CLASS_AUTORIDAD}">{SCORE_AUTORIDAD}/100</div>
        <div class="scorecard-status {CLASS_AUTORIDAD}">{ESTADO_AUTORIDAD}</div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 2: DIAGNÓSTICO TÉCNICO SEO -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 2</div>
    <h2>Diagnóstico Técnico SEO</h2>
    <p class="section-desc">Auditoría de los elementos técnicos que determinan si Google puede indexar y posicionar el sitio de {NOMBRE_NEGOCIO}.</p>
    <table class="qw-table">
      <thead>
        <tr><th>Elemento</th><th>Estado</th><th>Hallazgo específico</th><th>Impacto</th></tr>
      </thead>
      <tbody>
        <!-- Repite <tr> por cada elemento analizado. Usa ✅ ⚠️ ❌ en Estado -->
        <tr><td>Sitio web propio</td><td>{ESTADO_WEB}</td><td>{HALLAZGO_WEB}</td><td style="color:{COLOR_IMP_WEB};font-size:.8rem">{IMPACTO_WEB}</td></tr>
        <tr><td>Title tag</td><td>{ESTADO_TITLE}</td><td>{HALLAZGO_TITLE}</td><td style="color:{COLOR_IMP_TITLE};font-size:.8rem">{IMPACTO_TITLE}</td></tr>
        <tr><td>Meta description</td><td>{ESTADO_META}</td><td>{HALLAZGO_META}</td><td style="color:{COLOR_IMP_META};font-size:.8rem">{IMPACTO_META}</td></tr>
        <tr><td>H1 principal</td><td>{ESTADO_H1}</td><td>{HALLAZGO_H1}</td><td style="color:{COLOR_IMP_H1};font-size:.8rem">{IMPACTO_H1}</td></tr>
        <tr><td>Contenido</td><td>{ESTADO_CONTENIDO_WEB}</td><td>{HALLAZGO_CONTENIDO_WEB}</td><td style="color:{COLOR_IMP_CONTENIDO};font-size:.8rem">{IMPACTO_CONTENIDO}</td></tr>
        <tr><td>HTTPS / SSL</td><td>{ESTADO_HTTPS}</td><td>{HALLAZGO_HTTPS}</td><td style="color:var(--muted);font-size:.8rem">{IMPACTO_HTTPS}</td></tr>
        <tr><td>Mobile-friendly</td><td>{ESTADO_MOBILE}</td><td>{HALLAZGO_MOBILE}</td><td style="color:{COLOR_IMP_MOBILE};font-size:.8rem">{IMPACTO_MOBILE}</td></tr>
        <tr><td>Schema markup</td><td>{ESTADO_SCHEMA}</td><td>{HALLAZGO_SCHEMA}</td><td style="color:{COLOR_IMP_SCHEMA};font-size:.8rem">{IMPACTO_SCHEMA}</td></tr>
        <tr><td>Datos de contacto</td><td>{ESTADO_CONTACTO}</td><td>{HALLAZGO_CONTACTO}</td><td style="color:{COLOR_IMP_CONTACTO};font-size:.8rem">{IMPACTO_CONTACTO}</td></tr>
        <tr><td>Velocidad de carga</td><td>{ESTADO_VELOCIDAD}</td><td>{HALLAZGO_VELOCIDAD}</td><td style="color:{COLOR_IMP_VELOCIDAD};font-size:.8rem">{IMPACTO_VELOCIDAD}</td></tr>
        <tr><td>Google Business Profile</td><td>{ESTADO_GBP}</td><td>{HALLAZGO_GBP}</td><td style="color:{COLOR_IMP_GBP};font-size:.8rem">{IMPACTO_GBP}</td></tr>
      </tbody>
    </table>
    <p style="font-size:.78rem;color:var(--muted);margin-top:1rem">✅ Correcto &nbsp;⚠️ Mejorable &nbsp;❌ Ausente o crítico</p>
  </div>
</div>

<!-- SECCIÓN 3: POSICIONAMIENTO EN GOOGLE -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 3</div>
    <h2>Posicionamiento en Google</h2>
    <p class="section-desc">Visibilidad actual de {NOMBRE_NEGOCIO} en búsquedas locales y en el Local Pack de {CIUDAD}.</p>
    <table class="qw-table">
      <thead>
        <tr><th>Métrica</th><th>Estado</th><th>Observación</th></tr>
      </thead>
      <tbody>
        <tr><td>Google Business Profile</td><td>{ESTADO_GBP_POS}</td><td>{OBS_GBP}</td></tr>
        <tr><td>Aparece en Local Pack</td><td>{ESTADO_LOCAL_PACK}</td><td>{OBS_LOCAL_PACK}</td></tr>
        <tr><td>Búsqueda "{KEYWORD_PRINCIPAL}"</td><td>{ESTADO_BUSQ_1}</td><td>{OBS_BUSQ_1}</td></tr>
        <tr><td>Búsqueda "{KEYWORD_SECUNDARIA}"</td><td>{ESTADO_BUSQ_2}</td><td>{OBS_BUSQ_2}</td></tr>
        <tr><td>Búsqueda por nombre</td><td>{ESTADO_BUSQ_NOMBRE}</td><td>{OBS_BUSQ_NOMBRE}</td></tr>
      </tbody>
    </table>
    <div style="margin-top:1.5rem;padding:1.25rem;background:rgba(239,68,68,.06);border:1px solid rgba(239,68,68,.15);border-radius:12px">
      <p style="font-size:.85rem;color:rgba(255,255,255,.6);line-height:1.7"><strong style="color:#ef4444">¿Quién domina el Local Pack ahora?</strong><br>{DESCRIPCION_COMPETIDORES_LOCAL_PACK}</p>
    </div>
  </div>
</div>

<!-- SECCIÓN 4: KEYWORDS DE OPORTUNIDAD -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 4</div>
    <h2>Keywords de Mayor Oportunidad</h2>
    <p class="section-desc">Búsquedas mensuales estimadas en {CIUDAD} para {GIRO}s. {NOMBRE_NEGOCIO} actualmente no aparece en estas posiciones.</p>
    <table class="qw-table">
      <thead>
        <tr><th>#</th><th>Keyword</th><th>Búsquedas/mes*</th><th>Intención</th><th>Dificultad</th></tr>
      </thead>
      <tbody>
        <!-- Mínimo 5 keywords, máximo 10. Ordena por volumen descendente -->
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">1</td>
          <td>{KW_1}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace">~{VOL_1}</td>
          <td><span class="pill high">Transaccional</span></td>
          <td><span class="pill med">Media</span></td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">2</td>
          <td>{KW_2}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace">~{VOL_2}</td>
          <td><span class="pill high">Transaccional</span></td>
          <td><span class="pill low">Baja</span></td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">3</td>
          <td>{KW_3}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace">~{VOL_3}</td>
          <td><span class="pill high">Transaccional</span></td>
          <td><span class="pill low">Baja</span></td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">4</td>
          <td>{KW_4}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace">~{VOL_4}</td>
          <td><span class="pill med">Informacional</span></td>
          <td><span class="pill low">Baja</span></td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">5</td>
          <td>{KW_5}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace">~{VOL_5}</td>
          <td><span class="pill high">Transaccional</span></td>
          <td><span class="pill low">Baja</span></td>
        </tr>
      </tbody>
    </table>
    <div style="margin-top:1rem;padding:1rem 1.25rem;background:var(--bg2);border-radius:10px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem">
      <div>
        <div style="font-size:.75rem;color:var(--muted);text-transform:uppercase;letter-spacing:.08em">Volumen total estimado</div>
        <div style="font-family:'Syne',sans-serif;font-size:1.8rem;font-weight:800;color:var(--accent)">{VOL_TOTAL}/mes</div>
      </div>
      <div style="font-size:.85rem;color:rgba(255,255,255,.4);max-width:400px;line-height:1.6">{NOMBRE_NEGOCIO} actualmente captura <strong style="color:#ef4444">0%</strong> de este tráfico. {RAZON_CERO_TRAFICO}</div>
    </div>
    <p style="font-size:.75rem;color:rgba(255,255,255,.2);margin-top:.75rem">*Estimado — sin herramienta de keywords conectada. Basado en datos demográficos y benchmarks del sector en ciudades comparables.</p>
  </div>
</div>

<!-- SECCIÓN 5: ANÁLISIS COMPETITIVO -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 5</div>
    <h2>Análisis Competitivo</h2>
    <p class="section-desc">Comparación de {NOMBRE_NEGOCIO} contra los competidores que sí aparecen en Google para las búsquedas objetivo en {CIUDAD}.</p>
    <table class="qw-table">
      <thead>
        <tr><th>Competidor</th><th>Web</th><th>GBP</th><th>Reseñas</th><th>Pos. Google</th><th>Ventaja vs {NOMBRE_NEGOCIO_CORTO}</th></tr>
      </thead>
      <tbody>
        <!-- 3-4 competidores reales detectados en el análisis -->
        <tr>
          <td style="font-weight:500">{COMP_1_NOMBRE}</td>
          <td>{COMP_1_WEB}</td>
          <td>{COMP_1_GBP}</td>
          <td style="font-size:.82rem">{COMP_1_RESENAS}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace;font-size:.82rem">{COMP_1_POS}</td>
          <td style="font-size:.82rem;color:rgba(255,255,255,.45)">{COMP_1_VENTAJA}</td>
        </tr>
        <tr>
          <td style="font-weight:500">{COMP_2_NOMBRE}</td>
          <td>{COMP_2_WEB}</td>
          <td>{COMP_2_GBP}</td>
          <td style="font-size:.82rem">{COMP_2_RESENAS}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace;font-size:.82rem">{COMP_2_POS}</td>
          <td style="font-size:.82rem;color:rgba(255,255,255,.45)">{COMP_2_VENTAJA}</td>
        </tr>
        <tr>
          <td style="font-weight:500">{COMP_3_NOMBRE}</td>
          <td>{COMP_3_WEB}</td>
          <td>{COMP_3_GBP}</td>
          <td style="font-size:.82rem">{COMP_3_RESENAS}</td>
          <td style="color:var(--accent);font-family:'JetBrains Mono',monospace;font-size:.82rem">{COMP_3_POS}</td>
          <td style="font-size:.82rem;color:rgba(255,255,255,.45)">{COMP_3_VENTAJA}</td>
        </tr>
      </tbody>
    </table>
    <div style="margin-top:1.5rem;display:grid;grid-template-columns:1fr 1fr;gap:1rem">
      <div style="padding:1.25rem;background:rgba(16,185,129,.06);border:1px solid rgba(16,185,129,.15);border-radius:12px">
        <div style="font-size:.75rem;color:#10b981;text-transform:uppercase;letter-spacing:.1em;margin-bottom:.75rem">✅ Fortalezas de {NOMBRE_NEGOCIO_CORTO}</div>
        <ul style="list-style:none;display:flex;flex-direction:column;gap:.4rem">
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{FORTALEZA_1}</li>
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{FORTALEZA_2}</li>
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{FORTALEZA_3}</li>
        </ul>
      </div>
      <div style="padding:1.25rem;background:rgba(239,68,68,.06);border:1px solid rgba(239,68,68,.15);border-radius:12px">
        <div style="font-size:.75rem;color:#ef4444;text-transform:uppercase;letter-spacing:.1em;margin-bottom:.75rem">❌ Brechas a cerrar</div>
        <ul style="list-style:none;display:flex;flex-direction:column;gap:.4rem">
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{BRECHA_1}</li>
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{BRECHA_2}</li>
          <li style="font-size:.85rem;color:rgba(255,255,255,.6)">{BRECHA_3}</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 6: REDES SOCIALES -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 6</div>
    <h2>Redes Sociales y Presencia Digital</h2>
    <p class="section-desc">Estado actual de cada canal digital de {NOMBRE_NEGOCIO} y oportunidades no aprovechadas.</p>
    <table class="qw-table">
      <thead>
        <tr><th>Canal</th><th>¿Existe?</th><th>Seguidores</th><th>Estado</th><th>Problema detectado</th></tr>
      </thead>
      <tbody>
        <tr><td>Instagram</td><td>{EXISTE_IG}</td><td>{SEG_IG}</td><td>{ESTADO_IG}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_IG}</td></tr>
        <tr><td>Facebook</td><td>{EXISTE_FB}</td><td>{SEG_FB}</td><td>{ESTADO_FB}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_FB}</td></tr>
        <tr><td>WhatsApp Business</td><td>{EXISTE_WA}</td><td>—</td><td>{ESTADO_WA}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_WA}</td></tr>
        <tr><td>TikTok</td><td>{EXISTE_TT}</td><td>{SEG_TT}</td><td>{ESTADO_TT}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_TT}</td></tr>
        <tr><td>Google Business Profile</td><td>{EXISTE_GBP2}</td><td>—</td><td>{ESTADO_GBP2}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_GBP2}</td></tr>
        <tr><td>Email marketing</td><td>{EXISTE_EMAIL}</td><td>—</td><td>{ESTADO_EMAIL}</td><td style="font-size:.82rem;color:rgba(255,255,255,.45)">{PROBLEMA_EMAIL}</td></tr>
      </tbody>
    </table>
  </div>
</div>

<!-- SECCIÓN 7: DINERO PERDIDO -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 7</div>
    <h2>Lo Que Estás Perdiendo 💸</h2>
    <p class="section-desc">En {CIUDAD}, aproximadamente <strong style="color:var(--accent)">{VOL_TOTAL} personas</strong> buscan {GIRO}s cada mes. Sin presencia digital optimizada, ese tráfico va a la competencia.</p>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1.25rem;margin-top:2rem">
      <div style="background:var(--bg2);border:1px solid var(--border);border-radius:16px;padding:1.75rem;text-align:center">
        <div style="font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.1em;margin-bottom:.5rem">Escenario Conservador</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.4);margin-bottom:1rem">Captura del 3% del tráfico objetivo</div>
        <div style="font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;color:#f59e0b">{MONEDA_LOCAL} {PERDIDA_MES_MIN}</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.3);margin-top:.25rem">valor mensual no captado</div>
      </div>
      <div style="background:var(--bg2);border:1px solid rgba(var(--accent-rgb),.2);border-radius:16px;padding:1.75rem;text-align:center">
        <div style="font-size:.72rem;color:var(--accent);text-transform:uppercase;letter-spacing:.1em;margin-bottom:.5rem">Escenario Optimista</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.4);margin-bottom:1rem">Captura del 10% del tráfico objetivo</div>
        <div style="font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;color:var(--accent)">{MONEDA_LOCAL} {PERDIDA_MES_MAX}</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.3);margin-top:.25rem">valor mensual no captado</div>
      </div>
      <div style="background:rgba(239,68,68,.06);border:1px solid rgba(239,68,68,.2);border-radius:16px;padding:1.75rem;text-align:center">
        <div style="font-size:.72rem;color:#ef4444;text-transform:uppercase;letter-spacing:.1em;margin-bottom:.5rem">Valor Anual Estimado</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.4);margin-bottom:1rem">No captado por falta de presencia digital</div>
        <div style="font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;color:#ef4444">{MONEDA_LOCAL} {PERDIDA_ANUAL}</div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.3);margin-top:.25rem">valor anual no captado</div>
      </div>
    </div>
    <p style="font-size:.82rem;color:rgba(255,255,255,.3);margin-top:1.25rem;line-height:1.7">{CALCULO_PERDIDA_DETALLE}</p>
  </div>
</div>

<!-- SECCIÓN 8: HALLAZGOS CRÍTICOS -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 8</div>
    <h2>Hallazgos críticos 🔴</h2>
    <p class="section-desc">{N_CRITICOS} problemas identificados que están frenando activamente el posicionamiento.</p>

    <!-- REPITE este bloque por cada hallazgo crítico. Mínimo 2, máximo 5. -->
    <div class="finding aos">
      <div class="finding-header">
        <div class="finding-sev red"></div>
        <div class="finding-title">CRÍTICO #1 — {TITULO_CRITICO_1}</div>
        <span class="finding-tag red">Impacto Alto</span>
      </div>
      <div class="finding-body">
        <p>{DESCRIPCION_CRITICO_1}</p>
        <!-- Si hay comparación antes/después, usa este bloque. Si no, elimínalo. -->
        <div class="code-compare">
          <div class="code-block">
            <label class="bad">❌ Actual</label>
            <code>{EJEMPLO_ACTUAL_1}</code>
          </div>
          <div class="code-block">
            <label class="good">✅ Recomendado</label>
            <code>{EJEMPLO_CORRECTO_1}</code>
          </div>
        </div>
        <ul class="finding-list">
          <li>{DETALLE_1A}</li>
          <li>{DETALLE_1B}</li>
          <li>{DETALLE_1C}</li>
        </ul>
      </div>
    </div>

    <!-- Hallazgo crítico #2 -->
    <div class="finding aos">
      <div class="finding-header">
        <div class="finding-sev red"></div>
        <div class="finding-title">CRÍTICO #2 — {TITULO_CRITICO_2}</div>
        <span class="finding-tag red">Impacto Alto</span>
      </div>
      <div class="finding-body">
        <p>{DESCRIPCION_CRITICO_2}</p>
        <ul class="finding-list">
          <li>{DETALLE_2A}</li>
          <li>{DETALLE_2B}</li>
          <li>{DETALLE_2C}</li>
        </ul>
      </div>
    </div>

    <!-- Hallazgo crítico #3 (si existe) -->
    <!-- Copiar bloque anterior y ajustar numeración -->
  </div>
</div>

<!-- SECCIÓN 9: HALLAZGOS IMPORTANTES -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 9</div>
    <h2>Hallazgos importantes 🟡</h2>
    <p class="section-desc">Oportunidades de mejora con impacto significativo en visibilidad y conversión.</p>

    <div class="finding aos">
      <div class="finding-header">
        <div class="finding-sev amber"></div>
        <div class="finding-title">IMPORTANTE #1 — {TITULO_IMPORTANTE_1}</div>
        <span class="finding-tag amber">Impacto Medio</span>
      </div>
      <div class="finding-body">
        <p>{DESCRIPCION_IMPORTANTE_1}</p>
        <ul class="finding-list">
          <li>{DETALLE_IMP_1A}</li>
          <li>{DETALLE_IMP_1B}</li>
        </ul>
      </div>
    </div>
    <!-- Repetir para cada hallazgo importante (hasta 5) -->
  </div>
</div>

<!-- SECCIÓN 10: QUICK WINS -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 10</div>
    <h2>Quick Wins ⚡</h2>
    <p class="section-desc">Acciones implementables en menos de 7 días con impacto inmediato en posicionamiento.</p>
    <table class="qw-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Acción</th>
          <th>Esfuerzo</th>
          <th>Impacto</th>
          <th>Tiempo</th>
        </tr>
      </thead>
      <tbody>
        <!-- Repite <tr> por cada quick win (mínimo 5) -->
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">01</td>
          <td>{ACCION_QW_1}</td>
          <td><span class="pill low effort-low">Bajo</span></td>
          <td><span class="pill high">🔴 Alto</span></td>
          <td style="color:var(--muted);font-size:.8rem">{TIEMPO_QW_1}</td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">02</td>
          <td>{ACCION_QW_2}</td>
          <td><span class="pill low effort-low">Bajo</span></td>
          <td><span class="pill med">🟡 Medio</span></td>
          <td style="color:var(--muted);font-size:.8rem">{TIEMPO_QW_2}</td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">03</td>
          <td>{ACCION_QW_3}</td>
          <td><span class="pill low effort-low">Bajo</span></td>
          <td><span class="pill high">🔴 Alto</span></td>
          <td style="color:var(--muted);font-size:.8rem">{TIEMPO_QW_3}</td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">04</td>
          <td>{ACCION_QW_4}</td>
          <td><span class="pill low effort-low">Bajo</span></td>
          <td><span class="pill med">🟡 Medio</span></td>
          <td style="color:var(--muted);font-size:.8rem">{TIEMPO_QW_4}</td>
        </tr>
        <tr>
          <td style="color:var(--muted);font-family:'JetBrains Mono',monospace">05</td>
          <td>{ACCION_QW_5}</td>
          <td><span class="pill low effort-low">Bajo</span></td>
          <td><span class="pill med">🟡 Medio</span></td>
          <td style="color:var(--muted);font-size:.8rem">{TIEMPO_QW_5}</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<!-- SECCIÓN 11: PLAN DE ACCIÓN -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 11</div>
    <h2>Plan de acción priorizado</h2>
    <p class="section-desc">Roadmap en 3 fases para transformar la presencia digital de {NOMBRE_NEGOCIO}.</p>

    <div class="phase aos">
      <div class="phase-header">
        <div class="phase-num">1</div>
        <div class="phase-title">Fundamentos críticos</div>
        <div class="phase-timeline">Semanas 1–2</div>
      </div>
      <div class="action-list">
        <div class="action-item">{ACCION_FASE1_1}</div>
        <div class="action-item">{ACCION_FASE1_2}</div>
        <div class="action-item">{ACCION_FASE1_3}</div>
        <div class="action-item">{ACCION_FASE1_4}</div>
      </div>
    </div>

    <div class="phase aos">
      <div class="phase-header">
        <div class="phase-num">2</div>
        <div class="phase-title">Optimización</div>
        <div class="phase-timeline">Semanas 3–4</div>
      </div>
      <div class="action-list">
        <div class="action-item">{ACCION_FASE2_1}</div>
        <div class="action-item">{ACCION_FASE2_2}</div>
        <div class="action-item">{ACCION_FASE2_3}</div>
      </div>
    </div>

    <div class="phase aos">
      <div class="phase-header">
        <div class="phase-num">3</div>
        <div class="phase-title">Crecimiento</div>
        <div class="phase-timeline">Mes 2–3</div>
      </div>
      <div class="action-list">
        <div class="action-item">{ACCION_FASE3_1}</div>
        <div class="action-item">{ACCION_FASE3_2}</div>
        <div class="action-item">{ACCION_FASE3_3}</div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 12: PROPUESTA HUMANIO -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 12 — ¿Quieres que lo hagamos por ti?</div>
    <h2>Solución completa Humanio</h2>
    <div class="proposal-banner">
      <h3>Transformamos tu presencia digital en 30 días</h3>
      <p>Implementamos todo el plan de acción por ti — página web moderna, SEO local optimizado, WhatsApp Business automatizado y campañas en redes sociales.</p>
      <div class="proposal-services">
        <div class="service-pill">
          <h4>🌐 Página Web</h4>
          <p>Diseño moderno, rápida, optimizada para Google</p>
          <div class="price">{PRECIO_WEB}</div>
        </div>
        <div class="service-pill">
          <h4>📱 WhatsApp Business</h4>
          <p>Chatbot 24/7 + respuestas automáticas</p>
          <div class="price">{PRECIO_WA}</div>
        </div>
        <div class="service-pill">
          <h4>📣 Meta Ads</h4>
          <p>Campañas Facebook e Instagram locales</p>
          <div class="price">{PRECIO_ADS}</div>
        </div>
        <div class="service-pill">
          <h4>🤖 Agentes IA</h4>
          <p>Automatizaciones y flujos inteligentes</p>
          <div class="price">{PRECIO_AI}</div>
        </div>
      </div>
      <a href="https://wa.me/52{WHATSAPP_HUMANIO}?text=Hola,%20vi%20mi%20diagnóstico%20de%20{NOMBRE_NEGOCIO_URL}%20y%20me%20interesa%20la%20propuesta" class="proposal-cta">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
        Agendar llamada gratuita
      </a>
    </div>
  </div>
</div>

<!-- FOOTER -->
<footer class="diag-footer">
  <p>Diagnóstico elaborado por <strong>Humanio</strong> · Para uso exclusivo de {NOMBRE_NEGOCIO}</p>
  <p class="disclaimer">Esta auditoría fue realizada mediante análisis de HTML, sitemap y robots.txt. Para análisis completo se recomienda acceso a Google Search Console y PageSpeed Insights. Los scores son estimaciones basadas en factores observables públicamente.</p>
</footer>

<script>
// SCROLL PROGRESS
const bar = document.getElementById('scrollBar');
window.addEventListener('scroll', () => {
  const pct = (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100;
  bar.style.width = pct + '%';
});

// ANIMATE BARS ON SCROLL
const observer = new IntersectionObserver((entries) => {
  entries.forEach(el => {
    if (el.isIntersecting) {
      el.target.classList.add('visible');
      // Animate scorecard bars
      el.target.querySelectorAll('.scorecard-bar-fill').forEach(fill => {
        const w = fill.dataset.w;
        setTimeout(() => fill.style.width = w + '%', 100);
      });
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.aos').forEach(el => observer.observe(el));

// ANIMATE GLOBAL BAR + COUNTER
const globalFill = document.getElementById('globalBarFill');
const counter = document.getElementById('scoreCounter');
const pctLabel = document.getElementById('barPct');
const target = parseInt(globalFill.dataset.target);

setTimeout(() => {
  globalFill.style.width = target + '%';
  let current = 0;
  const step = Math.ceil(target / 60);
  const interval = setInterval(() => {
    current = Math.min(current + step, target);
    counter.innerHTML = current + '<span>/100</span>';
    pctLabel.textContent = current + '%';
    if (current >= target) clearInterval(interval);
  }, 20);
}, 300);

// FINDING ACCORDIONS
document.querySelectorAll('.finding-header').forEach(header => {
  const body = header.nextElementSibling;
  body.style.display = 'none';
  header.addEventListener('click', () => {
    const isOpen = body.style.display !== 'none';
    body.style.display = isOpen ? 'none' : 'block';
  });
});

// Open first finding by default
const firstBody = document.querySelector('.finding-body');
if (firstBody) firstBody.style.display = 'block';
</script>
</body>
</html>
```

### 4. Guardar el archivo

```bash
# El archivo ya está en /tmp/proposal-{slug}/reporte.html
# Confirmar que existe:
ls -la /tmp/proposal-{slug}/reporte.html
```

### 5. Notificar al DesignPlanner

Incluye en el ticket del DesignPlanner:

```
### Diagnóstico HTML generado

El archivo `/tmp/proposal-{slug}/reporte.html` ya existe y debe incluirse
en el deploy como página secundaria.

Instrucción para DesignPlanner:
- Copiar `reporte.html` al directorio del site antes del deploy
- Asegurarse que el `index.html` tenga un botón "Ver reporte" que apunte a `./reporte`
- URL final: `humanio.surge.sh/{slug}/reporte.html`
```

### 6. Actualizar el ticket de Outreach

Cuando DesignPlanner entregue la URL del site, el brief de Outreach debe incluir:

```
- URL propuesta web: https://humanio.surge.sh/{slug}
- URL diagnóstico gratuito: https://humanio.surge.sh/{slug}/reporte.html
```

## Reglas críticas

- NUNCA dejar marcadores `{...}` sin reemplazar — revisa el HTML antes de guardarlo
- El score total debe ser coherente con los scores por área (promedio ponderado)
- Los hallazgos deben tener evidencia específica (URLs reales, texto real del sitio)
- Los quick wins deben ser realmente ejecutables en < 7 días
- El bloque de propuesta Humanio SIEMPRE va incluido — es el CTA del documento
- WhatsApp Humanio: usa la variable de entorno `$HUMANIO_WHATSAPP` o el número definido en company settings
