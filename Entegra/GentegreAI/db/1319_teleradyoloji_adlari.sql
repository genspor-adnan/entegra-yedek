-- 1319 - Ekran adları: "Teletıp" yerine "TeleRadyoloji" (kullanıcı 12.11.2026: "teletıp yerine TeleRadyoloji kullanalım")
--
-- Yalnız görünen adlar. Teknik adlar değişmez: yetki kodları (radyoloji.teletip*), teletip_gonderim tablosu, teletip.*
-- ayar anahtarları, Mirth kanalları (TELETIP_*), Bakanlık alan adı (teletip.saglik.gov.tr). Laboratuvar / onam
-- ekranlarındaki "Teletıp" istem kaynağı başka bir kavram - dokunulmaz.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;
update public.yetki set ad = 'TeleRadyoloji Gönderimleri (Radyoloji)' where kod = 'radyoloji.teletip'       and ad like 'Teletıp%';
update public.yetki set ad = 'TeleRadyoloji Panosu (Radyoloji)'      where kod = 'radyoloji.teletip.pano'  and ad like 'Teletıp%';
update public.yetki set ad = 'TeleRadyoloji Ayarları (Radyoloji)'    where kod = 'radyoloji.teletip.ayar'  and ad like 'Teletıp%';
commit;
