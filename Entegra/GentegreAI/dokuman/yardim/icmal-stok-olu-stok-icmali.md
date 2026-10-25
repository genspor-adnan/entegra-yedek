---
id: icmal-stok-olu-stok-icmali
baslik: Ölü Stok / Devir Hızı İcmali
modul: stok
ekran: stok-olu-stok-icmali
rota: /stok-olu-stok-icmali
surec: icmal
roller: stok, satinalma, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: stok.olu_stok_icmali
erisim: kullanici
ozet: Eşikten uzun süre çıkış görmemiş bakiyeli stokları ve eritme önerilerini; stok başına devir hızını, ABC × hız tablosunu ve ay sonlarında ölü stok gelişimini gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi mala para bağladık ve dönmüyor? Neyi iade, transfer ya da kampanya ile eritelim?" sorusunu cevaplar. Satınalma için "bunu bir daha alma" listesidir; muhasebe ve yönetim ölü stok oranını izler.

## Bu ekranda neler yapabilirsiniz
- **Ölü eşiğini seçmek** — "90 gün / 180 gün / 365 gün" düğmeleri (varsayılan 180).
- **Hareket tanımını seçmek** — "Yalnız çıkış" (varsayılan; yeni alış ölü stoku canlandırmaz) ya da "Her hareket".
- **Tarih, depo, kategori süzmek** — "📅 Tarih itibarıyla", "🏬 Depo", "🗂 Kategori".
- **Sekmeler arasında geçmek** — Ölü Stoklar, Devir Hızı, ABC × Hız, Ölü Stok Gelişimi.
- **Öneri gerekçesini görmek** — Ölü Stoklar satırına tıklayın; depo dağılımı, önerinin nedeni (SKT, hangi depoda çıkıyor, son alış tedarikçisi) ve birim maliyet açılır.
- **Devir listesini sıralamak** — Devir Hızı sekmesinde "Tutar / Devir / Gün" düğmeleri.
- **Stok kartını açmak** — stok adına tıklayın.
- **Transfer listesine geçmek** — "🔄 Stok Transfer" düğmesi transfer listesini açar (fiş elle açılır).
- **Listede aramak** — "🔍 Stok kodu, adı ya da kategori…" kutusu.
- **Çıktı almak** — "🖨️ Ölü Stok / Devir Hızı İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › Ölü Stok / Devir Hızı İcmali** (`/stok-olu-stok-icmali`).
- `stok.olu_stok_icmali` görme yetkisi gerekir.

## Süzgeçler
- **Tarih itibarıyla**, **Depo**, **Kategori**, **Ölü eşiği** (90 / 180 / 365 gün), **Hareket sayılan** (yalnız çıkış / her hareket).

## Özet ve sekmeler
- Kutular: Ölü Stok Değeri, Ölü Oranı (önceki ay sonuyla), Devir Hızı, Stokta Kalma (gün), Hiç Çıkmamış, Yavaş (eşiğin yarısı ile eşik arası), Ölü + SKT Yakın, A Sınıfı.
- **Ölü Stoklar:** miktar, tutar, son giriş, son çıkış, çıkışsız gün, en yakın SKT, ABC sınıfı ve öneri.
- **Devir Hızı:** ortalama stok, 12 aylık çıkış, devir, gün karşılığı ve sınıf (hızlı ≥ 6 · normal 2–6 · yavaş < 2 · ölü).
- **ABC × Hız:** çıkış payına göre A / B / C ile hız sınıfının kesişimi (kalem ve stok değeri) ve Pareto tablosu.
- **Ölü Stok Gelişimi:** son 6 ay sonu ve bugün için ölü stok değeri, kalem, oran; bu dönem ölüye düşen / ölüden çıkan kalem sayısı.

## Rakamlar nereden gelir
- Ölü = bakiyesi olan ve son çıkıştan (hiç çıkmadıysa son girişten) bu yana eşikten fazla gün geçmiş kalem; transfer çıkış sayılmaz.
- Öneri sırası: SKT eşikten önce doluyorsa **iade / imha** · başka depoda aynı stok son 90 günde çıkıyorsa **transfer** · son alış 12 aydan yeniyse **tedarikçiye iade** · maliyeti yoksa **sayımla doğrula** · kalanında **kampanya / fiyat**.
- Devir = son 12 ayın çıkışı / ay sonu bakiyelerinin ortalaması; gün = 365 / devir. Tutarlar ortalama maliyetle, KDV hariç.
- ABC: 12 aylık çıkış tutarına göre ilk %80 A, %95'e kadar B, kalan C (çıkışı olmayan C).

## Çıktı
A4: tarih, eşik, depo, genel devir hızı; ölü stok listesi (miktar, tutar, son çıkış, öneri); stok değeri / yavaş / ölü toplamları.

## Dikkat edilecekler
- Öneriler yol gösterir, belge açmaz; transfer ya da alış iadesini kullanıcı açar.
- Stok hareket geçmişi kısaysa (ör. Delphi'den aktarılan açılış bakiyesi aktarım gününde giriş sayılır) liste ancak eşik süresi geçtikten sonra dolar.
- Geçmiş ay sonu bakiyeleri bugünkü bakiyeden sonraki hareketler geri sarılarak bulunur; değerler bugünkü maliyetle.

## Örnek sorular
- Hangi stoklar 6 aydır hiç satılmadı?
- Ölü stok oranımız ne kadar, geçen aya göre arttı mı?
- Bu stok neden "tedarikçiye iade" öneriyor?
- Devir hızı en düşük kalemler hangileri?
- ABC analizi nasıl hesaplanıyor?
