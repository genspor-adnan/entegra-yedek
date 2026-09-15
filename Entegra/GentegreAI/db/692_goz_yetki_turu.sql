-- 692: GÖZ YETKİLERİ — ekran yetkileri KAYNAK yetkisi olmalı (tur 0).
--
-- 691 göz alt yetkilerini AKSİYON (tur = 1) olarak açmıştı. Sonuç: menüde
-- yalnız "Ünite Akışı" görünüyordu, Muayeneler / Görüntüleme / İşlemler /
-- Reçeteler / Takip / Cihazlar hem menüden hem ROTADAN düşüyordu — kabuk ve
-- rota süzgeci `yetki(kod)` ile KAYNAK yetkisine bakar; aksiyon yetkileri
-- (tur 1) ekran açmaz, yalnız ekran içindeki düğmeyi yetkilendirir.
--
-- Laboratuvardaki ayrımın aynısı: `lab.numune` / `lab.sonuc` / `lab.kk` birer
-- EKRANDIR ve tur = 0'dır; `lab.kk.onay` bir KARARDIR ve tur = 1'dir. Gözde de
-- ölçüm ekranları kaynak, "değerlendirmeyi imzala" ve "işlemi uygula"
-- aksiyondur.
--
-- Ayrım süs değil: göz ünitesinde tekniker ön tetkik ekranını görmeli ama
-- muayene ekranını görmemeli; optik görevlisi yalnız reçeteyi görmeli. Tek bir
-- `goz` yetkisiyle hepsi birden açılır ya da birden kapanırdı.

-- Ekran (kaynak) yetkileri: tur 0, grup modülün adı.
update public.yetki
   set tur = 0, grup = 'Göz'
 where kod in ('goz.on_tetkik', 'goz.muayene', 'goz.goruntuleme',
               'goz.recete', 'goz.islem', 'goz.takip', 'goz.cihaz');

-- Karar (aksiyon) yetkileri tur 1 kalır, yalnız grubu düzelir: aksiyon
--   listesinde "Göz" başlığı altında toplansınlar.
update public.yetki
   set grup = 'Göz'
 where kod in ('goz.goruntuleme.degerlendir', 'goz.islem.uygula');

-- Modül kökü de 'belge' grubuna düşmüştü (radyolojiden kopyalanırken);
--   yetki ağacında Göz kendi başlığı altında dursun.
update public.yetki
   set grup = 'Göz'
 where kod = 'goz';
