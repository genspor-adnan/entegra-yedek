---
id: icmal-alis-icmali
baslik: Alış İcmali
modul: alis
ekran: alis-icmali
rota: /alis-icmali
surec: icmal
roller: satinalma, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: alis.icmali
erisim: kullanici
ozet: Seçilen dönemde tedarikçi ve ürün bazında net alışı, iskontoyu, iadeyi, geçen yılla karşılaştırmayı, teslim süresini ve açık borcu; aynı kalemin fiyat gelişimini, aylık alış / satılan malın maliyeti trendini, para birimi tablosunu ve sözleşme üstü alış, daha ucuz tedarikçi, faturası gelmemiş irsaliye, geciken sipariş, gelen e-Fatura kutusunda bekleyen fatura uyarılarını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Kimden ne aldık, ne kadar ödedik, fiyatlar nasıl değişti, hangi tedarikçi geç getiriyor, nerede pahalı alıyoruz?" sorusunu cevaplar. Satınalma ve muhasebe için. Tutarlar belgenin dip toplamından gelir; hizmet alımları (kira, bakım, danışmanlık…) da icmale girer.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Bu yıl / Geçen yıl seçin (varsayılan bu yılın başı – bugün).
- **Karşılaştırmayı değiştirmek** — "⇄ Karşılaştır": Geçen yılın aynı dönemi (varsayılan) ya da Önceki dönem.
- **Şube ve kategoriye göre süzmek** — "🏢 Şube" ve "🗂 Kategori" (alt dallarıyla) listeleri.
- **Stok / hizmet ayırmak** — şeritteki "Stok" / "Hizmet" / "İkisi" düğmeleri (varsayılan ikisi).
- **Tek döviz görmek** — "💱 Para birimi" listesinden bir döviz; sekmeler o dövizdeki belgeleri o dövizin cinsinden gösterir.
- **KDV hariç / dahil ve iadeler** — "KDV hariç" / "KDV dahil" düğmeleri ve "İadeleri düş" kutusu.
- **Tedarikçinin kategori dağılımını görmek** — Tedarikçi Bazında satırına tıklayın; son alış tarihi de açılır.
- **Cari ekstresine geçmek** — tedarikçi satırına çift tıklayın ya da satırı seçip "📄 Seçili tedarikçinin ekstresi" düğmesine basın; adına tıklayınca cari kartı açılır.
- **Kalemin tedarikçi karşılaştırmasını görmek** — Ürün Bazında satırına tıklayın; tedarikçi başına miktar ve ortalama fiyat, en ucuz tedarikçi koyu.
- **Fiyat artışlarını incelemek** — Fiyat Gelişimi sekmesi: aynı kalem + aynı tedarikçinin dönemdeki ilk ve son fiyatı, değişim ve etkisi.
- **Belge kartını açmak** — Dikkat listelerinde satıra çift tıklayın.
- **Çıktı almak** — "🖨️ Alış İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Alış › İcmaller › Alış İcmali** (`/alis-icmali`).
- Satış İcmali'ndeki "🛒 Alış İcmali" düğmesi.
- `alis.icmali` görme yetkisi gerekir.

## Süzgeçler
- **Dönem**, **Karşılaştır**, **Şube** (yalnız kullanıcının şubeleri), **Kategori**, **Stok / Hizmet / İkisi**, **Para birimi**, **KDV hariç / dahil**, **İadeleri düş**.

## Özet ve sekmeler
- Kutular: Net Alış, Geçen Yıl Aynı Dönem, Belge (fatura · fiş), Tedarikçi (ilk 3 tedarikçinin payı), Alış İadesi, Fiyat Artışı (ağırlıklı), Ort. Teslim Süresi, Vadesi Gelen Borç (30 gün içinde, gecikenler dahil).
- **Tedarikçi Bazında:** belge, brüt, iskonto, iade, net alış, geçen yıl, değişim, pay, teslim günü, açık borç; altında Para birimi tablosu.
- **Ürün Bazında:** miktar, net alış, ortalama / en düşük / en yüksek / son fiyat, tedarikçi sayısı, dönemde satılan ve bugün stokta.
- **Fiyat Gelişimi:** ilk fiyat ve tarih, son fiyat ve tarih, değişim, etki; altta ağırlıklı ortalama değişim.
- **Ay Trendi:** net alış, geçen yıl, stok alışı, satılan malın maliyeti ve fark (stoğa giden).
- **Dikkat:** sözleşme fiyatının üstünde alış, aynı kalemde daha ucuz tedarikçi (son 90 gün), faturası gelmemiş alış irsaliyesi, geciken sipariş, gelen e-Fatura kutusunda bekleyen fatura.

## Rakamlar nereden gelir
- Kesin alış faturası ve alış fişi ile aynı türlerin iadeleri. Gelen konsinye ayrıdır, icmale girmez. İrsaliyeden türeyen fatura bir kez sayılır; faturası gelmemiş irsaliye Dikkat'te durur.
- Tutar belgenin dip toplamından; kategori ve stok / hizmet süzgecinde belge toplamı satırlara satır tutarı oranında dağıtılır.
- Fiyat gelişimi satırın KDV hariç birim fiyatından; dövizli kalemde döviz fiyatı karşılaştırılır (kur etkisi fiyat artışı sayılmaz). Etki = (son − ilk fiyat) × ilk alıştan sonra alınan miktar.
- Teslim süresi = alış siparişinin tarihi → mal kabul (siparişin teslim kaydı, yoksa siparişten oluşturulan ilk giriş belgesi); siparişsiz alım hesaba girmez.
- Açık borç cari bakiyeden (TL); vadesi gelen borç cari hareketlerinin FIFO ile açık kalan kısmından.
- Satılan malın maliyeti ve "Satılan" sütunu stok hareketlerinden (satış − satış iadesi, ortalama maliyet).

## Çıktı
A4: dönem, kip, şube; tedarikçi başına belge, net alış, geçen yıl, pay; altta brüt / iskonto / iade / net alış ve döviz özeti; imza alanları (Hazırlayan, Satınalma Müdürü).

## Dikkat edilecekler
- Gelen e-Fatura kutusunda bekleyen (henüz kaydedilmemiş) faturalar alışa sayılmaz; cari ve stok etkisi yoktur. Dikkat sekmesinde tedarikçi, tutar ve kaç gündür beklediğiyle ayrı listelenir.
- Hizmet satırında Satılan / Stokta boştur.
- Borçta kur artışı aleyhimizedir (kırmızı); kur farkı yalnız açık borç için tahmindir.
- Sözleşme üstü alış yalnız yürürlükteki tedarikçi sözleşmesinde kalem fiyatı tanımlıysa görünür.

## Örnek sorular
- Bu yıl en çok hangi tedarikçiden alım yaptık?
- Hangi kalemlerin alış fiyatı yılbaşından bu yana arttı?
- Hangi tedarikçi geç teslim ediyor?
- Aynı ürünü daha ucuza veren tedarikçi var mı?
- Gelen kutusunda kaydedilmeyi bekleyen faturalar hangileri?
- Önümüzdeki 30 günde ne kadar borç ödeyeceğiz?
