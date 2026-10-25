---
id: icmal-goruntuleme-icmal
baslik: Görüntüleme İcmali
modul: radyoloji
ekran: goruntuleme-icmal
rota: /goruntuleme-icmal
surec: icmal
roller: radyolog, radyoloji_sorumlusu, yonetici, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji.icmal
erisim: kullanici
ozet: Seçilen dönemde modalite ve tetkik başına çekim, ciro, kontrast / sarf maliyeti ve marjı; raporlayanların rapor süresini, cihaz doluluğunu ve teleradyoloji giden / gelen çekimlerini gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönemde hangi modalitede kaç çekim yapıldı, ne kadar ciro ve sarf maliyeti oluştu, raporlar zamanında yazıldı mı, cihazlar ne kadar dolu?" sorusunu cevaplar. Radyoloji sorumlusu, yönetim ve mali işler kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları (bir ay geri / ileri); varsayılan geçen ay.
- **Modaliteye göre süzmek** — "🩻 Modalite" listesi (BT, MR, USG, Röntgen…).
- **Raporlayana göre süzmek** — "👤 Raporlayan": Tümü / İç radyolog / Teleradyoloji.
- **Sekmeler arasında geçmek** — Modaliteler, Tetkikler, Raporlayanlar, Cihazlar, Teleradyoloji.
- **Modalite seçmek** — Modaliteler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili modaliteleri basar.
- **En çok çekilen tetkikleri açmak** — modalite adının yanındaki ▸ işaretine tıklayın.
- **Çıktı almak** — "🖨️ Görüntüleme İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "📊 Radyoloji Pano" ve "🧾 Teleradyoloji Dönem Faturası" düğmeleri.

## Ekrana giriş
- Sol menü **Radyoloji › Görüntüleme İcmali** (`/goruntuleme-icmal`, yalnız HBYS modu).
- `radyoloji.icmal` görme yetkisi gerekir (haklar ilk tanımda rapor onay yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: çekim tarihine göre (çekilmemiş istemde istem tarihi). Varsayılan bir önceki takvim ayı.
- **Modalite** listesi dönemde geçen modalitelerden dolar; **Raporlayan** iç radyolog ile dışarıya (teleradyoloji) raporlatılan çekimleri ayırır.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır. Yalnız aktif şubenin kayıtları sayılır.
- Şeritte rozetler: "N çekim rapor bekliyor", "N rapor hedef süreyi aştı", "sarf düşümü yok" (dönemde hiç radyoloji sarfı girilmemiş).

## Özet ve sekmeler
Özet kutuları: **Çekim** (hasta, faturasız) · **Ciro** · **Kurum / Hasta Payı** · **Kontrast + Sarf** (kontrastlı çekim sayısı) · **Brüt Kâr** (marj) · **Ort. Rapor Süresi** (hedef ve aşan sayısı) · **Teleradyoloji** (net tutar, giden / gelen çekim) · **Cihaz Doluluğu**.

Sekmeler:
- **Modaliteler** — Çekim, Ciro, Kurum %, Kontrastlı, Kontrast / Sarf, Telerad, Brüt Kâr, Marj, Ort. Rapor, Hedef Aşan.
- **Tetkikler** — SUT / Kod, Tetkik, Modalite, Adet, Ciro, Ort. Fiyat, Sarf / Çekim, Maliyet, Marj; "faturasız" etiketi.
- **Raporlayanlar** — Rapor, Bekleyen, Ort. Süre, Hedef Aşan, Aşım Oranı, Kritik Bulgu, İkinci Okuma, Revizyon, İş Yükü; altta hedef süreyi aşan raporlar listesi.
- **Cihazlar** — Çekim, Kullanım, Kapasite, Doluluk, Arıza / Bakım, Sarf, Sarf / Çekim.
- **Teleradyoloji** — dışarıya giden çekimler (kurum, çekim, birim ücret, maliyet) ve dışarıdan gelen çekimler (çekim, raporlanan, SLA aşan, gelir).

## Rakamlar nereden gelir
- Uç: `GET /api/goruntuleme-icmal` (`GoruntulemeIcmalUclari.cs`); ekran hesap yapmaz.
- **Birim = çekim** (iç ve dışarıya raporlatılan istemler, iptal hariç; yalnız başvuruya bağlı, iptal başvuru hariç).
- **Ciro**: istemin başvuru satırı; satır bağı yoksa başvurunun aynı hizmetli satırları o hizmetteki çekimlere bölünür. Kurum payı satır dağılımından.
- **Maliyet**: kontrast / sarf = radyoloji sarfı × stok maliyeti; dışarıya raporlatılan çekimde teleradyoloji ücreti eklenir. Gelen teleradyoloji geliri ciroya **katılmaz**, kendi sekmesinde izlenir.
- **Rapor süresi** = çekim → ilk onaylı rapor. Hedef ayarlardan (rutin ve acil ayrı dakika); teleradyolojide sözleşmenin SLA bitişi.
- **Doluluk** = çekim × cihazın çekim süresi ÷ (çalışma saati × iş günü − arıza / bakım kapatmaları).

## Çıktı
"GÖRÜNTÜLEME DÖNEM İCMALİ" başlıklı A4: antet, dönem, süzgeç bilgisi, modalite tablosu (seçim varsa yalnız seçili modaliteler) ve özet; Hazırlayan / Sorumlu / Onaylayan imza alanları. Dosya adı "Görüntüleme İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Sarf girilmeyen çekimlerde maliyet 0'dır, marj ciroya eşit görünür.
- Cihazı seçilmemiş çekimler doluluğa girmez ("N çekimde cihaz yok" uyarısı).
- Bu ekran yalnız rapor verir; çekim, rapor ya da fatura değiştirmez.

## Örnek sorular
- Geçen ay MR'da kaç çekim yaptık, cirosu ne kadardı?
- Hangi radyologun raporları hedef süreyi aşıyor?
- Teleradyolojiye ödediğimiz ve kazandığımız tutar ne?
- BT cihazının doluluğu neden düşük görünüyor?
- Sadece USG ve Röntgen için icmali nasıl yazdırırım?
