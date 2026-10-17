-- =============================================================================
--  1124  `hasta` YETKİSİNİN ADI: "Hasta Listesi" -> "Hasta Verisi"
--
--  Kullanıcı (17.10.2026): "yetki matrisinde kayıt kabul grubunda hasta listesi 2 tane var..
--  biri ikonsuz".
--
--  1115 Kayıt Kabul › Hasta Listesi ekranını kendi koduna (`hasta.liste`) böldü; `hasta` kodu
--  artık yalnız VERİ kapısı (hasta kartı, hasta araması, muayenedeki hasta bandı). Ama adı 684'ten
--  kalma "Hasta Listesi" idi: menüde ekranı olmayan yetki matriste kendi adıyla çizildiği için
--  aynı grupta ikinci, ikonsuz bir "Hasta Listesi" satırı görünüyordu. Ad işini söylesin.
--
--  Yalnız ad değişir; kod, haklar, rol_yetki satırları aynen kalır. Kurum adı elle değiştirmişse
--  (ad hâlâ 684'ün adı değilse) dokunulmaz. İdempotent.
-- =============================================================================

update public.yetki
   set ad = 'Hasta Verisi (kart, arama, hasta bandı)'
 where kod = 'hasta'
   and ad = 'Hasta Listesi';
