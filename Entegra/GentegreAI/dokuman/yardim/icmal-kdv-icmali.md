---
id: icmal-kdv-icmali
baslik: KDV İcmali
modul: finans
ekran: kdv-icmali
rota: /kdv-icmali
surec: icmal
roller: muhasebe, on_muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: muhasebe.kdv_icmali
erisim: kullanici
ozet: Beyandan önce KDV kontrolü — seçilen ayda mükellefin (VKN) satış ve alış belgelerinden orana göre hesaplanan ve indirilecek KDV'yi, tevkifatı, istisnaları, iadeleri, Ba/Bs ön listesini, düzeltilmesi gereken belgeleri ve muhasebedeki 191 / 391 / 360 hareketiyle karşılaştırmayı gösterir; tahmini ödenecek KDV'yi devreden KDV ile birlikte hesaplar. Beyanname değildir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu ay ne kadar KDV ödeyeceğiz, beyandan önce düzeltmemiz gereken belge var mı, müşavire ne göndereceğiz?" sorusunu cevaplar. Muhasebe ve mali müşavir için ön kontroldür; **beyanname değildir** — beyan müşavirin programında hazırlanır. Rakamlar belgenin kayıtlı KDV toplamından gelir; ekran yeniden hesaplamaz.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" listesinden ayı seçin (son 24 ay; kapanmış aylar "(kapalı)" yazar). Yanındaki rozet ayın açık mı kapalı mı olduğunu gösterir.
- **Mükellef seçmek** — "🏢 Mükellef" listesi şubelerin vergi numarasına (VKN) göre gruplanır; aynı VKN'li şubeler tek icmaldir.
- **Şubeye göre süzmek** — mükellefin birden çok şubesi varsa "Şube" listesinden birini seçin (varsayılan Tümü).
- **Belge türüne ve e-Belge türüne göre süzmek** — "📑 Belge türü" (Tümü / Fatura / Fiş) ve şeritteki Hepsi / e-Fatura / e-Arşiv / Kağıt düğmeleri. Süzgeç açıkken "süzgeçli" rozeti çıkar: tahmin mükellefin bütün belgeleri değildir.
- **Taslakları ön izlemek** — "Taslaklar dahil (ön izleme)" kutusu; taslaklar Oran Bazında sekmesinde ayrı renkte ayrı tablo olarak ve Hesap özetinde ayrı satırda görünür, ödenecek KDV'ye eklenmez.
- **Devreden KDV girmek** — muhasebe kullanılmıyorsa Oran Bazında › Hesap özeti › "Önceki dönemden devreden" satırındaki "✎ gir / değiştir" ile ayın başındaki devreden KDV'yi ve açıklamasını yazıp "💾 Kaydet"e basın. Dönem başına bir değerdir ve işlem günlüğüne yazılır. Muhasebe kullanılıyorsa devreden 190 hesabının bakiyesinden gelir, elle girilmez.
- **Belgeyi açmak** — Tevkifat, İadeler, Uyarılar ve Muhasebe Bağı satırına çift tıklayın ya da satırı seçip "📄 Seçili belgeyi aç"a basın; belge numarası ve öneri bağlantıları da belge kartını açar.
- **Cari kartını açmak** — Ba / Bs satırına çift tıklayın; VKN eksik uyarısındaki "cari kartına vergi no gir" bağlantısı da kartı açar.
- **Uyarılara gitmek** — şeritteki kırmızı "Uyarı: N" rozetine tıklayın.
- **Çıktı almak** — "🖨️ KDV İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.
- **Müşavire döküm göndermek** — "Müşavir dökümü ▾" menüsünden Gönder › Excel: dönemin bütün belgeleri belge belge (taraf, VKN, e-Belge türü, oran, matrah, KDV, tevkifat).
- **İlgili ekranlara geçmek** — "📨 Fatura / e-Belge İcmali" ve "📕 Muhasebe Fişi Listesi" düğmeleri.

## Ekrana giriş
- Sol menü **Muhasebe › İcmaller › KDV İcmali** (`/kdv-icmali`).
- `muhasebe.kdv_icmali` görme yetkisi gerekir. Devreden KDV'yi elle girmek için ayrıca **Muhasebe Fişi** (`muhasebe_fis`) değiştirme yetkisi ve şubede yazma hakkı gerekir.

## Süzgeçler
- **Dönem** (ay), **Mükellef** (VKN), **Şube** (yalnız seçili mükellefin, yalnız kullanıcının şubeleri), **Belge türü**, **e-Belge türü**, **Taslaklar dahil**.

## Özet ve sekmeler
- Kutular: Hesaplanan KDV (satış matrahı), İndirilecek KDV (alış + gider matrahı), Tevkifat (alıcı olarak KDV-2), Ödenecek KDV (tahmini; devreden ya da sonraki döneme devreden), İstisna Matrahı (kodlar), İade KDV, Belge (satış · alış), Uyarı.
- **Oran Bazında:** satış (oran, belge, matrah, KDV, pay) ve alış (oran, belge, matrah, KDV, tevkif edilen) tabloları; Hesap özeti — hesaplanan, satış iadeleri, indirilecek, alış iadeleri, KDV-2 ve indirimi, devreden, ödenecek (tahmini).
- **Tevkifat:** tevkifatlı belgeler — tevkifat kodu, oran (7/10 gibi), matrah, KDV, tevkif edilen, ödenen KDV.
- **İstisnalar:** istisna / muafiyet kodu başına belge ve matrah; dövizli belgelerde döviz rozeti; kodsuz %0 satır ayrıca.
- **İadeler:** satış ve alış iadesi faturaları, iade edilen belge (bağsızsa rozet).
- **Ba / Bs Ön Kontrol:** sınırı aşan taraflar — form, VKN / TCKN, belge, KDV hariç tutar, durum.
- **Uyarılar:** GİB'e gitmemiş / reddedilmiş / hatalı e-Belge, e-Belgesi hazırlanmamış fatura, KDV'siz ve kodsuz satır, kartındaki KDV oranından farklı satır, fatura tarihi önceki ay olup bu ay kaydedilen alış, bağsız iade, Ba/Bs için eksik vergi numarası; mavi satırlar bilgi (aktarılan tahakkuk, icmale girmeyen taslaklar).
- **Muhasebe Bağı:** 391 / 191 / 360 için icmal tutarı ile belgeden üretilmiş fişlerin dönem hareketi, fark ve fişi olmayan belgeler.
- **🖨 Önizleme (A4):** yazdırılacak icmal.

## Rakamlar nereden gelir
- Dönemde **belge (fatura) tarihi** düşen kesin satış faturası / fişi ve alış faturası / fişi ile aynı türlerin iadeleri. İrsaliye sayılmaz. Delphi'den satırsız aktarılan tahakkuklar KDV ayrıntısı taşımadığı için girmez.
- KDV ve matrah belgenin kayıtlı dip toplamından (fn_belge_diptoplam). Oran kırılımında belge toplamı satırlara dağıtılır; kırılımın toplamı belge toplamına eşittir. Dövizli belge belge kuruyla TL'dir.
- Tevkifat kodu ve oranı satırdan (yoksa belgenin e-Fatura bilgisinden); tevkif edilen = satır KDV'si × oran (e-Fatura ile aynı). Alışta KDV-2 hem beyan edilir hem aynı dönemde indirilir; satışta alıcının tevkif ettiği kısım hesaplanan KDV'den düşülür.
- İstisna kodu e-Fatura ile aynı öncelikle bulunur: istisna / ihraç kayıtlı faturasında başlık kodu, sonra satırın muafiyet kodu, ihracat faturasında 301.
- Ödenecek = hesaplanan − satış iadeleri − indirilecek + alış iadeleri + KDV-2 − KDV-2 indirimi − devreden. Sonuç eksiyse ödenecek 0, fark sonraki döneme devreder.
- Devreden KDV muhasebedeki **190** hesabının dönem başı bakiyesinden; mükellefin şubelerinde KDV hesaplarına fiş yoksa elle girilen değerden.
- Ba / Bs: yalnız faturalar; Bs = satış faturaları + alış iadeleri, Ba = alış faturaları + satış iadeleri; sınır Genel Ayarlar › Muhasebe › Ba/Bs sınırı (boşsa 5.000 TL).
- Kapanmış dönem: Genel Ayarlar'daki dönem kapanış tarihi (yoksa içinde bulunulan aydan önceki aylar kapalı sayılır) ya da muhasebede kilitlenmiş ay.

## Çıktı
- **KDV İcmali (A4):** mükellef, VKN, dönem; orana göre satış matrahı / hesaplanan ve alış matrahı / indirilecek; altta hesaplanan, iadeler, indirilecek, devreden ve tahmini ödenecek; imza alanları (Hazırlayan, Mali Müşavir).
- **Müşavir dökümü:** dönemin belgeleri tek tek; Excel olarak gönderilir.

## Dikkat edilecekler
- Ekran beyanname üretmez; rakam tahmindir.
- Mükellef VKN'ye göredir: şube kartında vergi numarası boşsa şube "(VKN yok)" mükellefi altında toplanır ve devreden elle girilemez.
- Birden çok VKN varken şubesi boş belge hiçbir icmale girmez; Uyarılar'da sayısı görünür.
- Fatura tarihi önceki ay olan alış, kaydı bu ay yapılsa da o ayın icmalindedir; o ay kapanmışsa Uyarılar'da "dönemi kapanmış, bu aya indirilecek" yazar ve tutarı Hesap özetinde bilgi olarak görünür (tahmine katılmaz).
- Taslaklar ödenecek KDV'ye hiçbir zaman eklenmez.
- Stopaj (serbest meslek makbuzu, muhtasar) bu icmalde yoktur; yalnız KDV.
- Muhasebe Bağı'nda elle ya da KDV mahsup fişleri "Diğer fişler" sütunundadır, karşılaştırmaya girmez.
- Cari kayıt kapsamınız sınırlıysa "kapsam sınırlı" rozeti çıkar; toplamlar yalnız erişebildiğiniz carilerin belgeleridir.

## Örnek sorular
- Bu ay ne kadar KDV ödeyeceğiz?
- Beyandan önce düzeltmemiz gereken fatura var mı?
- GİB'e gönderilmemiş e-Arşiv faturaları hangileri?
- Tevkifatlı alışlarımızın KDV-2 tutarı ne kadar?
- Önceki dönemden devreden KDV'yi nereye girerim?
- Ba / Bs formunda vergi numarası eksik cari var mı?
- Muhasebedeki 191 bakiyesi icmalle neden tutmuyor?
