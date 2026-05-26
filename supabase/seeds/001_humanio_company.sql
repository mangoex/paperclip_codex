-- Canonical Humanio company seed.
-- Safe to run multiple times. Does not include secrets.

insert into companies (
  slug,
  name,
  domain,
  status,
  metadata
)
values (
  'humanio',
  'Humanio',
  'humanio.digital',
  'active',
  jsonb_build_object(
    'slogan', 'Potenciando Humanos',
    'model', 'CEO, Contexto, Ecosistema y Orquestacion',
    'seed', '001_humanio_company'
  )
)
on conflict (slug) do update
set
  name = excluded.name,
  domain = excluded.domain,
  status = excluded.status,
  metadata = companies.metadata || excluded.metadata,
  updated_at = now();
