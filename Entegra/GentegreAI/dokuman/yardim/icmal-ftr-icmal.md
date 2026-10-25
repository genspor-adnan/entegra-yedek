---
id: icmal-ftr-icmal
baslik: FTR İcmali
modul: ftr
ekran: ftr-icmal
rota: /ftr-icmal
surec: icmal
roller: fizyoterapist, ftr_hekimi, ftr_sorumlusu, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: ftr.icmal
erisim: kullanici
ozet: Seçilen dönemde fizik tedavi kür ve seans hacmini, devam oranını, fizyoterapist iş yükünü, ödeyen kırılımını, tamamlanan kürlerde klinik sonucu (VAS, ölçek, yanıt), ara değerlendirmeleri ve uygulama / kabin doluluğunu gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönemde kaç kür ve seans yapıldı, hastalar seanslara devam etti mi, fizyoterapistlerin iş yükü nasıl, ciro hangi ödeyenden geldi, kabinler ne kadar dolu?" sorusunu cevaplar. FTR sorumlusu, fizyoterapistler ve yönetim kullanır. Ekranda hasta kimliği yoktur; kürler Program / Protokol No ile görünür.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Fizyoterapiste göre süzmek** — "🧑‍⚕️ Fizyoterapist" listesi.
- **Bölgeye göre süzmek** — "🦴 Bölge" listesi.
- **Ödeyene göre süzmek** — "💳 Ödeyen": Tümü / SGK (Medula) / ÖSS / Kurum / Özel.
- **Sekmeler arasında geçmek** — Fizyoterapistler, Kürler, Ödeyen, Klinik Sonuç, Cihaz / Kabin.
- **Fizyoterapist seçmek** — Fizyoterapistler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); seçim Kürler listesini ve A4'ü süzer.
- **Bölge dağılımını açmak** — fizyoterapist adının yanındaki ▸ işaretine tıklayın.
- **Çıktı almak** — "🖨️ FTR İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "🗂 Ünite Panosu" ve "📅 Seanslar" düğmeleri.

## Ekrana giriş
- Sol menü **FTR › FTR İcmali** (`/ftr-icmal`, yalnız HBYS modu).
- `ftr.icmal` görme yetkisi gerekir (haklar ilk tanımda FTR Panosu / seans yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: dönemde en az bir seansı olan ya da dönemde tamamlanan kürler alınır. Varsayılan bir önceki takvim ayı.
- **Fizyoterapist**, **Bölge**, **Ödeyen**: ödeyen, programın ödeyen kurumunun türünden gelir (SGK, ÖSS, kurum öder; kurum yoksa Özel).
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır. Yalnız aktif şubenin kayıtları.
- Şeritte rozetler: "N kürde ara değerlendirme gecikti", "N kür yarıda bırakıldı".

## Özet ve sekmeler
Özet kutuları: **Kür** (süren, biten, yarıda) · **Seans** (yarım, planlı) · **Gelmedi / İptal** (devam oranı; %80 altı kırmızı) · **Kür Başı Seans** (tamamlanan kürlerde) · **Ciro** (kurum / hasta) · **Medula Payı** (seans ve ciro payı) · **İyi Yanıt** (VAS ortalama düşüşü) · **Kabin Doluluğu**.

Sekmeler:
- **Fizyoterapistler** — Kür, Aktif, Seans, Yarım, Gelmedi, Devam, Süre, Ciro, Biten Kür, VAS Düşüşü, İş Yükü.
- **Kürler** — Program No, Protokol No, Bölge / Tanı, Ödeyen, Fizyoterapist, Seans, Dönem, Gelmedi, Kalan Hak, Durum, Yanıt, Ciro.
- **Ödeyen** — Kür, Seans, Seans Ücreti, Ciro, Kurum Payı, Hasta Payı, Rapor Hakkı, Ciro Payı.
- **Klinik Sonuç** — bölge / ölçek başına kür, VAS, ölçek skoru, iyileşme, iyi / kısmi / yanıtsız ve iyi yanıt oranı; altta Ara Değerlendirme durumu.
- **Cihaz / Kabin** — uygulama / cihaz kullanımı ve kabin / salon doluluğu.

## Rakamlar nereden gelir
- Uç: `GET /api/ftr-icmal` (`FtrIcmalUclari.cs`); ekran hesap yapmaz.
- **Seans** = durumu Yapıldı ya da Yarım olan seans; Gelmedi ve İptal ayrı sayılır. **Devam oranı** = yapılan ÷ (yapılan + gelmedi); merkez kaynaklı iptal devama girmez.
- **Ciro** = seansın bağlı olduğu başvuru satırı tutarı; kurum payı satır dağılımından. Satıra bağlanmamış seansın cirosu 0'dır.
- **Klinik sonuç** yalnız dönemde tamamlanan kürlerde: kür başı → kür sonu ölçek ortalaması (VAS hariç); yanıt programdan; VAS = ilk seansın "önce" değeri → son seansın "sonra" değeri.
- **Ara değerlendirme gecikti** = yapılan seans sayısı ara değerlendirme seansına ulaştı ama ara ölçek girilmedi.
- **Kabin doluluğu** = seans süreleri ÷ (Pzt-Cmt iş günü × 9 saat × kabin kapasitesi).

## Çıktı
"FİZİK TEDAVİ DÖNEM İCMALİ" başlıklı A4: antet, dönem, süzgeç bilgisi, fizyoterapist tablosu (seçim varsa yalnız seçili fizyoterapistler), ödeyen tablosu ve özet; Hazırlayan / Sorumlu / Onaylayan imza alanları. Dosya adı "FTR İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Kabin kapasitesi sabit 9 saat / gün varsayımıyla hesaplanır.
- Klinik sonuç ölçek ve VAS girilen kürlerde anlamlıdır; eksik girişli kür ortalamaya girmez.
- Bu ekran yalnız rapor verir; seans ya da program değiştirmez.

## Örnek sorular
- Geçen ay kaç FTR seansı yapıldı, devam oranı neydi?
- Hangi fizyoterapistin iş yükü en yüksek?
- SGK'dan gelen ciro payı ne kadar?
- Ara değerlendirmesi geciken kürler hangileri?
- İyi yanıt oranı nasıl hesaplanıyor?
