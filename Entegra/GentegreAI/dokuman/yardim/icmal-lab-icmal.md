---
id: icmal-lab-icmal
baslik: Laboratuvar İcmali
modul: lab
ekran: lab-icmal
rota: /lab-icmal
surec: icmal
roller: lab_uzmani, lab_sorumlusu, yonetici, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: lab.icmal
erisim: kullanici
ozet: Seçilen dönemde laboratuvar tetkiklerinin adet, ciro, kurum / hasta payı, reaktif maliyeti ve brüt kârını; tetkik grubu, cihaz, dış laboratuvar kırılımlarını, sonuç süresini (TAT) ve numune ret oranını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönemde laboratuvar kaç tetkik yaptı, ne kadar ciro getirdi, reaktif / dış lab maliyeti ne kadar tuttu, sonuçlar zamanında çıktı mı?" sorusunu cevaplar. Tetkik başına adet ve kârlılığı, cihaz iş yükünü, dış laboratuvarların kârlı olup olmadığını, hedef süreyi aşan tetkikleri ve numune ret nedenlerini tek ekranda toplar. Laboratuvar sorumlusu, yönetim ve mali işler kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları (bir ay geri / ileri); varsayılan geçen ay.
- **İsteyen bölüme göre süzmek** — "🏥 İsteyen Bölüm" listesi.
- **Tetkik grubuna göre süzmek** — "🧪 Tetkik Grubu" listesi.
- **Sekmeler arasında geçmek** — Tetkikler, Tetkik Grupları, Cihazlar, Dış Laboratuvar, Kalite / Süre.
- **Tetkik seçmek** — Tetkikler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); seçilenler A4 çıktısına ayrı tablo olarak eklenir.
- **Bölüm dağılımını açmak** — Tetkik kodunun yanındaki ▸ işaretine tıklayın; tetkiki isteyen bölümler ve adetleri açılır.
- **Dış lab tetkiklerini açmak** — Dış Laboratuvar sekmesinde lab satırına tıklayın; o laba giden tetkikler tek tek görünür.
- **Çıktı almak** — "🖨️ Laboratuvar İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "📚 Tetkik Kataloğu" ve "🏍️ Dış Lab Gönderimleri" düğmeleri.

## Ekrana giriş
- Sol menü **Laboratuvar › Laboratuvar İcmali** (`/lab-icmal`, yalnız HBYS modu).
- `lab.icmal` görme yetkisi gerekir (yetki ilk tanımlandığında haklar laboratuvar yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: başlangıç – bitiş tarihi; istem tarihine göre süzülür. Varsayılan bir önceki takvim ayıdır.
- **İsteyen Bölüm** ve **Tetkik Grubu**: listeler dönemde gerçekten geçen bölüm / gruplardan dolar; "Tümü" süzgeci kaldırır.
- Süzgeçler adres çubuğunda tutulur (sayfa yenilense de kalır); süzgeç değişince tetkik seçimi sıfırlanır.
- Yalnız aktif şubenin (ve şubesiz) başvuruları sayılır.
- Şeritte uyarı rozetleri: "N kalemde test başı maliyet tanımsız", "N dış lab zarar ediyor", "N tetkik hedef süreyi aştı".

## Özet ve sekmeler
Özet kutuları: **Tetkik** (hasta ve istem sayısı) · **Ciro** (faturasız kalem sayısı) · **Kurum / Hasta Payı** · **Reaktif / Kit** · **Brüt Kâr** (marj) · **Dış Lab** (test, maliyet, fatura) · **Tekrar / Ret** oranları · **Ort. Sonuç Süresi**.

Sekmeler:
- **Tetkikler** — Kod, Tetkik, Grup, Adet, Birim Fiyat, Ciro, Kurum %, Maliyet / Test, Maliyet, Marj, Ort. TAT, Tekrar; faturasız kalemlerde "N faturasız" etiketi.
- **Tetkik Grupları** — grup başına çeşit, adet, ciro, kurum / hasta payı, maliyet, brüt kâr, marj, tekrar, ciro payı.
- **Cihazlar** — Cihaz / Tezgâh, Bölüm, Test, QC / Kalibrasyon, QC Oranı, Arıza, Reaktif, Test Başı Maliyet.
- **Dış Laboratuvar** — gönderilen test, bizim faturaladığımız, dış lab maliyeti, fark, durum, ortalama sonuç günü.
- **Kalite / Süre** — sonuç süresi dağılımı, numune ret nedenleri (en çok hangi bölümde) ve hedef süreyi aşan tetkikler listesi (ilk 50).

## Rakamlar nereden gelir
- Uç: `GET /api/lab-icmal` (`LabIcmalUclari.cs`); ekran hesap yapmaz.
- **Birim = istem kalemi**; panel tek kalem sayılır. Yalnız hasta başvurusuna bağlı istemler sayılır; iptal başvuru ve iptal kalem hariç.
- **Ciro** başvurunun aynı hizmetli satırından gelir; faturada karşılığı olmayan kalemin cirosu 0'dır ("faturasız"). Kurum payı satır dağılımından (SGK + ÖSS).
- **Maliyet**: iç labda tetkik kartındaki "Test Başı Maliyet" × (1 + tekrar sayısı); dış labda gönderim fiyatı, yoksa dış lab fiyat listesi. QC / kalibrasyon brüt kâra girmez.
- **TAT** = numune kabul → sonuç onayı; hedef tetkik tanımından (acil istemde acil hedef). Özetteki ortalama yalnız rutin iç lab içindir (mikrobiyoloji ve dış lab hariç).
- **Numune ret oranı** dönem istemlerinin numuneleri üzerinden hesaplanır.

## Çıktı
"🖨️ Laboratuvar İcmali ▾" menüsü "LABORATUVAR DÖNEM İCMALİ" başlıklı A4 belge üretir: antet, dönem, süzgeç bilgisi, grup tablosu, maliyet özeti; tetkik seçildiyse seçilen tetkiklerin tablosu da eklenir. Hazırlayan / Sorumlu / Onaylayan imza alanları vardır. Dosya adı "Laboratuvar İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Tetkik kartında test başı maliyet girilmemişse maliyet 0 sayılır ve marj olduğundan yüksek görünür; marj sütununda "maliyet yok" yazar.
- Başvuruda satırı olmayan kalem ciroya girmez; "faturasız" sayısı yüksekse ücretlendirme kontrol edilmelidir.
- Bu ekran yalnız rapor verir; tetkik, fiyat ya da sonuç değiştirmez.

## Örnek sorular
- Geçen ay laboratuvarın brüt kârı ne kadardı?
- Hangi dış laboratuvar bize zarar ettiriyor?
- Hedef sonuç süresini aşan tetkikler hangileri?
- Numuneler en çok hangi nedenle reddediliyor?
- Marj neden %100 görünüyor?
- Sadece biyokimya grubunun icmalini nasıl yazdırırım?
