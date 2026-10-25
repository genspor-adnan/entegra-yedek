---
id: icmal-irsaliye-fatura-eslesme
baslik: İrsaliye-Fatura Eşleşme İcmali
modul: satis
ekran: irsaliye-fatura-eslesme
rota: /irsaliye-fatura-eslesme
surec: icmal
roller: muhasebe, on_muhasebe, fatura, satis, satinalma, depo
dil: tr
surum: 1
urun_modu: 1
yetki: irsaliye_fatura_eslesme
erisim: kullanici
ozet: Satış ve alış irsaliyelerinin faturalanma durumunu satır bazında gösterir; faturası kesilmemiş, kısmi, fazla ya da fiyatı farklı faturalanmış irsaliyeleri, VUK 7 gün süre aşımını ve stoğu iki kez düşürmüş olabilecek irsaliyesiz faturaları listeler; seçilen irsaliyeleri faturaya dönüştürür, irsaliyesiz faturayı açık irsaliyeye bağlar.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi irsaliyenin faturası kesilmedi ya da gelmedi, nerede miktar veya fiyat tutmuyor, hangi fatura irsaliyesiz kesilip stoğu iki kez düşürdü?" sorusunu cevaplar. Ay sonu kapanışından önce ve VUK'un "irsaliyeden sonra 7 gün içinde fatura" kuralı için muhasebenin kontrol ekranıdır.

## Bu ekranda neler yapabilirsiniz
- **Yön ve dönem seçmek** — "Satış (giden)", "Alış (gelen)" ya da "İkisi"; "📅 İrsaliye tarihi" aralığı (varsayılan yıl başından bugüne).
- **Cari, şube ve bekleme eşiğini süzmek** — "👥 Cari", "🏢 Şube" (birden çok şubeniz varsa) ve "⏱ Bekleme eşiği" (varsayılan 7 gün; VUK 231/5).
- **Faturası kesilmemiş irsaliyeleri görmek** — "Faturalanmamış İrsaliyeler" sekmesi: bekleyen gün, e-İrsaliye yanıt durumu (kabul / red / yanıt bekliyor / kağıt), konsinye ve taslak fatura notları. Satıra tıklayınca kalemler açılır, çift tıklayınca irsaliye kartı açılır.
- **Seçili irsaliyeleri faturalamak** — aynı carinin irsaliyelerini kutucukla seçip "🧾 Seçili irsaliyeleri faturala…"ya basın; Satış / Alış İrsaliyeleri listesindeki "Faturaya Dönüştür" penceresi açılır (alışta tedarikçinin fatura numarası sorulur). Bu akış her irsaliyeden ayrı fatura keser; birden çok irsaliye seçildiyse pencere sırayla açılır. Oluşan faturaların numarası bilgi kutusunda görünür ve tıklanınca açılır.
- **Kısmi ve farklı eşleşmeleri incelemek** — "Kısmi / Fark" sekmesi: irsaliye ↔ fatura satır bazında irsaliye miktarı, faturalanan miktar, kalan, iki fiyat ve fark tutarı; "kısmi", "fazla faturalandı", "fiyat farkı" ve alışta "tedarikçi pahalı faturaladı" rozetleri. Kalan miktarı olan satırda "kalanı faturala" ile dönüşüm penceresi açılır.
- **Tam eşleşenleri de görmek** — "Tam eşleşenleri de göster" kutusu, sorunsuz satırları da Kısmi / Fark sekmesine ekler.
- **İrsaliyesiz faturaları bulmak ve bağlamak** — "İrsaliyesiz Faturalar" sekmesi: stoklu kalemi stok düşürmüş ama hiçbir irsaliyeye bağlı olmayan faturalar ve aynı carinin açık irsaliyeleri. "Mükerrer stok çıkışı şüphesi" olan satırı seçip "🔗 Seçili faturayı irsaliyeye bağla…" (ya da satırdaki "bağla…") ile faturanın stoklu satırlarını açık irsaliye satırlarına bağlayın; faturanın stok etkisi kaldırılır, irsaliye faturalanmış görünür.
- **Cari bazında bakmak** — "Cari Bazında" sekmesi: cari ve yön başına irsaliye, tam eşleşen, açık adet ve tutar, ortalama faturalama süresi ve en eski bekleyen; satıra tıklayınca ekran o cariye süzülür.
- **Çıktı almak** — "🖨️ Eşleşme İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; "🖨 Önizleme (A4)" sekmesi aynı belgeyi ekranda gösterir (faturalanacaklar listesi, hazırlayan ve muhasebe imza alanları).

## Ekrana giriş
- Sol menü **Satış › İcmaller › İrsaliye-Fatura Eşleşme İcmali** (`/irsaliye-fatura-eslesme`).
- `irsaliye_fatura_eslesme` görme yetkisi gerekir.
- "Faturala" için belge ekleme yetkisi ve `belge.donustur` aksiyonu; "Bağla" için belge değiştirme yetkisi gerekir (yetkisi olmayanda düğme görünmez).

## Süzgeçler
- **Yön** (satış / alış / ikisi), **İrsaliye tarihi**, **Cari**, **Şube**, **Bekleme eşiği** (3 / 5 / 7 / 10 / 15 / 30 gün), **Tam eşleşenleri de göster**.
- Süzgeçler adres çubuğuna yazılır; sekme yenilenince kalır.

## Özet ve sekmeler
- Kutular: Faturalanmamış İrsaliye (adet, tutar, en eski gün), Kısmi Faturalanan (kalan tutar), İrsaliyesiz Fatura (mükerrer şüphesi), Miktar Farkı (fazla faturalanan dahil), Fiyat Farkı (sapma tutarı), Tam Eşleşen (oran), Ort. Faturalama Süresi, Yasal Süre Aşımı.
- Sağ üstteki "Ay sonu kapanışı: N gün kaldı" rozeti ayın bitimine kalan günü gösterir.
- Sekmeler: **Faturalanmamış İrsaliyeler**, **Kısmi / Fark**, **İrsaliyesiz Faturalar**, **Cari Bazında**, **Önizleme (A4)**.

## Rakamlar nereden gelir
- Eşleşme belge satırının kaynak bağındandır: irsaliyeden "Faturaya Dönüştür" ile kesilen her fatura satırı kendi irsaliye satırını gösterir. Bir irsaliye birden çok faturaya, bir fatura birden çok irsaliyeye bağlanabilir. Taslak ve iptal edilmiş faturalar faturalanan miktara girmez.
- İrsaliyeler: satış irsaliyesi ve giden konsinye (satış), alış irsaliyesi ve gelen konsinye (alış); yalnız kesinleşmiş belgeler.
- Tutarlar KDV hariçtir: belgenin matrahı ve satırın kayıtlı tutarı. Kalan tutar = satır tutarı × kalan miktar / miktar.
- Fiyat farkı: fatura satırının birim tutarı irsaliyeninkinden hem %2 hem 1 ₺'den fazla saparsa.
- Bekleyen gün bugünden irsaliye tarihine; ortalama faturalama süresi irsaliye tarihinden ilk faturanın tarihine.
- e-İrsaliye durumu: gönderilen irsaliyede e-İrsaliye gönderim durumu ve alıcı yanıtı, gelen irsaliyede verilen yanıt (kabul / red / yanıt süresi doldu).

## Çıktı
A4: dönem, yön, bekleme eşiği, açık irsaliye sayısı ve tutarı; faturalanmamış irsaliyeler (no, tarih, cari, tutar, bekleyen gün); faturalanmamış, kısmi kalan, fiyat farkı ve FATURALANACAK toplamı; hazırlayan ve muhasebe imza alanları.

## Dikkat edilecekler
- **Konsinye irsaliyeler** ay sonu toplu faturalandığı için 7 gün uyarısından muaftır: listede "konsinye" rozetiyle durur, Yasal Süre Aşımı'na ve ⚠ işaretine girmez.
- **Reddedilen e-İrsaliye faturalanmaz**: seçilirse "Faturala" uyarı verir.
- **Faturala** mevcut dönüşüm akışını kullanır ve KESİN fatura keser; her irsaliyeden ayrı fatura oluşur. Tek faturada birden çok irsaliye toplamak bu ekrandan henüz yapılamaz.
- **Bağla** cariyi ve fatura tutarını değiştirmez; yalnız faturanın bağlanan satırlarının stok etkisini geri alır (satışta çıkış, alışta giriş) ve satırları irsaliyeye bağlar. İşlem loglanır.
- **Kapanmış dönem:** bağlanacak fatura ya da irsaliye kapanmış döneme aitse (Genel Ayarlar › `muhasebe.donem_kapanis_tarihi`; tanımlı değilse önceki aylar kapanmış sayılır) onay istenir; işlem yapılır ve dönem bilgisi log kaydına işlenir.
- **Lot / seri izlemli** kalemler bu ekrandan bağlanmaz; böyle faturayı iptal edip irsaliyeden "Faturaya Dönüştür" ile yeniden kesin.
- Bağlanacak miktar irsaliye satırının faturalanmamış kalanını aşamaz; aynı stok ve aynı cari şarttır.

## Örnek sorular
- Faturası kesilmemiş irsaliyeler hangileri?
- 7 günü geçen faturasız irsaliye var mı?
- Bir irsaliyeyi buradan nasıl faturalarım?
- Konsinye irsaliye neden süre aşımında görünmüyor?
- İrsaliyesiz kesilen fatura stoğu iki kez düşürdü mü, nasıl düzeltirim?
- Tedarikçi irsaliyedeki fiyattan pahalı mı faturaladı?
