---
id: icmal-cek-senet-icmali
baslik: Çek / Senet İcmali
modul: finans
ekran: cek-senet-icmali
rota: /cek-senet-icmali
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.cek_senet_icmali
erisim: kullanici
ozet: Alınan ve verilen çek / senetlerin nerede olduğunu (portföy, bankada tahsilde, teminatta, ciro edilmiş), ne zaman paraya döneceğini, hangisinin riskli olduğunu ve kendi verdiğimiz çeklere hesapta karşılık olup olmadığını gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Elimizde ne kadarlık çek / senet var, nerede, ne zaman paraya dönüyor, hangisi riskli; kendi verdiğimiz çeklere ödeme günü hesapta karşılık var mı?" sorusunu cevaplar. Muhasebe ve finans sorumlusunun portföy ekranıdır. Evrakın durumu Çek / Senet Listesi'ndekiyle aynıdır (evrakın son hareketi); icmal kayıt yazmaz.

## Bu ekranda neler yapabilirsiniz
- **Yön ve türü seçmek** — "Alınan (müşteri)", "Verilen (kendi)", "İkisi" ile Portföy listesinde hangi evrakın görüneceğini; "Çek + Senet", "Çek", "Senet" ile bütün ekranın kâğıt türünü seçin.
- **Vade, banka ve para birimine göre süzmek** — "📅 Vade" (vadesi geçmiş, 7 / 30 / 60 / 90 gün içinde, 90 günden sonra), "🏦 Banka" (muhatap banka) ve "💱 Para birimi" (TL karşılığı ya da yalnız o paradaki evrak, kendi tutarıyla).
- **Portföyü incelemek** — Portföy sekmesinde evrak vadeye göre sıralıdır; kalan gün, tutar ve durum rozeti (portföyde, vadesi geçti, bankada tahsilde, teminatta, ciro edildi, karşılıksız / protestolu) görünür. Arama kutusu seri no, keşideci, cari ve bankada arar.
- **Evrakın geçmişini görmek** — satıra tıklayın: nereden ve hangi tahsilatla alındığı, ciro zinciri (keşideci → cari → bize), dövizli evrakta alış kuru, bugünkü kur ve kur farkı, bütün hareketleri açılır. Çift tıklayınca evrak kartı açılır.
- **Bankaya tahsile vermek ya da ciro etmek** — portföydeki alınan evrakı kutucukla seçip "🏦 Seçilenleri bankaya tahsile ver…" ya da "↪ Seçilenleri ciro et…"e basın; Çek / Senet Listesi'ndeki işlem akışı açılır, kaydı orada siz yaparsınız (icmal kayıt yazmaz).
- **Durum akışına bakmak** — "Durum Akışı" sekmesi: bugün hangi durumda kaç evrak ve tutar olduğu; bu ayın hareketleri (alındı, tahsil edildi, ciro edildi, bankaya tahsile verildi, teminata verildi, iade / karşılıksız).
- **Vade takvimini görmek** — "Vade Takvimi" sekmesi: vadesi geçmiş, önümüzdeki iki hafta, ayın kalanı ve sonraki aylar için alınan (giriş) ve verilen (çıkış) evrak ile net.
- **Riski okumak** — "Keşideci / Banka" sekmesi: tek keşidecide yoğunlaşma (pay, 3. kişi keşideci, geçmişte karşılıksız evrakı), muhatap banka dağılımı.
- **Kendi çeklerimizin karşılığını kontrol etmek** — "Verilen Çekler" sekmesi: her evrakın vade günündeki hesap bakiyesi; karşılamıyorsa satır kırmızıdır. Altta banka hesabı başına bugünkü bakiye, 30 gün içinde ödenecek ve sonuç (yeterli / yetersiz).
- **Çıktı almak** — "🖨️ Çek / Senet İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML (A4 portföy listesi; banka teslim bordrosu yerine geçmez).
- **İlgili ekranlara geçmek** — "💳 Tahsilat / Ödeme", "📈 Nakit Akış (Vade)" ve "📋 Çek / Senet Listesi" düğmeleri.

## Ekrana giriş
- Sol menü **Finans › İcmaller › Çek / Senet İcmali** (`/cek-senet-icmali`).
- `finans.cek_senet_icmali` görme yetkisi gerekir (Çek Listesi'ni gören rol bu icmali de görür).
- Kullanıcının yetkili olduğu bütün şubelerin evrakı gelir.

## Süzgeçler
- **Yön** (Portföy listesi), **Tür**, **Vade**, **Banka**, **Para birimi**.

## Özet ve sekmeler
- Kutular: Portföyde (ortalama vade), Bankada Tahsilde (hesap dağılımı), Teminatta, Ciro Edilen (vadesi gelmemiş, rücu riski), 30 Gün İçinde Vadeli, Vadesi Geçmiş (hâlâ portföyde), Karşılıksız / Protestolu, Verilen (ödenecek).
- **Portföy**, **Durum Akışı**, **Vade Takvimi**, **Keşideci / Banka**, **Verilen Çekler**.

## Rakamlar nereden gelir
- Kaynak çek / senet kartları ve hareket defteri (çek / senet ile tahsilat 23 / 24, ödeme 33 / 34; tahsil, ciro, bozdurma, ödendi 51–55). Durum evrakın son hareketidir; Çek / Senet Listesi ile aynı kod ve ad.
- Açık evrak = portföyde, bankada tahsilde, teminatta, karşılıksız ve vadesi gelmemiş ciro edilmiş evrak. Tahsil edilen, ödenen, iade ve iptal evrak gelmez.
- Dövizli evrak bugünkü kurla (döviz kuru tablosu, alış) TL'ye çevrilir: "elimdeki evrak bugün kaç TL eder". Alındığı günün kuru ve kur farkı satır ayrıntısındadır. Kur yoksa evrakın alış kuru kullanılır.
- Ortalama vade, portföydeki evrakın tutara göre ağırlıklı kalan günüdür.
- Dönem hareketleri evrakın kayıt (alış) kuruyla TL'dir.
- Vadede bakiye = banka hesabının bugünkü defter bakiyesi (Hesap Listesi'ndeki bakiye) + o hesapta tahsildeki alınan çeklerden o güne kadar vadesi gelenler − aynı hesaptan o güne kadar ödenecek evrakların toplamı. Evrakta hesap yoksa, bankası ve para birimi aynı tek banka hesabı varsayılır ("varsayılan").

## Çıktı
A4: tarih itibarıyla alınan evrak (portföy, tahsilde, teminatta) — seri no, keşideci, banka, vade, tutar, durum; portföy / tahsilde / teminat ve toplam alınan; hazırlayan ve mali işler imza alanları.

## Dikkat edilecekler
- İcmal kayıt yazmaz: tahsile verme ve ciro Çek / Senet Listesi'ndeki akışla yapılır.
- Karşılıksız çek takibi bu ekranda yalnız durum rozetidir; takip notu, hatırlatma ve ödeme sözü ayrı takip ekranındadır.
- Banka hesabı belli olmayan verilen evrakta vade günündeki bakiye karşılaştırılamaz.
- Vade süzgeci bütün sekmelere uygulanır.

## Örnek sorular
- Portföyümde ne kadarlık çek var?
- Vadesi geçip hâlâ portföyde duran çekler hangileri?
- Önümüzdeki ay hangi çekler paraya dönüyor?
- Verdiğimiz çeklere hesapta karşılık var mı?
- Dövizli çeklerin bugünkü TL karşılığı ne kadar?
- Hangi keşidecide risk yoğunlaşıyor?
