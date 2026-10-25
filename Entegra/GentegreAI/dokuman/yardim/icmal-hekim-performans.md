---
id: icmal-hekim-performans
baslik: Doktor Performans İcmali
modul: ik_prim
ekran: hekim-performans
rota: /hekim-performans
surec: icmal
roller: yonetim, ik, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: prim.hekim_performans
erisim: kullanici
ozet: Seçilen dönemde doktor ve bölüm başına başvuru, hizmet, ciro, kurum / hasta payı, iskonto, tahsil ve hakedişi önceki döneme göre değişimle birlikte gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Doktor Performans İcmali "hangi doktor / bölüm bu ay ne kadar ciro yaptı, geçen döneme göre ne değişti, ne kadar hakediş aldı?" sorusunu cevaplar. Yönetim ve İK prim / hakediş kararlarında, bölüm sorumluları kendi bölümünün gidişatını izlemek için kullanır. Ekran salt okunurdur; hakediş hesaplama ve onayı **Hakedişler** ekranındadır. (Kod ve adresler "hekim-performans" adını taşır, ekran adı "Doktor Performans İcmali"dir.)

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Bölüme göre süzme** — 🏥 Bölüm listesinden tek bölüm seçin ya da Tümü.
- **Ödeyene göre süzme** — 🏢 Ödeyen: Tümü / Ücretli / SGK / ÖSS / Kurumu öder.
- **Doktor seçme** — Doktorlar sekmesinde satıra tıklayın (yalnız o doktor), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; özet kutuları, Hizmet Grupları, Aylık Trend ve A4 seçili doktorlara süzülür. "temizle" seçimi kaldırır.
- **Sekmeler arasında geçiş** — Doktorlar, Bölümler, Hizmet Grupları, Aylık Trend.
- **Değişimi okuma** — Değişim rozetinin üzerine gelince önceki dönem cirosu görünür; ▲ yeşil %5 ve üstü artış, ▼ kırmızı %5 ve üstü düşüş.
- **Hakedişlere geçme** — sağ üstteki **💼 Hakedişler** düğmesi hakediş listesini açar.
- **Çıktı alma** — "Doktor Performans İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **İK › Doktor Performans İcmali** (yalnız HBYS).
- Dönem, bölüm, ödeyen ve seçili doktorlar adres çubuğunda tutulur; bağlantı paylaşıldığında aynı görünüm açılır.
- Yetki kodu `prim.hekim_performans`; haklarını Hakedişler (`prim`) yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: başvuru tarihine göre. Dönem, bölüm ya da ödeyen değişince doktor seçimi sıfırlanır.
- **Karşılaştırma dönemi** şeridin sağında yazar: tam takvim ayı seçildiyse önceki ay(lar), değilse aynı uzunlukta hemen önceki aralık.
- **Bölüm** ve **Ödeyen** (başvurunun ödeyen kurum türü) sunucuda uygulanır; şube süzgeci de sunucudadır.

## Özet ve sekmeler
- Kutular: **Başvuru** (doktor sayısı ve doktorsuz başvuru), **Hizmet** (kalem), **Ciro** (önceki döneme göre değişim), **Kurum Payı** (oranıyla), **Hasta Payı** (tahsil edilenle), **İskonto** (ciroya oranı), **Hakediş** (dönem hakediş satırları), **Ort. Başvuru** (ciro / başvuru).
- **Doktorlar**: Doktor, Bölüm, Başvuru, Hizmet, Ciro, Kurum %, Hasta Payı, İskonto, Tahsil, Hakediş, Değişim; "Doktoru girilmemiş başvuru" satırı ve toplam satırı.
- **Bölümler**: Bölüm, doktor sayısı ve aynı değer kolonları.
- **Hizmet Grupları**: Hizmet Grubu, Kalem, Tutar, Kurum Payı, İskonto, Pay; altta KDV hariç satır tutarı toplamı.
- **Aylık Trend**: son 6 ayın ciro sütunları (koyu kısım kurum payı) ve başvuru sayısı.

## Rakamlar nereden gelir
Veri `GET /api/hekim-performans?bas=&bit=&kurumTuru=&bolum=&hekimler=` ucundan gelir; uç yalnız okur.
- Küme: gerçek başvurular (belge tipi 30, tür 19), iptal (durum 6) hariç — Hasta ve Kurum İcmali ile aynı.
- Doktor = başvurudaki personel; doktorun bölümü dönemde en çok başvuru aldığı bölümdür.
- Ciro = başvurunun genel toplamı; kurum payı = SGK + ÖSS dağılımı (ciroyu aşamaz); hasta payı = ciro − kurum payı.
- İskonto = satır satır (adet × birim fiyat − tutar), İskonto İcmali ile aynı rakam; tahsil = başvuruya bağlı net kasa işlemi.
- Hakediş = dönem tarihli hakediş satırları (iptal edilenler hariç), doktor başına.
- Doktor ve bölüm tabloları her zaman tam listedir; doktor seçimi yalnız özeti, grupları, trendi ve A4'ü süzer.

## Çıktı
**Doktor Performans İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Doktor seçiliyken araç çubuğunda "Seçili N doktor: özet, gruplar, trend ve A4 süzülü" notu çıkar; A4 seçime göre basılır. Dosya adı dönemi taşır.

## Dikkat edilecekler
- Doktoru girilmemiş başvurular doktor satırlarına dağılmaz, ayrı satırda gösterilir ama toplama dahildir.
- Hakediş, Hakedişler ekranında hesaplanmış satırlardan gelir; hakediş hesaplanmamış dönemde sıfır görünür.
- Önceki dönemde cirosu olmayan doktorda değişim "yeni" yazar.
- Hizmet grupları KDV hariç satır tutarıdır; Ciro kutusu belge genel toplamıdır, ikisi birebir tutmayabilir.

## Örnek sorular
- Geçen ay en çok ciro yapan doktor kim?
- Kardiyoloji bölümünün cirosu önceki aya göre ne kadar değişti?
- Yalnız SGK hastalarına göre performansı nasıl görürüm?
- Değişim yüzdesi hangi dönemle karşılaştırılıyor?
- Hakediş neden sıfır görünüyor?
- İki doktoru birlikte nasıl karşılaştırırım?
