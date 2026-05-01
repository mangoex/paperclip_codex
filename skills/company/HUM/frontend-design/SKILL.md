---
name: "frontend-design"
description: "Guía de diseño frontend premium para DesignPlanner — patrones visuales, efectos CSS/JS avanzados, sistema de diseño Humanio y checklist de calidad para propuestas web de alto impacto."
slug: "frontend-design"
metadata:
  paperclip:
    slug: "frontend-design"
    skillKey: "company/HUM/frontend-design"
  paperclipSkillKey: "company/HUM/frontend-design"
  skillKey: "company/HUM/frontend-design"
key: "company/HUM/frontend-design"
---

# Frontend Design — Sistema de Diseño Premium | Humanio

## Propósito

Este skill es la guía de referencia visual del DesignPlanner. Define el sistema de diseño de Humanio, patrones de UI reutilizables, efectos CSS/JS avanzados y el checklist de calidad que toda propuesta debe pasar antes de publicarse.

Consulta este skill ANTES de construir cada propuesta para mantener consistencia y nivel premium.

---

## 1. Sistema de diseño Humanio

### Tipografía

```css
/* Fuentes obligatorias */
@import url('https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=Inter:wght@300;400;500;600&display=swap');

/* Jerarquía */
h1, h2, h3        { font-family: 'Syne', sans-serif; }
body, p, li, span  { font-family: 'Inter', sans-serif; }

/* Escala tipográfica (clamp para responsive) */
h1 { font-size: clamp(2.5rem, 5vw, 4.5rem); font-weight: 800; line-height: 1.05; letter-spacing: -0.03em; }
h2 { font-size: clamp(1.8rem, 3vw, 2.8rem); font-weight: 700; line-height: 1.1; }
h3 { font-size: clamp(1.2rem, 2vw, 1.6rem); font-weight: 700; }
p  { font-size: clamp(0.95rem, 1.2vw, 1.1rem); line-height: 1.7; font-weight: 400; }

/* Tags / labels */
.tag { font-size: 0.7rem; letter-spacing: 0.15em; text-transform: uppercase; font-weight: 600; }
```

### Paleta base (modo oscuro)

```css
:root {
  --bg-primary:    #03080f;
  --bg-secondary:  #0a1628;
  --bg-card:       #0d1b2a;
  --text-primary:  #f0f4f8;
  --text-secondary: rgba(255,255,255,0.5);
  --text-muted:    rgba(255,255,255,0.3);
  --accent:        #2dd4bf;  /* teal — color principal Humanio */
  --accent-glow:   rgba(45,212,191,0.15);
  --accent-hover:  #5eead4;
  --danger:        #ef4444;
  --warning:       #f59e0b;
  --success:       #10b981;
  --border:        rgba(255,255,255,0.06);
  --radius-sm:     8px;
  --radius-md:     12px;
  --radius-lg:     20px;
  --radius-full:   100px;
}
```

### Paleta adaptativa por giro

Cada propuesta usa la paleta base + un acento por giro:

| Giro | Acento | Gradiente hero |
|------|--------|----------------|
| Dental / Médico | `#2dd4bf` (teal) | `linear-gradient(135deg, #03080f 0%, #0a2a2a 100%)` |
| Estética / Belleza | `#f472b6` (rosa) | `linear-gradient(135deg, #03080f 0%, #2a0a1e 100%)` |
| Restaurante / Café | `#fb923c` (naranja) | `linear-gradient(135deg, #03080f 0%, #2a1a0a 100%)` |
| Abogados / Legal | `#818cf8` (índigo) | `linear-gradient(135deg, #03080f 0%, #0a0a2a 100%)` |
| Inmobiliaria | `#38bdf8` (sky blue) | `linear-gradient(135deg, #03080f 0%, #0a1e2a 100%)` |
| Fitness / Gym | `#a3e635` (lime) | `linear-gradient(135deg, #03080f 0%, #1a2a0a 100%)` |
| Automotriz | `#e2e8f0` (silver) | `linear-gradient(135deg, #03080f 0%, #1a1a2a 100%)` |
| Default | `#2dd4bf` (teal) | `linear-gradient(135deg, #03080f 0%, #0a1628 100%)` |

Sustituye `--accent` con el color del giro. El resto de la paleta permanece igual.

### Espaciado

```css
/* Secciones */
section { padding: clamp(60px, 10vw, 120px) clamp(20px, 5vw, 80px); }

/* Grid gap estándar */
.grid { gap: clamp(16px, 2vw, 32px); }

/* Separador entre secciones */
.section-divider { 
  height: 1px; 
  background: linear-gradient(90deg, transparent, var(--border), transparent); 
}
```

---

## 2. Componentes reutilizables

### Hero con parallax + partículas

```html
<section class="hero" id="hero">
  <canvas id="hero-particles"></canvas>
  <div class="hero-content">
    <span class="tag">Propuesta de Crecimiento Digital</span>
    <h1 class="split-reveal">{NOMBRE_NEGOCIO}</h1>
    <p class="hero-sub">{TAGLINE_GIRO} en {CIUDAD}</p>
    <a href="#servicios" class="btn-magnetic">Ver propuesta</a>
  </div>
  <div class="hero-scroll-indicator">
    <span>Scroll</span>
    <div class="scroll-line"></div>
  </div>
</section>
```

```css
.hero {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  background: var(--hero-gradient);
}
#hero-particles {
  position: absolute; inset: 0;
  pointer-events: none; opacity: 0.4;
}
.hero-content { position: relative; z-index: 2; text-align: center; max-width: 800px; }
.hero-sub { color: var(--text-secondary); margin-top: 16px; font-size: 1.1rem; }

/* Scroll indicator */
.hero-scroll-indicator {
  position: absolute; bottom: 40px; left: 50%; transform: translateX(-50%);
  display: flex; flex-direction: column; align-items: center; gap: 8px;
}
.hero-scroll-indicator span { font-size: 0.7rem; letter-spacing: 0.2em; text-transform: uppercase; color: var(--text-muted); }
.scroll-line { width: 1px; height: 40px; background: var(--accent); animation: scrollPulse 2s ease infinite; }
@keyframes scrollPulse { 0%,100% { scaleY: 1; opacity: 0.5; } 50% { scaleY: 1.5; opacity: 1; } }
```

### Tarjeta de servicio con tilt 3D

```html
<div class="service-card" data-tilt>
  <div class="card-icon">{ICONO_EMOJI}</div>
  <h3>{NOMBRE_SERVICIO}</h3>
  <p>{DESCRIPCION_CORTA}</p>
  <div class="card-price">
    <span class="price-amount">${PRECIO}</span>
    <span class="price-unit">USD base</span>
  </div>
</div>
```

```css
.service-card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  padding: 40px 32px;
  transition: transform 0.3s ease, border-color 0.3s ease;
  position: relative;
  overflow: hidden;
}
.service-card::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg, transparent, var(--accent), transparent);
  opacity: 0; transition: opacity 0.3s;
}
.service-card:hover::before { opacity: 1; }
.service-card:hover { border-color: rgba(45,212,191,0.2); }
.card-icon { font-size: 2.5rem; margin-bottom: 20px; }
.card-price { margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border); }
.price-amount { font-family: 'Syne'; font-size: 1.8rem; font-weight: 800; color: var(--accent); }
.price-unit { color: var(--text-muted); font-size: 0.85rem; margin-left: 4px; }
```

### Contador animado

```html
<div class="stat-grid">
  <div class="stat">
    <span class="stat-number" data-target="{BUSQUEDAS_MES}">0</span>
    <span class="stat-label">búsquedas/mes en {CIUDAD}</span>
  </div>
  <div class="stat">
    <span class="stat-number" data-target="{COMPETIDORES}" data-suffix="+">0</span>
    <span class="stat-label">competidores con web</span>
  </div>
  <div class="stat">
    <span class="stat-number" data-target="{CLIENTES_POTENCIALES}">0</span>
    <span class="stat-label">clientes potenciales/mes</span>
  </div>
</div>
```

```css
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 32px; text-align: center; }
.stat-number { font-family: 'Syne'; font-size: clamp(2.5rem, 4vw, 4rem); font-weight: 800; color: var(--accent); display: block; }
.stat-label { color: var(--text-secondary); font-size: 0.9rem; margin-top: 8px; display: block; }
```

### Sección de diagnóstico (problema → solución)

```html
<div class="diagnosis-row">
  <div class="diagnosis-before">
    <span class="tag danger">Situación actual</span>
    <h3>{PROBLEMA}</h3>
    <p>{DESCRIPCION_PROBLEMA}</p>
  </div>
  <div class="diagnosis-arrow">→</div>
  <div class="diagnosis-after">
    <span class="tag success">Con Humanio</span>
    <h3>{SOLUCION}</h3>
    <p>{DESCRIPCION_SOLUCION}</p>
  </div>
</div>
```

### CTA flotante (WhatsApp)

```html
<a href="https://wa.me/{WHATSAPP_NUMBER}?text={MENSAJE_ENCODED}" class="wa-fab" aria-label="WhatsApp">
  <svg>...</svg>
</a>
```

```css
.wa-fab {
  position: fixed; bottom: 24px; right: 24px; z-index: 999;
  width: 56px; height: 56px; border-radius: 50%;
  background: #25d366; color: #fff;
  display: grid; place-items: center;
  box-shadow: 0 4px 20px rgba(37,211,102,0.4);
  transition: transform 0.3s, box-shadow 0.3s;
}
.wa-fab:hover { transform: scale(1.1); box-shadow: 0 6px 30px rgba(37,211,102,0.6); }
```

---

## 3. Efectos JS avanzados

### Partículas en canvas (hero)

```javascript
const canvas = document.getElementById('hero-particles');
const ctx = canvas.getContext('2d');
let particles = [];

function initParticles() {
  canvas.width = canvas.offsetWidth;
  canvas.height = canvas.offsetHeight;
  particles = Array.from({length: 60}, () => ({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 0.3,
    vy: (Math.random() - 0.5) * 0.3,
    r: Math.random() * 2 + 0.5,
    o: Math.random() * 0.5 + 0.1
  }));
}

function drawParticles() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  particles.forEach(p => {
    p.x += p.vx; p.y += p.vy;
    if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
    if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(45,212,191,${p.o})`;
    ctx.fill();
  });
  // Draw connections
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x;
      const dy = particles[i].y - particles[j].y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 120) {
        ctx.beginPath();
        ctx.moveTo(particles[i].x, particles[i].y);
        ctx.lineTo(particles[j].x, particles[j].y);
        ctx.strokeStyle = `rgba(45,212,191,${0.1 * (1 - dist / 120)})`;
        ctx.stroke();
      }
    }
  }
  requestAnimationFrame(drawParticles);
}

initParticles();
drawParticles();
window.addEventListener('resize', initParticles);
```

### Split-text reveal (h1)

```javascript
// IMPORTANTE: usa split por palabras, NO por caracteres.
// Split por caracteres destruye los <span> internos del h1 (renderiza HTML como texto).
document.querySelectorAll('.split-reveal').forEach(el => {
  // Split by words to preserve inner HTML tags (spans, etc.)
  const words = el.innerText.trim().split(/\s+/);
  el.innerHTML = words.map((w, i) =>
    `<span style="display:inline-block;opacity:0;transform:translateY(40px);animation:letterIn 0.7s ${i * 0.08}s cubic-bezier(0.16,1,0.3,1) forwards">${w}</span>`
  ).join(' ');
});

// CSS
// @keyframes letterIn { to { opacity: 1; transform: translateY(0); } }
```

### Vanilla Tilt (tarjetas 3D)

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.8.1/vanilla-tilt.min.js"></script>
<script>
VanillaTilt.init(document.querySelectorAll('[data-tilt]'), {
  max: 8, speed: 400, glare: true, 'max-glare': 0.08, scale: 1.02
});
</script>
```

### Contador con easeOut

```javascript
function animateCounters() {
  document.querySelectorAll('.stat-number').forEach(el => {
    const target = +el.dataset.target;
    const suffix = el.dataset.suffix || '';
    const duration = 2000;
    const start = performance.now();
    const easeOut = t => 1 - Math.pow(1 - t, 3);

    function tick(now) {
      const t = Math.min((now - start) / duration, 1);
      el.textContent = Math.round(easeOut(t) * target).toLocaleString() + suffix;
      if (t < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  });
}

// Trigger on scroll
const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) { animateCounters(); counterObserver.disconnect(); } });
}, { threshold: 0.3 });
counterObserver.observe(document.querySelector('.stat-grid'));
```

### Botón magnético

```javascript
document.querySelectorAll('.btn-magnetic').forEach(btn => {
  btn.addEventListener('mousemove', e => {
    const rect = btn.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;
    btn.style.transform = `translate(${x * 0.15}px, ${y * 0.15}px)`;
  });
  btn.addEventListener('mouseleave', () => {
    btn.style.transform = 'translate(0, 0)';
    btn.style.transition = 'transform 0.4s cubic-bezier(0.23, 1, 0.32, 1)';
  });
});
```

### Scroll progress bar

```javascript
const progress = document.getElementById('scroll-progress');
window.addEventListener('scroll', () => {
  const pct = window.scrollY / (document.body.scrollHeight - window.innerHeight) * 100;
  progress.style.width = pct + '%';
});
```

```html
<div style="position:fixed;top:0;left:0;width:100%;height:3px;z-index:9999;background:transparent">
  <div id="scroll-progress" style="height:100%;width:0%;background:var(--accent);transition:width 0.1s"></div>
</div>
```

### Reveal on scroll (sin AOS)

```javascript
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('revealed');
      revealObserver.unobserve(e.target);
    }
  });
}, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));
```

```css
.reveal { opacity: 0; transform: translateY(30px); transition: opacity 0.8s ease, transform 0.8s ease; }
.reveal.revealed { opacity: 1; transform: translateY(0); }
.reveal.reveal-left { transform: translateX(-30px); }
.reveal.reveal-left.revealed { transform: translateX(0); }
.reveal.reveal-scale { transform: scale(0.95); }
.reveal.reveal-scale.revealed { transform: scale(1); }
```

---

## 4. Patrones de layout por sección

### Estructura recomendada de la propuesta

```
1. Hero — parallax + partículas + split-text h1
2. Problema — "Lo que estás perdiendo" con contadores
3. Diagnóstico — grid antes/después por área
4. Servicios — 3 cards con tilt + precios
5. Proceso — timeline vertical con pasos numerados
6. Resultados esperados — contadores + gráfico simple
7. Testimonios / Social proof — rating Google + reseñas
8. CTA final — botón magnético + datos de contacto
9. Footer — Humanio branding + WhatsApp FAB
```

### Grid responsive

```css
/* Auto-fit grid para cards */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: 24px;
}

/* 2 columnas en desktop, 1 en mobile */
.two-col {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(400px, 100%), 1fr));
  gap: 48px;
  align-items: center;
}
```

---

## 5. Optimización de performance

### Imágenes

```css
/* Blur-up lazy loading */
.lazy-img {
  filter: blur(20px); transform: scale(1.1);
  transition: filter 0.8s ease, transform 0.8s ease;
}
.lazy-img.loaded { filter: blur(0); transform: scale(1); }
```

```javascript
document.querySelectorAll('img[data-src]').forEach(img => {
  const observer = new IntersectionObserver(([e]) => {
    if (e.isIntersecting) {
      img.src = img.dataset.src;
      img.onload = () => img.classList.add('loaded');
      observer.disconnect();
    }
  });
  observer.observe(img);
});
```

### Meta tags obligatorios

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="Propuesta de crecimiento digital para {NOMBRE_NEGOCIO} en {CIUDAD} — Humanio">
<meta name="theme-color" content="#03080f">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🚀</text></svg>">
<title>{NOMBRE_NEGOCIO} — Propuesta Digital | Humanio</title>
```

### CSS crítico inline

Siempre incluye el CSS del hero y above-the-fold inline en `<style>` dentro del `<head>`. El resto puede ir después o al final del body.

---

## 6. Checklist de calidad (obligatorio antes de publicar)

Antes de solicitar aprobación al Board, verifica:

### Visual
- [ ] Tipografía: Syne para headings, Inter para body
- [ ] Paleta: modo oscuro con acento del giro correcto
- [ ] Hero: ocupa 100vh, tiene partículas o efecto visual
- [ ] Cards: tienen borde sutil + hover con tilt
- [ ] Imágenes: tienen blur-up loading
- [ ] WhatsApp FAB: visible y funcional

### Responsive
- [ ] Se ve bien en 375px (iPhone SE)
- [ ] Se ve bien en 768px (iPad)
- [ ] Se ve bien en 1440px (Desktop)
- [ ] Textos usan `clamp()` para escalar
- [ ] Grids usan `auto-fit` con `minmax()`

### Performance
- [ ] No frameworks JS pesados (no React, no Vue)
- [ ] Imágenes desde Pexels con lazy loading
- [ ] CSS inline para above-the-fold
- [ ] Un solo archivo HTML (CSS + JS embebido)

### Contenido
- [ ] Nombre del negocio correcto en título y h1
- [ ] Ciudad y giro mencionados correctamente
- [ ] Precios coinciden con la propuesta del Qualifier
- [ ] Teléfono/WhatsApp funcional en el enlace
- [ ] URL de reporte `/reporte` incluida si aplica

### Accesibilidad
- [ ] Contraste de texto legible (mínimo 4.5:1 para body)
- [ ] `alt` text en imágenes
- [ ] `aria-label` en el FAB de WhatsApp
- [ ] Estructura semántica: `<section>`, `<header>`, `<footer>`

---

## 7. CDNs autorizados

Solo usa CDNs verificados y estables:

```html
<!-- Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

<!-- Vanilla Tilt -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.8.1/vanilla-tilt.min.js"></script>

<!-- AOS (optional, prefer custom IntersectionObserver) -->
<link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
<script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
```

No uses npm, no instales paquetes, no uses frameworks. Todo vanilla.
