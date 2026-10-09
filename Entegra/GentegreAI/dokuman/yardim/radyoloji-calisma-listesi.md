---
id: radyoloji-calisma-listesi
baslik: Radyoloji teknisyeninin çalışma listesi (çekim, kontrol listesi, sarf)
modul: radyoloji
ekran: radyoloji-istem
rota: /radyoloji
surec: radyoloji
roller: rad_teknisyen
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji-istem
erisim: kullanici
ozet: Teknisyenin günlük işi - Çalışma Listesi'nde sıradaki hastayı bulma, istem kartı ve çekim öncesi kontrol listesi, cihaza randevu, Çekildi işaretleme, kontrast / sarf düşme, cihaz kapatma.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Teknisyen günü **Radyoloji › Çalışma Listesi**'nde geçirir: kabulü yapılmış hastalar burada **Bekleyen Çekim** olarak bekler. Teknisyen kontrol listesini doldurur, çekimi yapar, **Çekildi** işaretler ve kullanılan kontrast / malzemeyi stoktan düşer. Çekildi işaretlenen iş radyoloğun **Raporlanacak** listesine geçer.

## Ekrana giriş yolları
- Sol menü **Radyoloji › Çalışma Listesi** (modülün giriş ekranı).
- **Radyoloji › Pano**'daki "Çekim bekleyen" sayacına tıklamak listeyi süzülmüş açar.

## Ön koşullar
- **radyoloji-istem** yetkisi; randevu vermek **randevu** Ekle, sarf düşmek **stok** Değiştir ister (rolünüzde yoksa düğme görünmez).
- İstem buradan **açılmaz**: yalnız kabulden (banko), hekim isteminden ya da dış kurum portalından gelir. Listede "Yeni İstem" düğmesi bu yüzden yoktur.

## Liste ve çipler
Kolonlar: Accession · Hasta · Tetkik · İsteyen Kurum · Ödeyen Kurum · Radyolog · Kritik, saat ve durum kolonları. Liste önceliğe (Çok Acil / Acil önce) ve bekleme süresine göre sıralanır.
Çipler: **Bekleyen Çekim · Raporlanacak · Raporlanıyor · Onay Bekleyen · Onaylandı · Tümü**.

## İşlemler (düğmeler)
- **✎ Aç / Düzenle** (Enter): istem kartı.
- **📅 Randevu Ver**: istemi bir cihaza ve saate bağlar (süre çekim protokolünden gelir).
- **✔ Çekildi İşaretle**: çekim zamanını yazar, durum **Raporlanacak** olur, **Sarf Onayı** penceresi açılır.
- **🧪 Sarf Düş**: atlanan ya da düzeltilecek sarf için.
- **📦 Sonuç Teslim Et**, **✖ İstemi İptal Et**: yetkiye bağlı.

## İstem kartı
Üstte akış şeridi: **İstem → Randevu → Çekim → Raporlanıyor → Onay → Teslim** (zamanlarıyla). Alanlar: Hasta, Tetkik, Öncelik, Accession No; İstem Bilgisi (isteyen hekim / kurum, ön tanı, klinik bilgi, modalite); **Çekim** (Cihaz, Tekniker, Çekim Zamanı, Kontrast, Kontrast ml / yolu / etken madde / konsantrasyon, DLP, CTDIvol, Kritik Bulgu); PACS (Study UID, seri / görüntü sayısı). Sekmeler: **Kontrol Listesi**, **İstem Kâğıdı**.

## Adım adım
1. **Bekleyen Çekim** çipinde sıradaki hastayı seçin; **✎ Aç / Düzenle**.
2. Hastanın kimliğini ve tetkiği kontrol edin; klinik bilgiyi okuyun.
3. **Kontrol Listesi** sekmesinde modaliteye göre gelen soruları (Evet / Hayır / Bilinmiyor) yanıtlayıp **💾 Kontrol Listesini Kaydet**.
4. Cihazda hastayı **Accession No** ile bulun / kaydedin ve çekimi yapın. Kontrastlı çekimde Çekim bölümüne kontrast miktarı, yolu ve dozu (BT'de DLP / CTDIvol) yazın, **Kaydet**.
5. Listeye dönüp **✔ Çekildi İşaretle**.
6. **Sarf Onayı** penceresinde protokolün önerdiği miktarları hastaya göre düzeltin, lot takipli malzemede lotu seçin, **✔ Onayla ve Düş**. Hemen düşmeyecekseniz **↷ Şimdilik Atla** (sonra **🧪 Sarf Düş**).
7. İş **Raporlanacak** çipine geçer; radyolog raporlar.

## Cihaz ve randevu
- **📅 Randevu Ver** penceresi: Tetkik, **Cihaz (zorunlu)**, **Tarih / Saat (zorunlu)**, Süre (dk), Not. Cihaz yalnız tetkiğin modalitesindeki cihazlardır.
- Cihaz arıza / bakımdaysa **Radyoloji › Ayarlar › Cihazlar**'da cihaz kartından kapatma girilir; o aralığa randevu verilemez, takvimde taralı görünür.
- "Cihaz listesine (MWL) gönder" kabulde işaretlenir. Cihaz bağlantısı kurumunuzda kurulmamışsa hasta bilgisi cihaza elle girilir; Accession No'yu aynen kullanın — rapor ve PACS eşleşmesi bu numarayla yapılır.

## Sık karşılaşılan sorunlar
- **"Çekim öncesi kontrol listesi tamamlanmadan "Çekildi" işaretlenemez. Eksik: …"** → Kontrol Listesi sekmesinde eksik soruları yanıtlayın.
- **"Düşülecek malzeme seçilmedi."** → sarf penceresinde en az bir kalem işaretleyin.
- **"… lot takipli ama bu depoda bakiyeli lot yok"** → stok girişi yapılmalı; depo sorumlusuna bildirin.
- **"Bu isteme daha önce sarf düşülmüş"** uyarısı → yeniden onaylarsanız ikinci çıkış fişi oluşur; yalnız eksik malzemeyi işaretleyin.
- **"Sarf düşüldü. KRİTİK SEVİYE: …"** → stok azaldı, satın almaya haber verin.
- **"Bu istemin zaten randevusu var - önce onu taşıyın ya da iptal edin."** / **"Bu cihaz randevusuz (walk-in) çalışıyor."** → randevu gerekmez ya da mevcut randevuyu kullanın.
- **Hasta listede yok** → kabul yapılmamış ya da hekim istemi başvuruda ücretlendirilip kaydedilmemiş; bankoya sorun.
- **Sarf Düş düğmesi yok** → rolünüzde stok değiştirme yetkisi yok.

## Yapılmaması gerekenler
- Çekim yapılmadan **Çekildi** işaretlemeyin; sarf, bekleme süresi istatistiği ve rapor sırası buna bağlıdır.
- Kontrast miktarını protokol varsayılanında bırakmayın; hastaya verilen gerçek miktarı yazın.
- Yanlış hastaya çekim yaptıysanız istemi kendiniz silmeye çalışmayın; sorumluya bildirin.

## Örnek sorular
- Çekildi nasıl işaretlenir?
- Kontrol listesi neden zorunlu?
- Kontrast sarfı nasıl düşülür?
- Sarfı atladım, sonradan nasıl düşerim?
- Cihaza randevu nasıl verilir?
- Cihaz arızalı, randevuları nasıl durdururum?
- Hasta neden çalışma listemde görünmüyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Radyoloji.ts, web/src/sayfalar/liste/radyolojiAksiyonlari.ts
- web/src/sayfalar/RadyolojiIstemKarti.tsx, web/src/bilesenler/radyoloji/{KontrolListesi,SarfOnayModali,RandevuModali,CihazKapatmaModali,IstemAkisi}.tsx
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.Klinik.cs (radyoloji-liste)
- db/312_cekim_kontrolu_is_kurali_kodu.sql, db/320 (sarf); dokuman/00_TARIHCE.md (314-320)

## Doğrulama durumu
Kod incelemesiyle yazıldı. MWL / PACS canlı cihaz bağlantısı kod tarafında henüz yok (cihaz kartında yalnız bağlantı testi var); bu bölüm kurulumla doğrulanmalı. İnsan doğrulaması bekliyor.
