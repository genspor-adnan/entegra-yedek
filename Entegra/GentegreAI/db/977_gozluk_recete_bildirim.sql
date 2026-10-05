-- =====================================================================
-- 977 — GÖZLÜK REÇETESİ HASTAYA BİLDİRİM (mockup goz_gozluk_recete_listesi_v2:
--       araç çubuğundaki "📱 SMS / e-posta").
--
-- Hastaya REÇETE DEĞERLERİ gönderilmez: dioptri değerleri SMS'te yanlış
-- okunur (işaret, virgül, aks) ve hasta onu optikte okutulan belge sanır.
-- Mesaj yalnız reçetenin YAZILDIĞINI, numarasını ve geçerlilik tarihini
-- söyler - optikte sorulacak olan bunlar.
-- =====================================================================
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'gozluk.recete', 'Gözlük reçetesi (SMS)', 1, '',
       '{{kurum}}: {{tarih}} tarihli gözlük receteniz hazir. Recete no {{recete_no}}, gecerlilik {{gecerlilik}}. Optikte bu numarayi soyleyin.',
       '{"kurum": "Kurum adı", "tarih": "Reçete tarihi", "recete_no": "Reçete numarası", "gecerlilik": "Geçerlilik bitişi", "hasta": "Hasta adı"}',
       1, 'Göz (973): imzalı gözlük reçetesinin hastaya bildirimi.', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'gozluk.recete');

insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'gozluk.recete.eposta', 'Gözlük reçetesi (e-posta)', 2, '{{kurum}} - gözlük reçeteniz',
       'Sayın {{hasta}}, {{tarih}} tarihli gözlük reçeteniz hazır. Reçete no: {{recete_no}}. Geçerlilik: {{gecerlilik}}. Optikte reçete numarasını belirtmeniz yeterli; cam değerleri reçetede yazılıdır.',
       '{"kurum": "Kurum adı", "tarih": "Reçete tarihi", "recete_no": "Reçete numarası", "gecerlilik": "Geçerlilik bitişi", "hasta": "Hasta adı"}',
       1, 'Göz (973): imzalı gözlük reçetesinin hastaya bildirimi.', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'gozluk.recete.eposta');
