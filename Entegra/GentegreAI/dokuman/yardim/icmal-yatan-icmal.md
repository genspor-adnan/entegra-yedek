---
id: icmal-yatan-icmal
baslik: Yatan Hasta İcmali
modul: yatan
ekran: yatan-icmal
rota: /yatan-icmal
surec: icmal
roller: servis_sorumlusu, bashekim, faturalama, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: yatan.donem_icmal
erisim: kullanici
ozet: Seçilen dönemde servis başına yatış, taburcu, hasta-gün, yatak doluluğu, ortalama yatış süresi (ALOS), ciro ve açık hesapları; haftalık doluluk ile tanı / doktor kırılımlarını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu dönemde servislerimiz ne kadar dolu çalıştı, kaç yatış / taburcu oldu, hastalar ortalama kaç gün yattı, ciro ne kadar ve hangi taburcuların hesabı hâlâ açık?" sorusunu cevaplar. Servis sorumluları, faturalama ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Servise göre süzmek** — "🏥 Servis" listesi.
- **Sekmeler arasında geçmek** — Servisler, Yatışlar, Açık Hesaplar, Yatak Kullanımı, Tanı / Doktor.
- **Servis seçmek** — Servisler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili servisleri basar.
- **Doktor kırılımını açmak** — servis adının yanındaki ▸ işaretine tıklayın; o servisteki doktorların rakamları açılır.
- **Açık hesapları incelemek** — Açık Hesaplar sekmesi; taburcu olmuş ama hesabı kapanmamış yatışlar ve nedeni.
- **Çıktı almak** — "🖨️ Yatan Hasta İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "🗺️ Yatak Panosu" ve "🛏️ Yatan Hastalar" düğmeleri.

## Ekrana giriş
- Sol menü **Yatan Hasta › Yatan Hasta İcmali** (`/yatan-icmal`, yalnız HBYS modu).
- `yatan.donem_icmal` görme yetkisi gerekir (haklar ilk tanımda yatış hizmet icmali yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: döneme dokunan (dönem içinde yatan, giren ya da çıkan) yatışlar alınır. Varsayılan bir önceki takvim ayı.
- **Servis** listesi dönemde yatışı olan servislerden dolar. Yalnız aktif şubenin kayıtları; iptal yatış hariç.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır.
- Şeritte rozetler: "N açık hesaplı taburcu", "N yatış 30+ gün".

## Özet ve sekmeler
Özet kutuları: **Yatış / Taburcu** (şu an yatan) · **Yatak Doluluğu** (hasta-gün / yatak-gün; %85 ve üstü kırmızı) · **Ort. Yatış Günü** (ALOS) · **Hasta-Gün** · **Ciro** (gün başı) · **Kurum / Hasta Payı** · **Açık Hesap** · **Yatak Devir Hızı** (30 gün içinde tekrar yatış sayısı).

Sekmeler:
- **Servisler** — Yatak, Yatış, Taburcu, Hasta-Gün, Doluluk, ALOS, Ciro, Gün Başı, Kurum Payı, Açık Hesap; bugün kapalı yatak varsa etiket.
- **Yatışlar** — Protokol No, Hasta, Servis, Doktor, Yatış, Taburcu, Gün, Ödeyen, Tutar, Durum (yatıyor / açık / kapandı); 30 gün içinde tekrar yatış etiketi.
- **Açık Hesaplar** — taburcu tarihi, bekleme, yatış toplamı, faturalanmamış tutar, neden.
- **Yatak Kullanımı** — servis başına haftalık doluluk, dönem doluluğu, boş yatak-gün, bugün kapalı yatak.
- **Tanı / Doktor** — tanı (ICD) başına yatış, ALOS, ortalama tutar; doktor başına yatış, taburcu, hasta-gün, ALOS, ciro.

## Rakamlar nereden gelir
- Uç: `GET /api/yatan-icmal` (`YatanDonemIcmalUclari.cs`); ekran hesap yapmaz.
- **Ciro** yatış hizmet icmaliyle aynı kuralla: dönem tarihli yatak / refakat tahakkuku + dönemde uygulanan ilaç + dönemde başlayan tetkik / görüntüleme order'ı; fiyat belge kalem fiyatından.
- **Kurum / hasta payı**: ödeyen kurumu olmayan yatışta tamamı hasta payı; kurumu varsa yalnız refakat hasta payıdır (kesin pay Medula'nındır).
- **Hasta-gün** = döneme düşen gece (yatış günü sayılır, çıkış günü sayılmaz; hâlâ yatan için bugün dahil). **Doluluk** = hasta-gün ÷ (aktif yatak × gün). **ALOS** = dönemde taburcu olanların toplam günü ÷ taburcu sayısı (aynı gün çıkış 1 gün).
- **Açık hesap** = dönemde taburcu olmuş ve faturalanmamış tahakkuk / ilacı olan ya da kurumlu olup provizyonu olmayan yatış.

## Çıktı
"YATAN HASTA DÖNEM İCMALİ" başlıklı A4: antet, dönem, yatak ve servis sayısı, servis tablosu (seçim varsa yalnız seçili servisler) ve özet; Hazırlayan / Onaylayan imza alanları. Dosya adı "Yatan Hasta İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Yatak durum geçmişi tutulmadığı için "kapalı yatak" yalnız **bugün** kapalı olanları gösterir; geçmiş dönem doluluğunda kapalı yatak düşülmez.
- Tahsilat yatışa bağlı tutulmadığından "hasta payı tahsil edilmedi" ayrımı yapılmaz.
- Bu ekran yalnız rapor verir; yatış, tahakkuk ya da fatura değiştirmez.

## Örnek sorular
- Geçen ay dahiliye servisinin doluluğu yüzde kaçtı?
- Ortalama yatış süresi (ALOS) nasıl hesaplanıyor?
- Hesabı açık kalan taburcular hangileri, neden?
- Hangi doktorun hasta-günü en yüksek?
- 30 gün içinde tekrar yatan kaç hasta var?
