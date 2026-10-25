---
id: icmal-steril-icmal
baslik: Sterilizasyon İcmali
modul: steril
ekran: steril-icmal
rota: /steril-icmal
surec: icmal
roller: steril_sorumlu, dis_asistan, hemsire, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: steril.icmal
erisim: kullanici
ozet: Seçilen dönemde sterilizasyon cihazlarının döngü, doluluk ve validasyon durumunu; set ömrünü, indikatör sonuçlarını, karantina / geri çağırma / süresi dolan paketleri ve bölümlerin paket kullanımını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönemde kaç sterilizasyon döngüsü yapıldı, cihazlar ne kadar dolu yüklendi, başarısız indikatör ya da geri çağırma oldu mu, süresi dolan paket depoda kaldı mı, hangi setler ömür eşiğine yaklaştı?" sorusunu cevaplar. Sterilizasyon sorumlusu ve klinik yönetimi kullanır. Ekranda hasta bilgisi yoktur.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Cihaza göre süzmek** — "⚙ Cihaz" listesi (otoklav, yıkayıcı-dezenfektör, ultrasonik yıkayıcı).
- **Sete göre süzmek** — "🧰 Set" listesi.
- **Sekmeler arasında geçmek** — Cihazlar, Setler, İndikatörler, Karantina / Geri Çağırma, Bölümler.
- **Cihaz seçmek** — Cihazlar sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili cihazları basar.
- **Cihazın programlarını açmak** — cihaz adının yanındaki ▸ işaretine tıklayın.
- **Bölümün setlerini açmak** — Bölümler sekmesinde satıra tıklayın; o bölümün kullandığı setler ve adetleri açılır.
- **Çıktı almak** — "🖨️ Sterilizasyon İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Panoya geçmek** — "📊 Sterilizasyon Panosu" düğmesi.

## Ekrana giriş
- Sol menü **Diş › Sterilizasyon › Sterilizasyon İcmali** (`/steril-icmal`, yalnız HBYS modu).
- `steril.icmal` görme yetkisi gerekir (haklar ilk tanımda sterilizasyon panosu yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: döngüler başlama zamanına, paketler paketleme / kullanım okutması / SKT tarihine göre. Varsayılan bir önceki takvim ayı.
- **Cihaz** ve **Set** listeleri. Yalnız aktif şubenin cihazları.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır.
- Şeritte rozetler: "N indikatör başarısız", "N geri çağırma (açık / kapandı)", "N paket karantinada", "<cihaz> validasyonu gecikti".

## Özet ve sekmeler
Özet kutuları: **Sterilizasyon Döngüsü** (serbest, test, yıkama döngüsü) · **Cihaz Doluluğu** (yüklenen paket / kapasite) · **Üretilen Paket** (set türü, birim) · **Kullanılan Paket** (bölüm, steril depoda) · **İndikatör Başarısız** (okuma) · **Karantina / Geri Çağırma** (geri çağrılan, kullanılmış) · **Süresi Dolan Paket** (depoda işlenmemiş) · **Eşiğe Yakın Birim**.

Sekmeler:
- **Cihazlar** — Tür, Döngü, Serbest, Karantina, Başarısız / İptal, Test, Yüklenen, Kapasite, Doluluk, Ort. Süre, Validasyon.
- **Setler** — Kod, Set, Paket, Birim, Dönem Çevrimi, Birim Başı, Kullanılan, Ömür Ort. / Eşik, Eşiğe Yakın, Steril Depoda / Min.
- **İndikatörler** — tür başına okuma, geçti, kaldı, bekliyor, başarı; altta başarısız indikatörler (tarih, cihaz, döngü, lot, aksiyon).
- **Karantina / Geri Çağırma** — geri çağırmalar (tetik, döngü, paket, kullanılmış, hasta sayısı, durum), karantinadaki paketler (biyolojik sonuç bekleyen) ve süresi dolan paketler.
- **Bölümler** — Bölüm / Ünite, Kullanılan Paket, Set Çeşidi, İmplant Seti, Hasta, Ort. Depoda Bekleme, Pay.

## Rakamlar nereden gelir
- Uç: `GET /api/steril-icmal` (`SterilIcmalUclari.cs`); ekran hesap yapmaz.
- **Döngü** durumları: serbest, karantina, başarısız, iptal, test. Sterilizasyon döngüsü = otoklav; yıkama döngüsü = yıkayıcı-dezenfektör / ultrasonik.
- **Doluluk** = döngüye bağlı paket ÷ (yük kapasitesi × test dışı döngü); yük kapasitesi cihaz kartından, girilmemiş cihazda hesaplanmaz.
- **Paket**: üretilen = paketleme dönemde; kullanılan = kullanım okutması dönemde (bölüm = kullanım kaydındaki ünite); süresi dolan = SKT'si dönemde geçen ve "süresi doldu" ya da hâlâ "steril" duran (işlenmemiş).
- **Set ömrü** = birimin döngü sayısı ↔ üretici eşiği (yoksa setin eşiği); %90 üstü "eşiğe yakın".
- **Validasyon gecikti** = otoklavın son validasyonu yok ya da bir yıldan eski.

## Çıktı
"STERİLİZASYON DÖNEM İCMALİ" başlıklı A4: antet, dönem, paket sayıları, cihaz tablosu (seçim varsa yalnız seçili cihazlar), bölüm tablosu ve özet; Hazırlayan / Sorumlu / Onaylayan imza alanları. Dosya adı "Sterilizasyon İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Geri çağırmada yalnız sayılar görünür; hasta listesi geri çağırma kaydındadır.
- Süresi dolup hâlâ "steril" duran paket depoda işlenmemiş demektir; yeniden işlenmelidir.
- Bu ekran kayıt değiştirmez; döngü, paket ve geri çağırma işlemleri Sterilizasyon Panosu'ndan yapılır.

## Örnek sorular
- Geçen ay kaç otoklav döngüsü yapıldı, kaçı başarısız oldu?
- Hangi cihazın validasyonu gecikmiş?
- Ömür eşiğine yaklaşan setler hangileri?
- Süresi dolmuş ama depoda duran paket var mı?
- Hangi bölüm en çok paket kullanıyor?
