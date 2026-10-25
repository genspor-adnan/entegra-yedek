---
id: icmal-masraf-icmali
baslik: Masraf İcmali
modul: finans
ekran: masraf-icmali
rota: /masraf-icmali
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: finans.masraf_icmali
erisim: kullanici
ozet: Seçilen dönemde giderleri masraf kalemi ağacına (üst kalem › alt kalem), masraf merkezine, aya ve tedarikçiye göre; geçen yılla ve Planlı Giderler'in dönem planlarıyla karşılaştırarak gösterir; kalemi atanmamış, olağan dışı artan, mükerrer şüpheli giderleri uyarır ve kalemsiz satırlara toplu masraf kalemi atar.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Paramız nereye gidiyor, geçen yıla ve plana göre nerede artıyor, hangi merkez ne harcıyor?" sorusunu cevaplar. Yönetim, muhasebe ve bütçe için. Rakamlar sunucuda hesaplanır; ekran toplamaz.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihlerini değiştirin ya da "hazır…" listesinden Bu yıl / Bu ay / Geçen ay / Son 3 ay / Geçen yıl seçin (varsayılan bu yılın başı – bugün).
- **Karşılaştırmayı değiştirmek** — "⇄ Karşılaştır" listesinden Geçen yıl aynı dönem (varsayılan) ya da Önceki dönem (aynı uzunlukta hemen önceki dönem).
- **Şube, masraf merkezi ve kaleme göre süzmek** — "🏢 Şube", "🎯 Masraf merkezi" (alt merkezleriyle; "(merkez atanmamış)" seçeneği de var) ve "🗂 Kalem" (üst kalem seçilirse alt kalemleriyle; "Diğer (kalem atanmamış)" ve "Amortisman" de seçilebilir).
- **KDV hariç / dahil bakmak** — şeritteki "KDV hariç" (varsayılan; gider budur) ve "KDV dahil" (nakit bakışı) düğmeleri.
- **Planla kıyaslamayı, amortismanı ve taslakları açıp kapatmak** — "Planlı giderle kıyasla", "Amortisman dahil" (ikisi varsayılan açık) ve "Taslaklar dahil" kutuları.
- **Kalem ağacını açmak** — Kalem sekmesinde üst kaleme tıklayınca alt kalemleri açılır, çift tıklayınca Belge Detayı o kalemle süzülür; seçili kalemin kartını "🏷 Masraf kartı" açar.
- **Merkez × kalem kırılımını görmek** — Masraf Merkezi sekmesinde hücreye tıklayınca o merkez ve üst kalemin satırları Belge Detayı'nda listelenir.
- **Aylık trendi ve planı izlemek** — Aylık Trend sekmesi bu yıl, geçen yıl, plan ve planlı kalemlerin gerçeğini ay ay gösterir; Plan − Gerçek sekmesi planlı gider tanımı başına plan, gerçek, fark ve durumu verir (tanıma tıklayınca planlı gider kartı açılır).
- **Tedarikçiye göre bakmak** — Tedarikçi sekmesi ilk 10 tedarikçiyi gösterir; "… tedarikçi daha" bağlantısı hepsini açar, satıra tıklayınca o carinin gider satırları listelenir.
- **Belgeleri incelemek** — Belge Detayı sekmesinde satıra tıklayıp "📄 Seçili belgeyi aç" deyin ya da satıra çift tıklayın (alış belgesi, kasa işlemi ya da masraf beyanı kendi kartında açılır).
- **Masraf kalemi atamak** — "✎ Masraf kalemi ata…" önce kalemi atanmamış satırları listeler; satırların kutusunu işaretleyip (ya da "atanabilir … satırı seç") düğmeye yeniden basın, listeden kalemi seçip onaylayın. Başka kalemdeki bir satırı da yeniden atayabilirsiniz.
- **Uyarıları görmek** — Dikkat sekmesi kalemi atanmamış gideri, olağan dışı artışı, mükerrer şüphesini, KDV oranı değişen kalemi ve planlı gider tanımı olmayan tekrarlayan kalemi listeler; satıra tıklayınca ilgili satırlar açılır.
- **Planlı Giderler'e ya da Nakit Akış İcmali'ne geçmek** — araç çubuğunun sağındaki düğmeler.
- **Çıktı almak** — "🖨️ Masraf İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Finans › İcmaller › Masraf İcmali** (`/masraf-icmali`).
- `finans.masraf_icmali` görme yetkisi gerekir (haklar Masraf Listesi'nden kopyalanmıştır). Kalem atamak için ayrıca belge değiştirme, kasa işleminin masraf bacağı için kasa işlemi değiştirme yetkisi gerekir.

## Süzgeçler
- **Dönem**, **Karşılaştır**, **Şube** (yalnız kullanıcının şubeleri), **Masraf merkezi**, **Kalem**, **KDV hariç / dahil**, **Planlı giderle kıyasla**, **Amortisman dahil**, **Taslaklar dahil**.

## Özet ve sekmeler
- Kutular: Toplam Gider (ay sayısı), Geçen Yıl Aynı Dönem (değişim ve tutar), Aylık Ortalama (son 3 ay), Planlı Gider (aynı dönem, tanım sayısı), Plan − Gerçek (en çok aşan kalemler), En Büyük Kalem (pay), Gider / Ciro (net satış), Atanmamış (satır ve tutar).
- **Kalem (ağaç):** üst kalem › alt kalem; kod, muhasebe kodu, bu dönem, karşılaştırma, fark, pay, aylık ortalama. Olağan dışı artan kalem "⚠ artış", amortisman "nakit çıkışı yok" rozetiyle; kalemi atanmamış gider en altta "Diğer (kalem atanmamış)" satırında.
- **Masraf Merkezi:** merkez × ilk altı üst kalem + "Diğer"; toplam ve pay.
- **Aylık Trend:** ay, bu yıl, geçen yıl, fark; plan açıksa plan, planlı kalemlerin gerçeği ve gerçek − plan.
- **Plan − Gerçek:** planlı gider, kalem, plan, gerçek, fark, fark %, dönem (eşleşen / planlanan) ve durum (planında · plan dışı artış · tahmin düşük · dönem ödenmedi · planın altında).
- **Tedarikçi:** tedarikçi, ana kalem, gider, belge sayısı, karşılaştırma ve fark.
- **Belge Detayı:** tarih, belge, kaynak, tedarikçi, açıklama, kalem, merkez, KDV hariç, KDV; seçilebilir kutular ve toplam.
- **Dikkat:** tür, belge / kayıt, tarih, açıklama, öneri.

## Rakamlar nereden gelir
- **Alış belgeleri:** kesin alış faturası, alış fişi ve gider pusulası ile iadeleri (iade eksi). Yalnız stoksuz satırlar (hizmet / masraf satırı) gider sayılır; stoklu mal alımı stoğa girer, satılınca Kârlılık İcmali'nde maliyet olur. Satır tutarı belgenin dip toplamından (KDV hariç / dahil) satır payına bölüştürülür. Kalem satırın masraf kalemi, yoksa belgenin başlığındaki masraf kalemidir.
- **Kasa / banka:** gerçekleşmiş kasa işleminin masraf bacağı (Masraf Ekstresi ile aynı küme); kalemsiz masraf bacağı "Diğer"e düşer. Cariye yapılan ödemenin kendisi gider değildir (faturası sayılır), böylece aynı gider iki kez sayılmaz. Bordro modülü olmadığından maaş gibi giderler ödeme tarihine göre girer ("ödeme esaslı" rozeti).
- **Masraf beyanı:** onaylanmış personel masraf beyanlarının satırları, harcama tarihine göre.
- **Amortisman:** demirbaşların yıllık amortismanı döneme gün oranıyla bölünür, ayrı "Amortisman" üst kalemidir; nakit çıkışı değildir.
- **Masraf merkezi:** belge satırından, yoksa belgenin başlığından; o da yoksa "(merkez atanmamış)" — tahmin edilip dağıtılmaz.
- **Plan:** Planlı Giderler'in dönem planı (dondurulmuş ya da tanımın kuralıyla hesaplanan); plan tarihi dönemde olanlar, atlanan dönem hariç. Tanım eklenmeden önceki dönemler plan sayılmaz. Dövizli tanım bugünkü kurla TL'ye çevrilir (şeritte not düşülür). Gerçek = aynı masraf kalemindeki gider.
- **Gider / Ciro:** ciro, Satış İcmali'nin net satışıdır (kesin satış faturası ve fişi, KDV hariç, iadeler düşülmüş); oran her zaman KDV hariç giderle.
- **Eşikler** (Genel Ayarlar › İcmal Eşikleri): olağan dışı artış = son 3 tam ay ortalaması önceki 6 ayın `masraf.artis_esik_yuzde` (boş = %25) üstü; mükerrer = aynı cari + aynı belge tutarı ± `masraf.mukerrer_gun` (boş = 1) gün.

## Çıktı
A4: dönem, kip (KDV hariç / dahil, karşılaştırma, amortisman), şube ve masraf merkezi; üst kalem başına bu dönem, karşılaştırma, fark ve pay; altta toplam gider, planlı gider ve plan − gerçek (plan açıksa), gider / ciro; imza alanları (Hazırlayan, Genel Müdür). Dipnotta "Diğer" satırındaki atanmamış tutar ve amortismanın nakit çıkışı olmadığı yazar.

## Dikkat edilecekler
- Kapanmış muhasebe döneminde kalem atanamaz; satırın kutusu pasiftir ve gerekçesi üzerinde yazar.
- Hizmet kartına bağlı belge satırına, Delphi'den gelen kayda ve kapalı kasa gününe kalem atanmaz; masraf beyanının kalemi beyan kartında, amortisman demirbaş kartında düzeltilir.
- Kalem ataması tutarı, cariyi ve stoğu değiştirmez; belgenin muhasebe fişi varsa gider hesabı fişte kendiliğinden değişmez (sonuç mesajında uyarılır).
- Plan − Gerçek tablosunda yalnız planlı gider tanımı olan kalemler vardır; ötekiler Kalem sekmesinde.
- Tedarikçi tablosunda carisiz giderler (kasa masraf bacağı, masraf beyanı, amortisman) yoktur.

## Örnek sorular
- Bu yıl en çok hangi kaleme harcadık, geçen yıla göre ne kadar arttı?
- Hangi masraf merkezi ne kadar harcıyor?
- Planlı giderlerimizin hangisi planı aştı?
- Kalemi girilmemiş giderler hangileri, toplu nasıl atarım?
- Aynı tedarikçiden mükerrer fatura gelmiş olabilir mi?
- Giderlerimiz cironun yüzde kaçı?
