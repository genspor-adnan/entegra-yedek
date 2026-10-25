---
id: icmal-uretim-icmali
baslik: Üretim İcmali
modul: uretim
ekran: uretim-icmali
rota: /uretim-icmali
surec: icmal
roller: uretim, planlama, fabrika, maliyet
dil: tr
surum: 1
urun_modu: 0
yetki: uretim.icmali
erisim: kullanici
ozet: Üretim emirlerinin plan / gerçekleşen durumunu, sarf ve fire sapmasını, plan ile gerçek birim maliyeti, iş merkezlerinin önümüzdeki haftalardaki doluluğunu ve açık emirler için eksik hammaddeyi tek ekranda gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Planı tutturuyor muyuz, fire ve sarf sapması nerede, birim maliyet plandan ne kadar saptı, önümüzdeki haftalarda hangi iş merkezi dolu, hangi hammadde eksik?" sorularını cevaplar. Üretim planlama, fabrika müdürü ve maliyet muhasebesinin ekranıdır. Emir başlatma, sarf ve mamul bildirimi bu ekrandan yapılmaz; ekran yalnız gösterir, emre ve satınalma talebine götürür.

## Bu ekranda neler yapabilirsiniz
- **Dönemi ve kapsamı süzmek** — "📅 Plan başlangıcı" (iki tarih), "🏢 Şube", "🏬 Depo" (sarf ya da mamul deposu), "⚙ İş merkezi", "📦 Mamul".
- **Durum ve türe göre daraltmak** — "Planlı / Üretimde / Kısmi / Tamamlandı / Hepsi" ve "Tüm türler / Siparişe / Stoğa / Fason" düğmeleri.
- **Emri açmak** — Emirler sekmesinde satıra tıklayıp "🏭 Seçili emri aç"a basın ya da satıra çift tıklayın; emir kendi sekmesinde açılır. Alt emrin "Kaynak" hücresi ana emri, siparişe üretimde satış siparişini açar.
- **Sarf sapmasını görmek** — "Sarf" sekmesi: ağaca göre beklenen ile gerçek tüketim; eşiği aşanlar kırmızı ve üstte.
- **Fireyi incelemek** — "Fire" sekmesi: mamul başına fire %, ağaç hedefi, fire tutarı, en sık neden ve fire deposu.
- **Maliyeti karşılaştırmak** — "Maliyet" sekmesi: malzeme, işçilik, GÜG, fason, toplam, birim, plan birim ve sapma; kapanan emirde kapanış tarihi.
- **İş merkezi doluluğuna bakmak** — "İş Merkezi Yükü" sekmesi: önümüzdeki 4 haftanın plan saati / kapasite oranı; hücreye tıklayınca o haftanın operasyonları altta listelenir.
- **Eksik hammaddeyi görmek ve talep açmak** — "Malzeme İhtiyacı" sekmesi: kalan ihtiyaç, rezerve, eldeki, yoldaki, eksik ve ilk gereken tarih. Satırdaki "Talep aç" ya da araç çubuğundaki "📝 Eksik hammadde için talep aç" depo başına TASLAK satınalma talebi açar (onaya siz gönderirsiniz); `satinalma.talep` ekleme yetkisi gerekir.
- **İlgili ekranlara geçmek** — "🌳 Ürün Ağacı Listesi", "⚙ İş Merkezi Listesi", "⚠ Kritik Stok İcmali"; bileşen ve mamul adına tıklayınca stok kartı açılır.
- **Çıktı almak** — "🖨️ Üretim İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; "🖨 Önizleme (A4)" sekmesi aynı belgeyi ekranda gösterir.

## Ekrana giriş
- Sol menü **Üretim › İcmaller › Üretim İcmali** (`/uretim-icmali`).
- `uretim.icmali` görme yetkisi gerekir. Emri açmak için `uretim` görme, talep açmak için `satinalma.talep` ekleme yetkisi ayrıca gerekir.
- Dönem verilmezse içinde bulunulan ayın başı ile sonu kullanılır.

## Süzgeçler
- **Plan başlangıcı**: emrin plan başlangıç tarihi (yoksa oluşturma tarihi) bu aralıkta olan emirler. Emirler, Sarf, Fire, Maliyet sekmeleri ve özet kutuları bu dönemi kullanır.
- **Şube**, **Depo**, **İş merkezi**, **Mamul**, **Durum**, **Tür**.
- **İş Merkezi Yükü** ve **Malzeme İhtiyacı** ileriye bakar: dönem ve durum seçiminden bağımsız olarak bütün açık emirleri (taslak – kısmi) şube, depo, iş merkezi, mamul ve tür süzgeciyle hesaplar.

## Özet ve sekmeler
- Kutular: Emir (siparişe / stoğa / fason), Açık Emir (üretimde / kısmi / planlı), Plan / Gerçekleşen, Fire, Maliyet Sapması (kapanan emirler), Doluluk, Termini Geçen, Eksik Hammadde.
- **Kutular ve toplam satırları yalnız ana emirleri sayar.** Alt emirler (yarı mamul) ayrı satır olarak ana emrin altında girintili gösterilir ama özete girmez; yarı mamul iki kez sayılmaz.
- **Emirler**, **Sarf**, **Fire**, **Maliyet**, **İş Merkezi Yükü**, **Malzeme İhtiyacı**, **Önizleme (A4)**.

## Rakamlar nereden gelir
- Kaynak üretim emri ve satırları, operasyonlar, zaman kayıtları ve maliyet kapanışıdır. Ürün ağacı emir açılırken emre kopyalanır; hesap emrin kendi satırlarından yapılır, ağaç sonradan değişse emir bozulmaz.
- **Kalan** = plan − üretilen − fire. **Gecikme**: açık emirde bugün − termin; tamamlanmış emirde bitiş − termin.
- **Sarf**: Gerekli = birim ihtiyaç × plan × (1 + fire %). Beklenen = gerekli × üretilen / plan; Fark = sarf edilen − beklenen. Tek seferde sarf edilmiş ve hâlâ üretimdeki emirde fark "sürüyor" görünür (malzemenin hepsi başta çıkar). Kırmızı eşik Genel Ayarlar › `uretim.sapma_sarf_yuzde` (boşsa %5).
- **Fire** = emrin fire adedi; Fire % = fire / (üretilen + fire). Ağaç hedefi = emir satırlarının ağaçtan gelen fire %'si (gerekliyle ağırlıklı). Kırmızı: hedefin `uretim.fire_hedef_kat` katı (boşsa 1,5) aşılınca. Fire tutarı = fire adedi × kapanıştaki birim maliyet (kapanış yoksa plan birim maliyetle, "~" işaretli). Fire maliyeti malzemenin içindedir, ayrıca eklenmez.
- **Maliyet**: kapanan emirde maliyet kapanış kaydı (tarihli, donmuş); açık emirde canlı toplam. İşçilik = zaman kaydı saati × saat ücreti. GÜG ayrı dağıtılmaz, iş merkezi saat ücretine dahildir; ayrı GÜG yazılmamışsa sütun 0 ve "ücrete dahil" rozetlidir. Sapma = (birim − plan birim) / plan birim; plan maliyet emir açılırken ağaçtan donar. Kırmızı eşik `uretim.sapma_maliyet_yuzde` (boşsa ±%5).
- **Fason**: maliyet fason giriş irsaliyesi / faturası geldiğinde kesinleşir. Giriş belgesi gelmemiş açık fason emir "fasonda" rozetiyle görünür, canlı maliyet göstermez ve maliyet toplamlarına girmez. Kapanışta fason tutarı yazılmamış ama giriş belgesi gelmişse belge tutarı fason sütununa eklenir ("belge" rozeti).
- **İş merkezi yükü**: bitmemiş operasyonların kalan plan saati (plan − gerçek) başlangıç – bitiş arasındaki iş günlerine eşit yayılır; geçmişte kalan yük bu haftaya düşer. Kapasite = günlük kapasite × 5 iş günü. Duruş = bu ayın duruş zaman kayıtları. %100 üstü kırmızı.
- **Malzeme ihtiyacı**: Kalan ihtiyaç = gerekli − sarf edilen (alt emirle üretilen yarı mamul hariç). Eldeki = sarf deposundaki kalan (Kritik Stok İcmali ile aynı stok bakiyesi) − SKT'si geçmiş lot − başka kayıtların rezervi. Emrin kendi rezervi düşülmez, önce kendi satırını karşılar; kalan serbest stok ilk gereken tarihe (plan başlangıcı) göre sırayla dağıtılır. Yoldaki = açık alış siparişi. Eksik = karşılanamayan − yoldaki.

## Çıktı
A4: dönem, şube, emir ve mamul sayısı, plan / gerçekleşme oranı; mamul başına plan, üretilen, fire %, birim maliyet (kapanan emirlerden) ve sapma; dipte malzeme, işçilik, fason, fire (malzemenin içinde) ve üretim maliyeti toplamı; üretim planlama ve fabrika müdürü imza alanları.

## Dikkat edilecekler
- Sapma ve fire eşikleri Genel Ayarlar'dan değişir: `uretim.sapma_maliyet_yuzde`, `uretim.sapma_sarf_yuzde`, `uretim.fire_hedef_kat`. Ondalık nokta ile yazılır (`1.5`); bozuk ya da boş değer varsayılana düşer.
- Talep depo başına açılır; açık talebi olan kalem atlanır, satırda "Talep …" rozeti görünür. Sarf deposu seçilmemiş emir satırı için talep açılamaz.
- İptal edilen emir icmale girmez. Ekran en çok 3000 emir gösterir; daha fazlası için süzgeci daraltın.
- Maliyet kapanışı yapılmamış emirde birim maliyet "canlı" görünür; kesin birim için emirde "Maliyet Kapat" gerekir.

## Örnek sorular
- Bu ay üretim planını ne kadar tutturduk?
- Hangi mamulde fire hedefin üstünde?
- Birim maliyet plandan neden saptı?
- Önümüzdeki hafta hangi iş merkezi dolu?
- Açık emirler için hangi hammadde eksik, nasıl talep açarım?
- Alt emirler özete neden sayılmıyor?
