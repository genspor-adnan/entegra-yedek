---
id: icmal-satis-icmali
baslik: Satış İcmali
modul: satis
ekran: satis-icmali
rota: /satis-icmali
surec: icmal
roller: satis, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: satis.icmali
erisim: kullanici
ozet: Seçilen dönemde müşteri ve ürün bazında net satışı, iskontoyu, iadeyi, brüt kârı ve geçen yılla karşılaştırmayı; 12 aylık trendi, temsilci / kategori / şube / belge türü / para birimi kırılımlarını ve maliyet altı satış, düşen müşteri, faturası kesilmemiş irsaliye, gönderilmemiş e-Belge uyarılarını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönem kime ne sattık, geçen yıla göre nasılız, nerede kâr ediyoruz, nerede zararına satıyoruz?" sorusunu cevaplar. Satış müdürü, yönetim ve muhasebenin ay kapanışı için kullanılır. Tutarlar belgenin dip toplamından gelir; ekran satırları yeniden toplamaz.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Bu yıl seçin (varsayılan bu ayın başı – bugün).
- **Karşılaştırmayı değiştirmek** — "⇄ Karşılaştır" listesinden Geçen yılın aynı dönemi (varsayılan) ya da Önceki dönem (aynı uzunlukta, hemen önceki dönem).
- **Şube ve temsilciye göre süzmek** — "🏢 Şube" ve "👤 Temsilci" listeleri; temsilci belgedeki satıcıdır, belgede yoksa "(temsilcisiz)".
- **Tek döviz görmek** — "💱 Para birimi" listesinden bir döviz seçin; bütün sekmeler yalnız o dövizdeki belgeleri o dövizin cinsinden gösterir. Varsayılan "TL karşılığı" bütün belgeleri belge kuruyla TL'ye çevirir.
- **KDV hariç / dahil görmek** — şeritteki "KDV hariç" / "KDV dahil" düğmeleri.
- **İadeleri düşmek ya da taslakları katmak** — "İadeleri düş" (varsayılan açık) ve "Taslak belgeler dahil" kutuları.
- **Müşterinin belgelerini görmek** — Müşteri Bazında satırına tıklayın; dönemdeki belgeleri açılır, belge numarasına tıklayınca belge kartı açılır.
- **Cari ekstresine geçmek** — müşteri satırına çift tıklayın ya da satırı seçip "📄 Seçili carinin ekstresi" düğmesine basın.
- **Cari kartını açmak** — müşteri adına tıklayın.
- **Ürünün müşteri dağılımını görmek** — Ürün Bazında satırına tıklayın; ada tıklayınca stok kartı açılır.
- **Trendi gün gün görmek** — Gün / Ay Trendi sekmesinde dönem 62 günü aşmıyorsa "Dönem gün gün" düğmesi.
- **Listede aramak** — "🔍 Müşteri ya da temsilci…" / "🔍 Kod, ürün / hizmet ya da kategori…" kutusuna yazın.
- **Çıktı almak** — "🖨️ Satış İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Satış › İcmaller › Satış İcmali** (`/satis-icmali`).
- Alış İcmali'ndeki "🛍️ Satış İcmali" düğmesi.
- `satis.icmali` görme yetkisi gerekir.

## Süzgeçler
- **Dönem**, **Karşılaştır**, **Şube** (yalnız kullanıcının şubeleri), **Temsilci**, **Para birimi**, **KDV hariç / dahil**, **İadeleri düş**, **Taslak belgeler dahil**.

## Özet ve sekmeler
- Kutular: Net Satış, Geçen Yıl Aynı Dönem (değişim yüzdesi), Belge (fatura · fiş), Müşteri (yeni müşteri), İade, İskonto, Brüt Kâr (marj), Vadesi Geçen.
- **Müşteri Bazında:** temsilci, belge, brüt, iskonto, iade, net satış, geçen yıl, değişim, brüt kâr, marj, pay çubuğu; dövizli satışı olan müşteride döviz rozeti.
- **Ürün Bazında:** kod, ürün / hizmet, kategori, miktar, ortalama fiyat, liste fiyatı, net satış, maliyet, brüt kâr, marj, müşteri sayısı.
- **Gün / Ay Trendi:** son 12 ay (geçen yılın aynı ayıyla; son ay bitiş gününe kadar) ya da dönem gün gün.
- **Kırılımlar:** temsilci (tahsil edilen dahil), ana kategori, şube · depo, belge türü (e-Fatura / e-Arşiv / fiş, iadeler ayrı), para birimi.
- **Dikkat:** maliyet altı satış, satışı düşen / kaybedilen müşteri, faturası kesilmemiş satış irsaliyesi, e-Belgesi gönderilmemiş fatura.

## Rakamlar nereden gelir
- Kesin satış faturası ve satış fişi (taslaklar isteğe bağlı) ve aynı türlerin iadeleri. İrsaliye sayılmaz: irsaliyeden türeyen fatura bir kez sayılır, faturası kesilmemiş irsaliye Dikkat'te durur.
- Tutar belgenin dip toplamından (KDV hariç matrah ya da KDV dahil genel toplam). Ürün ve kategori kırılımında belge toplamı satırlara satır tutarı oranında dağıtılır; toplamları belge toplamına eşittir.
- İskonto = satırın adet × birim fiyatı − satır tutarı; brüt = net + iskonto.
- Brüt kâr = net satış − satılan malın ortalama maliyeti (Stok Değer İcmali ile aynı maliyet); hizmet satırında maliyet yoktur.
- Dövizli satış belgenin kendi kuruyla TL'dir (faturanın yasal TL tutarı). Para birimi tablosunda bugünkü kurla değer ve kur farkı yalnız açık (tahsil edilmemiş) alacak içindir.
- Tahsil edilen ve vadesi geçen, carinin hareketleri FIFO ile kapatılarak bulunur (Cari İcmali ile aynı kural).

## Çıktı
A4: dönem, kip (KDV, iade), şube ve temsilci; müşteri başına belge, net satış, geçen yıl, marj; altta brüt / iskonto / iade / net satış ve döviz özeti; imza alanları (Hazırlayan, Satış Müdürü).

## Dikkat edilecekler
- Temsilci belgeden gelir; cari kartındaki temsilci kullanılmaz.
- Tek döviz seçiliyken karışık para toplanmaz; Para birimi tablosu her zaman TL karşılığıdır.
- Kur farkı tahmindir; gerçekleşen kur farkı tahsilatta fişlenir.
- Liste fiyatı karşılaştırması KDV dahil kipinde yapılmaz.

## Örnek sorular
- Bu ay en çok satış yaptığımız müşteriler kimler?
- Geçen yılın aynı dönemine göre satışlarımız ne kadar arttı?
- Hangi ürünleri maliyetinin altında sattık?
- Satışı düşen ya da kaybettiğimiz müşteriler hangileri?
- Temsilci bazında satış ve tahsilatı nasıl görürüm?
- Euro ile yaptığımız satışların kur farkı ne kadar?
