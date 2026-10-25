---
id: icmal-tahsilat-odeme-icmali
baslik: Tahsilat / Ödeme İcmali
modul: finans
ekran: tahsilat-odeme-icmali
rota: /tahsilat-odeme-icmali
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.tahsilat_odeme_icmali
erisim: kullanici
ozet: Seçilen dönemde kimden ne tahsil edildiğini, kime ne ödendiğini ödeme aracına, cariye, kasa / banka hesabına ve tahsil eden kişiye göre gösterir; faturaya dağıtılmamış tahsilatları, iade / iptalleri ve vadesi geçmiş ödemeleri listeler.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönem kimden ne tahsil ettik, kime ne ödedik, hangi araçla, hangi hesaba; tahsilat satışa yetişiyor mu?" sorusunu cevaplar. Muhasebe ve yönetimin ay kapanışı içindir. Cari İcmali bakiyeyi, Kasa / Gün Sonu tek günü anlatır; bu icmal dönem içindeki para hareketini araç ve hesap bazında anlatır.

## Bu ekranda neler yapabilirsiniz
- **Tahsilat, ödeme ya da ikisini görmek** — şeritteki "Tahsilat / Ödeme / İkisi" düğmeleri.
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihleri ya da "Hızlı…" listesinden Bu ay, Geçen ay, Son 30 gün, Bu yıl.
- **Şube, tahsil eden ve para birimi süzmek** — "🏢 Şube", "👤 Tahsil eden / Temsilci", "💱 Para birimi" (TL karşılığı ya da yalnız o dövizdeki işlemler kendi tutarıyla).
- **Virmanları görmek** — "Virmanları göster" işaretlenince hesaplar arası aktarım ve cari virman ayrı tabloda / ayrı satırda görünür (toplama girmez).
- **Ödeme aracına göre dökümü açmak** — Ödeme Aracı sekmesinde araç satırına tıklayın; o araçla yapılan işlemler açılır.
- **Cari bazında incelemek** — Cari Bazında sekmesinde satıra tıklayın: işlemler ve dağıtıldığı faturalar açılır; çift tık cari ekstresini, cari adına tıklamak cari kartını açar.
- **Seçili carinin ekstresine geçmek** — Cari Bazında'da bir satır seçip araç çubuğundaki "📄 Seçili carinin ekstresi".
- **Hesap × dönem tablosuna bakmak** — Gün / Hesap sekmesinde hücreye tıklayın; o hesabın o dönemdeki ekstresi açılır. POS satırının altında brüt, hesaba geçen ve komisyon yazar.
- **Tahsil edene göre süzmek** — Tahsil Eden sekmesinde kişiye tıklayın; bütün sekmeler yalnız onun işlemlerini gösterir.
- **Dikkat listelerini görmek** — faturaya dağıtılmamış tahsilatlar, iade / iptaller, bu dönem hiç ödeme yapmayan bakiyeli müşteriler, vadesi geçmiş ödemelerimiz.
- **Çıktı almak** — "🖨️ Tahsilat / Ödeme İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Finans › İcmaller › Tahsilat / Ödeme İcmali** (`/tahsilat-odeme-icmali`).
- Nakit Akış (Vade) İcmali'ndeki "💳 Tahsilat / Ödeme" düğmesi.
- `finans.tahsilat_odeme_icmali` görme yetkisi gerekir (ilk kurulumda kasa işlem listelerini gören rollere verilir).

## Süzgeçler
- **Tahsilat / Ödeme / İkisi**, **Dönem**, **Şube** (yalnız kullanıcının şubeleri), **Tahsil eden / Temsilci**, **Para birimi**, **Virmanları göster**.
- Kayıt kapsamı tanımlı kullanıcı yalnız kendi carilerinin işlemlerini görür.

## Özet ve sekmeler
- Kutular: Tahsilat, Ödeme, Net Nakit Girişi, Tahsilat / Satış, Ortalama Tahsil Süresi (önceki aynı uzunluktaki dönemle), Ortalama Ödeme Süresi, Dağıtılmamış, Çek / Senet ile.
- **Ödeme Aracı:** tahsilat (Havale / EFT, Kredi kartı / POS, Çek, Senet, Nakit, Kupon) ve ödeme (Havale / EFT, Verilen çek / senet, Ciro edilen çek, Kredi kartı, POS ile ödeme, Nakit) araç başına işlem, tutar, pay. Avans mahsubu bilgi satırıdır.
- **Cari Bazında:** cari, tür, tahsilat, ödeme, dönem faturası, tahsil oranı, ortalama gün, dağıtılmamış, kalan bakiye.
- **Gün / Hesap:** kasa / banka / POS hesabı × dönem (14 güne kadar gün, 92 güne kadar 7 günlük dilim, üstü ay) giriş − çıkış; giriş, çıkış, net.
- **Tahsil Eden:** kişi başına işlem, tahsilat, nakit, POS, havale, çek / senet ve gün sonu farkı.
- **Dikkat:** dört liste (yukarıda).

## Rakamlar nereden gelir
- Tutarlar kasa işlemlerinin cari (ya da gelir / gider kalemi) bacağından, gerçekleşmiş işlemlerden gelir. Tahsilat: nakit, banka, çek, senet, POS, kupon; ödeme: nakit, banka, çek, senet, kredi kartı, kupon, çek ciro, POS ile ödeme (kredi kartı ödeme iadesi eksi).
- **Çekle / senetle tahsilat çekin alındığı gün sayılır** (cari o gün kapanır). Paraya dönüşmesi Nakit Akış ve Çek / Senet icmallerinde görünür.
- **POS tahsilatı brüttür**; banka komisyonu ve hesaba geçen tutar Gün / Hesap'ta POS satırının altında. Komisyon kaydı yoksa kart oranıyla "tahmini" yazar.
- İade eksi tutarla aracının içindedir; iptal edilen işlem ve ters kaydı toplama girmez (Dikkat sekmesinde listelenir).
- Gün / Hesap kasa / banka / POS bacaklarından, Kasa / Gün Sonu ile aynı kümedir; hesaplar arası aktarım (virman) toplama girmez.
- Ortalama gün: tahsilat faturaya dağıtılmışsa fatura tarihinden tahsilat tarihine (tutar ağırlıklı); dağıtılmamışsa Cari İcmali'nin kuralıyla en eski vadeli açık kalemden (FIFO).
- Tahsil oranı = dönem tahsilatı / dönem satış faturası (tedarikçide ödeme / alış). Kalan bakiye Cari İcmali ile aynı hesaptır (bitiş günü, + borçlu).
- Dövizli işlem işlem kuruyla TL'dir; para birimi seçilince yalnız o dövizdeki işlemler kendi tutarıyla.

## Çıktı
A4: dönem, kapsam, şube, işlem ve cari sayısı; araç grubu başına tahsilat / ödeme / net; altta tahsilat, ödeme, net nakit girişi ve imza alanları.

## Dikkat edilecekler
- Dağıtılmamış tahsilat cari bakiyesini düşürür ama faturayı açık gösterir; tahsilatı Kasa ekranında faturaya dağıtın.
- Aktarımla gelen tahsilatların fatura dağıtımı yoktur; ortalama günleri FIFO'dan hesaplanır, dağıtılmamış sayılmaz.
- Avans mahsubu para hareketi değildir; tahsilat toplamına girmez (avans alındığı gün kendi aracında sayılmıştır).
- Tahsil eden: kasa ve POS tahsilatı işlemi alan kullanıcıya (banko oturumunun kasiyerine), banka tahsilatı carinin temsilcisine yazılır.

## Örnek sorular
- Bu ay POS ile ne kadar tahsil ettik, komisyon ne kadar?
- Hangi müşterilerin tahsilatı faturaya dağıtılmamış?
- Tahsilatımız satışın yüzde kaçı?
- Bu dönem hiç ödeme yapmayan bakiyeli müşteriler kimler?
- Vadesi geçmiş tedarikçi ödemelerimizi nerede görürüm?
- Tahsilat / ödeme icmalini PDF olarak nasıl alırım?
