---
id: icmal-ameliyathane-icmal
baslik: Ameliyathane İcmali
modul: ameliyathane
ekran: ameliyathane-icmal
rota: /ameliyathane-icmal
surec: icmal
roller: ameliyathane_sorumlusu, cerrah, anestezi, yonetici, faturalama
dil: tr
surum: 1
urun_modu: 2
yetki: ameliyathane.icmal
erisim: kullanici
ozet: Seçilen dönemde salon kullanımı ve doluluğunu, süre disiplinini (plan-gerçek, ilk vaka, salon devri), cerrah / anestezi iş yükünü, ameliyat türüne göre sarf ve marjı, faturaya girmeyen sarfı ve iptal / ertelenen vakaları gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Salonlarımız ne kadar dolu, ameliyatlar planlanan sürede bitiyor mu, ilk vakalar zamanında başlıyor mu, hangi ameliyat türü kârlı, faturalanmamış sarf var mı?" sorusunu cevaplar. Ameliyathane sorumlusu, cerrahi birim yöneticileri, faturalama ve yönetim kullanır. Ekranda hasta kimliği yoktur; vakalar protokol numarasıyla görünür.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Salona göre süzmek** — "🚪 Salon" listesi.
- **Branşa göre süzmek** — "🩺 Branş" listesi (cerrahın branşı).
- **Sekmeler arasında geçmek** — Salonlar, Cerrah / Anestezi, Ameliyatlar, Sarf / Marj, İptal / Ertelenen.
- **Salon seçmek** — Salonlar sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili salonları basar.
- **Cerrah dağılımını açmak** — salon adının yanındaki ▸ işaretine tıklayın.
- **Tüm ameliyatları listelemek** — Ameliyatlar sekmesinde "tümünü göster" bağlantısı (varsayılan ilk 25).
- **Çıktı almak** — "🖨️ Ameliyathane İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "🗓 Masa Çizelgesi" ve "🔪 Ameliyat Planı" düğmeleri.

## Ekrana giriş
- Sol menü **Ameliyathane › Ameliyathane İcmali** (`/ameliyathane-icmal`, yalnız HBYS modu).
- `ameliyathane.icmal` görme yetkisi gerekir (haklar ilk tanımda ameliyat planı yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: salona alma zamanına göre (yoksa plan başlangıcı), şubenin saat diliminde. Varsayılan bir önceki takvim ayı.
- **Salon** ve **Branş** listeleri süzgeçten önce çıkarılır; seçili değer listeden düşmez. Yalnız aktif şubenin aktif salonları.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır.
- Şeritte rozetler: "N vakada faturalanmamış sarf", "N ilk vaka geç başladı", "N ertelenen".

## Özet ve sekmeler
Özet kutuları: **Ameliyat** (plan dışı / acil, salon sayısı) · **Salon Doluluğu** (kullanım / kapasite, mesai içi) · **Ort. Süre / Plan** (sapma) · **İlk Vaka Zamanında** · **Ort. Salon Devri** · **Ciro** · **Sarf + İmplant** (brüt kâr, marj) · **İptal / Ertelenen** (iptal oranı).

Sekmeler:
- **Salonlar** — Vaka, Plan Dışı, Kullanım, Kapasite, Doluluk, Ort. Süre, Plan, Sapma, İlk Vaka Zamanında, Ort. Devir, İptal, Ciro.
- **Cerrah / Anestezi** — cerrah başına vaka, masa süresi, sapma, geç ilk vaka, iptal, ciro, marj; anestezi uzmanı başına vaka, süre, iş yükü.
- **Ameliyatlar** — Tarih, Protokol No, Salon, Ameliyat, Cerrah, Plan, Gerçek, Sapma, Ciro, Sarf + İmplant, Marj.
- **Sarf / Marj** — ameliyat türü başına adet, ciro, sarf, implant, vaka başı maliyet, brüt kâr, marj, ort. süre; altta **Faturaya Girmeyen Sarf** listesi.
- **İptal / Ertelenen** — iptal ve ertelenen vakalar (neden, tür) ve neden dağılımı.

## Rakamlar nereden gelir
- Uç: `GET /api/ameliyathane-icmal` (`AmeliyathaneIcmalUclari.cs`); ekran hesap yapmaz.
- **Vaka** = bitmiş ameliyat; iptaller ayrı sayılır. Plan dışı (acil) vaka doluluğa girer, plan sapmasına ve ilk vaka hesabına girmez.
- **Masa süresi** = salona alma → salondan çıkış; **sapma** = (Σ gerçek − Σ plan) ÷ Σ plan.
- **Doluluk** = mesai içi masa süresi ÷ (iş günü × salon mesaisi); mesai salon kartından, iş günü Pazartesi-Cuma.
- **İlk vaka zamanında** = salonun günün ilk planlı vakası plan başlangıcından en çok 10 dk sonra salona alınmış. **Devir** = aynı salonda bir vakanın çıkışı ile sonrakinin alınması arası (0-240 dk).
- **Ciro** = ameliyatın işlem ve sarf satırlarının başvurudaki ücret satırları. **Maliyet** = sarf miktarı × stok maliyeti; implant ayrı gösterilir.
- **Faturaya girmeyen sarf** = faturaya işaretli ama başvuruda ücret satırı olmayan sarf. **Ertelenen** = iptal edilip aynı talepten sonra yeniden planlanan vaka.

## Çıktı
"AMELİYATHANE DÖNEM İCMALİ" başlıklı A4: antet, dönem, salon tablosu (seçim varsa yalnız seçili salonlar) ve özet; Hazırlayan / Sorumlu / Onaylayan imza alanları. Dosya adı "Ameliyathane İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Salon kartında mesai girilmemişse 08:00-17:00 varsayılır; hiç salon yoksa doluluk "salon tanımlı değil" görünür.
- Salona alma / çıkış saati girilmeyen vakada masa süresi hesaplanmaz.
- Faturaya girmeyen sarf kaçak riskidir; başvuruya ücret satırı eklenmesi gerekir. Bu ekran kayıt değiştirmez.

## Örnek sorular
- Geçen ay salon doluluğumuz yüzde kaçtı?
- Hangi cerrahın ameliyatları plandan en çok sapıyor?
- İlk vakalar neden geç başlıyor, hangi salonda?
- Faturaya girmemiş sarf olan vakalar hangileri?
- En kârlı ameliyat türü hangisi?
