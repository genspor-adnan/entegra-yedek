-- =============================================================================
--  1055  KURUMSAL KALİTE - KALİTE PANOSU (SADE)
--
--  Kullanıcı (12.10.2026): "Kalite 2 ile devam et" - mockup
--  Ekranlar/Kalite2/kalite_panosu.html: yedi sayı + "bana düşenler".
--  Sayılar /api/kys-pano ucunda (KysPanoUclari) hesaplanır; yeni tablo yok.
--  Yetki kys.pano 1048'de. Bu dosya yalnız asistan rehber satırını ekler.
--  İdempotent.
-- =============================================================================

begin;

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select 'kys-pano', '/kys-pano', 'Kalite Panosu', 'Kalite › Pano', 'Kalite', 'Pano', 'kys.pano', 0,
       'kalite pano açık döf vadesi geçen olay bildirimi denetim yüksek risk hedef dışı kalibrasyon eğitim bana düşenler',
       'Kurumsal kalite özeti: açık / vadesi geçen DÖF, değerlendirilecek olay, bu ayın denetimleri, yüksek risk, '
       || 'hedef dışı gösterge, kalibrasyonu yaklaşan cihaz, eksik zorunlu eğitim ve kullanıcıya atanmış işler.', ''
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'kys-pano');

commit;
