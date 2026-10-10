-- =============================================================================
--  1022  "Hekim Performans İcmali" -> "Doktor Performans İcmali" (yalnız ad)
--
--  Kullanıcı (10.10.2026): "Hekim Performans İcmali rename Doktor Performans
--  İcmali". Ekran kodu (prim.hekim_performans) ve adres (/hekim-performans)
--  DEĞİŞMEZ - rol yetkileri ve bağlantılar bozulmasın. Yalnız yetki
--  matrisinde görünen ad ve yardım kataloğu. Kurumun elle değiştirmediği
--  (hâlâ eski adı taşıyan) satırlar güncellenir.
-- =============================================================================

update public.yetki
   set ad = 'Doktor Performans İcmali (İK)'
 where kod = 'prim.hekim_performans' and ad = 'Hekim Performans İcmali (İK)';

update public.ai_rehber_ekran
   set baslik = 'Doktor Performans İcmali',
       menu_ad = 'Doktor Performans İcmali',
       yol = 'İK › Doktor Performans İcmali',
       anahtar = anahtar || ' doktor'
 where kaynak = 'hekim-performans' and menu_ad = 'Hekim Performans İcmali';
