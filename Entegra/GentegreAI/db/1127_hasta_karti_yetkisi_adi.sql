-- =============================================================================
--  1127  `hasta` YETKİSİNİN ADI: "Hasta Verisi (kart, arama, hasta bandı)" -> "Hasta Kartı"
--
--  Kullanıcı (17.10.2026): "hasta verisi rename Hasta Kartı olsun". 1126'dan beri hasta kartının
--  Gör / Ekle / Değiştir / Sil'i bu kodda (Hasta Listesi yalnız Gör). Başvuru tarafındaki
--  "Başvuru Kartı" (1125) ile aynı ad deseni.
--
--  Yalnız ad değişir. Ad 1124'ün koyduğu ad değilse (kurum elle değiştirmiş) dokunulmaz.
--  1124'ü hiç almamış kurulumda eski "Hasta Listesi" adı da düzeltilir. İdempotent.
-- =============================================================================

update public.yetki
   set ad = 'Hasta Kartı'
 where kod = 'hasta'
   and ad in ('Hasta Verisi (kart, arama, hasta bandı)', 'Hasta Listesi');
