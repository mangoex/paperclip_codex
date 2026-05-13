# Surge.sh Redirect Shim

Mientras Meta aprueba el template nuevo de WhatsApp con botón apuntando a `humanio.digital`, este shim hace que cualquier click del template actual (que va a `humanio.surge.sh/{slug}`) termine en `www.humanio.digital/?ref={slug}`.

## Deploy (una sola vez, manual)

```bash
cd scripts/surge-redirect/
SURGE_LOGIN=mangoex@gmail.com SURGE_TOKEN=$SURGE_TOKEN surge . humanio.surge.sh
```

El archivo `200.html` actúa como fallback para que rutas sin archivo propio (`humanio.surge.sh/{slug}/`) carguen el mismo redirect en vez de devolver 404. Después puedes deployar lo que quieras dentro de subcarpetas; si no existe una subcarpeta para el slug, caerá al fallback → redirect.

## Cuando llegue el template nuevo aprobado por Meta

- Botón URL del nuevo template: `https://www.humanio.digital/?ref={{1}}`
- Cuando esté aprobado, actualiza `outreach-proposals/SKILL.md` para usar el nombre nuevo del template.
- Este shim se vuelve innecesario, pero puede quedarse como branding/seguridad por si algún cliente viejo todavía clickea links viejos.
