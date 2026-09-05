-- ============================================================================
--  421 - DOKUMAN KARTI SECICILERI (belge turu / klasor)
--
--  Kart alanlari kod tablosundan okur; view olmadan kart "Bilinmeyen kod
--  tablosu" ile HIC ACILMAZ (358/375/409'daki ayni tuzak).
-- ============================================================================

create or replace view public.v_dokuman_turu_lookup as
    select t.id, t.ad, t.aktif from public.dokuman_turu t;

create or replace view public.v_dokuman_klasor_lookup as
    select k.id, k.yol as ad, k.aktif from public.dokuman_klasor k;
