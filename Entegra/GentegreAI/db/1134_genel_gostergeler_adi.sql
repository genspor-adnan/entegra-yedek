-- =============================================================================
--  1134  GÖSTERGE PANELİ "Genel (Ana Sayfa)" -> "Genel Göstergeler", ikon 🏠 -> 📊
--
--  Kullanıcı (17.10.2026): "Gösterge Panellerinde Genel (Ana Sayfa) rename Genel Göstergeler",
--  "ikonunu da veri yap, ev yerine". Ana sayfa artık ekran kutularından oluşuyor; "Ana Sayfa" adı ve
--  ev ikonu bu paneli ana sayfanın kendisi sandırıyordu.
--
--  Panel ve yetki satırı (matris: gosterge.genel). Kurum adı / ikonu elle değiştirmişse dokunulmaz.
--  İdempotent.
-- =============================================================================

update public.gosterge_paneli
   set ad = 'Genel Göstergeler'
 where kod = 'genel' and ad = 'Genel (Ana Sayfa)';

update public.gosterge_paneli
   set ikon = '📊'
 where kod = 'genel' and ikon = '🏠';

update public.yetki
   set ad = 'Genel Göstergeler'
 where kod = 'gosterge.genel' and ad = 'Genel (Ana Sayfa)';
