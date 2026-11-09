---
id: radyoloji-rapor-yazma-onay
baslik: Radyoloji raporu yazma, uzmana gönderme, onay ve ek rapor
modul: radyoloji
ekran: radyoloji-istem
rota: /radyoloji
surec: radyoloji
roller: radyolog
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji
erisim: kullanici
ozet: Radyoloğun rapor ekranı - şablon ve makrolar, yapılandırılmış alanlar, önceki tetkikler, taslak kaydetme, Uzmana Gönder, Onayla ve İmzala, kritik bulgu bildirimi, konsültasyon, ek rapor (addendum) ve çıktı.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Çekimi tamamlanan istem radyoloğun önüne **Raporlanacak** olarak gelir. Rapor ekranında şablon kendiliğinden yüklenir; radyolog bölümleri doldurur, makrolarla hızlanır, taslak kaydeder ve onaylar. Onaylanan rapor kilitlenir, numara alır, hekimin ekranına ve e-Nabız kuyruğuna gider; sonradan düzeltme yalnız **ek rapor** ile yapılır.

## Ekrana giriş yolları
- **Radyoloji › Çalışma Listesi**, çip **Raporlanacak** → satırı seçip **✎ Rapor Yaz**.
- **Kritik Bulgular**, **Konsültasyonlar**, **Sonuç Teslim** listelerinde **📄 Raporu Aç**.

## Ön koşullar
- **radyoloji** Gör ve `rad.rapor_yaz` aksiyon yetkisi; onay için ayrıca `rad.rapor_onayla`.
- Tetkiğe bağlı rapor şablonu varsa varsayılan olarak gelir (**Radyoloji › Ayarlar › Rapor Şablonları**).

## Ekranın bölümleri
- Üst bilgi: Hasta, Tetkik, Çekim, Durum (onaylıysa **🔒 Kilitli**); **Önceki Tetkikler** (hastanın eski raporları); **İstem Bilgisi** (ön tanı, klinik bilgi, isteyen, ödeyen); Seri / Görüntü (PACS eşleşmesi).
- **Şablon** seçimi ve rapor bölümleri (ör. Teknik, Bulgular, Sonuç ve Öneriler). "Klinik" başlıklı bölüm istemdeki klinik bilgiyle dolar.
- **Makrolar**: tıklanınca metin hedef bölüme (yoksa son yazdığınız bölüme) eklenir.
- **Yapılandırılmış Alanlar**: şablonun skor / ölçüm alanları.
- Kurumda Bakanlık profili açıksa **Bakanlık Değerlendirmesi** (İstem Nedeni, Çekim Kalitesi puanı).
- **Kritik Bulgu Bildirimleri** ve **Konsültasyon** kutuları.

## Düğmeler
**💾 Taslak Kaydet** · **➜ Uzmana Gönder** · **✍ Onayla ve İmzala** · **⚠ Kritik Bulgu Bildir** · **＋ Ek Rapor** (yalnız onaylı raporda) · **🖨 Çıktı** · **Kapat**.

## Adım adım
1. Listeden **✎ Rapor Yaz**; şablon gelir. Farklı şablon seçerseniz yazılmış metnin silineceği sorulur.
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
- **"Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın."** → **＋ Ek Rapor** kullanın.
- **"Bu istemde bildirim kaydı yok - önce kritik bulgu bildirimini kaydedin."** → kritik takibi kapatmadan önce bildirim girin.
- **Onayla düğmesi yetki hatası veriyor** → rolünüzde `rad.rapor_onayla` yok; **➜ Uzmana Gönder** kullanın.

## Yapılmaması gerekenler
- Onaylı raporu düzeltmek için yeni rapor yazmayın; ek rapor kullanın.
- Kritik bulguyu işaretleyip haber vermeden bırakmayın.
- "Yazdırılmaz" işaretli bölümlere hastanın görmesi gereken bilgi yazmayın; bu bölümler çıktıya ve e-Nabız'a gitmez.

## Örnek sorular
- Radyoloji raporu nasıl yazılır?
- Rapor şablonu nasıl değiştirilir?
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
