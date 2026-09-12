-- =====================================================================
--  557_kategori_ad_kirp.sql
--  Kategori adlarındaki baş/son boşluklar temizlenir.
--
--  546 kategorileri SKRS dökümünden gelen hizmet başlıklarından üretmişti ve
--  o dökümde adlar kırpılmamış: "Radyoloji ", "Tahlil İşlemleri ". Etkisi
--  görünür - alt kategori eklenince liste "Radyoloji  > Bilgisayarlı
--  Tomografi" (çift boşuk) yazıyor; ayrıca ada göre yapılan her eşleştirme
--  (göç, arama, süzgeç) sessizce tutmuyor.
--
--  Yalnız boşluk kırpılır; adın kendisine dokunulmaz.
-- =====================================================================

update public.kategori
   set ad = btrim(ad)
 where ad <> btrim(ad);

update public.kategori
   set kod = btrim(kod)
 where kod <> btrim(kod);

-- Aynı sorun hizmet/stok adlarında da var (aynı dökümden geldi): başlık
--   satırları ve kalem adları. Kırpmak arama ve eşleşmeyi düzeltir, veriyi
--   değiştirmez.
update public.hizmet set ad = btrim(ad) where ad <> btrim(ad);
update public.stok   set ad = btrim(ad) where ad <> btrim(ad);
