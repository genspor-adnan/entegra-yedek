-- ============================================================================
--  Gentegre AI — Doküman paylaşım linki (kimliksiz, tahmin edilemez token ile erişim)
--  058_dokuman_paylasim.sql
--
--  Kullanici: "dokümanda gridde en sağda paylaş ekle.. adres ver onu gönderince doküman
--  açılsın". paylasim_kodu ilk paylas() cagrisinda uretilir (idempotent - tekrar
--  paylasilinca AYNI kod donuyor), NULL ise hic paylasilmamis demektir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.dokuman add column if not exists paylasim_kodu character varying(40);
create unique index if not exists ux_dokuman_paylasim_kodu on public.dokuman (paylasim_kodu) where paylasim_kodu is not null;
