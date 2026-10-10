-- =============================================================================
--  1018  KURUM İCMALLERİ → KURUM İCMALİ › İCMALLER SEKMESİ (yardım kataloğu)
--
--  Kullanıcı (10.10.2026): "kurum icmallerini kurum icmali ekranına sekme
--  olarak alırsak nasıl olur", "ver2 yi kodla" (mockup Ekranlar/İcmal/
--  kurum_icmal_ver2.html). Liste menüden kalktı; eski adres /kurum-icmal
--  sekmeye yönlenir. Asistan ekranı eski yerinde tarif etmesin diye
--  ai_rehber_ekran satırı yeni yere çevrilir. Yalnız menü grubu hâlâ eski
--  değerde olan (kurumun elle değiştirmediği) satır güncellenir.
-- =============================================================================

update public.ai_rehber_ekran
   set rota = '/kurum-icmali?sekme=icmaller',
       baslik = 'Kurum İcmali › İcmaller',
       menu_grup = 'Kurumlar & Sigorta',
       menu_ad = 'Kurum İcmali',
       yol = 'Kurumlar & Sigorta › Kurum İcmali › İcmaller sekmesi'
 where kaynak = 'kurum-icmal'
   and menu_grup in ('Cari', 'Kurumlar & Sigorta')
   and rota = '/kurum-icmal';
