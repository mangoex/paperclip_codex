---
name: "dataanalyst-dashboard-html"
description: "Genera dashboards HTML estáticos con métricas del pipeline comercial de Humanio — diseño dark premium con KPIs animados, journey de prospectos, tabla de contactos y análisis de conversión. Se despliega en Surge.sh."
slug: "dataanalyst-dashboard-html"
metadata:
  paperclip:
    slug: "dataanalyst-dashboard-html"
    skillKey: "company/HUM/dataanalyst-dashboard-html"
    paperclipSkillKey: "company/HUM/dataanalyst-dashboard-html"
  skillKey: "company/HUM/dataanalyst-dashboard-html"
key: "company/HUM/dataanalyst-dashboard-html"
---

# DataAnalyst — Generador de Dashboard Comercial | Humanio Sales

## Cuándo usar este skill

Úsalo cuando el CEO solicita un reporte visual de desempeño comercial, dashboard semanal/mensual, o estado general del pipeline de prospectos.

Tienes todos los datos agregados del pipeline (de Paperclip issues API). Ahora conviertes esos datos en un dashboard HTML visual interactivo.

El archivo resultante (`index.html`) se despliega en Surge.sh dentro del root compartido como `https://humanio.surge.sh/dashboard-{YYYY-MM-DD}-{SUFFIX}/` y se entrega al CEO.

## Inputs requeridos

Antes de generar el HTML, confirma que tienes:

### Identificadores
- `FECHA_REPORTE` — fecha del reporte (ej: "16 de Abril, 2026")
- `PERIODO` — período cubierto (ej: "Semana 14, Abril 2026")

### Métricas Globales
- `TOTAL_PROSPECTOS` — total de prospectos activos en pipeline
- `PROSPECTOS_NUEVOS` — nuevos prospectos agregados en este período
- `TASA_CONV_GLOBAL` — conversión global (nuevo a ganado, en %)

### Conteos por Etapa (pipeline)
- `N_SCOUT` — cantidad en etapa Scout
- `N_QUALIFIER` — cantidad en etapa Qualifier
- `N_WEBPUBLISHER` — cantidad en etapa WebPublisher (publicación)
- `N_OUTREACH` — cantidad en etapa Outreach
- `N_CLOSER` — cantidad en etapa Closer
- `N_CERRADOS` — total cerrados (ganados)
- `N_PERDIDOS` — prospectos perdidos/rechazados

### Tasas de Conversión entre etapas
- `CONV_SCOUT_QUAL` — Scout → Qualifier (%)
- `CONV_QUAL_OUT` — Qualifier → Outreach (%)
- `CONV_DEMO_REQ` — Outreach/Inbound → Demo solicitada (%)
- `CONV_WP_HANDOFF` — WebPublisher → Closer/Outreach (%)
- `CONV_OUT_CLOSE` — Outreach → Closer (%)
- `CONV_CLOSE_WIN` — Closer → Ganado (%)

### Métricas de Ingresos
- `MRR_ACTUAL` — Monthly Recurring Revenue actual (USD)
- `MRR_TARGET` — MRR objetivo del período (USD)
- `CHURN_RATE` — tasa de churn de clientes (%)
- `LTV_PROMEDIO` — Lifetime Value promedio por cliente (USD)
- `ARPU` — Average Revenue Per User (USD)

### Desglose por Paquete
- `N_STARTER` — cantidad de clientes en plan Starter ($27/mes)
- `N_PRO` — cantidad de clientes en plan Pro ($47/mes)
- `N_BUSINESS` — cantidad de clientes en plan Business ($97/mes)
- `REV_STARTER` — ingresos mensuales del plan Starter (USD)
- `REV_PRO` — ingresos mensuales del plan Pro (USD)
- `REV_BUSINESS` — ingresos mensuales del plan Business (USD)

### Desglose por País
- `N_MEXICO` — cantidad de prospectos/clientes en México
- `N_COLOMBIA` — cantidad en Colombia
- `N_PERU` — cantidad en Perú
- `N_ARGENTINA` — cantidad en Argentina

### Tabla de Prospectos TOP (array)
Cada prospect debe incluir:
- `NOMBRE` — nombre del negocio
- `GIRO` — tipo de negocio
- `CIUDAD` — ciudad
- `PAIS` — país
- `SCORE` — puntuación de calificación (0-100)
- `PAQUETE` — Starter/Pro/Business
- `ETAPA` — Scout/Qualifier/DesignPlanner/WebBuilder/WebQA/WebPublisher/Outreach/Closer/Ganado/Perdido
- `CONTACTO_EMAIL` — ✅ o ❌ (fue contactado por email)
- `CONTACTO_WA` — ✅ o ❌ (fue contactado por WhatsApp)
- `RESPUESTA` — texto de respuesta o "Sin respuesta"
- `URL_PROPUESTA` — URL de propuesta (o "—" si no existe)

### Métricas de Outreach
- `TASA_APERTURA` — % de emails abiertos
- `TASA_RESPUESTA` — % de respuestas recibidas
- `TASA_POSITIVA` — % de respuestas positivas

## Proceso

### 1. Calcular estados y colores

```
MRR vs TARGET:
  MRR_ACTUAL >= MRR_TARGET → color = "#10b981" (green)
  MRR_ACTUAL >= MRR_TARGET * 0.8 → color = "#f59e0b" (amber)
  MRR_ACTUAL < MRR_TARGET * 0.8 → color = "#ef4444" (red)

CHURN RATE:
  < 3% → color = "#10b981" (green) — "Excelente"
  3-5% → color = "#f59e0b" (amber) — "Aceptable"
  > 5% → color = "#ef4444" (red) — "Crítico"

TASA_APERTURA / TASA_RESPUESTA:
  > 30% → "#10b981"
  15-30% → "#f59e0b"
  < 15% → "#ef4444"
```

### 2. Generar el HTML

Crea `/tmp/dashboard-{YYYY-MM-DD}/index.html` con el template completo a continuación.
Reemplaza TODOS los marcadores `{...}` con datos reales del pipeline.
NO dejes ningún marcador sin reemplazar.

```html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard Comercial — Humanio</title>
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
.scroll-progress{position:fixed;top:0;left:0;height:3px;background:var(--accent);z-index:999;transition:width .1s linear;width:0%}

/* NAV */
.dash-nav{position:fixed;top:0;left:0;right:0;z-index:100;padding:1rem 2.5rem;display:flex;justify-content:space-between;align-items:center;background:rgba(3,8,15,.95);backdrop-filter:blur(20px);border-bottom:1px solid var(--border)}
.dash-nav .brand{font-family:'Syne',sans-serif;font-size:.9rem;font-weight:800;color:#fff;letter-spacing:.05em}
.dash-nav .brand span{color:var(--accent)}
.dash-nav .date-info{font-size:.75rem;color:var(--muted);font-family:'JetBrains Mono',monospace}
.refresh-btn{font-size:.75rem;color:var(--accent);text-decoration:none;padding:.4rem .8rem;border:1px solid rgba(var(--accent-rgb),.2);border-radius:6px;transition:all .2s}
.refresh-btn:hover{background:rgba(var(--accent-rgb),.1);border-color:rgba(var(--accent-rgb),.5)}

/* HERO */
.dash-hero{padding:7rem 2.5rem 3rem;position:relative;overflow:hidden;border-bottom:1px solid var(--border)}
.dash-hero::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 70% 60% at 50% 0%,rgba(var(--accent-rgb),.08) 0%,transparent 70%)}
.hero-grid{position:absolute;inset:0;background-image:linear-gradient(rgba(var(--accent-rgb),.025) 1px,transparent 1px),linear-gradient(90deg,rgba(var(--accent-rgb),.025) 1px,transparent 1px);background-size:50px 50px;pointer-events:none}
.hero-inner{max-width:1200px;margin:0 auto;position:relative;z-index:1}
.hero-tag{display:inline-flex;align-items:center;gap:.5rem;padding:.35rem 1rem;border:1px solid rgba(var(--accent-rgb),.3);border-radius:100px;font-size:.72rem;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);margin-bottom:1.5rem}
.hero-tag::before{content:'';width:6px;height:6px;background:var(--accent);border-radius:50%;animation:blink 2s infinite}
@keyframes blink{0%,100%{opacity:1}50%{opacity:.2}}
.hero-inner h1{font-family:'Syne',sans-serif;font-size:clamp(2rem,5vw,3rem);font-weight:800;line-height:1.1;letter-spacing:-.02em;margin-bottom:.5rem}
.hero-inner h1 span{color:var(--accent)}
.hero-meta{display:flex;gap:2.5rem;margin-top:1.5rem;flex-wrap:wrap}
.hero-meta-item{font-size:.8rem;color:var(--muted);font-family:'JetBrains Mono',monospace}
.hero-meta-item strong{display:block;color:rgba(255,255,255,.7);font-size:.85rem;margin-bottom:.2rem;font-family:'Inter',sans-serif;font-weight:600}

/* SECTIONS */
.section{padding:4rem 2.5rem;border-bottom:1px solid var(--border)}
.section-inner{max-width:1200px;margin:0 auto}
.section-tag{font-size:.72rem;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);margin-bottom:.6rem;font-weight:600}
.section-inner h2{font-family:'Syne',sans-serif;font-size:1.5rem;font-weight:800;color:#fff;margin-bottom:.4rem}
.section-desc{font-size:.9rem;color:var(--muted);margin-bottom:2rem;line-height:1.6}

/* KPI CARDS GRID */
.kpi-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1.25rem;margin-bottom:2rem}
.kpi-card{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:1.75rem;position:relative;overflow:hidden;transition:border-color .2s}
.kpi-card:hover{border-color:rgba(var(--accent-rgb),.2)}
.kpi-card::before{content:'';position:absolute;top:-50%;right:-50%;width:200px;height:200px;border-radius:50%;background:radial-gradient(circle,rgba(var(--accent-rgb),.06),transparent 70%)}
.kpi-label{font-size:.72rem;color:var(--muted);letter-spacing:.1em;text-transform:uppercase;margin-bottom:.75rem;position:relative;z-index:1}
.kpi-value{font-family:'Syne',sans-serif;font-size:2.5rem;font-weight:800;line-height:1;margin-bottom:.5rem;position:relative;z-index:1}
.kpi-value.red{color:#ef4444}
.kpi-value.amber{color:#f59e0b}
.kpi-value.green{color:#10b981}
.kpi-value.blue{color:#3b82f6}
.kpi-subtitle{font-size:.8rem;color:rgba(255,255,255,.45);margin-bottom:1rem;position:relative;z-index:1}
.kpi-bar-wrap{margin-top:1rem;position:relative;z-index:1}
.kpi-bar-label{display:flex;justify-content:space-between;font-size:.75rem;color:var(--muted);margin-bottom:.4rem}
.kpi-bar{height:8px;background:rgba(255,255,255,.06);border-radius:100px;overflow:hidden}
.kpi-bar-fill{height:100%;border-radius:100px;width:0%;transition:width 1.2s cubic-bezier(.4,0,.2,1)}
.kpi-bar-fill.red{background:#ef4444}
.kpi-bar-fill.amber{background:#f59e0b}
.kpi-bar-fill.green{background:#10b981}
.kpi-bar-fill.blue{background:#3b82f6}

/* PIPELINE FUNNEL */
.funnel-container{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:2rem;margin:2rem 0}
.funnel-stage{display:grid;grid-template-columns:140px 1fr 80px;gap:1.5rem;align-items:center;margin-bottom:1.75rem}
.funnel-stage:last-child{margin-bottom:0}
.stage-label{font-size:.85rem;font-weight:600;color:rgba(255,255,255,.7)}
.stage-bar-wrap{position:relative}
.stage-bar{height:40px;background:rgba(255,255,255,.04);border-radius:8px;overflow:hidden;position:relative;border:1px solid var(--border)}
.stage-bar-fill{height:100%;background:linear-gradient(90deg,var(--accent),rgba(var(--accent-rgb),.6));border-radius:8px;display:flex;align-items:center;justify-content:flex-end;padding-right:1rem;font-size:.75rem;font-weight:600;color:#fff;transition:width 1.2s cubic-bezier(.4,0,.2,1);width:0%}
.stage-count{font-family:'JetBrains Mono',monospace;font-size:.9rem;font-weight:600;color:var(--accent);text-align:right}
.conv-rate{font-size:.75rem;color:var(--muted);margin-top:.3rem;font-family:'JetBrains Mono',monospace}

/* PROSPECT TABLE */
.prospect-table{width:100%;border-collapse:collapse;margin-top:1.5rem;font-size:.85rem}
.prospect-table th{padding:.75rem 1rem;text-align:left;font-size:.7rem;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);border-bottom:1px solid var(--border);background:rgba(255,255,255,.02);font-weight:600}
.prospect-table td{padding:.85rem 1rem;border-bottom:1px solid rgba(255,255,255,.03)}
.prospect-table tr:hover td{background:rgba(255,255,255,.015)}
.prospect-table tr:last-child td{border-bottom:none}
.prospect-idx{color:var(--muted);font-family:'JetBrains Mono',monospace;font-size:.8rem}
.prospect-name{font-weight:500;color:#fff}
.prospect-score{font-family:'JetBrains Mono',monospace;font-weight:600}
.score-high{color:#10b981}
.score-med{color:#f59e0b}
.score-low{color:#ef4444}
.badge{display:inline-flex;align-items:center;gap:.3rem;padding:.25rem .65rem;border-radius:100px;font-size:.7rem;font-weight:500}
.badge.starter{background:rgba(59,130,246,.12);color:#3b82f6}
.badge.pro{background:rgba(245,158,11,.12);color:#f59e0b}
.badge.business{background:rgba(16,185,129,.12);color:#10b981}
.badge.stage{background:rgba(var(--accent-rgb),.12);color:var(--accent);margin:0 .2rem}
.contact-icons{display:flex;gap:.3rem;font-size:.8rem}

/* REVENUE CARDS */
.revenue-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:1.25rem;margin:2rem 0}
.revenue-card{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:1.5rem;text-align:center;position:relative;overflow:hidden}
.revenue-card::before{content:'';position:absolute;inset:0;background:radial-gradient(circle,rgba(var(--accent-rgb),.05),transparent 70%)}
.revenue-label{font-size:.75rem;color:var(--muted);letter-spacing:.08em;text-transform:uppercase;margin-bottom:.75rem;position:relative;z-index:1;display:block}
.revenue-icon{font-size:1.8rem;margin-bottom:.5rem}
.revenue-count{font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;color:var(--accent);margin-bottom:.25rem;position:relative;z-index:1}
.revenue-amount{font-size:.85rem;color:rgba(255,255,255,.45);margin-bottom:.75rem;position:relative;z-index:1}
.revenue-percent{font-family:'JetBrains Mono',monospace;font-size:.8rem;font-weight:600;color:rgba(255,255,255,.5);position:relative;z-index:1}

/* GEO CARDS */
.geo-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1.25rem;margin:2rem 0}
.geo-card{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:1.5rem;text-align:center}
.geo-icon{font-size:2rem;margin-bottom:.75rem}
.geo-country{font-size:.9rem;font-weight:600;color:#fff;margin-bottom:.5rem}
.geo-count{font-family:'Syne',sans-serif;font-size:2.2rem;font-weight:800;color:var(--accent);margin-bottom:.5rem}
.geo-pct{font-size:.8rem;color:var(--muted);margin-bottom:.75rem}
.geo-bar{height:6px;background:rgba(255,255,255,.06);border-radius:100px;overflow:hidden}
.geo-bar-fill{height:100%;background:var(--accent);border-radius:100px;transition:width 1.2s cubic-bezier(.4,0,.2,1);width:0%}

/* OUTREACH METRICS */
.outreach-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1.25rem;margin:2rem 0}
.outreach-card{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:1.5rem;text-align:center;position:relative;overflow:hidden}
.outreach-card::before{content:'';position:absolute;top:-50%;right:-50%;width:150px;height:150px;border-radius:50%;background:radial-gradient(circle,rgba(var(--accent-rgb),.06),transparent 70%)}
.outreach-label{font-size:.72rem;color:var(--muted);letter-spacing:.1em;text-transform:uppercase;margin-bottom:.75rem;position:relative;z-index:1}
.outreach-value{font-family:'Syne',sans-serif;font-size:2.8rem;font-weight:800;position:relative;z-index:1;margin-bottom:.25rem}
.outreach-value.red{color:#ef4444}
.outreach-value.amber{color:#f59e0b}
.outreach-value.green{color:#10b981}
.outreach-subtitle{font-size:.8rem;color:rgba(255,255,255,.45);position:relative;z-index:1}

/* ALERTS & RECOMMENDATIONS */
.alerts-container{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:2rem;margin:2rem 0}
.alert-item{display:flex;gap:1rem;margin-bottom:1.5rem;padding:1.25rem;border-radius:10px;border-left:4px solid}
.alert-item:last-child{margin-bottom:0}
.alert-item.red{background:rgba(239,68,68,.08);border-left-color:#ef4444}
.alert-item.amber{background:rgba(245,158,11,.08);border-left-color:#f59e0b}
.alert-item.green{background:rgba(16,185,129,.08);border-left-color:#10b981}
.alert-icon{font-size:1.5rem;flex-shrink:0;line-height:1.3}
.alert-body{flex:1}
.alert-title{font-weight:600;color:#fff;margin-bottom:.25rem}
.alert-text{font-size:.85rem;color:rgba(255,255,255,.6);line-height:1.5}

/* FOOTER */
.dash-footer{padding:2.5rem;border-top:1px solid var(--border);text-align:center}
.dash-footer p{font-size:.78rem;color:rgba(255,255,255,.2)}
.dash-footer strong{color:var(--accent)}
.timestamp{font-family:'JetBrains Mono',monospace;font-size:.72rem;color:var(--muted);margin-top:.75rem}

/* RESPONSIVE */
@media(max-width:768px){
  .kpi-grid{grid-template-columns:1fr}
  .revenue-grid{grid-template-columns:1fr}
  .geo-grid{grid-template-columns:1fr}
  .outreach-grid{grid-template-columns:1fr}
  .funnel-stage{grid-template-columns:80px 1fr 60px}
  .prospect-table{font-size:.75rem}
  .prospect-table th,.prospect-table td{padding:.5rem .75rem}
  .dash-hero{padding:5.5rem 1.5rem 2.5rem}
  .section{padding:3rem 1.5rem}
  .dash-nav{padding:.75rem 1.5rem}
  .kpi-value{font-size:2rem}
  .outreach-value{font-size:2.2rem}
}

/* ANIMATIONS */
.aos{opacity:0;transform:translateY(20px);transition:opacity .6s ease,transform .6s ease}
.aos.visible{opacity:1;transform:translateY(0)}
</style>
</head>
<body>

<div class="scroll-progress" id="scrollBar"></div>

<nav class="dash-nav">
  <div class="brand">HUMANIO<span>.</span></div>
  <div class="date-info">{FECHA_REPORTE}</div>
  <button class="refresh-btn" onclick="location.reload()">↻ Actualizar</button>
</nav>

<!-- HERO -->
<div class="dash-hero">
  <div class="hero-grid"></div>
  <div class="hero-inner">
    <div class="hero-tag">Dashboard Comercial</div>
    <h1>Pipeline de Prospectos<br><span>Período {PERIODO}</span></h1>
    <div class="hero-meta">
      <div class="hero-meta-item"><strong>{TOTAL_PROSPECTOS}</strong>Prospectos activos</div>
      <div class="hero-meta-item"><strong>{PROSPECTOS_NUEVOS}</strong>Nuevos este período</div>
      <div class="hero-meta-item"><strong>{TASA_CONV_GLOBAL}%</strong>Conversión global</div>
      <div class="hero-meta-item"><strong>Humanio</strong>Dashboard Ejecutivo</div>
    </div>
  </div>
</div>

<!-- SECCIÓN 1: KPIs -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 1</div>
    <h2>KPIs Clave del Período</h2>
    <p class="section-desc">Resumen de las métricas más importantes de negocio y desempeño comercial.</p>
    <div class="kpi-grid">
      <div class="kpi-card aos">
        <div class="kpi-label">MRR Actual vs Target</div>
        <div class="kpi-value {CLASS_MRR}">${{MRR_ACTUAL}}</div>
        <div class="kpi-subtitle">de ${{{MRR_TARGET}}} objetivo</div>
        <div class="kpi-bar-wrap">
          <div class="kpi-bar-label">
            <span>Progreso</span>
            <span id="mrrPct">0%</span>
          </div>
          <div class="kpi-bar">
            <div class="kpi-bar-fill {CLASS_MRR}" id="mrrBar" data-target="{MRR_ACTUAL}" data-max="{MRR_TARGET}"></div>
          </div>
        </div>
      </div>

      <div class="kpi-card aos">
        <div class="kpi-label">Churn Rate</div>
        <div class="kpi-value {CLASS_CHURN}">{CHURN_RATE}%</div>
        <div class="kpi-subtitle">{CHURN_STATUS}</div>
        <div style="margin-top:1rem;padding:.75rem;background:rgba(255,255,255,.03);border-radius:8px;border:1px solid var(--border)">
          <div style="font-size:.75rem;color:var(--muted)">Clientes retentivos: {CLIENTES_RETENTIVOS}%</div>
        </div>
      </div>

      <div class="kpi-card aos">
        <div class="kpi-label">LTV Promedio</div>
        <div class="kpi-value green">${{{LTV_PROMEDIO}}}</div>
        <div class="kpi-subtitle">por cliente en relación</div>
        <div style="margin-top:1rem;font-size:.8rem;color:rgba(255,255,255,.45)">
          Promedio de <strong>{MESES_RETENTION}</strong> meses de retención
        </div>
      </div>

      <div class="kpi-card aos">
        <div class="kpi-label">ARPU</div>
        <div class="kpi-value blue">${{{ARPU}}}</div>
        <div class="kpi-subtitle">Ingreso promedio por usuario</div>
        <div style="margin-top:1rem;font-size:.8rem;color:rgba(255,255,255,.45)">
          Base actual: <strong>{TOTAL_CLIENTES_ACTIVOS}</strong> clientes
        </div>
      </div>

      <div class="kpi-card aos">
        <div class="kpi-label">Prospectos Totales</div>
        <div class="kpi-value">{TOTAL_PROSPECTOS}</div>
        <div class="kpi-subtitle">en pipeline activo</div>
        <div class="kpi-bar-wrap">
          <div class="kpi-bar-label">
            <span>vs período anterior</span>
            <span id="growthPct">+{CRECIMIENTO_PROSPECTOS}%</span>
          </div>
          <div class="kpi-bar">
            <div class="kpi-bar-fill green" id="growthBar" data-growth="{CRECIMIENTO_PROSPECTOS}"></div>
          </div>
        </div>
      </div>

      <div class="kpi-card aos">
        <div class="kpi-label">Tasa Conv. Global</div>
        <div class="kpi-value amber">{TASA_CONV_GLOBAL}%</div>
        <div class="kpi-subtitle">Scout a Ganado</div>
        <div style="margin-top:1rem;font-size:.8rem;color:rgba(255,255,255,.45)">
          <strong>{N_CERRADOS}</strong> deals cerrados este período
        </div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 2: PIPELINE FUNNEL -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 2</div>
    <h2>Journey del Pipeline — Funnel de Ventas</h2>
    <p class="section-desc">Distribución de prospectos en cada etapa del pipeline comercial y tasas de conversión entre etapas.</p>
    <div class="funnel-container">
      <div class="funnel-stage aos">
        <div class="stage-label">🔍 Scout</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-scout" data-value="{N_SCOUT}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_SCOUT}</div>
      </div>
      <div class="conv-rate" style="margin-left:140px">Conversión: {CONV_SCOUT_QUAL}% → Qualifier</div>

      <div class="funnel-stage aos">
        <div class="stage-label">✓ Qualifier</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-qualifier" data-value="{N_QUALIFIER}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_QUALIFIER}</div>
      </div>
      <div class="conv-rate" style="margin-left:140px">Conversión: {CONV_QUAL_OUT}% → Outreach</div>

      <div class="funnel-stage aos">
        <div class="stage-label">🚀 WebPublisher</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-webpublisher" data-value="{N_WEBPUBLISHER}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_WEBPUBLISHER}</div>
      </div>
      <div class="conv-rate" style="margin-left:140px">Conversión: {CONV_WP_OUT}% → Outreach</div>

      <div class="funnel-stage aos">
        <div class="stage-label">📧 Outreach</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-outreach" data-value="{N_OUTREACH}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_OUTREACH}</div>
      </div>
      <div class="conv-rate" style="margin-left:140px">Conversión: {CONV_OUT_CLOSE}% → Closer</div>

      <div class="funnel-stage aos">
        <div class="stage-label">🤝 Closer</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-closer" data-value="{N_CLOSER}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_CLOSER}</div>
      </div>
      <div class="conv-rate" style="margin-left:140px">Conversión: {CONV_CLOSE_WIN}% → Cerrado</div>

      <div class="funnel-stage aos">
        <div class="stage-label">✅ Ganados</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-cerrados" data-value="{N_CERRADOS}" data-max="{TOTAL_PROSPECTOS}"></div>
          </div>
        </div>
        <div class="stage-count">{N_CERRADOS}</div>
      </div>

      <div class="funnel-stage aos">
        <div class="stage-label">❌ Perdidos</div>
        <div class="stage-bar-wrap">
          <div class="stage-bar">
            <div class="stage-bar-fill" id="bar-perdidos" data-value="{N_PERDIDOS}" data-max="{TOTAL_PROSPECTOS}" style="background:#ef4444"></div>
          </div>
        </div>
        <div class="stage-count">{N_PERDIDOS}</div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 3: TOP PROSPECTS TABLE -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 3</div>
    <h2>Top Prospectos Activos</h2>
    <p class="section-desc">Lista de los mejores prospectos en el pipeline, ordenados por score de calificación.</p>
    <table class="prospect-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre / Giro</th>
          <th>Ubicación</th>
          <th>Score</th>
          <th>Paquete</th>
          <th>Etapa</th>
          <th>Contactos</th>
          <th>Respuesta</th>
          <th>Propuesta</th>
        </tr>
      </thead>
      <tbody>
        <!-- PROSPECT #1 -->
        <tr class="aos">
          <td class="prospect-idx">1</td>
          <td class="prospect-name">{PROSPECT_1_NOMBRE}<br><span style="font-size:.75rem;color:var(--muted)">{PROSPECT_1_GIRO}</span></td>
          <td style="font-size:.85rem;color:rgba(255,255,255,.6)">{PROSPECT_1_CIUDAD}<br>{PROSPECT_1_PAIS}</td>
          <td class="prospect-score {PROSPECT_1_SCORE_CLASS}">{PROSPECT_1_SCORE}</td>
          <td><span class="badge {PROSPECT_1_PAQUETE_CLASS}">{PROSPECT_1_PAQUETE}</span></td>
          <td><span class="badge stage">{PROSPECT_1_ETAPA}</span></td>
          <td class="contact-icons">{PROSPECT_1_EMAIL_ICON} {PROSPECT_1_WA_ICON}</td>
          <td style="font-size:.8rem;color:rgba(255,255,255,.5)">{PROSPECT_1_RESPUESTA}</td>
          <td style="text-align:center"><a href="{PROSPECT_1_URL_PROPUESTA}" style="color:var(--accent);text-decoration:none;font-size:.75rem">Ver →</a></td>
        </tr>
        <!-- PROSPECT #2 -->
        <tr class="aos">
          <td class="prospect-idx">2</td>
          <td class="prospect-name">{PROSPECT_2_NOMBRE}<br><span style="font-size:.75rem;color:var(--muted)">{PROSPECT_2_GIRO}</span></td>
          <td style="font-size:.85rem;color:rgba(255,255,255,.6)">{PROSPECT_2_CIUDAD}<br>{PROSPECT_2_PAIS}</td>
          <td class="prospect-score {PROSPECT_2_SCORE_CLASS}">{PROSPECT_2_SCORE}</td>
          <td><span class="badge {PROSPECT_2_PAQUETE_CLASS}">{PROSPECT_2_PAQUETE}</span></td>
          <td><span class="badge stage">{PROSPECT_2_ETAPA}</span></td>
          <td class="contact-icons">{PROSPECT_2_EMAIL_ICON} {PROSPECT_2_WA_ICON}</td>
          <td style="font-size:.8rem;color:rgba(255,255,255,.5)">{PROSPECT_2_RESPUESTA}</td>
          <td style="text-align:center"><a href="{PROSPECT_2_URL_PROPUESTA}" style="color:var(--accent);text-decoration:none;font-size:.75rem">Ver →</a></td>
        </tr>
        <!-- PROSPECT #3 -->
        <tr class="aos">
          <td class="prospect-idx">3</td>
          <td class="prospect-name">{PROSPECT_3_NOMBRE}<br><span style="font-size:.75rem;color:var(--muted)">{PROSPECT_3_GIRO}</span></td>
          <td style="font-size:.85rem;color:rgba(255,255,255,.6)">{PROSPECT_3_CIUDAD}<br>{PROSPECT_3_PAIS}</td>
          <td class="prospect-score {PROSPECT_3_SCORE_CLASS}">{PROSPECT_3_SCORE}</td>
          <td><span class="badge {PROSPECT_3_PAQUETE_CLASS}">{PROSPECT_3_PAQUETE}</span></td>
          <td><span class="badge stage">{PROSPECT_3_ETAPA}</span></td>
          <td class="contact-icons">{PROSPECT_3_EMAIL_ICON} {PROSPECT_3_WA_ICON}</td>
          <td style="font-size:.8rem;color:rgba(255,255,255,.5)">{PROSPECT_3_RESPUESTA}</td>
          <td style="text-align:center"><a href="{PROSPECT_3_URL_PROPUESTA}" style="color:var(--accent);text-decoration:none;font-size:.75rem">Ver →</a></td>
        </tr>
        <!-- PROSPECT #4 -->
        <tr class="aos">
          <td class="prospect-idx">4</td>
          <td class="prospect-name">{PROSPECT_4_NOMBRE}<br><span style="font-size:.75rem;color:var(--muted)">{PROSPECT_4_GIRO}</span></td>
          <td style="font-size:.85rem;color:rgba(255,255,255,.6)">{PROSPECT_4_CIUDAD}<br>{PROSPECT_4_PAIS}</td>
          <td class="prospect-score {PROSPECT_4_SCORE_CLASS}">{PROSPECT_4_SCORE}</td>
          <td><span class="badge {PROSPECT_4_PAQUETE_CLASS}">{PROSPECT_4_PAQUETE}</span></td>
          <td><span class="badge stage">{PROSPECT_4_ETAPA}</span></td>
          <td class="contact-icons">{PROSPECT_4_EMAIL_ICON} {PROSPECT_4_WA_ICON}</td>
          <td style="font-size:.8rem;color:rgba(255,255,255,.5)">{PROSPECT_4_RESPUESTA}</td>
          <td style="text-align:center"><a href="{PROSPECT_4_URL_PROPUESTA}" style="color:var(--accent);text-decoration:none;font-size:.75rem">Ver →</a></td>
        </tr>
        <!-- PROSPECT #5 -->
        <tr class="aos">
          <td class="prospect-idx">5</td>
          <td class="prospect-name">{PROSPECT_5_NOMBRE}<br><span style="font-size:.75rem;color:var(--muted)">{PROSPECT_5_GIRO}</span></td>
          <td style="font-size:.85rem;color:rgba(255,255,255,.6)">{PROSPECT_5_CIUDAD}<br>{PROSPECT_5_PAIS}</td>
          <td class="prospect-score {PROSPECT_5_SCORE_CLASS}">{PROSPECT_5_SCORE}</td>
          <td><span class="badge {PROSPECT_5_PAQUETE_CLASS}">{PROSPECT_5_PAQUETE}</span></td>
          <td><span class="badge stage">{PROSPECT_5_ETAPA}</span></td>
          <td class="contact-icons">{PROSPECT_5_EMAIL_ICON} {PROSPECT_5_WA_ICON}</td>
          <td style="font-size:.8rem;color:rgba(255,255,255,.5)">{PROSPECT_5_RESPUESTA}</td>
          <td style="text-align:center"><a href="{PROSPECT_5_URL_PROPUESTA}" style="color:var(--accent);text-decoration:none;font-size:.75rem">Ver →</a></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<!-- SECCIÓN 4: REVENUE BY PACKAGE -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 4</div>
    <h2>Ingresos por Paquete de Suscripción</h2>
    <p class="section-desc">Desglose de MRR por plan: Starter, Pro, Business.</p>
    <div class="revenue-grid">
      <div class="revenue-card aos">
        <div class="revenue-icon">🚀</div>
        <div class="revenue-label">Plan Starter</div>
        <div class="revenue-count">{N_STARTER}</div>
        <div class="revenue-amount">${{{REV_STARTER}}}/mes</div>
        <div style="height:1px;background:var(--border);margin:1rem 0"></div>
        <div class="revenue-percent">{STARTER_PERCENT}% del MRR</div>
      </div>
      <div class="revenue-card aos">
        <div class="revenue-icon">⚡</div>
        <div class="revenue-label">Plan Pro</div>
        <div class="revenue-count">{N_PRO}</div>
        <div class="revenue-amount">${{{REV_PRO}}}/mes</div>
        <div style="height:1px;background:var(--border);margin:1rem 0"></div>
        <div class="revenue-percent">{PRO_PERCENT}% del MRR</div>
      </div>
      <div class="revenue-card aos">
        <div class="revenue-icon">👑</div>
        <div class="revenue-label">Plan Business</div>
        <div class="revenue-count">{N_BUSINESS}</div>
        <div class="revenue-amount">${{{REV_BUSINESS}}}/mes</div>
        <div style="height:1px;background:var(--border);margin:1rem 0"></div>
        <div class="revenue-percent">{BUSINESS_PERCENT}% del MRR</div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 5: GEOGRAPHIC DISTRIBUTION -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 5</div>
    <h2>Distribución Geográfica de Prospectos</h2>
    <p class="section-desc">Concentración de oportunidades por país en Latinoamérica.</p>
    <div class="geo-grid">
      <div class="geo-card aos">
        <div class="geo-icon">🇲🇽</div>
        <div class="geo-country">México</div>
        <div class="geo-count">{N_MEXICO}</div>
        <div class="geo-pct">{MEXICO_PERCENT}% del total</div>
        <div class="geo-bar">
          <div class="geo-bar-fill" id="geo-mexico" data-value="{MEXICO_PERCENT}"></div>
        </div>
      </div>
      <div class="geo-card aos">
        <div class="geo-icon">🇨🇴</div>
        <div class="geo-country">Colombia</div>
        <div class="geo-count">{N_COLOMBIA}</div>
        <div class="geo-pct">{COLOMBIA_PERCENT}% del total</div>
        <div class="geo-bar">
          <div class="geo-bar-fill" id="geo-colombia" data-value="{COLOMBIA_PERCENT}"></div>
        </div>
      </div>
      <div class="geo-card aos">
        <div class="geo-icon">🇵🇪</div>
        <div class="geo-country">Perú</div>
        <div class="geo-count">{N_PERU}</div>
        <div class="geo-pct">{PERU_PERCENT}% del total</div>
        <div class="geo-bar">
          <div class="geo-bar-fill" id="geo-peru" data-value="{PERU_PERCENT}"></div>
        </div>
      </div>
      <div class="geo-card aos">
        <div class="geo-icon">🇦🇷</div>
        <div class="geo-country">Argentina</div>
        <div class="geo-count">{N_ARGENTINA}</div>
        <div class="geo-pct">{ARGENTINA_PERCENT}% del total</div>
        <div class="geo-bar">
          <div class="geo-bar-fill" id="geo-argentina" data-value="{ARGENTINA_PERCENT}"></div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 6: OUTREACH PERFORMANCE -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 6</div>
    <h2>Desempeño de Outreach</h2>
    <p class="section-desc">Métricas de efectividad de comunicación con prospectos por email y WhatsApp.</p>
    <div class="outreach-grid">
      <div class="outreach-card aos">
        <div class="outreach-label">Tasa de Apertura</div>
        <div class="outreach-value {CLASS_APERTURA}">{TASA_APERTURA}%</div>
        <div class="outreach-subtitle">de emails enviados</div>
      </div>
      <div class="outreach-card aos">
        <div class="outreach-label">Tasa de Respuesta</div>
        <div class="outreach-value {CLASS_RESPUESTA}">{TASA_RESPUESTA}%</div>
        <div class="outreach-subtitle">emails + WhatsApp</div>
      </div>
      <div class="outreach-card aos">
        <div class="outreach-label">Respuestas Positivas</div>
        <div class="outreach-value {CLASS_POSITIVA}">{TASA_POSITIVA}%</div>
        <div class="outreach-subtitle">de todas las respuestas</div>
      </div>
      <div class="outreach-card aos">
        <div class="outreach-label">Canal Más Efectivo</div>
        <div style="font-size:2.5rem;margin:.75rem 0">
          <span style="color:var(--accent);font-weight:800">{CANAL_MAS_EFECTIVO}</span>
        </div>
        <div class="outreach-subtitle">{CANAL_TASA}% de conversión</div>
      </div>
    </div>
  </div>
</div>

<!-- SECCIÓN 7: ALERTS & RECOMMENDATIONS -->
<div class="section">
  <div class="section-inner">
    <div class="section-tag">Sección 7</div>
    <h2>Alertas y Recomendaciones</h2>
    <p class="section-desc">Hallazgos clave y acciones recomendadas basadas en el análisis del período.</p>
    <div class="alerts-container">
      {ALERT_1}
      {ALERT_2}
      {ALERT_3}
      {ALERT_4}
      {ALERT_5}
    </div>
  </div>
</div>

<!-- FOOTER -->
<footer class="dash-footer">
  <p>Dashboard generado por <strong>Humanio</strong> — Inteligencia Artificial para Negocios</p>
  <p class="timestamp">Generado: {TIMESTAMP_GENERACION}</p>
  <p style="font-size:.72rem;color:rgba(255,255,255,.1);margin-top:1rem">Datos del período {PERIODO} | Próxima actualización automática en 7 días</p>
</footer>

<script>
// SCROLL PROGRESS
const bar = document.getElementById('scrollBar');
window.addEventListener('scroll', () => {
  const pct = (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100;
  bar.style.width = pct + '%';
});

// ANIMATE ON SCROLL
const observer = new IntersectionObserver((entries) => {
  entries.forEach(el => {
    if (el.isIntersecting) {
      el.target.classList.add('visible');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.aos').forEach(el => observer.observe(el));

// ANIMATE KPI BARS
setTimeout(() => {
  // MRR Bar
  const mrrBar = document.getElementById('mrrBar');
  const mrrPct = document.getElementById('mrrPct');
  if (mrrBar) {
    const target = parseFloat(mrrBar.dataset.target);
    const max = parseFloat(mrrBar.dataset.max);
    const pct = Math.min((target / max) * 100, 100);
    mrrBar.style.width = pct + '%';
    mrrPct.textContent = Math.round(pct) + '%';
  }

  // Growth Bar
  const growthBar = document.getElementById('growthBar');
  if (growthBar) {
    const growth = Math.min(parseFloat(growthBar.dataset.growth), 100);
    growthBar.style.width = growth + '%';
  }

  // Funnel bars
  const maxProspectos = {TOTAL_PROSPECTOS};
  document.querySelectorAll('.stage-bar-fill').forEach(bar => {
    const value = parseFloat(bar.id.replace('bar-', '').match(/\d+/) ? bar.parentElement.parentElement.querySelector('.stage-count').textContent : '0');
    const pct = (value / maxProspectos) * 100;
    bar.style.width = pct + '%';
  });

  // Geo bars
  document.querySelectorAll('.geo-bar-fill').forEach(bar => {
    const pct = parseFloat(bar.dataset.value);
    bar.style.width = pct + '%';
  });
}, 300);
</script>
</body>
</html>
```

### 3. Guardar el archivo

```bash
# El archivo ya está en /tmp/dashboard-{YYYY-MM-DD}/index.html
# Confirmar que existe:
ls -la /tmp/dashboard-{YYYY-MM-DD}/index.html
```

### 4. Desplegar en Surge.sh

```bash
# Sufijo aleatorio para que la URL no sea adivinable (dashboards tienen datos internos).
SUFFIX=$(openssl rand -hex 4)
DASHBOARD_SLUG="dashboard-{YYYY-MM-DD}-$SUFFIX"
ROOT_DIR="/tmp/humanio-root"
SRC_DIR="/tmp/dashboard-{YYYY-MM-DD}"

# NUNCA pases el token como argumento (--token) porque queda en `ps`/historial.
# `SURGE_TOKEN` debe estar exportado como variable de entorno.
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"
surge fetch humanio.surge.sh "$ROOT_DIR" || true
rm -rf "$ROOT_DIR/$DASHBOARD_SLUG"
cp -R "$SRC_DIR" "$ROOT_DIR/$DASHBOARD_SLUG"
surge "$ROOT_DIR" humanio.surge.sh

echo "✅ Dashboard desplegado en: https://humanio.surge.sh/$DASHBOARD_SLUG/"
echo "⚠️  Guarda esta URL — no es adivinable desde fuera."
```

**Variables de entorno necesarias:**
- `SURGE_TOKEN` — exportado como env var (NO pasarlo como argumento en CLI)

### 5. Retornar URL al CEO

```
✅ Dashboard generado y desplegado:
https://humanio.surge.sh/dashboard-{YYYY-MM-DD}-{SUFFIX}/

Período: {PERIODO}
Prospectos activos: {TOTAL_PROSPECTOS}
MRR: ${MRR_ACTUAL} (target: ${MRR_TARGET})
```

## Reglas críticas

- **NUNCA dejar marcadores `{...}` sin reemplazar** — revisa el HTML completo antes de desplegar
- **Todos los datos deben ser reales** — obtenidos de Paperclip issues API, NO inventados
- **Validar totales:** N_SCOUT + N_QUALIFIER + N_WEBPUBLISHER + N_OUTREACH + N_CLOSER + N_CERRADOS + N_PERDIDOS = TOTAL_PROSPECTOS (aproximadamente, puede haber variación mínima)
- **Validar MRR:** REV_STARTER + REV_PRO + REV_BUSINESS ≈ MRR_ACTUAL (dentro de tolerancia de ±2%)
- **Validar geografía:** N_MEXICO + N_COLOMBIA + N_PERU + N_ARGENTINA ≈ TOTAL_PROSPECTOS
- **Valores porcentuales:** Todas las tasas (conversión, churn, apertura, respuesta) deben estar entre 0-100%
- **URL de Surge.sh:** Formato exacto: `https://humanio.surge.sh/dashboard-YYYY-MM-DD-SUFFIX/`
- **Timestamp:** Incluir fecha y hora exacta de generación en el footer en formato ISO 8601
- **Si no hay datos para una sección:** Mostrar "Sin datos disponibles para este período" en lugar de dejar vacío
- **Responsividad:** El dashboard debe verse bien en móvil (< 768px) y escritorio

## Deploy

El flujo de despliegue es:

1. DataAnalyst ejecuta este skill → genera HTML en `/tmp/dashboard-{fecha}/index.html`
2. DataAnalyst corre con `SURGE_TOKEN` exportado en env, hace `surge fetch humanio.surge.sh /tmp/humanio-root`, copia `/tmp/dashboard-{fecha}` a `/tmp/humanio-root/dashboard-{fecha}-{suffix}` y publica `surge /tmp/humanio-root humanio.surge.sh`
3. Retorna la URL al CEO vía Paperclip

**Surge.sh setup:**
- Crear cuenta en surge.sh (si no existe)
- Generar token: `surge token`
- Guardar token en secrets de Paperclip bajo la clave `SURGE_TOKEN`
- Verificar que el dominio surge.sh está disponible (es gratuito)

## Ejemplo de variables para un dashboard real

```
FECHA_REPORTE: "16 de Abril, 2026"
PERIODO: "Semana 14, Abril 2026"
TOTAL_PROSPECTOS: 47
PROSPECTOS_NUEVOS: 8
N_SCOUT: 15
N_QUALIFIER: 12
N_WEBPUBLISHER: 10
N_OUTREACH: 6
N_CLOSER: 2
N_CERRADOS: 2
N_PERDIDOS: 4
CONV_SCOUT_QUAL: 80
CONV_QUAL_DP: 83
CONV_WP_OUT: 100
CONV_OUT_CLOSE: 33
CONV_CLOSE_WIN: 100
MRR_ACTUAL: 2840
MRR_TARGET: 3500
CHURN_RATE: 2.1
LTV_PROMEDIO: 1680
ARPU: 285
...
```
