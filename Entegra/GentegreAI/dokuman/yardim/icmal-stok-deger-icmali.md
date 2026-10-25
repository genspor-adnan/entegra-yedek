---
id: icmal-stok-deger-icmali
baslik: Stok Değer İcmali
modul: stok
ekran: stok-deger-icmali
rota: /stok-deger-icmali
surec: icmal
roller: stok, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: stok.deger_icmali
erisim: kullanici
ozet: Seçilen tarih itibarıyla depolardaki stok bakiyesinin miktar × birim maliyet değerini; kategori × depo kırılımını, stok yaşını ve dikkat edilecek kalemleri gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Depoda ne kadarlık mal var, nerede, ne kadar süredir duruyor?" sorusunu cevaplar. Seçilen tarihteki depo bakiyesini birim maliyetle çarpıp stok değerini (KDV hariç) verir; değerin kategori ve depoya dağılımını, hareketsiz kalan malı ve hatalı görünen kalemleri (eksi bakiye, maliyetsiz, lot uyumsuz) öne çıkarır. Stok sorumlusu, muhasebe (dönem sonu stok değeri) ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Tarih seçmek** — "📅 Tarih itibarıyla" kutusundan geçmiş bir günü seçin; bakiye o güne geri sarılarak hesaplanır (ileri tarih seçilemez).
- **Depo / kategori süzmek** — "🏬 Depo" ve "🗂 Kategori" listelerinden seçin; kategori seçimi alt kategorileri de kapsar.
- **Değerleme yöntemini değiştirmek** — Ortalama maliyet / Son alış / Satış fiyatı düğmelerinden birine tıklayın.
- **Pasif stokları dahil etmek** — "Pasif stoklar dahil" kutusunu işaretleyin.
- **Sekmeler arasında geçmek** — Stok Bazında, Kategori × Depo, Stok Yaşı, Dikkat.
- **Satırı açıp kırılımı görmek** — Stok Bazında sekmesinde satıra tıklayın; depo (bugün için lot) dağılımı açılır.
- **Stok kartını açmak** — Stok adına (ya da Dikkat listelerindeki koda) tıklayın; kart kendi sekmesinde açılır.
- **Listede aramak** — "🔍 Stok kodu, adı ya da kategori…" kutusuna yazın.
- **Çıktı almak** — "🖨️ Stok Değer İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer ekranlara geçmek** — ⏳ SKT / Lot İcmali, ⚖ Sayım Fark İcmali, 🧮 Stok Sayımları, 📦 Stok Listesi düğmeleri.

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › Stok Değer İcmali** (`/stok-deger-icmali`).
- SKT / Lot İcmali ve Sayım Fark İcmali ekranlarındaki "📦 Stok Değer İcmali" düğmesi.
- `stok.deger_icmali` görme yetkisi gerekir.

## Süzgeçler
- **Tarih itibarıyla** (varsayılan bugün), **Depo** (Tümü ya da tek depo; yalnız kullanıcının şubelerine ait depolar), **Kategori** (alt dallarıyla), **Değerleme** (Ortalama maliyet varsayılan), **Pasif stoklar dahil**.
- Süzgeçler adres çubuğuna yazılır; sekme yenilense de kalır.
- Eksi bakiyeli kalem varsa şeritte kırmızı "Eksi bakiyeli: N kalem" uyarısı çıkar.

## Özet ve sekmeler
Özet kutuları: **Stok Değeri** · **Kalem** (bakiyesi olan / aktif stok) · **Miktar** (ana birimde, karışık birim) · **Lotlu Kalem** (değerdeki payı, bugün için lot sayısı) · **Hareketsiz (180+ gün)** · **Maliyeti Tanımsız** · **Eksi Bakiye** · **Önceki Ay Sonu** (değer ve aradaki değişim).

Sekmeler:
- **Stok Bazında** — Kod, Stok Adı, Kategori, Birim, İzleme, Miktar, Birim Maliyet, Tutar, Pay çubuğu, Son Giriş, Son Çıkış, Hareketsiz gün; altta toplam. En fazla 1000 satır gösterilir.
- **Kategori × Depo** — kategori satırları, depo sütunları (ısı renkli), toplam, kalem ve pay.
- **Stok Yaşı** — son hareketten bu yana 0–30 / 31–90 / 91–180 / 180+ gün dilimleri; kategori bazında son 12 ay devir hızı ve "gün karşılığı" (365 / devir).
- **Dikkat** — ⛔ Eksi bakiye, ⚠ Maliyeti tanımsız, 🏷 Lot toplamı stok bakiyesini tutmuyor (yalnız bugün), 💤 En değerli hareketsiz kalemler.

## Rakamlar nereden gelir
- Uç: `GET /api/stok-icmal/deger` (`StokIcmalUclari.cs`). Ekran hesap yapmaz.
- **Miktar**: bugün için `stok_durum` bakiyesi; geçmiş tarihte bu bakiyeden o tarihten sonraki hareketler (`v_stok_hareket`) çıkarılır.
- **Birim maliyet**: Ortalama = giriş belgelerinin ağırlıklı ortalaması (`fn_uretim_stok_maliyeti`, üretim maliyetiyle aynı kaynak); Son alış = son alış belgesi satırının tutar / miktarı (yoksa ortalama); Satış = kart satış fiyatı.
- **Tutar** = miktar × birim maliyet (2 hane yuvarlanır); Stok Değeri bunların toplamı.
- **Hareketsiz gün** = son giriş ya da çıkıştan bu yana geçen gün; hiç hareket yoksa "hareket yok" (180+ sayılır).
- **Devir** = son 12 ayda çıkan miktar × birim maliyet / stok değeri.
- **Önceki Ay Sonu** = aynı süzgeçle bir önceki ayın son günü itibarıyla hesaplanan değer.

## Çıktı
"🖨️ Stok Değer İcmali ▾" menüsü A4 belge üretir: antet, tarih / değerleme / depo / kalem bilgisi, kategori × depo tablosu, stok listesi (ekrandaki arama süzgecine göre), depo toplamları, hareketsiz tutar ve STOK DEĞERİ; Hazırlayan ve Mali İşler / Yönetim imza alanları. Dosya adı "Stok Değer İcmali <tarih>".

## Dikkat edilecekler
- Maliyeti olmayan kalem değere 0 ile girer; Dikkat sekmesinde listelenir.
- Lot kırılımı ve lot uyumsuzluğu yalnız **bugün** için gösterilir (lot defteri geriye sarılmaz).
- Miktar toplamı farklı birimleri toplar; yalnız fikir verir.
- Değer KDV hariçtir. Depo süzgeci kullanıcının yetkili şubeleriyle sınırlıdır.

## Örnek sorular
- Ay sonu itibarıyla depodaki stoğun toplam değeri ne kadar?
- Hangi kalemler 180 günden fazladır hareketsiz duruyor?
- Neden bazı stoklar eksi bakiyede görünüyor?
- Ortalama maliyet ile son alış fiyatına göre değer ne kadar değişiyor?
- Hangi depoda hangi kategoriden ne kadarlık mal var?
- Bu listeyi Excel'e nasıl alırım?
