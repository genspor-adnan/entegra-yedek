---
id: icmal-stok-kritik-stok-icmali
baslik: Kritik Stok İcmali
modul: stok
ekran: stok-kritik-stok-icmali
rota: /stok-kritik-stok-icmali
surec: icmal
roller: stok, depo, satinalma
dil: tr
surum: 1
urun_modu: 0
yetki: stok.kritik_stok_icmali
erisim: kullanici
ozet: Depo bazında asgari seviyenin altına düşen, stokta olmayan ve tedarik süresinden önce bitecek kalemleri; yolda olanı, önerilen siparişi, tüketimden min / max önerisini ve max üstü fazlayı gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Neyi bugün sipariş etmeliyim, ne kadar? Hangisi zaten yolda, hangisi başka depoda var?" sorusunu cevaplar. Satınalma ve depo sorumlusunun günlük ekranıdır. Eşik ve sipariş miktarı kuralı otomatik kritik stok talebiyle aynıdır; ekran ve zamanlı iş farklı miktar önermez.

## Bu ekranda neler yapabilirsiniz
- **Depo, kategori, stok tipi süzmek** — "🏬 Depo", "🗂 Kategori" ve "🏷 Stok tipi" (Ticari Mal, Hammadde, Mamul, Demo… ya da "tipi tanımsız"); talep depo başına açıldığı için tek depo seçmek pratiktir.
- **Tüketim dönemini ve tedarik süresini seçmek** — "📈 Tüketim ortalaması" (son 30 / 60 / 90 / 180 gün) ve "🚚 Tedarik süresi".
- **Listeyi daraltmak** — "Kritik altı / yok", "Tükenmek üzere", "Tümü" düğmeleri.
- **Sipariş miktarını düzeltmek** — Kritik Altı sekmesinde "Sipariş" hücresine yeni miktarı yazın; tutar ve A4 buna göre değişir.
- **Satınalma talebi açmak** — kalemleri kutucukla seçip "🛒 Seçilenlerden Satınalma Talebi"ne basın; tek depo için TASLAK talep açılır ve talep kartı açılır (onaya siz gönderirsiniz). Açık talebi olan kalem atlanır; `satinalma.talep` ekleme yetkisi gerekir.
- **Min / max tanımlamak** — "Min / Max Önerisi" sekmesinde satırları seçin, gerekirse önerilen değerleri düzeltin, "🎯 Min / Max önerisini uygula"ya basın; değer stok kartı › Stok Durumu'ndaki depo bazlı seviyeye yazılır (stok kartında değiştirme yetkisi gerekir).
- **Tükenme takvimine bakmak** — "Tükenme Takvimi" sekmesi: bugün / 7 / 14 / 30 gün içinde biten kalemler; tedarik süresi içinde bitenler ▲ ile.
- **Fazla stoğu görmek** — "Max Üstü" sekmesi: fazla miktar, tutar, kaç günlük olduğu ve öneri (başka depoya transfer ya da alımı durdur).
- **Stok kartını ya da transferi açmak** — stok adına tıklayın; transfer için "🔄 Stok Transfer" düğmesi.
- **Çıktı almak** — "🖨️ Kritik Stok İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML (A4 imzalı istek listesi olarak verilebilir).

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › Kritik Stok İcmali** (`/stok-kritik-stok-icmali`).
- `stok.kritik_stok_icmali` görme yetkisi gerekir.
- Hiçbir stokta asgari seviye tanımlı değilse ekran ilk açılışta Min / Max Önerisi sekmesine geçer.

## Süzgeçler
- **Depo**, **Kategori**, **Stok tipi**, **Tüketim ortalaması**, **Tedarik süresi** (şimdilik ekrandan tek değer), **Kritik altı / Tükenmek üzere / Tümü**.

## Özet ve sekmeler
- Kutular: Kritik Altı, Stokta Yok, N Günde Biter, Yolda, Önerilen Sipariş (son alış fiyatıyla), Min Tanımsız (A sınıfı sayısıyla), Max Üstü, Diğer Depoda Var.
- **Kritik Altı:** eldeki, yolda, min, max, günlük çıkış, kaç gün yeter, sipariş, tutar, son alış tedarikçisi, talep / sipariş durumu, başka depodaki fazla.
- **Tükenme Takvimi**, **Min / Max Önerisi**, **Max Üstü**.

## Rakamlar nereden gelir
- Eldeki = kalan − rezerve − SKT'si 30 gün içinde dolan (ya da geçmiş) lot miktarı; düşülen miktar "SKT ≤ 30 g" sütunundadır (satılamayacak mal stok sayılmaz). Kritik = eldeki ≤ asgari (depo bazında asgari, yoksa stok kartının asgarisi; ikisi de boşsa kalem eşikle izlenmez).
- Hedef = azami, yoksa asgari × hedef katı (Genel Ayarlar › `satinalma.kritik_hedef_kat`, varsayılan 2), asgari de yoksa önerilen max. Sipariş = hedef − eldeki − yolda, yukarı yuvarlanır.
- Yolda = açık satınalma talepleri (taslak, onayda, onaylandı, teklifte) + açık alış siparişleri.
- Günlük çıkış = seçilen dönemdeki çıkış / gün (transfer çıkışı da deponun tüketimidir). Yeter = (eldeki + yolda) / günlük.
- Önerilen min = günlük × tedarik + emniyet stoku (günlük dalgalanma × 1,65 × √tedarik, %95 hizmet düzeyi); önerilen max = min + 30 günlük tüketim.
- Otomatik talep (Genel Ayarlar › `satinalma.kritik_stok_aktif`) kapalıysa bu ekran elle talep açmanın yoludur; açıksa saatlik iş aynı kuralla talep açar.

## Çıktı
A4: depo, tüketim dönemi, tedarik süresi; kalem başına eldeki / yolda / min / yeter / sipariş / tedarikçi; önerilen sipariş toplamı; depo sorumlusu ve satınalma imza alanları.

## Dikkat edilecekler
- Talep depo başına açılır: farklı depolardan kalem seçilirse uyarı verir.
- Son alış belgesi olmayan kalemde fiyat ve tutar boş kalır; talep satırına "son alış fiyatı yok" notu düşülür.
- Min / max uygulaması yalnız seçili satırlara ve depo bazında yazar; değişiklik loglanır.

## Örnek sorular
- Bugün neleri sipariş etmem gerekiyor?
- Kritik stoktan satınalma talebi nasıl açarım?
- Minimum stok seviyelerini nasıl toplu tanımlarım?
- Hangi kalemler tedarik süresinden önce bitecek?
- Yolda olan miktar neden siparişten düşülüyor?
