-- =============================================================================
--  1246  STOK KARTI AÇIKLAMA
--
--  Kullanıcı 02.11.2026 (stok_karti_v2.html onaylandı, "açıklama ... kutusunu da ekle"): stok kartının
--  Genel sekmesinde, alt grupların altında tam genişlik çok satırlı "Açıklama". Stok tablosunda serbest
--  metin kolonu yoktu (Delphi STOKLAR.ACIKLAMA aktarılmamıştı).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.stok add column if not exists aciklama varchar(1000);

commit;
