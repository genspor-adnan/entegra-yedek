---
id: icmal-kalite-icmal
baslik: Kalite / SKS İcmali
modul: klinik_kalite
ekran: kalite-icmal
rota: /kalite-icmal
surec: icmal
roller: kalite_birimi, yonetim, hemsirelik_yonetimi
dil: tr
surum: 1
urun_modu: 2
yetki: kalite.icmal
erisim: kullanici
ozet: Seçilen dönemin SKS ve klinik kalite göstergelerini, kritik / panik değer bildirim sürelerini, GRS olay bildirimlerini, servis bazında düşme ve bası yarasını, el hijyeni uyumunu ve hasta memnuniyetini tek raporda gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Kalite / SKS İcmali "bu dönem kalite göstergelerimiz hedefte mi, kritik sonuçlar hekime zamanında bildirildi mi, kaç güvenlik olayı oldu, düşme ve bası yarası oranımız ne?" sorusunu cevaplar. Kalite birimi dönem raporu ve SKS denetimine hazırlık için, yönetim ve hemşirelik yönetimi izleme için kullanır. Ekran salt okunurdur; veriler formlardan, laboratuvar / radyoloji bildirimlerinden ve Klinik Kalite dönem sonuçlarından gelir.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Gösterge setini seçme** — 📚 Gösterge seti: SKS + Klinik / SKS / Klinik.
- **Sekmeler arasında geçiş** — Göstergeler, Kritik / Panik Bildirim, Güvenlik Raporlama, Hasta Güvenliği, Memnuniyet.
- **Göstergenin kırılımını açma** — Göstergeler sekmesinde kodun önündeki ▸ işaretine tıklayın (kırılımı olan göstergelerde).
- **A4 için gösterge seçme** — satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; çıktı seçili göstergeleri basar.
- **Uyarı rozetlerini okuma** — şeritte hedef dışı gösterge, hedef süreyi aşan bildirim, ciddi GRS olayı ve kaynaksız gösterge sayıları.
- **Başka ekrana geçme** — **📈 Klinik Göstergeler** (Klinik Kalite dönem sonuçları) ve **🛡 Doldurulan Formlar** düğmeleri.
- **Çıktı alma** — "Kalite Raporu" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Klinik Kalite › Kalite / SKS İcmali** (yalnız HBYS).
- Dönem ve gösterge seti adres çubuğunda tutulur.
- Yetki kodu `kalite.icmal`; haklarını `klinik_kalite.donem` yetkisinden kopyalar.

## Süzgeçler
- **Dönem**: kayıt / olay tarihine göre.
- **Gösterge seti** yalnız Göstergeler sekmesini ve sayısını süzer; diğer sekmeler değişmez.
- Süzgeç değişince A4 seçimi sıfırlanır.

## Özet ve sekmeler
- Kutular: **Göstergeler** (hedefte / toplam, hedef dışı, veri yok), **Kritik / Panik Bildirim** (hedef sürede oranı, aşan), **Ort. Bildirim Süresi** (lab ve radyoloji ayrı, hedefleriyle), **GRS Olay Bildirimi** (ciddi / ölüm, önceki dönem), **Düşme** (‰ hasta-gün, hedef ≤ 2,50‰), **Bası Yarası** (hastanede gelişen, hedef ≤ %5), **El Hijyeni Uyum** (uyulan / fırsat, hedef %85), **Hasta Memnuniyeti** (ortalama puan / 5, anket sayısı).
- **Göstergeler**: Kod, Gösterge, Kaynak, Hedef, Pay / Payda, Dönem, Önceki, Trend, Durum.
- **Kritik / Panik Bildirim**: kaynağa göre (Hedef, Bildirim, Hedefte, Aşan, Oran, Ort. / En Uzun Süre, Teyit, Yükseltme) ve bildirim listesi (Zaman, Protokol No, Kaynak, Tetkik / Bulgu, Değer, Bölüm, Bildirilen, Kanal, Süre, Hedef, Teyit) — en geç olanlar üstte.
- **Güvenlik Raporlama**: olay türü × zarar düzeyi tablosu ve olay bildirimleri (Olay No, Tarih, Tür, Birim, Zarar, Bildiren, Kök Neden / Durum).
- **Hasta Güvenliği**: servis bazında Yatan, Hasta-Gün, İtaki Yüksek, Düşme, ‰ Hasta-Gün, Braden Riskli, Gelişen Bası Yarası, Oran; el hijyeni meslek grubu ve 5 endikasyon tabloları.
- **Memnuniyet**: birim bazında Gönderilen, Dolduran, Yanıt, Ort. Puan, Memnun, Memnuniyet, Şikâyet; soru başlıkları ortalaması.

## Rakamlar nereden gelir
Veri `GET /api/kalite-icmal?bas=&bit=` ucundan (`KaliteIcmalUclari`) gelir; uç yalnız okur, kaynağı olmayan gösterge uydurulmaz, "kaynak yok" döner.
- Klinik göstergeler: Klinik Kalite dönem sonuçlarından aynen (dönemin başlangıcını kapsayan periyot; trend bir önceki periyot); yalnız paydası olan (ölçülmüş) göstergeler. SKS göstergeleri kayıtlardan hesaplanır, trend önceki dönemle.
- Kritik / panik bildirim süresi: laboratuvarda sonuç onayı → hekime bildirim, radyolojide rapor onayı → bildirim. Hedefler ayardan: panik 30 dk, kritik 60 dk (varsayılan).
- GRS olayları, el hijyeni, memnuniyet, İtaki ve Braden: form motoru kayıtlarından (şablon koduna göre).
- Düşme ‰ = GRS türü "düşme" / yatan hasta-gün × 1000 (giriş günü sayılır, çıkış günü sayılmaz). Bası yarası = Braden ≤ 12 riskli hastada ilk formda yok, sonraki formda var.
- Memnun = ortalaması 4–5 puan olan anket.

## Çıktı
**Kalite Raporu** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Gösterge seçiliyken "A4 seçili N göstergeyi basar" notu çıkar. Dosya adı "Kalite Raporu" ve dönemi taşır.

## Dikkat edilecekler
- ISO kalite modülü (DÖF, olay takibi, şikâyet kaydı) henüz yok: bu kaynaklara bağlı göstergeler "kaynak yok", şikâyet sütunu boş görünür; GRS olaylarının kök neden / kapanış takibi tutulmaz.
- Ölçülmemiş (paydası 0) klinik göstergeler listede yoktur; alttaki not sayısını verir, Klinik Kalite › Dönem Sonuçları'ndan hesaplatılır.
- Hasta kimliği gösterilmez: bildirimler Protokol No ile, GRS olayları olay / form no ile; bildiren anonim olabilir.
- Birimi bir servisle eşleşmeyen düşme bildirimi toplama girer ama servis satırına girmez.

## Örnek sorular
- Bu ay hangi kalite göstergeleri hedef dışında?
- Panik değerler hekime ortalama kaç dakikada bildirildi?
- Geçen ay kaç ciddi güvenlik olayı bildirildi?
- Hangi serviste düşme oranı yüksek?
- El hijyeni uyumumuz hedefin altında mı?
- Neden bazı göstergeler "kaynak yok" diyor?
