---
id: icmal-dis-icmal
baslik: Diş İcmali
modul: dis
ekran: dis-icmal
rota: /dis-icmal
surec: icmal
roller: dis_hekimi, klinik_sorumlusu, yonetici, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: dis.icmal
erisim: kullanici
ozet: Seçilen dönemde diş hekimi başına seans, işlem, ciro, sarf, laboratuvar maliyeti ve brüt kârı; tedavi planı hunisini, yarım kalan planları, işlem türlerini, protez laboratuvarlarını ve ünite doluluğunu gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi hekim ne kadar ciro ve kâr üretti, sunulan planların ne kadarı kabul edilip tamamlandı, hangi planlar yarım kaldı, laboratuvarlar ve üniteler nasıl çalışıyor?" sorusunu cevaplar. Klinik sorumlusu, hekimler ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Hekime göre süzmek** — "🧑‍⚕️ Hekim" listesi.
- **İşlem grubuna göre süzmek** — "🦷 İşlem Grubu" listesi (Restoratif, Endodonti, Protetik…).
- **Sekmeler arasında geçmek** — Hekimler, Tedavi Planları, Yarım Kalanlar, İşlem Türleri, Lab / Ünite.
- **Hekim seçmek** — Hekimler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili hekimleri basar.
- **Hekimin işlemlerini açmak** — hekim adının yanındaki ▸ işaretine tıklayın.
- **Yarım kalan planları incelemek** — Yarım Kalanlar sekmesi; plan tutarı, yapılan, kalan, tahsil edilen, son seans ve neden.
- **Çıktı almak** — "🖨️ Diş İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "🦷 Tedavi Planları" ve "🧪 Lab İş Emirleri" düğmeleri.

## Ekrana giriş
- Sol menü **Diş › Diş İcmali** (`/dis-icmal`, yalnız HBYS modu).
- `dis.icmal` görme yetkisi gerekir (haklar ilk tanımda diş ödeme yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: seans başlangıç tarihine göre; plan hunisi için dönemde açılan planlar. Varsayılan bir önceki takvim ayı.
- **Hekim**: seansın hekimi (yoksa planın hekimi). **İşlem Grubu** seçilince seans = o gruptan işlem yapılan seans.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır. Yalnız aktif şubenin kayıtları.
- Şeritte rozetler: "N yarım kalan plan · tutar", "N lab işi geç", "N işlem faturasız".

## Özet ve sekmeler
Özet kutuları: **Seans** (hasta, işlem) · **Ciro** · **Sarf + Lab** · **Brüt Kâr** (marj) · **Plan Kabul** (kabul / sunulan) · **Plan Tamamlanma** (tamam / kabul) · **Yarım Kalan** (tutar, plan sayısı, gün eşiği) · **Ünite Doluluğu** (ünite sayısı, ort. seans dakikası).

Sekmeler:
- **Hekimler** — Uzmanlık, Seans, Hasta, İşlem, Ciro, Sarf, Lab, Brüt Kâr, Marj, Plan Kabul, Ort. Seans, Ciro Payı.
- **Tedavi Planları** — hekim başına sunulan, bekliyor, kabul, kabul tutarı / oranı, sürüyor, tamam, tamamlanma, iptal / süre doldu, yapılan tutar, ilerleme.
- **Yarım Kalanlar** — Plan No, Son Protokol No, Hasta (ad + soyadın baş harfi), Hekim, Plan Tutarı, Yapılan, Kalan, Tahsil Edilen, Son Seans, Neden.
- **İşlem Türleri** — İşlem, Grup, Adet, Ciro, Ort. Fiyat, Sarf, Lab, Marj, Hekim, Ciro Payı.
- **Lab / Ünite** — protez / ortodonti laboratuvarları (iş emri, lab bedeli, hastaya yansıyan, fark, sözleşme ve ortalama süre, teslim) ve ünite doluluğu.

## Rakamlar nereden gelir
- Uç: `GET /api/dis-icmal` (`DisIcmalUclari.cs`); ekran hesap yapmaz.
- **Seans** = durumu "Bitti" olan seans; **işlem** = tamamlanmış seans işlemi.
- **Ciro** = işlemin başvuru satırı tutarı (iptal başvuru hariç); satırı olmayan işlem "faturasız" sayılır, ciroya 0 girer.
- **Sarf** = seans sarf maliyeti, seansın işlemlerine ciro oranında (ciro yoksa eşit) dağıtılır. **Lab** = teslim tarihi dönemde olan lab iş emrinin lab fiyatı. Brüt kâr = ciro − sarf − lab.
- **Plan hunisi**: dönemde açılan (taslak hariç) planlar; kabul = Onaylı / Sürüyor / Tamamlandı, bekliyor = Sunuldu.
- **Yarım kalan** = Onaylı / Sürüyor plan, son seanstan (yoksa onaydan) 45+ gün geçmiş. Neden sırayla çıkarılır: açık lab işi › gecikmiş taksit › ertelenen satır; kalanı "Randevu almadı".
- **Ünite doluluğu** = seans süresi ÷ (Pzt-Cmt iş günü × 9 saat).

## Çıktı
"DİŞ DÖNEM İCMALİ" başlıklı A4: antet, dönem, ünite doluluğu, hekim tablosu (seçim varsa yalnız seçili hekimler) ve özet; Hazırlayan / Sorumlu / Onaylayan imza alanları. A4'te hasta bilgisi yoktur. Dosya adı "Diş İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Ünite çalışma saati kartta tutulmadığından kapasite sabit 9 saat / gün kabul edilir.
- Yarım kalan nedeni planda kayıtlı değildir; sistem tahmin eder.
- Bu ekran kayıt değiştirmez; planı açmak için Tedavi Planları ekranına geçin.

## Örnek sorular
- Geçen ay en çok ciro yapan hekim kim?
- Sunulan tedavi planlarının kaçı kabul edildi?
- Yarım kalan planlar hangileri, neden yarım kalmış?
- Protez laboratuvarına ödediğimizle hastaya yansıttığımız arasındaki fark ne?
- Ünite doluluğu nasıl hesaplanıyor?
