-- =============================================================================
--  1029  "Dönem İcmali" (Yatan Hasta) -> "Yatan Hasta İcmali" (yalnız ad)
--
--  Kullanıcı (11.10.2026): "Dönem icmali rename Yatan Hasta İcmali". Ekran
--  kodu (yatan.donem_icmal) ve adres (/yatan-icmal) DEĞİŞMEZ - rol yetkileri
--  ve bağlantılar bozulmasın. Yalnız yetki matrisinde görünen ad ve yardım
--  kataloğu; kurumun elle değiştirmediği (hâlâ eski adı taşıyan) satırlar.
-- =============================================================================

update public.yetki
   set ad = 'Yatan Hasta İcmali (Yatan Hasta)'
 where kod = 'yatan.donem_icmal' and ad = 'Dönem İcmali (Yatan Hasta)';

update public.ai_rehber_ekran
   set menu_ad = 'Yatan Hasta İcmali',
       yol = 'Yatan Hasta › Yatan Hasta İcmali'
 where kaynak = 'yatan-icmal' and menu_ad = 'Dönem İcmali';
