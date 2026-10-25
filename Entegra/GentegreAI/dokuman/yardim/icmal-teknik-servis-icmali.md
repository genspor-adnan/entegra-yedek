---
id: icmal-teknik-servis-icmali
baslik: Teknik Servis İcmali
modul: servis
ekran: teknik-servis-icmali
rota: /teknik-servis-icmali
surec: icmal
roller: servis, yonetim, muhasebe
dil: tr
surum: 1
urun_modu: 0
yetki: servis.icmali
erisim: kullanici
ozet: Seçilen dönemde açılan servis çağrılarının kapsamını (ücretli / sözleşme / garanti), ilk yanıt ve çözüm süresini, SLA ihlalini, ilk ziyarette çözüm ve tekrar arıza oranını, servis cirosu ve maliyetini; teknisyen, cihaz / model, arıza, parça, emanet cihaz, sözleşme kârlılığı ve faturalanmamış iş tablolarını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Taahhüdümüzü tutuyor muyuz, hangi teknisyen ilk gidişte çözüyor, hangi cihaz sık arızalanıyor, sözleşmeler kâr ediyor mu, faturalanmayı unuttuğumuz iş var mı?" sorularını cevaplar. Servis müdürü ve yönetim için. Üç katman korunur: çağrı (SLA ölçülür) → iş emri (iş ve tutar) → ziyaret (bir gidiş). Rakamlar sunucuda hesaplanır; ekran toplamaz.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Çağrı açılışı" başlangıç ve bitiş tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Bu yıl seçin (varsayılan bu ayın başı – bugün). Dönem çağrının açılış tarihine göredir.
- **Şube, teknisyen, müşteri ve marka / modele göre süzmek** — şeritteki "🏢 Şube", "👷 Teknisyen", "👥 Müşteri" ve "🏷 Marka / model" listeleri.
- **Kapsam seçmek** — "Tüm kapsam / Ücretli / Sözleşme / Üretici garantisi / Kendi garantimiz" düğmeleri.
- **İç ya da dış servisi görmek** — "Dış (müşteri) / İç (demirbaş) / İkisi" düğmeleri. Varsayılan ERP'de dış, HBYS'de iç servistir.
- **SLA'yı aşan açık çağrılara gitmek** — şeritteki kırmızı "SLA aşan açık çağrı" rozetine tıklayın; SLA sekmesi açılır.
- **Teknisyenin ziyaretlerini görmek** — Teknisyen sekmesinde satıra tıklayın; ziyarete çift tıklayınca iş emri kartı açılır.
- **Bir marka / modele odaklanmak** — Cihaz / Model sekmesinde satıra çift tıklayın; bütün ekran o marka / modelle süzülür.
- **Çağrı, iş emri, sözleşme ve emanet kartını açmak** — SLA'yı aşan çağrıya çift tık (çağrı kartı), iş emri numarasına tıklama ya da faturalanmamış işe çift tık (iş emri kartı), sözleşme numarasına tıklama (sözleşme kartı), emanete çift tık (emanet kartı).
- **İlgili ekranlara geçmek** — üstteki "📅 Çizelge", "📑 Sözleşme Listesi" ve "🔧 İş Emiri Listesi" düğmeleri.
- **Çıktı almak** — "🖨️ Teknik Servis İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.

## Ekrana giriş
- Sol menü **Teknik Servis › İcmaller › Teknik Servis İcmali** (`/teknik-servis-icmali`).
- `servis.icmali` görme yetkisi gerekir (servis iş emri listesini gören rollere verilmiştir).

## Süzgeçler
- **Çağrı açılışı** (dönem), **Şube** (yalnız kullanıcının şubeleri), **Teknisyen** (çağrıda ziyareti olan ya da iş emrini yapan), **Müşteri**, **Marka / model** (cihaz parkındaki cihazın), **Kapsam**, **Dış / İç / İkisi**.

## Özet ve sekmeler
- Kutular: Çağrı (kapanan · iptal), Açık Çağrı (parça bekliyor · atanmamış), İlk Yanıt (ortalama ve medyan), Çözüm Süresi, SLA İhlali, İlk Ziyarette Çözüm (ikinci ziyaret sayısı), Tekrar Arıza, Servis Cirosu (işçilik · parça), Servis Maliyeti (sözleşme · garanti · iç iş).
- **Özet:** kapsama göre çağrı, iş emri, işçilik, parça, diğer, toplam ve kime yazıldığı; çağrı durumu (şu an açık olanlar, SLA aşanlar); öncelik bazında ilk yanıt, çözüm ve SLA ihlali.
- **Teknisyen:** ziyaret, çözülen çağrı, ilk ziyarette çözüm, işçilik saati, yol, SLA ihlali, tekrar arıza, müşteri memnuniyeti ortalaması (1-5), ciro, imzasız ziyaret.
- **Cihaz / Model:** parktaki cihaz, çağrı, arıza / cihaz oranı, tekrar arıza, en sık arıza, ortalama çözüm, parça tutarı; altında arıza dağılımı (arıza kodu ya da metin).
- **SLA:** sözleşme başına SLA saati, çağrı, ortalama ilk yanıt, ihlal, en uzun gecikme ve durum (uygun / sınırda / ihlal); altında SLA'yı aşan çağrılar.
- **Parça Tüketimi:** parça başına miktar, maliyet, tutar, faturalanan, faturalanmayan, sözleşme / garanti, üreticiye iade (bekliyor / toplandı).
- **Emanet Cihaz:** şu an dışarıdaki emanet cihazlar, kaç gündür dışarıda olduğu ve iş emrinin durumu.
- **Sözleşme Kârlılığı:** yıllık bedel, geçen süre payı, harcanan işçilik / parça / diğer, kâr ve kâr yüzdesi.
- **Faturalanmamış:** kapanmış ama faturası kesilmemiş ücretli ve üretici garantili işler.

## Rakamlar nereden gelir
- Dönem çağrının açılışına göredir; çağrının iş emirleri ve ziyaretleri tarihinden bağımsız onunla gelir. Çağrısı olmayan iş emri (iç iş, elle açılmış dış iş) kendi çağrısı sayılır: açılış = bildirim, ilk yanıt = ilk müdahale, kapanış = tamamlanma; SLA'sı yoktur.
- "Çağrı durumu", "Açık Çağrı", "Emanet Cihaz" ve "Faturalanmamış" dönemden bağımsız, şu anki durumdur.
- Tutarlar iş emrinin işçilik / parça / diğer tutarıdır (ziyaret tutarları ve parça satırlarından otomatik toplanır), KDV hariç. Tutar hiçbir kapsamda sıfırlanmaz; yalnız kime yazıldığı değişir.
- **Ciro** = ücretli + üretici garantisi (ikisi de faturalanır). Sözleşme, kendi garantimiz ve iç iş ciro değildir, "Servis Maliyeti"nde görünür.
- **SLA** çağrının açılışında başlar (sözleşmenin SLA saati, yoksa kurum varsayılanı). İhlal: ilk yanıt SLA bitişinden sonra ya da hâlâ yanıt yok ve süre geçti. Sözleşme durumu: ihlal yoksa uygun, çağrıların %10'undan azında sınırda, fazlasında ihlal.
- **İlk ziyarette çözüm:** çağrının sonuçlanan ilk ziyareti "çözüldü" ise. SLA ihlali ilk ziyareti yapan teknisyene yazılır.
- **Tekrar arıza:** aynı cihazın (cihaz parkı) önceki çağrısının kapanışından sonra belirli gün içinde açılan yeni çağrı — farklı arıza da olsa. Süre Genel Ayarlar'daki "servis.tekrar_ariza_gun" (boşsa 30 gün). Teknisyen tablosunda önceki çağrıyı kapatan teknisyene yazılır.
- **Arıza:** iş emrinde arıza kodu seçilmişse koddan; kodu olmayan eski kayıtlar arıza metninden gruplanır ("metin" rozeti — serbest metin olduğu için öneri niteliğindedir).
- **Teknisyen cirosu:** ücretli ve üretici garantisi işlerde ziyaretin işçiliği + o ziyarette takılan parça. Ziyarete bağlanmamış parça ve "diğer" tutar teknisyene yazılmaz.
- **Memnuniyet:** ziyarette verilen 1-5 puanın ortalaması; puan verilmemiş ziyaret ortalamaya girmez.
- **Sözleşme kârlılığı** sözleşmenin başından bugünedir: geçen süre payı = yıllık bedel × geçen gün / sözleşme günü. İşçilik personel saat maliyetiyle (aylık net maaş / 225 × ziyaretin işçilik saati); teknisyenin maaşı ya da ziyaretin saati girilmemişse tarife (ziyaret tutarı) kullanılır ve "tarife" rozetiyle belirtilir. Parça ve diğer iş emrinin tutarıdır.
- **Parça maliyeti** stok kartının ortalama maliyetiyledir; stoğa bağlı olmayan parçada maliyet görünmez.

## Çıktı
A4: dönem, şube ve iç / dış; çağrı, iş emri, ziyaret, teknisyen ve sözleşme sayısı; ilk yanıt, SLA ihlali, ilk ziyarette çözüm ve tekrar arıza; teknisyen başına ziyaret, ilk ziyarette çözüm, SLA ihlali, memnuniyet ve ciro; altta işçilik, parça, servis maliyeti, faturalanmamış ve servis cirosu; imza alanları (Hazırlayan, Servis Müdürü).

## Dikkat edilecekler
- İmzasız ziyaret kapanmaz; gerekçe yazılarak kapatılan ziyaretler "imzasız" sayılır.
- Emanet cihaz iade edilmeden iş emri kapanmaz; iş emri çözüldüğü hâlde emanet dönmediyse sarı rozet görünür.
- Üretici garantisinde sökülen parça toplanmazsa üretici alacağı reddedebilir; 15 günü geçen "bekliyor" kırmızıdır.
- Faturalama ayrı adımdır; bu ekran fatura kesmez, faturalanmamış işleri listeler.

## Örnek sorular
- Bu ay SLA'yı kaç çağrıda aştık, hangisi hâlâ açık?
- Hangi teknisyen ilk gidişte daha çok çözüyor?
- Hangi cihaz modeli en sık arızalanıyor?
- Aynı cihaz 30 gün içinde kaç kez yeniden arızalandı?
- Bakım sözleşmelerimizden hangisi zarar ediyor?
- Kapanmış ama faturası kesilmemiş servis işi var mı?
- Teknisyenlerin müşteri memnuniyet puanı ortalaması nedir?
