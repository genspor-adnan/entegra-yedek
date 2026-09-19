---
id: radyoloji-istem-rapor
baslik: Radyoloji istemi, çekim ve rapor
modul: radyoloji
ekran: radyoloji-istem
rota: /radyoloji
surec: radyoloji
roller: radyoloji_teknikeri, radyolog, hekim, banko
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji-istem
erisim: kullanici
ozet: Radyoloji › Çalışma Listesi ekranında istem açma, cihaz randevusu, çekildi işaretleme, sarf düşme, rapor yazma / onaylama, kritik bulgu ve sonuç teslimi.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Radyoloji Çalışma Listesi modülün giriş ekranıdır: istem burada açılır, cihaza randevu verilir, çekim işaretlenir, rapor yazılır ve onaylanır, sonuç teslim edilir. Ayrı bir istem ekranı yoktur; kart bu listeden açılır (`/radyoloji/[kayıt no]`).

## Ekrana giriş yolları
- Sol menü: **Radyoloji › Çalışma Listesi**; aynı grupta **Pano**, **Kritik Bulgular**, **Konsültasyonlar**, **Sonuç Teslim**, Ayarlar altında **Rapor Şablonları**, **Çekim Protokolleri**, **Cihazlar**.
- Muayene kartı › **İstem & Sonuçlar › 🔬 İstem Aç › Görüntüleme** (modalitesi tanımlı hizmetler).
- Komut paleti (Ctrl+K) › "Radyoloji".

## Ön koşullar
- Liste için **radyoloji-istem** yetkisi; ayar ekranları **radyoloji**; rapor yazma `rad.rapor_yaz`, teslim `rad.teslim`, iptal `rad.istem_iptal` aksiyon yetkileri.
- Tetkik hizmet kartında modalite seçili olmalı; cihaz tanımlı ve o modalitede olmalı.
- Rapor şablonu tetkike bağlıysa rapor ekranı varsayılanı kendiliğinden yükler.

## Alanlar
Kimlik: **Hasta (zorunlu)**, **Tetkik (zorunlu)**, Öncelik, Accession No, Durum.
İstem Bilgisi: İsteyen Hekim, Dış Hekim (kayıtsız), İsteyen Kurum, Ön Tanı (ICD-10), Klinik Bilgi (zorunlu), Modalite.
Çekim: Cihaz listesine (MWL) gönder, Randevu SMS'i, Hazırlık talimatı verildi, Sonuç CD'si hazırlanacak, Cihaz, Tekniker, Çekim Zamanı, Kontrast, Kontrast (ml), Kontrast Yolu, Etkin Madde, Konsantrasyon (mg/ml), DLP, CTDIvol, Kritik Bulgu.
PACS: Study UID, Seri Sayısı, Görüntü Sayısı, Açıklama. "Kontrol Listesi" sekmesi: çekim öncesi sorular modaliteye göre üretilir.
Rapor ekranı bölümleri: İstem Nedeni, Çekim Kalitesi, Yapılandırılmış Alanlar, Sonuç ve Öneriler, Makrolar, Önceki Tetkikler, Kritik Bulgu Bildirimleri, Konsültasyon; düğme **💾 Taslak Kaydet**.

## Liste kolonları ve çipler
Kolonlar: Accession · Hasta · Tetkik · İsteyen Kurum · Ödeyen Kurum · Radyolog · Kritik ve saat / durum kolonları.
Çipler: **Bekleyen Çekim · Raporlanacak · Raporlanıyor · Onay Bekleyen · Onaylandı · Tümü**; tarih süzgeci saat alanına göre.

## İşlemler (düğmeler)
- `radyoloji.yeni` **＋ Yeni İstem** (Ctrl+N), `radyoloji.duzenle` **✎ Düzenle** (Enter).
- `radyoloji.randevu` **📅 Randevu Ver**: cihaza randevu (randevu modülüne yazılır).
- `radyoloji.cekildi` **✔ Çekildi İşaretle**: çekim zamanı; sarf penceresi kendiliğinden açılır.
- `radyoloji.sarf` **🧪 Sarf Düş**: kontrast / malzeme stoktan düşer.
- `radyoloji.rapor` **✎ Rapor Yaz**: rapor ekranı.
- `radyoloji.teslim` **📦 Sonuç Teslim Et**: film / CD / basılı rapor kime verildi.
- `radyoloji.iptal` **✖ İstemi İptal Et**.
- Kritik Bulgular listesinde bildirim / kapatma; Konsültasyonlar listesinde cevap.

## Adım adım
1. **Radyoloji › Çalışma Listesi › ＋ Yeni İstem**: hasta, tetkik, klinik bilgi ve isteyen hekimi girin; **Kaydet**.
2. **📅 Randevu Ver** ile cihaz ve saat seçin (walk-in cihazda gerekmez).
3. Hasta geldiğinde Kontrol Listesi'ni doldurun; çekimden sonra **✔ Çekildi İşaretle**, açılan pencerede sarfı onaylayın.
4. Radyolog **✎ Rapor Yaz** → şablon yüklenir, makrolarla metni yazın, **💾 Taslak Kaydet**; sonra raporu onaya gönderin / onaylayın (rapor ekranındaki durum düğmeleri).
5. Kritik bulgu varsa rapor ekranında "Bu tetkikte kritik bulgu var" işaretleyip bildirilen kişiyi yazın; takibi **Kritik Bulgular** ekranından kapatın.
6. Onaylı raporu **📦 Sonuç Teslim Et** ile teslim edin; teslim alan kişi zorunludur.

## Durumlar
- **Bekleyen Çekim (1)** → **Raporlanacak (2)** → **Raporlanıyor (3)** → **Onay Bekleyen (4)** → **Onaylandı (5)**; iptal ayrı.
- Kritik bulgu takibi: Bildirilmedi → Teyit Bekleyen → Teyitli → Kapatılan. Teslim: Teslim Bekleyen → Teslim Edilen.
- Onaylı rapora ek yazılır (addendum); rapor metni değişmez.

## Yetki
- Liste **radyoloji-istem** (dar yetki; dış hekim portali bu yetkiyle yalnız kendi hastalarını görür).
- Pano, kritik, konsültasyon, teslim ve ayar ekranları **radyoloji**. Rapor `rad.rapor_yaz`, teslim `rad.teslim`, iptal `rad.istem_iptal`, sarf **stok** Değiştir, randevu **randevu** Ekle.

## Sık görülen hata ve uyarılar
- **"En az bir tetkik seçilmeli." / "Hasta seçilmeli." / "Klinik bilgi / istem gerekçesi yazılmalı."** (DOGRULAMA) → istem kaydı için üçü de gerekli.
- **"İptal edilmiş isteme randevu verilemez." / "Bu istemin zaten randevusu var - önce onu taşıyın ya da iptal edin." / "Bu cihaz randevusuz (walk-in) çalışıyor."** (IS_KURALI).
- **"Tetkik ile cihazın modalitesi uyuşmuyor"** → doğru cihazı seçin.
- **"Teslim alan kişi yazılmalı." / "Görüş metni boş olamaz." / "Konsültasyon gerekçesi yazılmalı."**
- **"Düşülecek malzeme seçilmedi."** → sarf penceresinde en az bir kalem.
- **"Modalitesi tanımlı radyoloji tetkiki yok"** (muayene kartından) → Stok & Hizmet › Hizmet kartında modalite seçin.

## Diğer modüllere etkisi
- Randevu cihaz sütununda görünür ve MWL ile cihaza iner; sarf stok hareketi üretir.
- Onaylı rapor hekimin muayene kartındaki İstem & Sonuçlar sekmesinde listelenir.
- Kritik bulgu hasta güvenliği listesine düşer; teleradyoloji istekleri dış kurumla aynı akışı kullanır.
- Yazdırma tarayıcıdan ("PDF olarak kaydet"); ayrı sunucu PDF üreticisi yoktur.

## Yapılmaması gerekenler
- Çekim yapılmadan "Çekildi" işaretlemeyin; sarf ve MWL ona bağlıdır.
- Onaylı raporu düzeltmek için yeni rapor yazmayın; ek (addendum) kullanın.
- Kritik bulguyu işaretleyip bildirim yapmadan bırakmayın; "Bildirilmedi" çipinde kalır.

## Örnek sorular
- Radyoloji istemi nasıl açılır?
- Cihaza randevu nasıl verilir?
- Çekildi işaretini nereden koyarım?
- Rapor nasıl yazılır ve onaylanır?
- Kritik bulgu bildirimi nasıl yapılır?
- Sonuç CD'sini teslim ettiğimi nereye yazarım?
- Kontrast sarfı nasıl düşülür?
- İstem neden iptal edilemiyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Radyoloji.ts
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (radyoloji-liste)
- api/src/Gentegre.Cekirdek/Katalog/KartKatalogu.Radyoloji.cs, KaynakKatalogu.Radyoloji.cs
- api/src/Gentegre.Api/Uclar/RadyolojiUclari*.cs, web/src/sayfalar/RadyolojiRapor.tsx
- dokuman/00_TARIHCE.md (283-336 radyoloji)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Rapor ekranındaki onay / onaya gönder düğmelerinin tam adları doğrulanacak.
