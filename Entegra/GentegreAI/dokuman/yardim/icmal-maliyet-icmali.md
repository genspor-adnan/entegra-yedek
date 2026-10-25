---
id: icmal-maliyet-icmali
baslik: Hasta Başı Maliyet İcmali
modul: finans
ekran: maliyet-icmali
rota: /maliyet-icmali
surec: icmal
roller: yonetim, muhasebe, finans
dil: tr
surum: 1
urun_modu: 2
yetki: maliyet.hasta_basi
erisim: kullanici
ozet: Seçilen dönemde başvuru başına ciroyu düşülen sarf ve ilaç maliyetiyle karşılaştırır; brüt kâr, marj, zarar eden başvurular, hizmet ve bölüm kârlılığı ile faturaya girmemiş sarfı gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Hasta Başı Maliyet İcmali "bir hasta bize ne kadar kazandırıyor, hangi başvuru / hizmet / bölüm zarar ediyor, düşülen malzeme faturaya girdi mi?" sorusunu cevaplar. Yönetim ve finans kârlılık analizi için, sarf sorumluları kaçak gelir kontrolü için kullanır. Ekran salt okunurdur; sarf düşümü ve fiyat düzeltmesi ilgili modüllerde yapılır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Bölüme göre süzme** — 🏥 Bölüm listesinden tek bölüm seçin ya da Tümü.
- **Sekmeler arasında geçiş** — Başvurular, Hizmetler, Faturalanmamış Sarf, Bölümler.
- **Düşülen kalemleri açma** — Başvurular sekmesinde maliyeti olan satırın ▸ okuna tıklayın; o başvuruda düşülen sarf / ilaç kalemleri açılır.
- **A4 için başvuru seçme** — satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; çıktı seçili başvuruları listeler.
- **Hasta icmaline geçme** — hasta adına tıklayın; Hasta İcmali açılır, ↩ Geri Dön ile aynı süzgeçlere dönersiniz.
- **Kaçak gelir kontrolü** — Faturalanmamış Sarf sekmesi, düşülmüş ama başvuruya fatura satırı olarak girmemiş kalemleri listeler.
- **Doktor Performans'a geçme** — sağ üstteki **🩺 Doktor Performans** düğmesi.
- **Çıktı alma** — "Hasta Başı Maliyet İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Finans › Hasta Başı Maliyet** (yalnız HBYS).
- Dönem ve bölüm adres çubuğunda tutulur.
- Yetki kodu `maliyet.hasta_basi`; haklarını `kasa.finans` yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: başvuru tarihine göre.
- **Bölüm**: başvurunun bölümü. Şube süzgeci sunucuda uygulanır. Süzgeç değişince A4 seçimi sıfırlanır.
- Şeritte uyarılar: dönemde hiç sarf / ilaç düşümü yoksa sarı "marj ciroya eşit görünür" rozeti; zarar eden başvuru varsa kırmızı sayı ve tutar rozeti.

## Özet ve sekmeler
- Kutular: **Başvuru** (maliyetli olan sayısı), **Ciro** (başvuru genel toplamı), **Sarf Maliyeti**, **İlaç Maliyeti**, **Brüt Kâr** (marjıyla), **Hasta Başı Maliyet** (maliyet / başvuru), **Zarar Eden** (sayı ve tutar), **Faturalanmamış Sarf** (kalem ve maliyet).
- **Başvurular**: Tarih, Protokol No, Hasta, Bölüm / Doktor, Ciro, Sarf, İlaç, Kâr, Marj.
- **Hizmetler**: Hizmet, Adet, Ciro, Ort. Fiyat, Dağıtılan Maliyet, Ort. Maliyet, Standart Sarf, Marj.
- **Faturalanmamış Sarf**: Tarih, Protokol No, Hasta, Bölüm, Kalem, Miktar, Maliyet, Kaynak.
- **Bölümler**: Bölüm, Başvuru, Ciro, Sarf, İlaç, Kâr, Hasta Başı Maliyet, Marj.

## Rakamlar nereden gelir
Veri `/api/maliyet-icmal` ucundan (`MaliyetIcmalUclari`) gelir; uç yalnız okur.
- Küme: gerçek başvurular (tür 19), iptal hariç. Ciro = başvurunun genel toplamı.
- Maliyet iki kaynaktan: **düşülen sarf** (radyoloji istem sarfı, diş seans sarfı, ameliyat sarfı — gerçek tüketim) ve **faturalı stok** (başvurudaki stok satırı, aynı stok için sarf kaydı yoksa). Aynı başvuruda aynı stok iki kez sayılmaz, sarf kaydı önceliklidir.
- Birim maliyet: giriş belgelerinden ağırlıklı ortalama, yoksa alış fiyatı. İlaç kataloğuna bağlı stok **İlaç**, diğerleri **Sarf** sayılır.
- Brüt kâr = ciro − (sarf + ilaç); marj = kâr / ciro.
- Hizmet kârlılığı: başvurunun maliyeti hizmet satırlarına tutar oranında dağıtılır; hizmetin standart sarf seti varsa birim maliyeti ayrıca gösterilir.
- Faturalanmamış sarf: düşülmüş ama başvuruda aynı stok satırı olmayan kalem.

## Çıktı
**Hasta Başı Maliyet İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Başvuru seçiliyken araç çubuğunda "A4 seçili N başvuruyu listeler" notu çıkar. Dosya adı dönemi taşır.

## Dikkat edilecekler
- Sarf yalnız radyoloji, diş ve ameliyat modüllerinde düşülür; poliklinikte malzeme düşülmüyorsa marj ciroya eşit görünür, bu gerçek kâr değildir.
- Faturalanmamış sarf **kaçak gelir adayıdır**, kesin hata değildir: her sarf faturalanmaz (ör. kontrast hizmet fiyatına dahilse).
- Maliyet bugünkü ağırlıklı ortalamadan hesaplanır; alış fiyatı değiştikçe eski dönemlerin kârı da değişebilir.
- Ciro KDV dahil genel toplamdır.

## Örnek sorular
- Hasta başı maliyetimiz ne kadar?
- Hangi başvurular zarar ediyor?
- Marj neden yüzde yüz görünüyor?
- Faturaya girmemiş sarf var mı?
- En kârlı bölüm hangisi?
- Bir hizmetin standart sarf maliyeti nereden geliyor?
