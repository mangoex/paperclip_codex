# Vendor Skill Inventory

Este paquete conserva algunas skills vendorizadas para compatibilidad de import y para evitar que Paperclip falle si una referencia historica aparece en una corrida antigua.

## Usadas actualmente

- `paperclipai/paperclip/paperclip`
- `paperclipai/paperclip/para-memory-files`
- `gtmagents/gtm-agents/social-selling`
- `company/HUM/*`

## Compatibilidad / bajo uso

- `company/HUM/package-outreach`: legacy, no usar para cold outreach. Se conserva para imports antiguos.
- `lucasvibecoder/gtme-skills/web-scraping`: vendor skill no referenciado por agentes Humanio. Su frontmatter usa `name: executing-web-scraping` aunque la carpeta sea `web-scraping`; no debe cargarse en agentes hasta normalizarlo o reemplazarlo por `scrapling-official`.
- `anthropics/skills/frontend-design`, `microsoft/skills/*`, `nextlevelbuilder/ui-ux-pro-max-skill/*`, `paperclip-create-plugin`: stubs o skills auxiliares no usadas por el pipeline Humanio actual.

## Regla

Antes de borrar una vendor skill, hacer `rg` sobre `agents/`, `skills/company/HUM/` y `.paperclip.yaml` para confirmar que no existe referencia activa.
