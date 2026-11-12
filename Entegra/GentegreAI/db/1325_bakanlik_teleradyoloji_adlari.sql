-- 1325 - Ekran adları: Bakanlık TeleRadyoloji ekranları "Bakanlık" önekiyle
--
-- Kullanıcı 12.11.2026: "2 tane teleradyoloji panosu var". 1319'da "Teletıp" → "TeleRadyoloji" olunca Bakanlık panosu
-- (radyoloji.teletip.pano) kurumlar arası ticari teleradyoloji panosuyla (Radyoloji › Teleradyoloji › Telerad Panosu) aynı
-- okunuyordu. Bakanlık'a giden ekranlar "Bakanlık TeleRadyoloji …" adını alır (menü + yetki matrisi). Yalnız 1319'un
-- yazdığı ad değiştirilir - kurumun elle değiştirdiği ad korunur. Yetki kodları değişmez.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;
update public.yetki set ad = 'Bakanlık TeleRadyoloji Gönderimleri (Radyoloji)'
 where kod = 'radyoloji.teletip'      and ad = 'TeleRadyoloji Gönderimleri (Radyoloji)';
update public.yetki set ad = 'Bakanlık TeleRadyoloji Panosu (Radyoloji)'
 where kod = 'radyoloji.teletip.pano' and ad = 'TeleRadyoloji Panosu (Radyoloji)';
-- Ayar ekranı kalktı (şube özeti panoda); yetki yalnız eski rol eşlemeleri için durur.
update public.yetki set ad = 'Bakanlık TeleRadyoloji şube özeti (eski ayar ekranı)'
 where kod = 'radyoloji.teletip.ayar' and ad = 'TeleRadyoloji Ayarları (Radyoloji)';
commit;
