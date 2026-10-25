---
id: icmal-iskonto-icmali
baslik: İskonto İcmali
modul: kayit_kabul
ekran: iskonto-icmali
rota: /iskonto-icmali
surec: icmal
roller: yonetim, muhasebe, kayit_kabul_sorumlusu
dil: tr
surum: 1
urun_modu: 2
yetki: iskonto.icmal
erisim: kullanici
ozet: Seçilen dönemde verilen bütün iskontoları (onaylı talep, kampanya, bankonun talepsiz verdiği), ücretsiz hizmetleri ve reddedilen talepleri; onaylayana, verene ve gerekçeye göre gösteren dönem sonu denetim raporu.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
İskonto İcmali "bu ay ne kadar iskonto verildi, kim verdi, kim onayladı, onay akışı atlandı mı?" sorusunu cevaplar. Yönetim ve muhasebe dönem sonu denetiminde kullanır. **İskonto Onayı** ekranından ayrıdır: orası talep kuyruğu ve karar yeridir, bu ekran yalnız rapordur; iskonto verme, onaylama ya da geri alma buradan yapılmaz.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Kaynağa göre süzme** — 🏷 Kaynak: Tümü / Onaylı talep / Kampanya / Banko (talepsiz).
- **Sekmeler arasında geçiş** — İskontolar, Onaylayana Göre, Verene Göre, Gerekçeye Göre, Ücretsiz Hizmetler, Reddedilen Talepler.
- **Başvurunun kalemlerini açma** — İskontolar sekmesinde tarihin önündeki ▸ okuna tıklayın; hizmet, liste fiyatı, iskonto ve kaynak satır satır açılır.
- **A4 için başvuru seçme** — satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; çıktı yalnız seçili başvuruları basar.
- **Hasta icmaline geçme** — hasta adına tıklayın; Hasta İcmali açılır, ↩ Geri Dön ile aynı süzgeçlere dönersiniz.
- **Eşik üstü uyarıları görme** — şeritteki kırmızı "⚠ N başvuruda eşik üstü talepsiz iskonto" rozeti ve satırda ⚠ işaretli oran.
- **Başka ekrana geçme** — **✅ İskonto Onayı** (talep kuyruğu) ve **🩺 Doktor Performans** düğmeleri.
- **Çıktı alma** — "İskonto İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Kayıt Kabul › İskonto İcmali** (yalnız HBYS).
- Dönem ve kaynak adres çubuğunda tutulur.
- Yetki kodu `iskonto.icmal`; haklarını İskonto Onayı (`iskonto_onay`) yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: başvuru tarihine göre.
- **Kaynak**: satırın iskontosunun nereden geldiği — onaylı iskonto talebi, kampanya satırı ya da ikisi de değilse banko (talepsiz).
- Şube süzgeci sunucuda uygulanır. Süzgeç değişince A4 seçimi sıfırlanır.
- Şeridin sağında **onay eşiği** (Kayıt Kabul ayarı, varsayılan %10) yazar.

## Özet ve sekmeler
- Kutular: **İskontolu Başvuru** (reddedilen talep sayısıyla), **Toplam İskonto** (ortalama oran), **Onaylı Talep**, **Banko (Talepsiz)** (eşik üstü sayısı), **Kampanya**, **Ücretsiz Hizmet** (kalem, liste fiyatı), **Personel / Yakın** (gerekçesi personel olan), **Ciroya Oranı** ((iskonto + ücretsiz) / ciro).
- **İskontolar**: Tarih, Protokol No, Hasta, Bölüm / Doktor, Veren / İsteyen, Onaylayan, Liste, Oran, İskonto, Gerekçe, Kaynak (talep / kampanya / banko / karma).
- **Onaylayana / Verene / Gerekçeye Göre**: grup başına Başvuru, Kalem, Liste, İskonto, Ort. Oran, Pay.
- **Ücretsiz Hizmetler**: Tarih, Protokol No, Hasta, Bölüm / Doktor, Hizmet, Liste Fiyatı, Kaynak, Gerekçe, Onaylayan.
- **Reddedilen Talepler**: Tarih, Protokol No, İsteyen, Reddeden, İstenen Oran, İstenen Tutar, Gerekçe, Karar Notu.

## Rakamlar nereden gelir
Veri `GET /api/iskonto-icmal?bas=&bit=&kaynak=` ucundan gelir; uç yalnız okur.
- Küme: gerçek başvurular (tür 19), iptal hariç.
- İskonto = satırın (adet × birim fiyat − tutar), satır satır yuvarlanır — Doktor Performans İcmali ile aynı formül, iki ekran aynı dönem için aynı rakamı verir.
- Ücretsiz hizmet = liste tutarı olan ama tutarı sıfırlanan satır; iskonto toplamına değil Ücretsiz Hizmet kutusuna girer.
- Eşik üstü = talepsiz (banko) satırın iskonto oranı onay eşiğini aşıyor; onay akışı atlanmış olabilir.
- Verene göre: talepte isteyen, talepsizde başvuruyu açan banko görevlisi. Gerekçe kategorisi gerekçe metninin "—" öncesidir.
- Reddedilen talepler toplamlara girmez, ayrı sayılır. Ciro = dönemin başvuru genel toplamı.

## Çıktı
**İskonto İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Başvuru seçiliyken araç çubuğunda "A4 yalnız seçili N başvuruyu basar" notu çıkar. Dosya adı dönemi taşır.

## Dikkat edilecekler
- Bu ekran yalnız **verilmiş** iskontoyu gösterir; bekleyen talepler İskonto Onayı ekranındadır.
- Eşik üstü işareti suç değil uyarıdır: eşik sonradan değiştiyse eski başvurular da işaretlenebilir.
- Bir başvuruda farklı kaynaklı satırlar varsa kaynak "karma" görünür; kalemleri açarak ayrıntıya bakın.
- Ücretsiz hizmet iskonto oranına girmez ama ciroya oranına girer.

## Örnek sorular
- Geçen ay toplam ne kadar iskonto verildi?
- Onay almadan eşik üstü iskonto veren var mı?
- Hangi personel en çok iskonto onayladı?
- Ücretsiz verilen hizmetler hangileri?
- Reddedilen iskonto taleplerini nerede görürüm?
- İskonto icmalini yalnız seçtiğim başvurularla nasıl yazdırırım?
