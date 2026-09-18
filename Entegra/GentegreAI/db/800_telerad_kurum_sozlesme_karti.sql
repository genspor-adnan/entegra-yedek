-- =====================================================================
-- 800 - TELERADYOLOJI KURUM / SOZLESME KARTLARI
--
-- Kullanici: *"kurum ve sözleşme kartlarını da yap"*. 797'de iki liste
-- ekrani vardi ama karti yoktu: kurum ve sozlesme yalnizca goc/betikle
-- acilabiliyordu - yani teleradyoloji is baglantisi ekrandan HIC kurulamadi.
--
-- Kartlarin ihtiyaci olan tek DB nesnesi rapor sablonu secimi: kurum karti
-- "bu kurumun raporu su sablonla yazilsin" diyor ve sablon listesi bir
-- lookup gorunumu istiyor (kart alani KodTablosu ile calisir).
-- =====================================================================

-- RAPOR SABLONU LOOKUP: kod + ad birlikte (ayni adla iki surum olabilir),
--   pasif sablon secilemesin diye `durum` aktif bayragina donuyor.
create or replace view public.v_rad_sablon_lookup as
select s.id,
       (coalesce(nullif(s.kod, '') || ' · ', '') || s.ad)::varchar(200) as ad,
       case when coalesce(s.durum, 1) = 1 then 1 else 0 end             as aktif,
       -- MODALITE UST KIRILIM: BT sablonunu MR kurumunda gostermek yerine
       --   istemci gerekirse buna gore daraltabilsin.
       coalesce(s.modalite, 0)::integer                                 as ust_id
  from public.radyoloji_sablon s;

comment on view public.v_rad_sablon_lookup is
  '800: radyoloji rapor sablonu secimi (telerad kurum karti). ust_id = modalite.';
