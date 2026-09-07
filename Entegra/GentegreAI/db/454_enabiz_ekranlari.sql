-- =====================================================================
-- 454 - e-NABIZ: yeni ekranlar rehber kataloğuna + süreç konusu
--
-- Faz 1'de (415-417) kuyruk, paket üretimi ve gönderici vardı; ekran olarak
-- yalnız kuyruk görünüyordu. Bu sürümle iki ekran daha açıldı:
--   * **Veri Kalitesi** panosu (`/enabiz-pano`) — "bu ay ne kadarını
--     gönderebildik, neden gönderemedik";
--   * **Kod Eşleme** (`/enabiz-kod-esleme`) — yerel tanım ile SKRS kodu
--     arasındaki köprü; eşleme yoksa paket "eksik alan" ile kuyrukta bekler.
-- Kuyruk satırının altında ayrıca **paket kartı** açılıyor (hangi USS alanı
-- boş, kaçıncı denemede ne hatası alındı) - şema değişikliği gerektirmedi.
--
-- Rehber ekranı MENÜDEKİ YERİYLE tarif eder: katalog güncellenmezse asistan
-- kullanıcıyı olmayan bir menüye gönderir.
-- =====================================================================

insert into public.ai_rehber_ekran
  (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu,
   modul, kart_yolu, menu_gizli, aksiyon_ekrani, anahtar)
values
('enabiz-pano', '/enabiz-pano', 'e-Nabız Veri Kalitesi',
 'e-Nabız › Veri Kalitesi', 'e-Nabız', 'Veri Kalitesi', 'entegrasyon', 2,
 'muayene', '', 0, '',
 'e-Nabız Veri Kalitesi uyum panosu gonderim orani eksik alan eslenmemis kod '
 || 'hata analizi enabiz istatistik'),

('enabiz-kod-esleme', '/enabiz-kod-esleme', 'e-Nabız Kod Eşleme',
 'e-Nabız › Kod Eşleme', 'e-Nabız', 'Kod Eşleme', 'entegrasyon', 2,
 'muayene', '/enabiz-kod-esleme', 0, 'enabiz-kod-esleme-liste',
 'e-Nabız Kod Eşleme SKRS kod eslemesi yerel kod klinik gelis sekli sonuc '
 || 'birimi enabiz esleme')

on conflict (rota) do update set
  kaynak = excluded.kaynak, baslik = excluded.baslik, yol = excluded.yol,
  menu_grup = excluded.menu_grup, menu_ad = excluded.menu_ad,
  yetki_kodu = excluded.yetki_kodu, urun_modu = excluded.urun_modu,
  modul = excluded.modul, kart_yolu = excluded.kart_yolu,
  aksiyon_ekrani = excluded.aksiyon_ekrani, anahtar = excluded.anahtar;

-- ---------------------------------------------------------------------
--  SÜREÇ KONUSU (451 deseni)
--
--  "e-Nabıza nasıl gidiyor" sorusu tek ekranla cevaplanmıyor: olay klinik
--  ekranda oluyor, paket arka planda üretiliyor, gönderim zamanlı işle
--  yürüyor. Kullanıcı bu zinciri görmeden "kuyruk niye dolu" diye soruyor.
-- ---------------------------------------------------------------------
insert into public.ai_rehber_konu
  (kod, baslik, urun_modu, modul, ekran_kaynak, yetki_kodu, anahtar, adimlar,
   uyarilar, sira)
values
('enabiz-surec', 'e-Nabız süreci: olaydan USS''ye', 2, '', '/enabiz-paket',
 'entegrasyon',
 'enabiz sureci e-nabiz sureci uss bildirim sureci saglik bakanligi bildirimi '
 || 'paket uretimi kuyruk gonderim isleyis akis asama nasil gidiyor '
 || 'bildirim yukumlulugu',
 $j$[
  {"no":1,"ekran":"/basvuru","metin":"OLAY. Bildirim klinik işten doğar: başvuru açılması, muayenenin tamamlanması, başvurunun kapanması. Ayrıca bir şey yapılmaz - kayıt doğruysa paket kendiliğinden üretilir."},
  {"no":2,"ekran":"/enabiz-paket","metin":"PAKET ÜRETİMİ. Olay tetiklenince USS paket türüne göre (101 Hasta Kabul, 103 Muayene, 106 Çıkış) paket üretilir; aynı kayıt için aynı içerik iki kez paket açmaz."},
  {"no":3,"ekran":"/enabiz-paket","metin":"ZORUNLU ALAN KONTROLÜ. Kılavuzun istediği alanlar dolu mu bakılır; eksikse paket \"Eksik Alan\" durumunda kuyrukta bekler ve gönderilmez."},
  {"no":4,"ekran":"/enabiz-kod-esleme","metin":"KOD EŞLEME. Klinik, geliş şekli, sonuç birimi gibi yerel tanımların SKRS karşılığı burada tanımlanır; eşleme yoksa alan geçersiz sayılır."},
  {"no":5,"ekran":"/enabiz-paket","metin":"GÖNDERİM. Zamanlı iş kuyruktan sırayla alır ve USS''ye gönderir; \"Şimdi Gönder\" ile elle de denenebilir. Servis hatası otomatik tekrarlanır, veri hatası tekrarlanmaz."},
  {"no":6,"ekran":"/enabiz-paket","metin":"DÜZELTME. Eksik ya da hatalı paket ELLE DÜZELTİLMEZ: kaynak kayıt (hasta kartı, başvuru, muayene) düzeltilir ve paket \"Yeniden Üret\" ile kaynaktan yeniden üretilir."},
  {"no":7,"ekran":"/enabiz-pano","metin":"ÖLÇÜM. Veri Kalitesi panosunda gönderim oranı, süre sınırı içinde kalan paketler, en sık hata ve eksik alanlar izlenir."}
 ]$j$::jsonb,
 'USS test hesabı / KTS tescili tanımlı değilken paketler ÜRETİLİR ve kuyrukta bekler - gönderim kapısı açılınca sırayla giderler. Gönderilmiş paket yeniden üretilemez; düzeltme için güncelleme paketi gerekir.',
 235)

on conflict (kod) do update set
  baslik = excluded.baslik, urun_modu = excluded.urun_modu, modul = excluded.modul,
  ekran_kaynak = excluded.ekran_kaynak, yetki_kodu = excluded.yetki_kodu,
  anahtar = excluded.anahtar, adimlar = excluded.adimlar,
  uyarilar = excluded.uyarilar, sira = excluded.sira,
  degistirme_tarihi = now();

do $$
begin
    raise notice '454 tamam: e-Nabız ekranı % · rehber konusu %',
        (select count(*) from public.ai_rehber_ekran where menu_grup = 'e-Nabız'),
        (select count(*) from public.ai_rehber_konu);
end $$;
