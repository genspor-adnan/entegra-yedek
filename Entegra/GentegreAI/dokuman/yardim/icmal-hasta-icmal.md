---
id: icmal-hasta-icmal
baslik: Hasta İcmali (Hesap İcmali)
modul: kayit_kabul
ekran: hasta-icmal
rota: /hasta-icmal
surec: icmal
roller: banko, vezne, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 2
yetki: hasta
erisim: kullanici
ozet: Tek bir hastanın seçilen dönemdeki başvurularını, hizmet satırlarını, kurum / hasta payını, tahsilat ve iadelerini, SGK provizyonlarını ve kalan borcunu tek ekranda gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Hasta İcmali "bu hasta bize ne kadar borçlu, neyi ödedi, kurum ne kadarını karşılıyor?" sorusunu cevaplar. Banko / vezne görevlisi hastaya söylenecek kalan borcu görür, muhasebe başvuru başvuru tahsilatı kontrol eder, icmal A4 olarak yazdırılıp hastaya verilebilir. Ekran salt okunurdur; tahsilat ya da düzeltme bu ekrandan yapılmaz.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — şeritteki 📅 Dönem başlangıç / bitiş tarihini değiştirin; icmal hemen yeniden hesaplanır (varsayılan son 12 ay).
- **Özet kutularını okuma** — Toplam Hizmet, Kurum Payı, Hasta Payı, İskonto, Tahsil Edilen, İade, Kalan Borç ve Avans / Alacak tek bakışta.
- **Sekmeler arasında geçiş** — Başvurular, Hizmetler, Tahsilatlar, Kurum Provizyonları, Hareket Özeti sekmelerine tıklayın; sekme adındaki sayı satır adedidir.
- **Başvurunun hizmetlerini açma** — Başvurular sekmesinde satıra tıklayın; altında o başvurunun hizmet satırları (kod, ad, adet × fiyat = tutar) açılır, tekrar tıklayınca kapanır.
- **Cari ekstre gibi okuma** — Hareket Özeti sekmesinde hasta payı borç, tahsilat alacak olarak tarih sırasıyla yürüyen bakiyeyle listelenir.
- **Provizyon kontrolü** — Kurum Provizyonları sekmesinde kurum payı olan başvuruların provizyon / takip numarası var mı ("Provizyonlu" / "Provizyon yok") görülür.
- **Çıktı alma** — "Hasta İcmali" çıktı menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Geldiğiniz ekrana dönme** — başka bir icmalden ya da listeden geldiyseniz **↩ Geri Dön** sizi aynı süzgeçlerle oraya götürür.

## Ekrana giriş
- Hasta listesinde hastayı seçip araç çubuğu / sağ tuş / komut paleti (Ctrl+K) › **🧾 Hesap İcmali** (aksiyon `hasta.icmal`; hasta seçilmemişse "Önce bir hasta seçin.").
- Hasta kartının hesap bölümündeki **Hesap Özeti** kutusunda **📊 Hesap İcmali** düğmesi.
- Hasta adına tıklayarak: Kurum İcmali, İskonto İcmali, Hasta Başı Maliyet, Hasta Borç Takibi, Alacak Yaşlandırma, Medula Mutabakat İcmali ekranlarından (bu durumda **↩ Geri Dön** çıkar).
- Adres `/hasta-icmal/[hasta no]`; sol menüde ayrı bir girişi yoktur, her zaman bir hasta için açılır.
- Rota hem **hasta** hem **belge** görme yetkisi ister; ikisinden biri yoksa ekran açılmaz.

## Süzgeçler
- Tek süzgeç **dönem** (başlangıç – bitiş tarihi). Başvuru tarihi bu aralıkta olan başvurular alınır.
- Şube: aktif şube sunucuda uygulanır; şubesiz başvurular da görünür.
- Şerit ayrıca hastanın adını, maskeli TC'sini (ilk 3 + son 2 hane), yaşını, cinsiyetini, dosya numarasını ve dönemdeki kurumlarını gösterir. Kalan borç varsa sağda **Açık borç var** rozeti çıkar.

## Özet ve sekmeler
- **Toplam Hizmet**: iptal hariç başvuruların genel toplamı; altında başvuru ve kalem sayısı.
- **Kurum Payı** (SGK + özel sigorta), **Hasta Payı** (katılım + fark + ücretli), **İskonto** (satır iskontoları).
- **Tahsil Edilen** (iptal hariç), **İade** (iade makbuzları), **Kalan Borç** (hastadan alınacak), **Avans / Alacak** (başvuruya bağlanmamış, mahsup edilmemiş avans).
- **Başvurular**: Tarih, Protokol No, Bölüm / Hekim, Kurum, Toplam, İskonto, Kurum Payı, Hasta Payı, Tahsil, Kalan, Durum (Açık / Kısmi / Kapandı / İptal); altta iptal hariç toplam satırı.
- **Hizmetler**: Tarih, Protokol No, Kod (SUT kodu öncelikli), Hizmet, Adet, Birim Fiyat, Tutar, Kurum, Hasta.
- **Tahsilatlar**: Makbuz No, Tarih, Banko, Ödeme rozeti (nakit / POS / havale / iade / iptal), İşlem, Protokol No, Tutar (iade eksi gösterilir).
- **Kurum Provizyonları**: Protokol No, Provizyon / Takip No, SGK, Özel Sigorta, Satır, Durum.
- **Hareket Özeti**: Tarih, Belge, Açıklama, Borç, Alacak, Bakiye.

## Rakamlar nereden gelir
Bütün rakamlar sunucuda hesaplanır (`GET /api/hasta-icmal/{hastaId}?bas=&bit=`); ekran yalnız çizer. Kurallar banko açık borç sorgusuyla aynıdır:
- Başvuru = belge tipi 30, tür 19 (hasta / kurum tahakkuk belgeleri çift sayılmasın diye alınmaz).
- Toplam = başvurunun `genel_toplam`'ı; kurum payı = satır dağılımındaki SGK + özel sigorta (toplamı aşamaz); hasta payı = toplam − kurum.
- İskonto = satırlarda (adet × birim fiyat − tutar) farkı.
- Tahsil = başvuruya bağlı kasa işlemlerinin neti (iade düşülür, iptal makbuz sayılmaz); kalan = hasta payı − tahsil. Özetteki kalan borç yalnız pozitif kalanların toplamıdır.
- İptal başvuru (durum 6) listede soluk görünür, toplamlara girmez.
- Avans = avans olarak alınan tahsilat − avanstan yapılan mahsup; dönemden bağımsız hastanın tamamı için hesaplanır.

## Çıktı
**Hasta İcmali** düğmesi açılır menüdür: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. A4 belge "HASTA HESAP İCMALİ" başlığıyla kurum anteti, düzenleyen kullanıcı ve "Hasta / Yakını" ile "Vezne Yetkilisi" imza alanlarını taşır. PDF, yazdırma penceresinde "PDF olarak kaydet" seçilerek alınır. Veri yüklenmeden menü kapalıdır.

## Dikkat edilecekler
- Hastaya söylenecek rakam **Kalan Borç**'tur; kurum payı bilgi amaçlıdır, hastadan istenmez (Hareket Özeti'nde borç yazılmaz).
- Avans kalan borçtan **kendiliğinden düşmez**; mahsup ayrı bir kasa işlemidir.
- Dönem başvuru tarihine göredir: dönem dışındaki başvuruya sonradan yapılan tahsilat bu icmalde görünmez, dönemi genişletin.
- Fazla tahsilat başvuru satırında eksi kalan olarak görünür ama özetteki Kalan Borç'u azaltmaz.
- TC numarası ekranda ve çıktıda maskelidir.

## Örnek sorular
- Bu hastanın kalan borcu ne kadar?
- Kurum payı neden kalan borca eklenmiyor?
- Hastanın avansı borcundan neden düşmedi?
- Hangi başvurunun provizyonu alınmamış?
- Geçen yılki başvuruları da nasıl görürüm?
- Hasta icmalini PDF olarak nasıl gönderirim?
