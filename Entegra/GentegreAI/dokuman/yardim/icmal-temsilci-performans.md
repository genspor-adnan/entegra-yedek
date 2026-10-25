---
id: icmal-temsilci-performans
baslik: Temsilci Performans İcmali
modul: satis
ekran: temsilci-performans
rota: /temsilci-performans
surec: icmal
roller: satis, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: satis.temsilci_performans
erisim: kullanici
ozet: Satış temsilcisi bazında ciro, brüt kâr, tahsilat, vadesi geçen alacak, yeni müşteri ve teklifi; hedef / gerçekleşen ve dönem sonu tahmini, son 6 ayın gidişatı, müşteri portföyü, tahsilat kalitesi, CRM aktivitesi ve Prim Planı hakedişlerini gösterir; yetkili kullanıcı aylık hedefleri buradan tanımlar.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi temsilci hedefinde, kim kârlı satıyor, kimin müşterisi ödemiyor, prim ne çıkıyor?" sorusunu cevaplar. Satış müdürü ve yönetimin ay sonunda baktığı ekrandır. Her rakam kendi icmalinin kuralıyla hesaplanır: ciro ve brüt kâr Kârlılık İcmali, vade ve ödeme davranışı Cari İcmali ile Müşteri Risk İcmali, prim Prim Planı — ikinci bir hesap yoktur.

## Bu ekranda neler yapabilirsiniz
- **Temsilcileri karşılaştırmak** — "Özet" sekmesi: ciro, brüt kâr, marj, tahsilat, vadesi geçen, aktif ve yeni müşteri, ortalama iskonto, teklif sayısı ve ciro hedefinin gerçekleşme çubuğu. Satıra tıklayınca temsilcinin dönemdeki en büyük müşterileri açılır; müşteri adına tıklayınca cari kartı açılır.
- **Hedefi izlemek** — "Hedef / Gerçekleşen" sekmesi: temsilci × ölçüt (ciro, brüt kâr, tahsilat, yeni müşteri) için hedef, gerçekleşen, oran, kalan ve içinde bulunulan dönemde dönem sonu tahmini.
- **Hedef tanımlamak** — araç çubuğundaki "Hedef tanımla…" (yetkisi olan kullanıcıda): ay seçin, temsilci × ölçüt ızgarasına hedefleri yazın; boş bırakılan hücre o ölçütün hedefini kaldırır. Her değişiklik loglanır.
- **Gidişatı görmek** — "Aylık Gidişat" sekmesi: son 6 ayın net cirosu ve geçen yılın aynı ayına göre değişim.
- **Portföyü incelemek** — "Müşteri Portföyü" sekmesi: temsilcinin müşteri sayısı, bu dönem alan, 90 gündür almayan, son 12 ayda kaybedilen, ilk 5 müşterinin payı ve limit aşan müşteri.
- **Tahsilat kalitesini görmek** — "Tahsilat Kalitesi" sekmesi: tahsilat, ortalama tahsil süresi ve gecikme, zamanında ödeme oranı, vadesi geçen, 90 günü aşan, karşılıksız evrak ve A–D skoru.
- **Aktiviteyi görmek** — "Aktivite" sekmesi: görüşme, toplantı, görev, teklif, açık ve geciken görevler, temas başına ciro.
- **Prim hakedişini görmek** — "Prim" sekmesi: Prim Planı'nın yazdığı hakediş satırları durumlarına göre (taslak, kesin, onaylı, ödendi).

## Ekrana giriş
Satış › İcmaller › Temsilci Performans İcmali. Ekranı görmek için `satis.temsilci_performans`, hedef tanımlamak için `satis.temsilci_hedef` yetkisi gerekir. Ekran yalnız ERP kurulumunda vardır.

## Süzgeçler
- **Dönem** — Ay / Çeyrek / Yıl seçimi ve ◀ ▶ ile önceki / sonraki dönem.
- **Şube** — kullanıcının şubeleriyle sınırlıdır.
- **İadeler düşülsün** — işaretliyse iade faturaları ciro ve maliyetten düşülür (varsayılan).

## Rakamlar nereden gelir
- **Temsilci faturadan alınır** — faturadaki satıcı. Cari başka temsilciye geçse de eski faturalar eski temsilcide kalır. Faturasında temsilci olmayan satış "(temsilcisiz)" satırında görünür: toplama girer, prime ve hedefe girmez. Şeritteki sarı rozet bu tutarı gösterir.
- **Ciro ve brüt kâr** — Kârlılık İcmali ile aynı: kesin satış faturası / fişi, KDV hariç dip toplam, satış anındaki ortalama maliyet.
- **Tahsilat** — dönem faturalarının (KDV dahil) cari hareketinde açık kalmayan kısmı (FIFO). Kârlılık İcmali'nin temsilci sekmesindeki "tahsil edilen" ile aynıdır.
- **Yeni müşteri** — ilk satış faturası bu dönemde olan cari; o ilk faturanın temsilcisine sayılır.
- **Müşterinin temsilcisi** (portföy, vadesi geçen, tahsilat kalitesi) — son 12 ayda ona en çok satış yapan temsilci; son 12 ayda satış yoksa önceki 12 ayın. Vadesi geçen ve 90+ Cari İcmali'nin yaşlandırmasıdır; ödeme süresi ve skor Müşteri Risk İcmali'nin kurallarıdır.
- **Aktivite** — görev kayıtlarından (sorumlu = temsilci); teklif sayısı dönemde verilen teklifler (iptal hariç).
- **Prim** — Prim Planı motorunun yazdığı hakediş satırları. Prim Planı tanımlı değilse sekme bunu söyler; icmal prim hesaplamaz.

## Çıktı
"Performans İcmali" menüsü A4 icmali yazdırır ya da PDF'e verir: temsilci bazında ciro, brüt kâr, tahsilat, vadesi geçen ve hedef oranı.

## Dikkat edilecekler
- Faturalarda satıcı seçilmiyorsa bütün satış "(temsilcisiz)" görünür; temsilci bazında anlamlı rakam için faturada satıcı seçilmelidir.
- Aktivite sütunları kayıt alışkanlığını ölçer: görev / görüşme girilmiyorsa sıfır görünür.
- Dönem sonu tahmini doğrusaldır (bugüne kadarki hız); yalnız içinde bulunulan dönemde gösterilir.

## Örnek sorular
- "Bu ay hangi temsilci hedefinin altında kaldı?"
- "Hangi temsilcinin müşterilerinde vadesi geçen alacak birikiyor?"
- "Geçen yılın aynı ayına göre kimin cirosu düştü?"
- "Bu çeyrekte temsilcilere ne kadar prim hakedişi yazıldı?"
