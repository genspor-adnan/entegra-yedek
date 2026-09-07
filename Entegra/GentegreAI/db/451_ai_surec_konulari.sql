-- =====================================================================
-- 451 - AI REHBER: SÜREÇ KONULARI
--
-- Katalogdaki konular tek işi anlatıyordu ("istem açma", "numune kabul").
-- Kullanıcı ise sık sık **işleyişi** soruyor: "biyokimya hasta testleri
-- işleyiş süreci nedir, hangi aşamalardan geçiyor?" Tek-iş konuları bu
-- soruya zayıf eşleşiyor, cevap ekran önerisine düşüyordu.
--
-- Süreç konusu = uçtan uca AKIŞ: hangi ekranda ne olur, kayıt hangi duruma
-- geçer, hangi kapı hangi şartla açılır. Adımlar kurumun gerçek akışını
-- anlatır (durum kodları `labKodlari.ts` ile birebir) - model bağlansa da
-- doğruluk kaynağı burasıdır.
--
-- SIRA: süreç konuları 200'den başlar. Eşit puanda tek-iş konusu önce
-- gelsin - "numune nasıl kabul edilir" sorana bütün süreci okutmak, sorunun
-- cevabını saklamaktır.
--
-- MODÜL BOŞ BIRAKILDI: süreç birden çok modüle dokunuyor; tek modül yazıp
-- "bu modül kapalı" uyarısı basmak yanıltırdı.
-- =====================================================================

insert into public.ai_rehber_konu
  (kod, baslik, urun_modu, modul, ekran_kaynak, yetki_kodu, anahtar, adimlar,
   uyarilar, sira)
values

-- ------------------------------------------------------- LABORATUVAR ----
('lab-surec', 'Laboratuvar süreci: istemden onaylı sonuca', 2, '', 'lab-istem', 'lab',
 'laboratuvar sureci lab sureci laboratuvar isleyisi test sureci tetkik sureci '
 || 'isleyis akis asama asamalar biyokimya hormon hematoloji kan tahlili '
 || 'numune yolculugu test nasil calisir bastan sona uctan uca',
 $j$[
  {"no":1,"ekran":"muayene","metin":"İSTEM. Tetkik ya muayene kartının İstem & Sonuçlar sekmesinden ya da bankodan Laboratuvar › İstemler ekranından açılır; istem hastanın başvurusuna bağlanır (durum: İstendi)."},
  {"no":2,"ekran":"lab-istem","metin":"TÜP PLANI. Seçilen tetkiklere göre hangi tüpten kaç adet gerektiği sunucuda hesaplanır; 🏷 Barkod Üret ile numune barkodları basılır (numune: Etiketlendi)."},
  {"no":3,"ekran":"lab-numune","metin":"NUMUNE ALMA. Kan alma biriminde barkod okutulup 🩸 Alındı İşaretle denir (numune: Alındı, istem: Numune alındı)."},
  {"no":4,"ekran":"lab-numune","metin":"KABUL / RET. Laboratuvar numuneyi ✔ Kabul Et ya da ✖ Reddet ile karşılar; ret nedeninde hemoliz, yetersiz, pıhtılı gibi kalite sebebi seçilir ve tetkikler tekrar numune bekler."},
  {"no":5,"ekran":"lab-sonuc","metin":"ÇALIŞMA. Kabul edilen numune cihaza gider; sonuç cihazdan otomatik düşer ya da Sonuç Onay Kuyruğunda elle girilir (satır: Çalışılıyor → Sonuçlandı)."},
  {"no":6,"ekran":"lab-sonuc","metin":"OTOMATİK DEĞERLENDİRME. Referans aralığına göre bayrak (H/L, panik HH/LL), önceki sonuçla delta kontrolü ve serum indeksi (hemoliz/lipemi/ikterus) çalışır; eşik aşılırsa tetkik tekrar numune ister."},
  {"no":7,"ekran":"lab-sonuc","metin":"ONAY. Kural takılmayan sonuç oto-onaydan geçer; takılan sonuç kuyrukta bekler ve ✔ Teknik Onay, ardından ✅ Uzman Onayı (yayınla) ile yayımlanır - yayın için lab.onay yetkisi gerekir."},
  {"no":8,"ekran":"lab-sonuc","metin":"PANİK DEĞER. Panik bayraklı sonuçta hekime haber verilir ve ☎ Panik Bildirimi ile kim, ne zaman, kime bildirdi kaydedilir."},
  {"no":9,"ekran":"lab-sonuc","metin":"RAPOR. Onaylı sonuçlar hasta raporunda toplanır (yazdır/PDF); istem e-Nabız kuyruğuna düşer."},
  {"no":10,"ekran":"basvuru","metin":"ÜCRETLENDİRME. Tetkikler başvurunun hizmet satırlarına yazılır; tahsilat ya da kuruma faturalama başvuru kartından yürür."}
 ]$j$::jsonb,
 'Dış laboratuvara gönderilen tetkik "Dış lab" durumunda kalır, sonucu gelince kuyruğa döner. Cihaz sonucu için o günün iç kalite kontrolü (İKK) çalışılmış olmalı; Westgard kuralı ihlâlinde sonuç onaya kapatılır.',
 200),

-- ------------------------------------------------------ HASTA AKIŞI ----
('hasta-surec', 'Hasta yolculuğu: randevudan tahsilata', 2, '', 'basvuru', 'belge',
 'hasta sureci hasta yolculugu hbys sureci isleyis akis asama randevudan faturaya '
 || 'basvuru muayene sureci hasta nasil ilerler klinik akis bastan sona uctan uca surec',
 $j$[
  {"no":1,"ekran":"hasta","metin":"HASTA KARTI. Hasta yoksa T.C. ile aranır, yoksa kart açılır; dosya numarası otomatik üretilir."},
  {"no":2,"ekran":"randevu","metin":"RANDEVU (varsa). Bölüm/hekim takviminden boş saate randevu verilir; randevusuz hasta doğrudan başvuruya alınır."},
  {"no":3,"ekran":"basvuru","metin":"BAŞVURU. Kayıt kabul başvuruyu açar, protokol numarası verilir; ödeyen kurum (özel/SGK/sigorta) ve hekim burada seçilir."},
  {"no":4,"ekran":"basvuru","metin":"PROVİZYON. Kurum başvurusunda provizyon alınır; provizyonsuz hizmet kurumdan tahsil edilemez."},
  {"no":5,"ekran":"muayene","metin":"MUAYENE. Hekim muayeneyi başvurudan açar; anamnez, bulgu, tanı (ICD-10) ve reçete burada girilir."},
  {"no":6,"ekran":"lab-istem","metin":"TETKİK / GÖRÜNTÜLEME. Muayeneden laboratuvar istemi ya da radyoloji istemi açılır; sonuçlar aynı muayene kartına döner."},
  {"no":7,"ekran":"basvuru","metin":"HİZMET SATIRLARI. Yapılan işlemler başvurunun Ücretlendirme sekmesine satır olarak düşer; fiyat, ödeyen kuruma göre listeden gelir."},
  {"no":8,"ekran":"basvuru","metin":"TAHSİLAT. Hasta payı Tahsilat sekmesinden alınır (nakit, kart, havale); kalan bakiye hastanın açık borcunda görünür."},
  {"no":9,"ekran":"basvuru","metin":"BELGE. Başvuru faturaya/serbest meslek makbuzuna dönüştürülür; kurum alacağı ise kurum hesabında toplanır."}
 ]$j$::jsonb,
 'Başvuru kapanmadan muayene ve tetkik faturalanamaz. Tamamlanma yüzdesi başvuru listesindeki şeritten izlenir.',
 205),

-- -------------------------------------------------------- RADYOLOJİ ----
('radyoloji-surec', 'Radyoloji süreci: istemden rapora', 2, '', 'radyoloji', 'radyoloji',
 'radyoloji sureci goruntuleme sureci rontgen mr bt ultrason isleyis akis asama '
 || 'tetkik cekim rapor sureci radyoloji nasil isler uctan uca',
 $j$[
  {"no":1,"ekran":"radyoloji","metin":"İSTEM. Muayeneden ya da çalışma listesinden ＋ Yeni İstem ile açılır; istem hastanın başvurusuna bağlanır ve accession numarası üretilir."},
  {"no":2,"ekran":"radyoloji","metin":"RANDEVU. Cihaz/oda takvimine 📅 Randevu Ver ile saat verilir (acil çekimlerde atlanır)."},
  {"no":3,"ekran":"radyoloji","metin":"ÇEKİM. Çekim yapılınca ✔ Çekildi İşaretle denir; kullanılan sarf 🧪 Sarf Düş ile stoktan düşülür."},
  {"no":4,"ekran":"radyoloji","metin":"RAPOR. Radyolog ✎ Rapor Yaz ile bulgu ve sonucu yazar; şablon ve metin makroları kullanılabilir."},
  {"no":5,"ekran":"radyoloji","metin":"KRİTİK BULGU. Acil bulguda hekime haber verilir ve 📞 Bildirimi Kaydet ile bildirim kaydı tutulur."},
  {"no":6,"ekran":"radyoloji","metin":"TESLİM. Rapor onaylanıp 📦 Sonuç Teslim Et ile hastaya/hekime verilir; işlem başvurunun hizmet satırına yazılır."}
 ]$j$::jsonb,
 'Rapor yazılmadan istem kapanmaz; çekilmemiş istem çalışma listesinde bekler.',
 210),

-- --------------------------------------------------- MİKROBİYOLOJİ ----
('mikrobiyoloji-surec', 'Kültür süreci: ekimden antibiyograma', 2, '', 'lab-kultur', 'lab.kultur',
 'kultur sureci mikrobiyoloji sureci ekim ureme identifikasyon antibiyogram '
 || 'isleyis akis asama kultur nasil calisir idrar kulturu kan kulturu uctan uca',
 $j$[
  {"no":1,"ekran":"lab-istem","metin":"EKİM. Kabul edilen numuneden 🧫 Ekim Yap ile kültür açılır; besiyeri ve inkübasyon koşulu seçilir."},
  {"no":2,"ekran":"lab-kultur","metin":"OKUMA. Günlük okumada üreme var/yok, koloni sayısı ve gram boyama 👁 Okuma Kaydet ile yazılır."},
  {"no":3,"ekran":"lab-kultur","metin":"ÖN RAPOR. Gram sonucu klinik için 📄 Ön Rapor (Gram) ile hemen paylaşılabilir; kesin sonuç beklenmez."},
  {"no":4,"ekran":"lab-kultur","metin":"İZOLAT. Üreyen mikroorganizma 🔬 İzolat / İdentifikasyon ile tanımlanır (organizma kataloğundan)."},
  {"no":5,"ekran":"lab-kultur","metin":"ANTİBİYOGRAM. 💊 Antibiyogram ile duyarlılık girilir; S/I/R değerlendirmesi ve dirençli üreme uyarısı burada çıkar."},
  {"no":6,"ekran":"lab-kultur","metin":"RAPOR. 🖨 Sonuç Raporu hazırlanır, ✔ Raporu Onayla ile yayımlanır ve tetkik sonuçlanmış sayılır."}
 ]$j$::jsonb,
 'Kültür süresi tetkike göre değişir; üreme yoksa negatif rapor da onaylanmalıdır - açık kalan kültür istemi kapanmaz.',
 215),

-- --------------------------------------------------------- GENETİK ----
('genetik-surec', 'Genetik süreci: vakadan raporlu varyanta', 2, '', 'lab-genetik-vaka',
 'lab.genetik',
 'genetik sureci ngs sureci dizileme sureci vaka onam dna izolasyon run varyant '
 || 'yorumlama isleyis akis asama genetik nasil calisir panel uctan uca',
 $j$[
  {"no":1,"ekran":"lab-genetik-vaka","metin":"VAKA. Lab isteminden 🧬 Genetik Vaka Aç ile vaka açılır; endikasyon ve istenen panel seçilir."},
  {"no":2,"ekran":"lab-genetik-vaka","metin":"ONAM. 📋 Onam Kaydet ile aydınlatılmış onam kayda geçer; onamsız çalışma başlatılmaz."},
  {"no":3,"ekran":"lab-genetik-vaka","metin":"İZOLASYON. 🧪 DNA İzolasyon ile konsantrasyon ve saflık değerleri girilir."},
  {"no":4,"ekran":"lab-genetik-run","metin":"RUN. Örnek 📚 Run'a Al ile dizileme rununa eklenir; run kapanınca 📊 Kalite Metrikleri (kapsama, derinlik) yazılır."},
  {"no":5,"ekran":"lab-varyant","metin":"VARYANT. Bulunan varyantlar eklenir; zigosite, kalıtım ve ACMG sınıfı ile değerlendirilir."},
  {"no":6,"ekran":"lab-genetik-vaka","metin":"RAPOR. 🖨 Sonuç Raporu yazılır, ✔ Raporu Onayla ile yayımlanır; onaylı rapor hastanın sonuçlarına düşer."}
 ]$j$::jsonb,
 'Kalite metrikleri eşiğin altındaysa örnek tekrar çalışılır; sınıflandırılmamış varyant rapora "önemi bilinmeyen" olarak girer.',
 220),

-- ------------------------------------------------ DIŞ LABORATUVAR ----
('dis-lab-surec', 'Dış laboratuvar süreci: gönderimden faturaya', 2, '', 'lab-dis-gonderim',
 'lab.dislab',
 -- "laboratuvar" KELIMESI BILEREK YOK: "laboratuvar sureci nasil isler" sorusu
 -- bu konuya vuruyordu; dis lab ozel bir dal, genel surec degil.
 'dis lab sureci dis gonderim disari gonderilen tetkik kurye teslim '
 || 'gonderilen numune sonuc gelisi anlasmali lab',
 $j$[
  {"no":1,"ekran":"lab-istem","metin":"SEÇİM. Kurumda çalışılmayan tetkik dış laboratuvara gönderilmek üzere işaretlenir; tetkik \"Dış lab\" durumuna geçer."},
  {"no":2,"ekran":"lab-dis-gonderim","metin":"GÖNDERİM. Aynı laboratuvara giden numuneler tek gönderime toplanır; 🚚 Yola Çıktı ile kurye/kargo bilgisi kaydedilir."},
  {"no":3,"ekran":"lab-dis-gonderim","metin":"TESLİM. Karşı taraf aldığında 📦 Teslim Edildi işaretlenir; bekleyen gün sayısı buradan izlenir."},
  {"no":4,"ekran":"lab-dis-gonderim","metin":"SONUÇ. Gelen sonuç 🧾 Sonuç Gir ile işlenir ve tetkik normal onay kuyruğuna döner; ✖ Dış Lab Reddetti seçilirse tetkik tekrar numune bekler."},
  {"no":5,"ekran":"lab-dis-gonderim","metin":"MALİYET. Dış laboratuvarın faturası 🧾 Alış Faturası Eşleştir ile gönderime bağlanır; tetkik başına maliyet böyle ölçülür."}
 ]$j$::jsonb,
 'Sonucu gelmeyen gönderim listede bekleyen olarak durur; hastanın raporu dış sonuç işlenmeden tamamlanmaz.',
 225),

-- -------------------------------------------------------- SATIŞ (ERP) ----
('satis-surec', 'Satış süreci: tekliften tahsilata', 1, '', 'teklif', 'belge',
 'satis sureci siparis sureci teklif irsaliye fatura tahsilat isleyis akis asama '
 || 'belge donusumu satis nasil ilerler uctan uca surec',
 $j$[
  {"no":1,"ekran":"/teklif","metin":"TEKLİF. Müşteriye teklif hazırlanır; kabul edilirse belge dönüşümüyle siparişe çevrilir (teklif kalemleri korunur)."},
  {"no":2,"ekran":"/siparis","metin":"SİPARİŞ. Sipariş stoktan rezerve edilir; kısmi sevkiyat yapılabilir, kalan miktar açık kalır."},
  {"no":3,"ekran":"/irsaliye","metin":"İRSALİYE. Mal çıkışı irsaliye ile yapılır; stok bu belgede düşer."},
  {"no":4,"ekran":"/belge","metin":"FATURA. İrsaliye(ler) faturaya dönüştürülür; tutarlar tek yerden (belge dip toplamı) hesaplanır."},
  {"no":5,"ekran":"/belge","metin":"e-BELGE. Alıcı e-Fatura mükellefi ise e-Fatura, değilse e-Arşiv olarak hazırlanıp gönderilir; durum belge üzerinde izlenir."},
  {"no":6,"ekran":"/kasa","metin":"TAHSİLAT. Ödeme kasa/banka işlemi olarak girilir ve faturaya kapatılır; kalan bakiye cari ekstresinde görünür."}
 ]$j$::jsonb,
 'Taslak belge stoğu ve cari bakiyesini etkilemez. Zincirin her adımı bir öncekinden dönüştürülerek açılırsa miktar ve fiyat tekrar girilmez.',
 230)

on conflict (kod) do update set
  baslik = excluded.baslik, urun_modu = excluded.urun_modu, modul = excluded.modul,
  ekran_kaynak = excluded.ekran_kaynak, yetki_kodu = excluded.yetki_kodu,
  anahtar = excluded.anahtar, adimlar = excluded.adimlar,
  uyarilar = excluded.uyarilar, sira = excluded.sira,
  degistirme_tarihi = now();

do $$
begin
    raise notice '451 tamam: rehber konusu % (süreç konuları eklendi)',
        (select count(*) from public.ai_rehber_konu);
end $$;
