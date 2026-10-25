---
id: icmal-stok-hareket-icmali
baslik: Stok Hareket İcmali
modul: stok
ekran: stok-hareket-icmali
rota: /stok-hareket-icmali
surec: icmal
roller: stok, depo, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: stok.hareket_icmali
erisim: kullanici
ozet: Seçilen dönemde her stokun devir, hareket türüne göre giriş / çıkış ve dönem sonu kalanını; tür × hafta tablosunu, depo akışını ve tek stokun yürüyen bakiyeli ekstresini gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Dönemde hangi stoktan ne girdi, ne çıktı, nereye gitti?" sorusunu cevaplar. Ay kapanışında depo sorumlusunun mutabakatı, kayıp-kaçak ve "bu mal nereye gitti" soruşturması için kullanılır. Devir ve kalan, Stok Değer İcmali'nin "tarih itibarıyla" bakiyesiyle aynı hesaptan gelir; iki ekran aynı gün için aynı rakamı verir.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihlerini değiştirin (varsayılan bu ayın başı – bugün; ileri tarih seçilemez).
- **Depo / kategori süzmek** — "🏬 Depo" ve "🗂 Kategori" listelerinden seçin; tek depo seçilince transfer giriş / çıkış sütunları açılır.
- **Miktar ya da tutar görmek** — "Miktar" / "Tutar (ort. maliyet)" düğmeleri; tutarda girişler belgenin kendi fiyatıyla, çıkışlar ve devir / kalan ortalama maliyetle hesaplanır, aradaki "değerleme farkı" Kalan kutusunda yazar.
- **Sekmeler arasında geçmek** — Stok Bazında, Hareket Türü × Hafta (ya da Ay), Depo Akışı, Stok Ekstresi.
- **Depo kırılımını açmak** — birden fazla depoda hareketi olan stok satırına tıklayın; depo başına devir / giriş / çıkış / transfer / kalan açılır.
- **Stok ekstresine geçmek** — Stok Bazında satırına çift tıklayın; o stokun dönemdeki bütün hareketleri yürüyen bakiyeyle Stok Ekstresi sekmesinde açılır.
- **Belge kartını açmak** — Stok Ekstresi'nde harekete çift tıklayın; fatura / irsaliye / fiş kartı açılır.
- **Stok kartını açmak** — stok adına tıklayın.
- **Listede aramak** — "🔍 Stok kodu, adı ya da kategori…" kutusuna yazın.
- **Çıktı almak** — "🖨️ Stok Hareket İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › Stok Hareket İcmali** (`/stok-hareket-icmali`).
- Diğer stok icmallerindeki düğmeler.
- `stok.hareket_icmali` görme yetkisi gerekir (ilk kurulumda Stok Listesi'ni gören rollere verilmiştir).

## Süzgeçler
- **Dönem**, **Depo** (yalnız kullanıcının şubelerine ait depolar), **Kategori** (alt dallarıyla), **Miktar / Tutar**.

## Özet ve sekmeler
- Kutular: Devir (dönem başı), Giriş, Çıkış, Kalan (dönem sonu), Hareket Gören kalem, Belge sayısı, Transfer, Sayım Farkı.
- **Stok Bazında:** devir, her giriş türü (alış, satış iadesi, giriş fişi, sayım fazlası…), her çıkış türü (satış, alış iadesi, çıkış fişi, sarf, sayım eksiği…), kalan ve hareket sayısı. Dönemde eksiye düşen stok işaretlenir.
- **Hareket Türü × Hafta / Ay:** türlerin dönem içindeki dağılımı; koyuluk hacme göre. Dönem 62 günü aşarsa sütunlar ay olur.
- **Depo Akışı:** depo başına devir / giriş / çıkış / transfer / kalan ve depolar arası transfer listesi (çıkış deposu → giriş deposu, fiş sayısı).
- **Stok Ekstresi:** tarih, belge, numara, cari, depo, lot · SKT, giriş, çıkış, bakiye.

## Rakamlar nereden gelir
- Hareketler stoku etkileyen kesin belgelerden (fatura, irsaliye, giriş / çıkış fişi, transfer, konsinye, üretim) gelir; yön kuralı stok fişleriyle aynıdır, iade ters yöndedir.
- Sayım kapatılınca kesilen giriş / çıkış fişleri ayrı sütundur (Sayım fazlası / eksiği).
- Depolar arası transfer tüm depolarda sıfır toplamlıdır: kutulardaki Giriş / Çıkış'a girmez, ayrı gösterilir.
- Devir = dönem başından bir gün önceki bakiye; Kalan = bitiş günündeki bakiye (stok durumu − sonraki hareketler).
- Tutar modu: alış faturası / irsaliyesi / fişi, gelen konsinye, üretim girişi, giriş fişi ve sayım fazlası satırın kendi tutarıyla (TL, KDV hariç; fiyatı boşsa ortalama maliyet); çıkış, iade ve transfer ortalama maliyetle; devir ve kalan stok değeri (ortalama maliyet). Değerleme farkı = kalan − (devir + giriş − çıkış ± transfer); miktarda sıfırdır.

## Çıktı
A4: dönem, depo, birim; stok başına devir / giriş / çıkış / kalan; altta toplamlar ve imza alanları.

## Dikkat edilecekler
- Devir / Kalan kutuları bakiyesi olan bütün stokları kapsar; tablodaki satırlar yalnız hareket görenlerdir.
- Aktarımla gelen açılış bakiyesi aktarım gününde giriş fişi olarak görünebilir.
- Ekstre her zaman miktardır; tüm depolar seçiliyken transfer iki satırdır (çıkan depo eksi, giren depo artı).

## Örnek sorular
- Bu ay hangi stoklardan en çok çıkış oldu?
- Bir stokun dönem içindeki bütün hareketlerini nasıl görürüm?
- Sayım farkı olarak ne kadar mal düştü?
- Anadepo'dan ALT depoya ne kadar transfer yapıldı?
- Stok hareket icmalini Excel'e nasıl alırım?
