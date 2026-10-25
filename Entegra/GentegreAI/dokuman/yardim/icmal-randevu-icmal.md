---
id: icmal-randevu-icmal
baslik: Randevu / Poliklinik İcmali
modul: randevu
ekran: randevu-icmal
rota: /randevu-icmal
surec: icmal
roller: yonetim, poliklinik_sorumlusu, randevu_birimi
dil: tr
surum: 1
urun_modu: 2
yetki: randevu.icmal
erisim: kullanici
ozet: Seçilen dönemde verilen, gelen, gelmeyen ve iptal edilen hekim randevularını; poliklinik ve hekim başına slot doluluğunu, kanalları, gün × saat yoğunluğunu, bekleme süresini ve gelmeyen hastaları gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Randevu / Poliklinik İcmali "polikliniklerimiz ne kadar dolu, hastaların ne kadarı randevusuna gelmiyor, hangi saatler boş kalıyor, hasta ne kadar bekliyor?" sorusunu cevaplar. Yönetim ve poliklinik sorumluları kapasite planlaması, randevu birimi gelmeyen hasta takibi için kullanır. Ekran salt okunurdur; randevu ve çalışma planı kendi ekranlarında düzenlenir.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Süzme** — 🏥 Poliklinik, 🩺 Hekim, 📲 Kanal ve 🔖 Tip listelerinden seçim yapın (her biri Tümü ile kaldırılır).
- **Sekmeler arasında geçiş** — Poliklinikler, Hekimler, Kanallar, Gün / Saat, Gelmeyenler.
- **Polikliniğin hekimlerini açma** — Poliklinikler sekmesinde poliklinik adının önündeki ▸ işaretine tıklayın; hekim satırları (çalışılan gün, izin günü) açılır.
- **A4 için poliklinik seçme** — satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; çıktı seçili poliklinikleri basar.
- **Gelmeyen hastaları görme** — Gelmeyenler sekmesi gelmeyen randevuları önceki gelmeme sayısına göre sıralı listeler.
- **Başka ekrana geçme** — **📅 Randevular** ve **🗓 Çalışma Planı** düğmeleri.
- **Çıktı alma** — "Poliklinik İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Randevu › Randevu / Poliklinik İcmali** (yalnız HBYS).
- Dönem ve süzgeçler adres çubuğunda tutulur.
- Yetki kodu `randevu.icmal`; haklarını `randevu` yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: randevu saati, şubenin yerel saatine göre.
- **Poliklinik** (randevunun bölümü), **Hekim**, **Kanal** (randevu kartındaki "Kaynak" alanı), **Tip** (ilk / kontrol vb.). Seçenekler süzülmemiş veriden gelir.
- Kanal ve tip süzgeci slot sayısına ve randevusuz muayeneye **uygulanmaz**.
- Süzgeç değişince A4 seçimi sıfırlanır. Şeritte rozetler: gelmeme oranı (%10 üstü sarı), "hasta 3. kez gelmedi" sayısı, sonuçlanmamış (planlandı durumunda kalan) randevu sayısı.

## Özet ve sekmeler
- Kutular: **Verilen Randevu** (kayıt ve iptal sayısı), **Gelen** (oran), **Gelmeyen** (no-show oranı), **İptal**, **Slot Doluluğu** (verilen / slot, boş slot), **Ort. Bekleme** (30+ dk bekleyen sayısı), **Randevusuz Muayene** (toplam muayene), **İlk / Kontrol** oranı.
- **Poliklinikler**: Poliklinik, Hekim, Slot, Verilen, Doluluk, Gelen, Gelmeyen, No-show, İptal, Randevusuz, Ort. Bekleme, İlk / Kontrol.
- **Hekimler**: Hekim, Poliklinik, Gün, Slot, Dolu, Boş, Doluluk, No-show, Muayene, Gün Başı, Ort. Bekleme, 30+ dk.
- **Kanallar**: Kanal, Kayıt, Pay, Verilen, Gelen, Gelmeyen, No-show, İptal, Ort. Öne Alma.
- **Gün / Saat**: saat × haftanın günü tablosu (slot ve verilen), altında bekleme süresi dilimleri.
- **Gelmeyenler**: Randevu, Tarih / Saat, Hasta, Poliklinik, Hekim, Kanal, Tip, Önceki Gelmeme, Verilme (en çok 500 satır).

## Rakamlar nereden gelir
Veri `GET /api/randevu-icmal` ucundan (`RandevuIcmalUclari`) gelir; uç yalnız okur.
- Yalnız **hekim randevusu** sayılır; cihaz / ünite randevusu poliklinik değildir. Durumlar: 1 planlandı, 2 geldi, 3 gelmedi, 4 iptal.
- Kayıt = iptal dahil bütün randevular; Verilen = iptal dışı (1–3); no-show = gelmedi / verilen; iptal doluluğa girmez.
- Slot = çalışma planı blokları slot süresine bölünerek; izin / kongre / kapalı gün slot üretmez. Doluluk = verilen / slot.
- Bekleme = randevu saati → muayene başlangıcı (randevuya bağlı muayene, yalnız gelenler; erken başlayan 0 dk).
- Randevusuz muayene = randevuya bağlı olmayan, tarihi dönemde olan muayene.
- Önceki gelmeme = aynı hastanın son 6 ayda gelmediği randevu sayısı.

## Çıktı
**Poliklinik İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Poliklinik seçiliyken "A4 seçili N polikliniği basar" notu çıkar. A4'te hasta bilgisi yoktur; hasta adı yalnız ekrandaki Gelmeyenler listesindedir (TC gösterilmez).

## Dikkat edilecekler
- "Planlandı" durumunda kalan randevular sonuçlanmamıştır; gelen / gelmeyen işaretlenmedikçe oranlar eksik görünür.
- Çalışma planı tanımlı olmayan hekimde slot sıfırdır, doluluk hesaplanamaz ("çalışma planı yok").
- Bekleme yalnız muayene başlama saati girilmiş ve randevuya bağlanmış muayenelerden ölçülür.
- Gelmeyenler listesi 500 satırla sınırlıdır; toplam sayı alttaki notta yazar.

## Örnek sorular
- Geçen ay randevuya gelmeme oranımız neydi?
- Hangi poliklinik en boş?
- Hastalar randevu saatinden sonra ne kadar bekliyor?
- Üçüncü kez randevusuna gelmeyen hastalar kimler?
- Hangi kanaldan gelen randevular daha çok iptal oluyor?
- Doluluk neden "çalışma planı yok" diyor?
