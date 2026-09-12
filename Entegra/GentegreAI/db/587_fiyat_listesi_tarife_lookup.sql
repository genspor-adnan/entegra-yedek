-- =====================================================================
--  587_fiyat_listesi_tarife_lookup.sql
--  Anlaşmalı kurum kartı: sözleşmenin fiyat listesi KURUM TÜRÜNE göre süzülür.
--
--  Kullanıcı: "Tarife Listesi rename Fiyat Listesi olsun ve combo içine
--  başlıktaki kurum türü ne ise ona uygun fiyat listeleri gelsin."
--
--  Combo bugüne kadar TÜM satış listelerini veriyordu: SGK sözleşmesine Özel
--  tarifesi, özel kuruma SUT listesi seçilebiliyordu - ikisi de sessiz
--  yanlış fiyatlandırma demek.
--
--  Görünüm listeleri TARİFE TİPİYLE işaretler (`ust_id`); kurum türünün
--  hangi tarifeyi kullandığı ekranda tanımlıdır (web: tarifeKurallari.ts),
--  çünkü eşleme çok-a-bir: SGK ve ÖSS sözleşmesi de TTB/HUV tarifesiyle
--  çalışır, lookup satırı ise her liste için TEK üst taşıyabilir.
--
--  Kolon sözleşmesi lookup görünümleriyle aynı: id, ad, aktif, ust_id.
-- =====================================================================

create or replace view public.v_fiyat_listesi_tarife_lookup as
select l.id,
       l.ad::text                     as ad,
       l.durum                        as aktif,
       coalesce(l.tarife_tipi, 0)::integer as ust_id
  from public.fiyat_listesi l
 where l.yon = 2;

comment on view public.v_fiyat_listesi_tarife_lookup is
  'Satış fiyat listeleri, tarife tipiyle (1 Özel · 2 TTB/HUV · 3 SUT) - 587.';
