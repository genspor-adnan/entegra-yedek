---
id: icmal-medula-mutabakat
baslik: Medula Mutabakat İcmali
modul: medula
ekran: medula-mutabakat
rota: /medula-mutabakat
surec: icmal
roller: medula, faturalama, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: medula.mutabakat
erisim: kullanici
ozet: Bir SGK döneminin takip → hizmet → çıkış → fatura → dönem → ödeme hunisini; faturasız takipleri nedeniyle, HBYS – Medula tutar farklarını ve kesintileri gösterir; eksik takipler buradan faturalanır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu ay SGK'ya alınan takiplerin kaçı faturaya, döneme ve ödemeye ulaştı; kaçı nerede kaldı, kesinti ve açık alacak ne?" sorusunu cevaplar. Huninin her adımında düşen takip kaçak gelirdir; ekran bunları nedeniyle listeler ve faturaya hazır olanları buradan faturalatır. Medula / faturalama birimi, muhasebe ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" ay listesi ve yıl kutusu; ‹ / › okları önceki / sonraki aya geçer (varsayılan geçen ay).
- **Sekmeler arasında geçmek** — Huni, Faturasız Takipler, Tutar Farkları, Kesintiler.
- **Eksikleri toplu faturalamak** — "🧾 Eksikleri Faturala (N)"; onaydan sonra engeli olmayan bütün "Faturaya hazır" takipler Medula'ya faturalanır.
- **Seçili takipleri faturalamak** — Faturasız Takipler sekmesinde yalnız "Faturaya hazır" satırlar seçilebilir; "☑ Seçilileri Faturala" tek tek gönderir, kabul / hata sayısı bildirilir.
- **Ne yapılacağını görmek** — faturasız takip satırındaki Neden ve Yapılacak sütunları (ör. "Takibe çıkış verin").
- **Hasta icmalini açmak** — hasta adına tıklayın; geri dönüş bu ekrana gelir.
- **Çıktı almak** — "🖨️ Medula Mutabakat İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Fatura & Dönem ekranına geçmek** — "🧮 Fatura & Dönem" düğmesi.

## Ekrana giriş
- Sol menü **Medula › Mutabakat İcmali** (`/medula-mutabakat`).
- Görmek için `medula.mutabakat` yetkisi gerekir; faturalama düğmeleri Fatura & Dönem ekranının uçlarını kullanır, o ekranın faturalama yetkisi de gerekir.

## Süzgeçler
- Yalnız **Dönem** (yıl + ay). Şeritte dönemin durumu (rozet ve icmal no; dönem yoksa "dönem oluşturulmadı") ve faturasız takip sayısı / tutarı yazar. Dönem değişince seçim temizlenir.

## Özet ve sekmeler
Özet kutuları: **Takip** (HBYS tutarı) · **Faturalanan** · **Faturasız Takip** (hazır sayısı, tutar) · **Medula Tutarı** (fark çıkan fatura sayısı ve fark) · **Kesinti** (iade düşülmüş) · **İtiraz Bekleyen** · **Ödenen** (ödeme tarihi) · **Açık Alacak** (Medula − kesinti − ödenen).

Sekmeler:
- **Huni** — Adım, Takip, Tutar (HBYS), Düşen, Oran çubuğu: takip alınan → hizmeti kabul edilen → çıkışı verilen → faturalanan → döneme alınan → ödenen.
- **Faturasız Takipler** — Tarih, Takip No, Protokol No, Hasta, Bölüm / Hekim, Tutar, Neden, Yapılacak. Nedenler: Hizmet girilmemiş, Hizmet hatalı, Hizmet Medula'ya gitmedi, Takip çıkışı yok, Fatura taslakta, Faturaya hazır.
- **Tutar Farkları** — Protokol No, Hasta, Takip No, Fatura No, HBYS, Medula, Fark, Katılım.
- **Kesintiler** — Protokol No, Hasta, Fatura No, SUT Kodu, Kesinti Kodu, Açıklama, Kesinti, İade, Net, İtiraz (İtiraz edilmedi / İtiraz bekliyor / Kabul · iade / Reddedildi).

## Rakamlar nereden gelir
- Uç: `GET /api/medula/mutabakat` (`MedulaUclari.Mutabakat.cs`); yalnız okur.
- Kaynak Fatura & Dönem ekranıyla aynıdır (`v_medula_takip`, `medula_fatura`, `medula_kesinti`, `medula_donem`); iki ekran aynı dönem için farklı sayı vermez.
- Faturalama Fatura & Dönem uçlarıyla yapılır: toplu (`/fatura/toplu`) ve tek tek (`/basvuru/{id}/fatura-kaydet`).
- Fatura durumları: taslak, kaydedildi, dönemde, dönem kapandı, incelendi, ödendi, iptal.

## Çıktı
"🖨️ Medula Mutabakat İcmali ▾" menüsü "SGK DÖNEM MUTABAKAT TUTANAĞI" başlıklı A4 üretir (huni adımları: Adım, Takip, Tutar). Dosya adı "Medula Mutabakat <yıl-ay>".

## Dikkat edilecekler
- Yalnız "Faturaya hazır" takipler faturalanabilir; diğerlerinde önce Yapılacak sütunundaki eksik giderilmelidir.
- Toplu faturalama Medula'ya gerçek gönderim yapar; onay penceresindeki takip sayısını kontrol edin.
- Ödeme girilmemişse Ödenen 0, Açık Alacak tüm Medula tutarı − kesinti olarak görünür.

## Örnek sorular
- Geçen ay faturalanmadan kalan takipler hangileri, neden?
- Faturaya hazır takipleri toplu nasıl faturalarım?
- HBYS ile Medula tutarı hangi faturalarda tutmuyor?
- Bu dönemde ne kadar kesinti yedik, itiraz bekleyen var mı?
- SGK'dan açık alacağımız ne kadar?
