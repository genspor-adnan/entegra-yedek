---
id: radyoloji-rapor-yazma-onay
baslik: Radyoloji raporu yazma, uzmana gönderme, onay ve ek rapor
modul: radyoloji
ekran: radyoloji-rapor
rota: /radyoloji/rapor
surec: radyoloji
roller: radyolog
dil: tr
surum: 2
urun_modu: 2
yetki: radyoloji
erisim: kullanici
ozet: Radyoloğun rapor ekranı - şablon ve makrolar, yapılandırılmış alanlar, önceki tetkikler, taslak kaydetme, Uzmana Gönder, Onayla ve İmzala, kritik bulgu bildirimi, konsültasyon, ek rapor (addendum) ve çıktı.
guncelleme: 2026-11-14
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Çekimi tamamlanan istem radyoloğun önüne **Raporlanacak** olarak gelir. Rapor ekranı **boş** açılır (şablon kendiliğinden uygulanmaz); radyolog **📄 Şablon Seç…** ile şablonu seçer ya da serbest yazar, makrolarla hızlanır, taslak kaydeder ve onaylar. Onaylanan rapor kilitlenir, numara alır, hekimin ekranına ve e-Nabız kuyruğuna gider; sonradan düzeltme yalnız **ek rapor** ile yapılır.

## Ekrana giriş yolları
- **Radyoloji › Çalışma Listesi**, çip **Raporlanacak** → satırı seçip **✎ Rapor Yaz**.
- **Kritik Bulgular**, **Konsültasyonlar**, **Sonuç Teslim** listelerinde **📄 Raporu Aç**.

## Ön koşullar
- **radyoloji** Gör ve `rad.rapor_yaz` aksiyon yetkisi; onay için ayrıca `rad.rapor_onayla`.
- Şablonlar **Radyoloji › Ayarlar › Rapor Şablonları**'nda tanımlanır; tetkike bağlı olanlar seçim penceresinde en üstte "Bu tetkike bağlı" grubunda gelir.

## Ekranın bölümleri
- Üst bilgi: Hasta, Tetkik, Çekim, Durum (onaylıysa **🔒 Kilitli**); **Önceki Tetkikler** (hastanın eski raporları); **İstem Bilgisi** (ön tanı, klinik bilgi, isteyen, ödeyen); Seri / Görüntü (PACS eşleşmesi).
- **Şablon** satırı (sağ panel): seçili şablonun adı · kodu · sürümü ve **📄 Şablon Seç… / Değiştir…** düğmesi; rapor bölümleri (ör. Teknik, Bulgular, Sonuç ve Öneriler). "Klinik" başlıklı bölüm istemdeki klinik bilgiyle dolar.
- **Makrolar**: tıklanınca metin hedef bölüme (yoksa son yazdığınız bölüme) eklenir.
- **Yapılandırılmış Alanlar**: şablonun skor / ölçüm alanları.
- Kurumda Bakanlık profili açıksa **Radyolog Değerlendirmesi** (İstem Nedeni, Çekim Kalitesi puanı; onay için ikisi de zorunlu).
- **Kritik Bulgu Bildirimleri** ve **Konsültasyon** kutuları.

## Düğmeler
**💾 Taslak Kaydet** · **➜ Uzmana Gönder** · **✍ Onayla ve İmzala** · **⚠ Kritik Bulgu Bildir** · **＋ Ek Rapor** (yalnız onaylı raporda) · **🖨 Çıktı** · **Kapat**.

## Adım adım
1. Listeden **✎ Rapor Yaz**; rapor boş açılır. **📄 Şablon Seç…** ile şablonu seçip **Uygula** deyin (ya da **Serbest yaz**). Dolu rapora başka şablon uygularsanız yazılmış metnin değişeceği sorulur.
2. **Önceki Tetkikler**'e bakın; karşılaştırma gerekiyorsa ilgili bölüme yazın.
3. Bölümleri doldurun, makroları kullanın; yapılandırılmış alanları girin.
4. **💾 Taslak Kaydet** ("Rapor taslağı kaydedildi."). İstem **Raporlanıyor** olur.
5. Raporu bir uzmanın onaylaması gerekiyorsa **➜ Uzmana Gönder** → "Ön rapor uzman onayına gönderildi." İstem **Onay Bekleyen** olur.
6. Onay yetkiniz varsa **✍ Onayla ve İmzala** → "Rapor onaylandı ve imzalandı; artık kilitlidir." Rapor numarası bu anda verilir, istem **Onaylandı** olur.
7. **🖨 Çıktı** ile hastaya verilecek raporu açın; tarayıcıdan yazdırın ya da PDF kaydedin. Onaysız raporun çıktısında "taslak" uyarısı vardır.

## Kritik bulgu
1. Raporda **⚠ Kritik Bulgu Bildir** → Bulgu, Bildirilen kişi, Yol (telefon vb.) ve geri bildirimi yazıp **Kaydet**.
2. Kritik işaretli tetkikte **bildirim kaydı olmadan rapor onaylanmaz**.
3. Karşı taraf teyit edince **Radyoloji › Kritik Bulgular**'da satırı seçip **✔ Kapat (teyit alındı)**. Çipler: Bildirilmedi · Teyit Bekleyen · Teyitli · Kapatılan.

## Konsültasyon ve ek rapor
- İkinci görüş için Konsültasyon kutusundan gerekçeyle istek gönderin; gelen görüş **Konsültasyonlar** listesinde **✎ Cevabı Yaz** ile yazılır. Görüş raporu değiştirmez.
- Onaylı raporda hata / ek bilgi varsa **＋ Ek Rapor**: "Ek rapor (addendum) açıldı; orijinal rapor değişmeden kalır."

## Teleradyoloji
Dışarıdan raporlanan işler **Teleradyoloji › Çalışma Listesi**'ndedir (Pano, Gelen Raporlar, Teslim Kuyruğu, Nöbet, Atama Kuralları, Kurumlar, Sözleşmeler). Rapor yazma ekranı aynıdır; atama ve teslim teleradyoloji yetkilerine bağlıdır.

## Durumlar
İstem: Bekleyen Çekim (1) → Raporlanacak (2) → Raporlanıyor (3) → Onay Bekleyen (4) → Onaylandı (5).
Rapor: Taslak · Uzman onayında · Onaylı · Ek rapor.

## Sık karşılaşılan sorunlar
- **"Zorunlu bölümler boş: rapor onaya gönderilemez."** → şablonda zorunlu işaretli bölümleri doldurun.
- **"Kritik bulgu bildirimi kaydedilmeden rapor onaylanamaz."** → önce **⚠ Kritik Bulgu Bildir**.
- **"Bakanlık profili: "Bulgular" en az 50 karakter olmalı …" / ""Sonuç ve Öneriler" bölümü boş …"** → Bakanlık profili açık kurumda bu iki bölüm zorunludur.
- **"Radyolog Değerlendirmesi eksik: İstem Nedeni ve Çekim Kalitesi puanlarını verin."** → sağ paneldeki iki puanı seçip yeniden onaylayın.
- **"Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın."** → **＋ Ek Rapor** kullanın.
- **"Bu istemde bildirim kaydı yok - önce kritik bulgu bildirimini kaydedin."** → kritik takibi kapatmadan önce bildirim girin.
- **Onayla düğmesi yetki hatası veriyor** → rolünüzde `rad.rapor_onayla` yok; **➜ Uzmana Gönder** kullanın.

## Yapılmaması gerekenler
- Onaylı raporu düzeltmek için yeni rapor yazmayın; ek rapor kullanın.
- Kritik bulguyu işaretleyip haber vermeden bırakmayın.
- "Yazdırılmaz" işaretli bölümlere hastanın görmesi gereken bilgi yazmayın; bu bölümler çıktıya ve e-Nabız'a gitmez.

## Ekran kılavuzu

### Şablon seçimi
Rapor **boş** açılır; şablon kendiliğinden uygulanmaz. Ortadaki ya da sağ paneldeki **📄 Şablon Seç…** pencereyi açar: arama (ad / kod), kapsam çipleri (**Bu tetkike bağlı · Benim şablonlarım · Genel · Hepsi**), biçim çipleri (**Tek · Parçalı · Yapısal**), sağda önizleme. **Uygula** şablonu rapora yazar; **Boş rapor** şablonsuz serbest yazıma döner.
- ★ yıldız: kişisel favori - listede öne gelir.
- **Bu tetkik için varsayılanım yap**: bir sonraki raporda aynı şablon "önerilen" rozetiyle en üstte gelir; yine de otomatik uygulanmaz.
- Dolu rapora yeni şablon uygulanırken onay sorulur: bölüm metinleri şablonun varsayılanıyla değişir.

### Makrolar
Seçili şablonun hazır metin parçalarıdır (ör. `.nl` normal bulgular). Tıklanınca metin hedef bölüme, hedefi yoksa son yazdığınız bölüme eklenir. Şablon seçilmeden makro gelmez; makrolar şablon kartında tanımlanır.

### Yapılandırılmış Alanlar
Serbest metnin yanında şablona bağlı, **kodlanmış** bulgu alanlarıdır; bulgu sorgulanabilir ve sayılabilir olur (ör. "bu ay kaç DVT pozitif"), kritik bulgu ve zorunluluk kuralı işletilebilir, Bakanlık / kalite göstergeleri üretilebilir.
- **Seçimli**: Menisküs yırtığı = Yok / Medial / Lateral / Her ikisi.
- **Sayısal**: Orta hat kayması (mm) - metne "Orta hatta {değer} mm kayma izlendi." kalıbıyla yazılır.
- **Skor**: Fazekas 0-3. **Evet/Hayır**: Difüzyon kısıtlaması, Reflü.
- Yıldızlı alan zorunludur: doldurulmadan rapor onaylanamaz.
- **Metne ekle**: girilen değerleri kalıplarıyla cümleye çevirip ilgili bölüme (Bulgular / Sonuç) yazar.
Alanlar şablon kartında tanımlanır; şablon seçilmeden görünmez. BI-RADS / TI-RADS gibi tam formlar bunun büyük hâlidir (**Giriş: Yapısal**).

### Radyolog Değerlendirmesi
Yalnız kurum ayarı **Bakanlık profili** açıkken görünür. Sağlık Bakanlığı Teletıp rapor teslimi (HL7 ORU, OBX-13) için raporu yazan radyoloğun verdiği iki puandır (1-5); **ikisi de verilmeden rapor onaylanamaz**:
- **İstem Nedeni**: isteyen hekimin klinik bilgisi / ön tanısı raporu yazmaya ne kadar yetti (Yok · Yetersiz · Orta · İyi · Mükemmel). Bakanlık istem kalitesini bununla izler.
- **Çekim Kalitesi**: görüntülerin değerlendirilebilirliği (Çok kötü · Kötü · Orta · İyi · Çok iyi). Cihaz / teknisyen kalite göstergesidir.
Aynı profil onayda ek kural işletir: rapor dört Bakanlık parçasıyla (Teknik, Karşılaştırma, Bulgular, Sonuç ve Öneriler) **parçalı** yazılmalı, Bulgular en az 50 karakter, Sonuç ve Öneriler dolu olmalı. Puanlar onaylanan raporla Teletıp kuyruğuna gider.

### Rapor biçimi ve giriş
- **Tek / Parçalı**: tek A4 metin ya da başlıklı bölümler. Parçalıdan teke geçişte bölümler birleşir; tekten parçalıya geçişte metin Bulgular bölümüne taşınır.
- **Serbest / Yapısal**: yapısal formu (BI-RADS, TI-RADS…) olan şablonda form görünümü; form değerlerinden metin üretilir.

### Kritik Bulgu
Hastayı bekletmeyecek bulgu varsa **⚠ Kritik Bulgu Bildir**: bulgu, haber verilen kişi, yol (telefon vb.) ve geri bildirim kaydedilir. Kritik işaretli tetkikte **bildirim kaydı olmadan rapor onaylanmaz**; teyit gelince **Radyoloji › Kritik Bulgular**'da kapatılır.

### Onay ve e-İmza
**💾 Taslak Kaydet** raporu saklar; **➜ Uzmana Gönder** onay yetkilisine iletir; **✍ Onayla ve İmzala** raporu kilitler ve numara verir. Kurumda e-İmza (EIMZA hesabı) açıksa onay yalnız e-imzayla olur: kart doktorun bilgisayarında ya da sunucuda, imzalı belge **🔏 İmzalı Belge** ile indirilir. Onaylı raporda düzeltme yalnız **＋ Ek Rapor** ile yapılır.

## Örnek sorular
- Yapılandırılmış alanlar nedir?
- Radyolog Değerlendirmesi ne işe yarar?
- Radyoloji raporu nasıl yazılır?
- Rapor şablonu nasıl seçilir?
- Makro nasıl kullanılır?
- Raporu nasıl onaylarım?
- Uzmana gönder ne demek?
- Onaylı raporu nasıl düzeltirim?
- Kritik bulgu bildirimi nasıl yapılır?
- Rapor çıktısını nasıl alırım?

## Kaynaklar
- web/src/sayfalar/RadyolojiRapor.tsx, RadyolojiRaporCikti.tsx
- api/src/Gentegre.Api/Uclar/RadyolojiUclari.Rapor.cs, RadyolojiUclari.OnayVeBulgu.cs
- db/809_bakanlik_rapor_parcalari.sql (fn_radyoloji_rapor_onaylanabilir); dokuman/00_TARIHCE.md (283-336, 797-809, 883)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Kritik bulgu "Yol" seçenek adları ve yapılandırılmış alanların görünümü ekranda doğrulanmadı. İnsan doğrulaması bekliyor.
