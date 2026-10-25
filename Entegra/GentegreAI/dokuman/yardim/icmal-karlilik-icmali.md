---
id: icmal-karlilik-icmali
baslik: Kârlılık İcmali
modul: satis
ekran: karlilik-icmali
rota: /karlilik-icmali
surec: icmal
roller: satis, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: satis.karlilik_icmali
erisim: kullanici
ozet: Seçilen dönemde net satış, satış anındaki ortalama maliyet ve brüt kârı müşteri (ABC), ürün, temsilci, kategori, şube ve para birimi bazında; maliyetin altında satılan satırları, ciro × marj matrisini ve 12 aylık kâr trendini gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Kimden, hangi üründen, hangi temsilciyle para kazanıyoruz; nerede iskonto kârı yiyor; zararına satış var mı?" sorusunu cevaplar. Yönetim ve satış müdürü için. Satış İcmali ciroyu ve geçen yılı anlatır; bu ekranın ekseni kârdır: marj, maliyet, iskontonun kâra etkisi, ciro × marj matrisi ve zararlı satır ayrıntısı. Tutarlar belgenin dip toplamından gelir; ekran satırları yeniden toplamaz.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Bu yıl seçin (varsayılan bu ayın başı – bugün).
- **Karşılaştırmayı değiştirmek** — "⇄ Karşılaştır" listesinden Önceki dönem (varsayılan, aynı uzunlukta hemen önceki dönem) ya da Geçen yılın aynı dönemi.
- **Şube, temsilci ve kategoriye göre süzmek** — "🏢 Şube", "👤 Temsilci" ve "🗂 Kategori" listeleri; temsilci belgedeki satıcıdır, belgede yoksa "(temsilcisiz)". Kategori alt kategorileriyle birlikte süzer.
- **Tek döviz görmek** — "💱 Para birimi" listesinden bir döviz seçin; bütün sekmeler yalnız o dövizdeki belgeleri o dövizin cinsinden gösterir. Varsayılan "TL karşılığı" bütün belgeleri belge kuruyla TL'ye çevirir.
- **Bugünkü maliyetle bakmak** — "Satış anı maliyeti" / "Bugünkü maliyetle" düğmeleri. Bugünkü maliyet yalnız fiyat kararı için bilgidir; A4 her zaman satış anındaki maliyetle basılır.
- **İadeleri ve hizmetleri katmak / çıkarmak** — "İadeleri düş" ve "Hizmetler dahil" kutuları (ikisi de varsayılan açık).
- **Maliyetsiz satırları toplamdan çıkarmak** — "Maliyetsiz satırları hariç tut" kutusu; işaretli değilken maliyetsiz satırlar kâra %100 yazılır ve "maliyetsiz" rozetiyle görünür.
- **Müşterinin ürün dağılımını görmek** — Müşteri sekmesinde satıra tıklayın; müşteri adına tıklayınca cari kartı açılır, çift tıklayınca cari ekstresi.
- **Ürünün müşteri dağılımını görmek** — Ürün sekmesinde satıra tıklayın; ürün adına tıklayınca stok kartı açılır.
- **Temsilciyle süzmek** — Temsilci sekmesinde satıra çift tıklayın.
- **Zararlı satışı incelemek** — Zararlı Satışlar sekmesinde satıra tıklayıp "📄 Seçili belgeyi aç" ya da "🏷 Fiyat listesine git" (stok kartının fiyatları); belge numarasına tıklayınca belge kartı, ürüne tıklayınca stok kartı açılır.
- **Ciro × marj hücresinin müşterilerini görmek** — Ciro × Marj sekmesinde hücreye tıklayın; listede çift tık cari ekstresini açar.
- **Listede aramak** — Müşteri ve Ürün sekmelerindeki "🔍" kutusuna yazın.
- **Satış İcmali'ne ya da Stok Değer İcmali'ne geçmek** — araç çubuğunun sağındaki düğmeler.
- **Çıktı almak** — "🖨️ Kârlılık İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Satış › İcmaller › Kârlılık İcmali** (`/karlilik-icmali`).
- `satis.karlilik_icmali` görme yetkisi gerekir (haklar Satış Faturası Listesi'nden kopyalanmıştır).

## Süzgeçler
- **Dönem**, **Karşılaştır**, **Şube** (yalnız kullanıcının şubeleri), **Temsilci**, **Kategori**, **Para birimi**, **Satış anı / Bugünkü maliyet**, **İadeleri düş**, **Hizmetler dahil**, **Maliyetsiz satırları hariç tut**.

## Özet ve sekmeler
- Kutular: Net Satış, Satılan Malın Maliyeti, Brüt Kâr (karşılaştırma dönemiyle), Brüt Kâr % (puan farkı), İskonto (kârın yüzde kaçı), Zararlı Satır (tutar, müşteri sayısı), Maliyetsiz Satır (satış tutarı, kâra yazıldı mı), Hizmet Payı.
- **Müşteri:** temsilci, net satış, maliyet, brüt kâr, marj, karşılaştırma dönemi marjı ("yeni" müşteri), iskonto, ABC (kâra katkıya göre: A ilk %80, B sonraki %15, C kalan), kâr payı ve çubuk.
- **Ürün:** kod, ürün / hizmet, kategori, miktar, ortalama satış, ortalama maliyet, net satış, brüt kâr, marj, marjın puan değişimi ve maliyet kaynağı rozeti (ortalama · kart fiyatı · maliyetsiz · kısmen maliyetsiz · hizmet).
- **Temsilci:** müşteri sayısı, net satış, brüt kâr, marj, iskonto, iskonto / brüt satış, zararlı satır, tahsil edilen.
- **Kategori / Şube / Para birimi:** ana kategori (brüt kârdaki pay), şube · depo, para birimi (döviz satış, TL satış, TL maliyet, marj).
- **Zararlı Satışlar:** maliyetin altında satılan satırlar — belge, tarih, müşteri, temsilci, ürün, miktar, net fiyat, maliyet, fark, iskonto ve tahmini neden.
- **Ciro × Marj:** müşteriler ciro sınıfı (ABC, net satışa göre) × marj sınıfı (düşük < %25, orta %25–35, yüksek > %35) matrisinde; hücrede müşteri sayısı, net satış ve öneri.
- **Trend:** son 12 ay net satış, maliyet, brüt kâr, marj, iskonto oranı ve maliyetsiz satır sayısı.

## Rakamlar nereden gelir
- Kesin satış faturası ve satış fişi ile aynı türlerin iadeleri (Satış İcmali ile aynı küme). İrsaliye sayılmaz; irsaliyeden türeyen fatura bir kez sayılır.
- Net satış belgenin KDV hariç dip toplamından (fn_belge_diptoplam) satırlara satır tutarı oranında bölüştürülür; toplamları belge toplamına eşittir.
- **Maliyet:** satırın stoktan çıktığı andaki ortalama maliyet × miktar — o güne kadarki giriş belgelerinin ağırlıklı ortalaması (Stok Değer İcmali'ndeki ortalama maliyetle aynı formül, tarihle sınırlı); giriş yoksa stok kartının alış fiyatı. Fatura irsaliyeden türemişse maliyet irsaliyenin çıkış günündendir. Sonradan gelen alış maliyeti geçmiş satışın kârını değiştirmez.
- **Maliyetsiz:** o gün ortalama maliyet de kart alış fiyatı da yoksa satır maliyetsizdir; varsayılan kâra %100 yazılır ve rozetle uyarılır, kutu işaretlenince bütün toplamlardan çıkar.
- **Hizmet:** hizmet ve masraf satırlarında maliyet 0'dır ("hizmet" rozeti).
- **İade:** iade satırı, iade edilen satışın maliyetiyle eksi yazılır (bağlı satış belgesi varsa onun çıkış günündeki maliyet, yoksa iade günündeki ortalama); iade edilen kâr da düşer.
- **İki seviye:** maliyetin altı kırmızıdır ve Zararlı Satışlar sekmesinde listelenir; hedef marjın altı sarı "hedef altı" rozetidir. Hedef marj Genel Ayarlar'daki `satis.hedef_marj`, boşsa %15.
- **Neden tahmini:** iskonto %20'den büyükse "yüksek iskonto"; stok kartında satış fiyatı varsa ve son alış maliyeti onu aşmışsa "maliyet arttı, fiyat eski".
- Dövizli satış belgenin kendi kuruyla TL'dir; maliyet her zaman TL tutulur, tek döviz seçilirse aynı belge kuruyla o dövize çevrilir.
- Tahsil edilen: dönem faturalarının cari hareketinde FIFO ile açık kalmayan kısmı (Cari İcmali ile aynı kural); bilgi içindir.
- Delphi'den satırsız aktarılan satış tahakkuku ürün ve maliyet taşımadığı için icmale girmez; şeritte adet ve tutarıyla rozet olarak durur, trendde o aylar "aktarım: satır yok" rozetiyle belirtilir.

## Çıktı
A4: dönem, kip (KDV hariç, iade, hizmet), şube ve temsilci, maliyetsiz satırların durumu; müşteri başına net satış, maliyet, brüt kâr, marj; altta net satış, satılan malın maliyeti, kâra yazılan maliyetsiz satış ve brüt kâr; imza alanları (Hazırlayan, Genel Müdür). A4 her zaman satış anındaki maliyetle basılır; genel gider, kargo ve prim dağıtılmaz (brüt kâr).

## Dikkat edilecekler
- Temsilci belgeden gelir; cari kartındaki temsilci kullanılmaz.
- "Bugünkü maliyetle" yalnız bilgi içindir; geçmiş satışın gerçek kârı satış anındaki maliyetledir.
- Maliyetsiz satırlar sessizce sıfır maliyet sayılmaz: rozet ve KPI kutusu her zaman gösterilir.
- Hizmet satırları için maliyet girilmez (şimdilik maliyet 0).
- Hedef marjın altındaki satışlar için ayrı sekme yoktur; Müşteri, Ürün, Temsilci ve Kategori tablolarında sarı rozetle görünür.

## Örnek sorular
- Bu ay en çok kâr ettiğimiz müşteriler kimler?
- Hangi ürünleri maliyetinin altında sattık, neden?
- Hangi temsilci en çok iskonto veriyor ve kârı ne kadar?
- Hangi müşteriler yüksek ciro ama düşük marjlı?
- Maliyeti girilmemiş hangi ürünleri sattık?
- Son 12 ayda brüt kâr marjımız nasıl değişti?
