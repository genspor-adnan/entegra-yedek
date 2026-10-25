---
id: icmal-siparis-icmali
baslik: Sipariş İcmali
modul: satis
ekran: siparis-icmali
rota: /siparis-icmali
surec: icmal
roller: satis, satinalma, depo, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: siparis.icmali
erisim: kullanici
ozet: Satış ve alış siparişlerinin açık kalan miktar ve tutarını, termin takvimini, termini geçen satırları, zamanında ve tam teslim (OTIF) oranını, açık satış siparişlerinin eldeki ve yoldaki stokla karşılanmasını (alışta gelecek malı), 12 aylık sipariş / sevk trendini ve temsilci / kategori / şube · depo / para birimi kırılımlarını gösterir; seçili satırları irsaliyeye dönüştürür, kalanı kapatır ve eksik stok için satınalma talebi açar.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Kime ne söz verdik, ne kadarını teslim ettik, neyi geciktiriyoruz, elimizdeki stok yetecek mi?" sorusunu cevaplar. Satış destek, depo ve satınalmanın sabah toplantısı için kullanılır. İki yön tek ekrandadır: şeritte Satış / Alış seçilir; alış yönünde müşteri yerine tedarikçi, teslim performansı tedarikçi karnesi, stok karşılama yerine "Gelecek mal" gelir. Tutarlar sipariş belgesinin dip toplamından gelir; ekran satırları yeniden toplamaz.

## Bu ekranda neler yapabilirsiniz
- **Satış ya da alış siparişlerine bakmak** — şeritteki "Satış siparişleri" / "Alış siparişleri" düğmeleri.
- **Dönem seçmek** — "📅 Sipariş tarihi" başlangıç ve bitiş tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Son 3 ay / Bu yıl seçin (varsayılan bu ayın başı – bugün).
- **Termine göre süzmek** — "⏰ Termin" listesinden Termini geçen, Önümüzdeki 7 gün, Önümüzdeki 30 gün ya da Termini yazılmamış. Şeritteki kırmızı "Termini geçen: N satır" rozetine tıklayınca geciken satırlar açılır.
- **Şube, depo, temsilci ve kategoriye göre süzmek** — "🏢 Şube" ve yanındaki depo listesi (sipariş deposu), "👤 Temsilci" (siparişteki satıcı; yoksa "(temsilcisiz)") ve "🗂 Kategori" (alt kategorileriyle) listeleri.
- **Satır durumuna göre süzmek** — Açık / Kısmi / Kapalı / Açık + kısmi (varsayılan) / İptal / Tümü düğmeleri; "İptal" kalanı kapatılmış satırlardır.
- **Tek döviz görmek** — "💱 Para birimi" listesinden bir döviz seçin; yalnız o dövizdeki siparişler o dövizin cinsinden görünür. Varsayılan "TL karşılığı" siparişleri sipariş kuruyla TL'ye çevirir.
- **Konsinyeyi katmak** — "Konsinye dahil" kutusu; konsinye satırlar mor rozetle görünür, açık sipariş tutarına, termine ve teslim performansına katılmaz.
- **Carinin açık satırlarını görmek** — Özet sekmesinde cari satırına tıklayın; açık satırları (sipariş no, kalem, kalan, termin, gecikme) açılır, sipariş numarasına tıklayınca sipariş kartı açılır.
- **Cari ekstresine geçmek** — cari satırına çift tıklayın ya da satırı seçip "📄 Seçili carinin ekstresi" düğmesine basın; cari adına tıklayınca cari kartı açılır.
- **Siparişi açmak** — Açık Satırlar sekmesinde satıra tıklayın.
- **Seçili satırları irsaliyeye dönüştürmek** — Açık Satırlar sekmesinde aynı carinin satırlarını ☐ ile seçip "🚚 Seçili satırları irsaliyeye dönüştür" düğmesine basın. Mevcut dönüşüm penceresi sipariş başına sırayla açılır (her siparişten ayrı irsaliye); bitince oluşan irsaliyelerin bağlantıları gösterilir. Satış İrsaliyesi / Alış İrsaliyesi ekleme ve "belge dönüştür" yetkisi gerekir.
- **Kalanı kapatmak** — satırları seçip "✂ Kalanı kapat…" düğmesine basın, nedeni yazın (zorunlu). Kalan miktar iptal edilir ve satır kapalıya alınır; teslim edilen kısım ve sipariş belgesi değişmez, kapanış nedeniyle loglanır. Sipariş belgesinin değiştirme yetkisi gerekir. Arada başka biri teslim girdiyse ekran uyarır ve tazelenir.
- **Haftanın satırlarını görmek** — Termin Takvimi sekmesinde haftaya tıklayın; Açık Satırlar o haftanın satırlarıyla açılır (rozetteki ✕ ile kaldırılır).
- **Eksik stok için satınalma talebi açmak** — Stok Karşılama sekmesinde eksik satırındaki "Satınalma talebi aç" düğmesi; Kritik Stok İcmali'ndeki gibi taslak talep açılır (satınalma talebi ekleme yetkisi gerekir, deposuz siparişte açılmaz).
- **Stok kartını açmak** — Stok Karşılama / Gelecek Mal sekmesinde ürün adına tıklayın.
- **Temsilciyle süzmek** — Kırılımlar › Temsilci satırına çift tıklayın.
- **Listede aramak** — Özet'te "🔍 Müşteri ya da temsilci…", Açık Satırlar'da "🔍 Sipariş, cari, kod ya da ürün…" kutusuna yazın.
- **Başka ekranlara geçmek** — "📑 Açık Satır Listesi", "🛍️ Satış İcmali" (alışta "🛒 Alış İcmali") ve "⚠ Kritik Stok İcmali" düğmeleri.
- **Çıktı almak** — "🖨️ Sipariş İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Satış › İcmaller › Sipariş İcmali** (`/siparis-icmali`).
- `siparis.icmali` görme yetkisi gerekir (Satış Siparişi Listesi'ni gören rol icmali de görür).

## Süzgeçler
- **Yön** (satış / alış), **Sipariş tarihi**, **Termin**, **Şube** (yalnız kullanıcının şubeleri) ve **depo**, **Temsilci**, **Kategori**, **Durum**, **Para birimi**, **Konsinye dahil**.

## Özet ve sekmeler
- Kutular: Açık Sipariş Tutarı (KDV hariç), Açık Satır (kısmi teslim), Termini Geçen (tutar, en eski gecikme), Zamanında + Tam (OTIF; geçen ay), Ort. Teslim Süresi, Dönüşüm (siparişten irsaliyeye geçen miktar oranı), Karşılanamayan (alışta Gelecek Mal), İptal Edilen Kalan.
- **Özet:** cari bazında sipariş, açık satır, sipariş tutarı, teslim edilen, kalan tutar, termini geçen, OTIF, pay; dövizli açık kalan rozeti, konsinye rozeti; alışta tedarikçi skoru.
- **Açık Satırlar:** sipariş, tarih, cari, ürün, sipariş / teslim / kalan miktar, kalan tutar, termin, gecikme (ya da kalan gün), stok durumu (satışta), durum.
- **Termin Takvimi:** termini geçen, önümüzdeki dört hafta, daha sonra ve termini yazılmamış satırlar; satır, miktar, tutar, stokta hazır ve eksik (satışta).
- **Teslim Performansı:** kapanan satırlarda zamanında, geç, eksik kapanan, OTIF, ortalama gecikme ve teslim süresi; alışta tedarikçi karnesi (Satınalma skoru ve gecikme olayı).
- **Stok Karşılama (satış):** açık satış siparişini karşılayamayan ya da ancak yoldaki malla karşılanan stoklar — açık sipariş, eldeki, rezerve, yoldaki, eksik, ilk termin, öneri.
- **Gelecek Mal (alış):** açık alış siparişlerinden gelecek miktar ve tutar, ilk termin, geciken satır, eldeki ve bekleyen satış siparişi.
- **Trend:** son 12 ayın sipariş tutarı, sevk edilen (alışta teslim alınan), ay sonu açık, OTIF ve ortalama teslim süresi.
- **Kırılımlar:** temsilci, ana kategori (satışta eksik kalem), şube · depo, para birimi (açık döviz, sipariş kuru, bugünkü kurla değer).

## Rakamlar nereden gelir
- Kesin satış siparişleri (başvurular hariç) ya da alış siparişleri; konsinye isteğe bağlı.
- Açıklık Açık Satır Listesi ile aynı kuraldır: satırın dönüşmemiş kalanı varsa açıktır. Kalanı kapatılan satır icmalde kapalıdır.
- Teslim, siparişten türeyen kesin irsaliye / fatura / fiş satırlarının miktarıdır; taslak irsaliye teslim sayılmaz (satırda "taslak" rozeti çıkar).
- Tutar siparişin dip toplamının (KDV hariç) satır tutarı oranında satıra düşen payıdır; kalan / teslim / iptal tutarı bu payın miktar oranıdır.
- Termin satırın teslim tarihidir; alışta satırda yoksa siparişin sözleşmeli teslim tarihi. İkisi de yoksa "termini yazılmamış" — gecikme ve OTIF hesabına girmez.
- Zamanında = son teslim termin gününde ya da önce (kısmi teslimde satırın tamamlandığı gün). OTIF = zamanında ve tam; kalanı kapatılan satır eksik sayılır. Ortalama teslim süresi sipariş → ilk sevktir.
- Stok karşılamada eldeki = sipariş deposundaki kalan − SKT'si geçmiş lot; rezerve edilmiş miktar önce kendi satırını karşılar, kalan stok açık siparişlere termin sırasıyla dağıtılır (ilk termin ilk alır), sonra yoldaki açık alış siparişi. Dönemden bağımsız, bütün açık satış siparişleri.
- Dövizli sipariş sipariş kuruyla TL'dir; bugünkü kurla değer bilgi amaçlıdır.
- Tedarikçi skoru Satınalma'nın skor olaylarından okunur; icmal yeniden hesaplamaz.

## Çıktı
A4: dönem, durum, şube ve temsilci; cari başına açık satır, kalan tutar, termini geçen, OTIF; altta sipariş tutarı, teslim edilen, kalanı kapatılan, termini geçen, AÇIK SİPARİŞ ve döviz özeti; imza alanları (Hazırlayan, Satış / Satınalma Müdürü).

## Dikkat edilecekler
- İrsaliyeye dönüştürme mevcut dönüşüm akışını kullanır: birden çok sipariş seçilirse her siparişten ayrı irsaliye kesilir.
- Kalanı kapatılan satır geri açılmaz; sipariş belgesi değişmediği için Açık Satır Listesi'nde ayrıca kapanış görünmeyebilir.
- Termini yazılmamış açık satır varsa şeritte "Dikkat" rozeti çıkar; sipariş girişinde termin zorunluluğu önerilir.
- Konsinye satış değildir; açık sipariş tutarına ve teslim performansına katılmaz.
- Cariye termin hatırlatması bu ekrandan gönderilmez.

## Örnek sorular
- Termini geçen satış siparişlerimiz hangileri?
- Bu ay müşterilere zamanında ve tam teslim oranımız ne?
- Hangi açık siparişleri eldeki stokla karşılayamıyoruz?
- Bir müşterinin açık sipariş satırlarını nasıl görürüm?
- Siparişin kalanını nasıl kapatırım?
- Tedarikçilerimiz alış siparişlerini zamanında teslim ediyor mu?
- Önümüzdeki hafta hangi siparişlerin termini dolacak?
