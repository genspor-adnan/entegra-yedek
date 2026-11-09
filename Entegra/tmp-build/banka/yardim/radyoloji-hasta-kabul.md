---
id: radyoloji-hasta-kabul
baslik: Görüntüleme hastası kabulü (randevudan başvuru, istem ve tahsilat)
modul: radyoloji
ekran: randevu
rota: /randevu
surec: radyoloji
roller: banko_gorevlisi, doktor_sekreteri, kayit_kabul
dil: tr
surum: 1
urun_modu: 2
yetki: randevu
erisim: kullanici
ozet: Cihaz randevusu olan hasta geldiğinde Geldi / Başvuruya Dönüştür ile açılan Radyoloji İstemi (kabul) penceresi; tetkik seçimi, isteyen hekim / kurum, ödeyen kurum, kabul sonrası seçenekleri ve tahsilat.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Görüntüleme merkezinde hasta çoğunlukla **randevu alarak** gelir. Randevu yalnız bir plandır: başvuru, ücret ve istem (Accession No) yoktur. Hasta kapıya geldiğinde **kabul** yapılır; bu tek işlemde başvuru (protokol) açılır, her tetkik için ayrı istem oluşur, ücret başvuruya yazılır ve istenirse tahsilat alınır. İstem ancak bundan sonra teknisyenin çalışma listesine düşer.

## Ekrana giriş yolları
- **Randevu › Randevular**: hastanın cihaz randevusunu seçin → **✔ Geldi** ya da **➜ Başvuruya Dönüştür**. Cihazlı randevuda iki düğme de durum yazmak yerine **Radyoloji İstemi — [hasta adı]** penceresini açar.
- Polikliniği olan merkezde hekimin muayeneden istediği görüntüleme başvuru kartında **🩺 Doktor İstemi** ile ücretlendirilir (bkz. `basvuru-acma`).

## Ön koşullar
- **randevu** yetkisi; başvuru açmak için **belge** Ekle; tahsilat için **kasa_islem** ve (kurum ayarı açıksa) **açık banko oturumu**.
- Hasta kayıtlı olmalı; randevuda hasta yoksa "Randevuda hasta yok." uyarısı gelir.
- Tetkik hizmet kartında **modalite** tanımlı olmalı; yoksa tetkik listede çıkmaz.

## Alanlar
- **Tetkik Seçimi** (sol ağaç): randevunun tetkiki seçili gelir; birden çok tetkik seçilebilir, her biri **ayrı istem / ayrı Accession No** olur.
- **İstem Bilgisi**: İsteyen Hekim (kayıtlı) ya da **İsteyen Hekim (dış)** / **Hekim Adı (kayıtsız)**, İsteyen Kurum, **Ön Tanı (ICD-10)**, **Klinik Bilgi / İstem Gerekçesi (zorunlu)**, Öncelik (Normal / Acil / Çok Acil), Kontrast (Verilmeyecek / Verilecek).
- **Ödeme / Kabul**: Ödeyen Kurum (boşsa hasta kendi öder), Poliçe No (hastanın aktif poliçesinden gelir), satır bazlı Liste / İndirim / Tutar, Hastadan / Kurumdan payı ve Genel Toplam. "Başvuru aç ve ücretlendir" kutusu açık gelir.
- **Kabul Sonrası**: Cihaz listesine (MWL) gönder · Randevu / hazırlık SMS'i yolla · Hazırlık talimatı ver · Sonuç için CD hazırla. Hazırlık metni tetkikin çekim protokolünden gelir.
- **📷 İstem Kâğıdını Tara**: dış hekimin istek kâğıdını isteme ekler.

## Adım adım
1. **Randevu › Randevular**'da hastanın satırını seçin, **✔ Geldi**'ye basın.
2. Açılan pencerede tetkiğin doğru olduğunu kontrol edin; gerekirse başka tetkik ekleyin.
3. İsteyen hekimi seçin (dış hekimse adını yazın), **Klinik Bilgi**'yi doldurun — radyolog raporu bu bilgiyle yazar.
4. Ödeyen kurumu ve poliçe numarasını kontrol edin; tutarları gözden geçirin.
5. Hastaya CD verilecekse **Sonuç için CD hazırla**'yı işaretleyin (teslimde CD kutusu hazır gelir).
6. Ödeme şimdi alınacaksa **💵 Tahsilat Al ve Kabul Et**, alınmayacaksa **✔ İstemi Aç (n)**.
7. Ekranda "n istem açıldı: [Accession No'lar]" mesajını görün. Hastadan ödeme kaldıysa **💵 Tahsilat Al (tutar)** düğmesi çıkar.
8. Randevu kendiliğinden **Geldi** olur ve başvuruya bağlanır; istem teknisyenin listesinde **Bekleyen Çekim**'de görünür.

## Randevusuz gelen hasta
Kabul penceresi randevudan açılır. Randevusuz gelen hasta için önce **Randevu › Randevular › 📅 Takvim**'de ilgili cihazın şimdiki saatine randevu verin, ardından **✔ Geldi** ile kabul edin. (Bu yol kurumunuzda farklı tanımlanmış olabilir; sorumlunuza danışın.)

## Sık karşılaşılan sorunlar
- **"En az bir tetkik seçilmeli."** → soldan tetkik seçin.
- **"Klinik bilgi / istem gerekçesi yazılmalı — radyolog raporu buradan yazar."** → klinik bilgi zorunludur.
- **"Tahsilat için açık banko oturumu gerekiyor."** → vardiyanızı açın (`banko-oturum-gun-sonu`), sonra başvuru kartının Tahsilat sekmesinden ödemeyi alın.
- **"Kurum tutarın tamamını karşılıyor — hastadan tahsilat yok."** → bilgi mesajı; hastadan para alınmaz.
- **"Tetkik ile cihazın modalitesi uyuşmuyor"** → randevunun cihazı tetkiğe uygun değil; istem cihazsız açılır, teknisyen randevu verir.
- **"Randevuda hasta yok."** → randevu kartında hastayı seçin.

## Yapılmaması gerekenler
- Aynı hastaya aynı gün ikinci başvuru açmayın; sistem açık başvuruyu getirir.
- Önce tahsilat, sonra istem sırasıyla çalışmayın; pencere önce kaydı açar, sonra parayı alır ("tahsil edildi ama istem yok" kalmasın diye).
- Klinik bilgiye "kontrol" gibi boş ifadeler yazmayın; raporun kalitesi buna bağlıdır.

## Örnek sorular
- Radyoloji hastasının kabulü nasıl yapılır?
- Randevulu hasta geldiğinde ne yapmalıyım?
- Accession numarası nereden verilir?
- Dış hekimden gelen istek kâğıdını nasıl eklerim?
- Kabulde CD hazırla ne işe yarar?
- Randevusuz gelen hastayı nasıl kabul ederim?

## Kaynaklar
- web/src/sayfalar/liste/randevuAksiyonlari.ts (cihazlı randevuda Geldi / Başvuru = kabul)
- web/src/bilesenler/radyoloji/IstemModali.tsx, web/src/sayfalar/liste/RadyolojiModallari.tsx
- api/src/Gentegre.Api/Uclar/RadyolojiUclari.cs (POST /api/radyoloji/istem)
- dokuman/00_TARIHCE.md (310-313 kabul ekranı, 316-317 randevudan kabul)

## Doğrulama durumu
Kod incelemesiyle yazıldı. "Randevusuz gelen hasta" bölümü kod yolundan çıkarıldı (kabul penceresi yalnız randevudan açılıyor); kurum uygulamasıyla doğrulanmalı. İnsan doğrulaması bekliyor.
