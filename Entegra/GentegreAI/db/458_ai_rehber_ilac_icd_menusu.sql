-- =====================================================================
-- 458 - REHBER KATALOĞU: İlaç Kataloğu ve ICD-10 Muayene menüsüne
--
-- İkisi de Yönetim › Ortak Platform altındaydı (kullanıcı):
--   * **İlaç Kataloğu** → Muayene altında, Muayene Ayarları'nın ÜSTÜNDE:
--     reçete yazan hekimin günlük baktığı liste, ayar değil.
--   * **ICD-10 Tanı** → Muayene › Muayene Ayarları: katalog salt görünüm,
--     senkron doldurur - kurulum tarafı.
--   * **Klinik Kataloglar** (ICD-10 + ilaç yükleme/durum ekranı) → aynı yere:
--     beslediği iki katalog da orada.
--
-- Rotalar DEĞİŞMEDİ; rehber ekranı menüdeki yeriyle tarif ettiği için
-- katalogdaki yol/menü adı güncelleniyor.
-- =====================================================================

update public.ai_rehber_ekran
   set yol = 'Muayene › İlaç Kataloğu', menu_grup = 'Muayene',
       menu_ad = 'İlaç Kataloğu'
 where rota = '/ilac';

update public.ai_rehber_ekran
   set yol = 'Muayene › Muayene Ayarları › ICD-10 Tanı', menu_grup = 'Muayene',
       menu_ad = 'ICD-10 Tanı'
 where rota = '/icd';

update public.ai_rehber_ekran
   set yol = 'Muayene › Muayene Ayarları › Klinik Kataloglar',
       menu_grup = 'Muayene', menu_ad = 'Klinik Kataloglar'
 where rota = '/katalog-ayarlar';

do $$
begin
    raise notice '458 tamam: % ekran Muayene menusune tasindi',
        (select count(*) from public.ai_rehber_ekran
          where rota in ('/ilac', '/icd', '/katalog-ayarlar')
            and menu_grup = 'Muayene');
end $$;
