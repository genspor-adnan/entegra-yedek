---
id: icmal-cagri-icmal
baslik: Çağrı Merkezi İcmali
modul: cagri
ekran: cagri-icmal
rota: /cagri-icmal
surec: icmal
roller: cagri_supervizor, yonetim
dil: tr
surum: 1
urun_modu: 2
yetki: cagri.icmal
erisim: kullanici
ozet: Seçilen dönemde çağrı merkezinin kuyruk başına gelen / cevaplanan / terk edilen aramalarını, SLA'yı, bekleme ve görüşme sürelerini, randevuya dönüşmeyi, temsilci performansını, saat ve gün yoğunluğunu, geri arama zamanlamasını ve kampanya başarısını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Çağrı Merkezi İcmali "aramaların ne kadarını zamanında cevapladık, kaç arayanı kaybettik, kaç arama randevuya döndü, geri aramalar zamanında yapıldı mı, hangi saatlerde personel yetmiyor?" sorusunu cevaplar. Çağrı merkezi süpervizörü vardiya ve personel planlaması, yönetim hizmet kalitesi izleme için kullanır. Ekran salt okunurdur; anlık izleme Süpervizör Panosu'ndadır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Kuyruğa göre süzme** — 📥 Kuyruk listesinden tek kuyruk seçin ya da Tümü.
- **Kanala göre süzme** — ☎ Kanal: Tümü / Telefon / WhatsApp / SMS / Web formu / E-posta.
- **Sekmeler arasında geçiş** — Kuyruklar, Temsilciler, Saat Yoğunluğu, Geri Aramalar, Kampanyalar.
- **Kuyruğun sonuç dağılımını açma** — Kuyruklar sekmesinde kuyruk adının önündeki ▸ işaretine tıklayın; cevaplanan çağrıların sonuçlara göre dağılımı açılır.
- **A4 için kuyruk seçme** — satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; çıktı seçili kuyrukları basar.
- **Geciken geri aramaları görme** — Geri Aramalar sekmesinde kaynak bazında özet ve geciken / yapılmayan geri aramalar listesi (en fazla 50, numaralar maskeli).
- **Başka ekrana geçme** — **📡 Süpervizör Panosu**, **📋 Çağrılar** ve **📣 Kampanyalar** düğmeleri.
- **Çıktı alma** — "Çağrı Merkezi İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Çağrı Merkezi › Çağrı Merkezi İcmali** (yalnız HBYS).
- Dönem, kuyruk ve kanal adres çubuğunda tutulur.
- Yetki kodu `cagri.icmal`; haklarını `cagri.supervizor` yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: çağrı tarihine göre.
- **Kuyruk** ve **Kanal** sunucuda uygulanır. Süzgeç değişince A4 seçimi sıfırlanır.
- Şeritte rozetler: **SLA** (hedefe ulaştıysa yeşil, değilse kırmızı) ve geciken / yapılmayan geri arama sayısı.

## Özet ve sekmeler
- Kutular: **Gelen Arama** (telefon, WhatsApp, diğer), **Cevaplanan** (cevap oranı, SLA), **Terk / Sesli** (terk oranı; sesli mesaj / mesai dışı), **Ort. Bekleme** (en uzun), **Ort. Görüşme** (işlem sonrası ortalama), **Randevuya Dönüşme**, **Geri Arama Zamanında** (istek ve hedef süre), **Giden Arama** (geri arama ve kampanya).
- **Kuyruklar**: Kuyruk (SLA süresi ve hedefi), Gelen, Cevaplanan, Terk, Sesli / Mesai Dışı, Cevap %, SLA, Ort. Bekleme, En Uzun, Ort. Görüşme, Randevu; toplam satırı.
- **Temsilciler**: Temsilci, Dahili, Gelen, Giden, Konuşma, Ort. Görüşme, Ort. İşlem Sonrası, Randevu, Dönüşüm, Geri Arama (zamanında / geç / yok), Kalite, İş Yükü.
- **Saat Yoğunluğu**: saat bazında Gelen, Cevaplanan, Terk, Sesli, SLA, Ort. Bekleme; haftanın günü bazında gün başına ortalama.
- **Geri Aramalar**: kaynağa göre İstek, Zamanında, Geç, Yapılmadı, Süresiz Tamam, Ulaşıldı, Ort. Süre, Zamanında %; altında geciken / yapılmayan liste.
- **Kampanyalar**: Kampanya, Tür, Kanal, Kişi, Arama, Ulaşılan, Onayladı / Randevu, İptal Etti, Ulaşılamadı, Bekliyor, Başarı.

## Rakamlar nereden gelir
Veri `/api/cagri-icmal` ucundan (`CagriIcmalUclari`) gelir; uç yalnız okur.
- Gelen = gelen yönlü çağrı; cevaplanan = cevap zamanı dolu; terk = "Kaçan" durumu; sesli / mesai dışı ayrı sayılır. Giden = giden yönlü çağrı.
- SLA = kuyruğun SLA süresi içinde cevaplanan / (cevaplanan + terk); sesli mesaj SLA'ya girmez. Kuyrukta SLA tanımlı değilse varsayılan kullanılır.
- Randevuya dönüşme = sonucu "Randevu verildi" olan / cevaplanan gelen.
- Geri arama isteği = sonucu "geri aranacak" olan, terk edilen ya da sesli mesaj bırakılan çağrı. Tamamlanma = istekten sonra aynı numaraya / kişiye yapılan ilk giden arama; zamanında = ayardaki hedef süre (`cagri.geri_arama_hedef_dk`, varsayılan 120 dk) içinde. Elle tamam işaretlenip giden araması bulunamayan istek "süresiz" sayılır.
- Kampanya başarısı = onaylayan / ulaşılan; dönemle kesişen kampanyalar alınır.

## Çıktı
**Çağrı Merkezi İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Kuyruk seçiliyken "A4 seçili N kuyruğu basar" notu çıkar. A4'te arayan bilgisi yoktur.

## Dikkat edilecekler
- Telefon numaraları maskeli, arayan adları kısaltılmış gösterilir.
- 4 saatten uzun görünen çağrılar (kapanmamış kayıt) görüşme süresi ortalamasına girmez; sayısı Kuyruklar sekmesinin altındaki notta yazar.
- Gelen sayısı cevaplanan + terk + sesli toplamından büyük olabilir: çalan / beklemede kalan çağrılar da gelene sayılır.
- Geri arama tamamlanma zamanı ayrıca tutulmaz; aynı numaraya giden arama yapılmadıysa istek "yapılmadı" görünür.

## Örnek sorular
- Geçen ay SLA hedefini tutturduk mu?
- Kaç arayan beklerken kapattı?
- Hangi saatlerde terk oranı yükseliyor?
- Geri aramalar zamanında yapılıyor mu?
- Hangi temsilci en çok randevu verdi?
- Hatırlatma kampanyasının başarısı ne oldu?
