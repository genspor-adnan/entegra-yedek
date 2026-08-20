-- ============================================================================
--  Gentegre AI — taraf.alias_eposta (e-Fatura alias / e-Arsiv e-posta)
--  036_cari_alias_eposta.sql
--
--  e-Belge gonderiminde: alici e-Fatura mukellefiyse GIB alias'ina (urn:mail:...
--  formatinda olabilir), degilse e-Arsiv icin bu adrese e-posta gonderilir.
--  Delphi tarafinda REHBERALIAS tablosundan geliyordu (bkz. CLAUDE.md ebelge-akis.md);
--  GentegreAI'da henuz tek-satirlik basit kolon olarak taraf'a eklendi.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf add column if not exists alias_eposta varchar(200);

comment on column public.taraf.alias_eposta is
  'e-Fatura alias (GIB PK) varsa oraya, yoksa e-Arsiv icin bu adrese e-posta gonderilir.';
