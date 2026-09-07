-- =====================================================================
-- 456 - REHBER KATALOĞU: Muayene Ayarları alt menüsü
--
-- Yönetim › Muayene alt başlığı (Muayene Şablonları · Metin Makroları)
-- **Muayene** ana menüsünün altına, "Muayene Ayarları" adıyla ve en sona
-- alındı (kullanıcı): şablon ve makro, muayene yazan hekimin işidir -
-- yönetim menüsünün dibinde aranıyordu.
--
-- Rehber ekranı menüdeki yeriyle tarif eder; katalog güncellenmezse asistan
-- artık var olmayan bir menü yolunu söyler. Rotalar DEĞİŞMEDİ.
-- =====================================================================

update public.ai_rehber_ekran
   set yol = 'Muayene › Muayene Ayarları › Muayene Şablonları',
       menu_grup = 'Muayene', menu_ad = 'Muayene Şablonları'
 where rota = '/muayene-sablon';

update public.ai_rehber_ekran
   set yol = 'Muayene › Muayene Ayarları › Metin Makroları',
       menu_grup = 'Muayene', menu_ad = 'Metin Makroları'
 where rota = '/metin-makro';

do $$
begin
    raise notice '456 tamam: % ekran Muayene menusune tasindi',
        (select count(*) from public.ai_rehber_ekran
          where rota in ('/muayene-sablon', '/metin-makro') and menu_grup = 'Muayene');
end $$;
