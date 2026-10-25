---
id: icmal-nakit-akis-icmali
baslik: Nakit Akış (Vade) İcmali
modul: finans
ekran: nakit-akis-icmali
rota: /nakit-akis-icmali
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.nakit_akis_icmali
erisim: kullanici
ozet: Bugünkü kasa + banka bakiyesinden başlayarak önümüzdeki 30 / 90 / 180 gün ya da 12 ayın haftalık veya aylık beklenen giriş, çıkış ve kapanış bakiyesini; en düşük noktayı, döviz pozisyonunu ve görünüm amaçlı senaryoları gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Önümüzdeki haftalarda kasada / bankada ne kadar param olacak, hangi hafta eksiye düşüyorum, ne yaparsam düzelir?" sorusunu cevaplar. Mali işler ve yönetim içindir. Vadeye dayalı bir tahmindir, kesin bakiye değildir.

## Bu ekranda neler yapabilirsiniz
- **Ufku seçmek** — "30 gün / 90 gün / 180 gün / 12 ay" düğmeleri; başlangıç her zaman bugündür.
- **Haftalık ya da aylık görmek** — "Haftalık / Aylık" düğmeleri.
- **Hesap seçmek** — "🏦 Hesaplar" listesinden açılışa girecek kasa / banka / POS hesaplarını işaretleyin (yalnız açılış bakiyesini etkiler).
- **Vadesi geçmiş alacakları ilk haftaya koymak** — kutu işaretliyse gecikmiş alacak, gerçekleşme oranıyla ilk haftaya girer; işaretli değilse akışa girmez.
- **Planlı ödemeleri dahil etmek / çıkarmak** — maaş, kredi taksiti, kredi kartı borcu ve ödeme planları.
- **Girişleri ve çıkışları kalem kalem görmek** — Girişler / Çıkışlar sekmeleri; çift tık belge, çek / senet ya da cari kartını açar; kutuya yazarak arayın.
- **Senaryo denemek** — Senaryo sekmesinde carinin ortalama gecikmesi, vadesi geçmiş alacakların gerçekleşme oranı, 3. kişi çeklerinde karşılıksız payı ve "pazarlık edilebilir" ödemelerin ertelenmesi; sonuç tablosu iyimser ve seçili senaryonun en düşük bakiyesini yan yana gösterir. Senaryo hiçbir şey kaydetmez.
- **Döviz pozisyonuna bakmak** — her dövizden girecek / çıkacak tutar, açık pozisyon ve bugünkü kurla TL karşılığı.
- **Planlı gider tanımlarını denetlemek** — hangi tekrarlayan giderin akışta olduğu, hangisinin tanımı olmadığı.
- **Çıktı almak** — "🖨️ Nakit Akış İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; A4'e seçili senaryo yazılır.

## Ekrana giriş
- Sol menü **Finans › İcmaller › Nakit Akış (Vade) İcmali** (`/nakit-akis-icmali`).
- Tahsilat / Ödeme İcmali'ndeki "📈 Nakit Akış (Vade)" düğmesi.
- `finans.nakit_akis_icmali` görme yetkisi gerekir (ilk kurulumda kasa işlem listelerini gören rollere verilir).

## Süzgeçler
- **Ufuk**, **Haftalık / Aylık**, **Hesaplar**, **Şube** (birden çok şubesi olan kullanıcıda), **Vadesi geçmiş alacakları ilk haftaya koy**, **Planlı ödemeler dahil**.
- Senaryo ayarları adres çubuğunda durur; sekme yenilenince kalır, başka kullanıcıyı etkilemez.

## Özet ve sekmeler
- Kutular: Bugünkü Nakit (kasa · banka · POS), Beklenen Giriş, Beklenen Çıkış, Ufuk Sonu Bakiyesi, En Düşük Nokta, Vadesi Geçmiş Alacak (geçmiş gerçekleşme oranıyla), Ortalama Tahsilat Gecikmesi, Kredi Limiti Boşta (KMH).
- **Haftalık / Aylık Akış:** açılış, fatura tahsilatı, çek / senet, plan, toplam giriş, tedarikçi ödemesi, verilen çek, planlı, toplam çıkış, kapanış; eksi bakiyeli dönem kırmızı. Altında döviz pozisyonu ve planlı gider tanımı.
- **Girişler:** vade, kaynak, cari, belge, tutar, carinin ortalama gecikmesi, beklenen tarih, güven.
- **Çıkışlar:** vade, kaynak, alacaklı, belge, tutar, ödeme hesabı, esneklik (ertelenemez / pazarlık edilebilir).
- **Senaryo:** ayarlar ve sonuç tablosu (vadeye göre, seçili, + ödemeler ertelenirse, + KMH kullanılırsa).

## Rakamlar nereden gelir
- **Açılış:** seçili kasa / banka / POS hesaplarının bugünkü bakiyesi (hesap ekstresiyle aynı).
- **Giriş:** açık satış alacaklarının vadesi (Cari İcmali'nin kuralı: tahsilat en eski vadeli kalemi kapatır; vade = hareketin plan tarihi, yoksa işlem + carinin vade günü); tahsilat planı varsa plan (planın tutarı carinin en eski açık alacağından düşülür); portföydeki, tahsildeki ve teminattaki alınan çek / senet vadesi.
- **Çıkış:** açık borçların vadesi (ödeme planı varsa plan), verilen ve henüz ödenmemiş çek / senet, kredi taksitleri, kredi kartı borcu (son ödeme gününe), ödeme planları ve maaş.
- **Maaş:** aktif personelin kartındaki aylık net maaş toplamı, her ayın son günü (bordro modülü olmadığı için yaklaşık).
- **Döviz:** dövizli kalemler bugünkü kurla TL'ye çevrilir; kur yoksa kalem kendi kuruyla girer ve döviz tablosunda "kur yok" yazar.
- **Gecikme:** carinin son 6 aydaki tahsilatlarının vadeden sonra kaç gün geldiği (tutar ağırlıklı). **Gerçekleşme oranı:** vadesi 90 - 270 gün önce dolan alacakların vadeden sonraki 90 gün içinde tahsil edilen payı.
- Vadesi geçmiş ödemeler (verilen çek, tedarikçi borcu) her zaman ilk haftaya girer.

## Çıktı
A4: başlangıç, ufuk, periyot, hesaplar, seçili senaryo, bugünkü nakit; hafta / ay başına açılış, giriş, çıkış, kapanış; beklenen giriş / çıkış, en düşük bakiye, ufuk sonu bakiyesi ve imza alanları.

## Dikkat edilecekler
- Kira, vergi, SGK, abonelik gibi tekrarlayan giderlerin tanım ekranı henüz yok; "Planlı gider tanımı" tablosunda "tanım yok" uyarısıyla görünür ve akışa girmez.
- Kredi kartı borcunun tamamı bir sonraki son ödeme gününe yazılır (ekstre kesimi ayrımı yoktur).
- Yeni satış varsayımı (henüz faturalanmamış satış) bu sürümde yoktur.
- Hesap seçimi yalnız açılışı değiştirir; kalemlerin hangi hesaptan ödeneceği çoğunlukla belli değildir.

## Örnek sorular
- Önümüzdeki 90 günde hangi hafta eksiye düşüyoruz?
- Vadesi geçmiş alacakların yarısı gelmezse en düşük bakiye ne olur?
- Tedarikçi ödemelerini 15 gün ertelersek nakit yeter mi?
- Euro borcumuz kur artarsa ne kadar büyür?
- Maaş ve kredi taksitleri akışa dahil mi?
- Nakit akış icmalini Excel'e nasıl alırım?
