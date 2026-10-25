---
id: icmal-satinalma-icmali
baslik: Satınalma Süreç İcmali
modul: satinalma
ekran: satinalma-icmali
rota: /satinalma-icmali
surec: icmal
roller: satinalma, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: satinalma.icmali
erisim: kullanici
ozet: Seçilen dönemde açılan satınalma taleplerinin talepten ödemeye her aşamadaki sayısını, tutarını, ortalama bekleme süresini ve hedef süreyi; onaycısında, teklifte, mal kabulde ve fatura kontrolünde bekleyen belgeleri (onaycıya hatırlatma ile), tedarikçi karnesini, son 3 alışa göre fiyat değişimini ve teklif tasarrufunu, bütçe kullanımını (taahhüt dahil) ve kritik stoktan açılan talepleri gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Talepler nerede tıkanıyor, kim bekletiyor, hangi tedarikçi güvenilir, fiyatlar ne kadar arttı, bütçenin ne kadarı kaldı?" sorusunu cevaplar. Satınalma sorumlusu, mali işler ve yönetim için. Alış İcmali gerçekleşen alışı (faturayı) anlatır; bu ekran SÜRECİ anlatır — talepten ödemeye her aşamanın süresi ve bekleyeni. Hizmet alımları (bakım, danışmanlık…) da icmale girer ve "hizmet" rozetiyle ayrılır.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Talep tarihi" tarihlerini değiştirin ya da "hazır…" listesinden Bu ay / Geçen ay / Bu yıl / Geçen yıl seçin (varsayılan bu ayın başı – bugün). Dönem talebin tarihidir; sonraki aşamalar o taleplerden izlenir.
- **Süzmek** — "🏢 Şube", "🏬 Talep eden bölüm", "🗂 Kategori" (alt dallarıyla), "🤝 Tedarikçi" ve "💰 Bütçe kalemi" listeleri; şeritteki Hepsi / Birim talebi / Kritik stok / Arıza / Yatırım düğmeleri talebin kaynağına göre süzer.
- **Tıkanan aşamayı bulmak** — Süreç Hunisi sekmesinde bir aşama satırına tıklayın; Bekleyenler sekmesi o aşamadaki belgelerle açılır.
- **Uzun bekleyen onayları görmek** — şeritteki kırmızı "… günden uzun onay bekleyen" rozetine tıklayın.
- **Belgeyi açmak** — Bekleyenler satırına çift tıklayın, satırdaki "Teklife git / Siparişe git / Kontrole git" bağlantısını kullanın ya da satırı seçip "📄 Seçili belgeyi aç" düğmesine basın.
- **Onaycıya hatırlatmak** — onay bekleyen talep satırındaki "🔔 Hatırlat" düğmesi ya da satırı seçip araç çubuğundaki "🔔 Onaycıya hatırlat". Aynı belge için günde bir kez gönderilir; aynı onaycıya ikinci kez hatırlatılırsa zincirin bir üst basamağına da bilgi gider. Satırda kaç kez hatırlatıldığı görünür.
- **Tedarikçinin olaylarını görmek** — Tedarikçi Karnesi satırına tıklayın (dönemdeki gecikme, uygunsuzluk, fatura farkı olayları ve skor etkisi); adına tıklayınca cari kartı açılır.
- **Fiyat artışlarını ve tasarrufu incelemek** — Fiyat Analizi sekmesi: son 3 alış fiyatı, değişim ve etkisi; altında teklif tasarrufu (ortalama teklife ve son alışa göre).
- **Bütçeyi izlemek** — Bütçe sekmesi: kalem başına plan, gerçekleşen, taahhüt, onaylı talep, kalan ve kullanım; çift tıkla bütçe kalemi kartı.
- **Kritik stoktan gelen talepleri izlemek** — Kritik Stoktan Gelen sekmesi; çift tıkla talep kartı.
- **Çıktı almak** — "🖨️ Satınalma İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML; ekranda görmek için "🖨 Önizleme (A4)" sekmesi.
- **İlgili icmallere geçmek** — "🛒 Alış İcmali", "📋 Sipariş İcmali (alış)", "⚠ Kritik Stok İcmali" düğmeleri.

## Ekrana giriş
- Sol menü **Satınalma › İcmaller › Satınalma Süreç İcmali** (`/satinalma-icmali`).
- `satinalma.icmali` görme yetkisi gerekir (Satınalma Talep Listesi'ni gören rol icmali de görür). Hatırlatma için ayrıca satınalma talebi görme yetkisi yeterlidir.

## Süzgeçler
- **Talep tarihi**, **Şube** (yalnız kullanıcının şubeleri), **Talep eden bölüm**, **Kategori** (talepte o kategoriden bir stok kalemi olan talepler), **Tedarikçi** (o tedarikçiye sipariş verilmiş talepler), **Bütçe kalemi**, **Kaynak** (birim talebi / kritik stok / arıza / yatırım).

## Özet ve sekmeler
- Kutular: Talep (tahmini tutar, kritik stoktan gelen), Açık Talep (onayda · teklifte · onaylı), Talep → Sipariş (ortalama ve medyan gün, bölünen talep), Sipariş → Mal Kabul (gün, termin uyumu), Teklif / Talep (talep başına geçerli teklif, tek teklifle sipariş), Tasarruf (ortalama teklife göre), Fatura Uyuşmazlığı (ödemesi durdurulan, fark tutarı), Bütçe Kullanımı (gerçekleşen + taahhüt / yıllık).
- **Süreç Hunisi:** 1 Talep açıldı · 2 Onay · 3 Teklif · 4 Sipariş · 5 Mal kabul · 6 Fatura kontrolü · 7 Ödemeye onay, ayrıca Reddedilen / iptal; her aşamada adet, tutar, bekleyen, ortalama bekleme ve hedef.
- **Bekleyenler:** belge, aşama (onayda kaçıncı basamak), talep eden bölüm, konu (ürün / hizmet ve "bölündü" rozeti), tutar, kimde, kaç gündür, öncelik ve eylem.
- **Tedarikçi Karnesi:** sipariş, tutar, zamanında teslim oranı, ortalama gecikme, eksik / fazla teslim, kalite reddi, fiyat sapması, fatura farkı, skor.
- **Fiyat Analizi:** 3. önceki, 2. önceki ve son alış fiyatı, değişim, bu dönem sipariş miktarı ve etkisi; Teklif tasarrufu tablosu.
- **Bütçe:** yıllık plan, gerçekleşen (fatura), taahhüt (açık sipariş), onaylı talep, kalan, kullanım, aşım davranışı (uyar / ek onay / engeller).
- **Kritik Stoktan Gelen:** talep, tarih, kaynak (Kritik Stok İcmali'nden elle ya da otomatik), ürün, miktar, durum, talep → sipariş süresi, tedarikçi.

## Rakamlar nereden gelir
- Talep, onay zinciri, teklif, alış siparişi (talepten dönüştürülen), mal kabul tutanağı ve fatura kontrolü (üçlü eşleştirme) kayıtlarından. Birleştirilen talep hedef talepte sayılır; iptal edilmiş sipariş sayılmaz.
- **Onay süresi:** talebin onaya gönderilmesinden zincirin onaylanmasına. **Teklif süresi:** teklif dosyasının açılmasından kararına. **Sipariş süresi:** onayın (teklif kararı varsa onun) bitişinden ilk siparişe — talep birden çok siparişe bölündüyse ilk sipariş esas alınır. **Mal kabul süresi:** sipariş tarihinden ilk kabul tutanağına. **Fatura kontrolü:** fatura tarihinden kontrole. **Ödemeye onay:** kontrolden ödeme kararına.
- **Hedef süreler** Genel Ayarlar'daki satınalma aşama hedef süreleridir (onay, teklif, sipariş, mal kabul, ödeme); tanımlı değilse hedef sütunu boş kalır ve yalnız ortalama görünür. Ortalama hedefi aşarsa kırmızıdır.
- **Kimde:** onay zincirinde bekleyen basamağın atanan kişisi (atanmamışsa basamağın adı / rolü), teklifte kaç firmanın yanıt verdiği, mal kabulde tedarikçi ve termin, fatura kontrolünde kontrolü açan kişi.
- **Tedarikçi skoru** tedarikçi olaylarından türer (gecikme, uygunsuzluk, fatura farkı; son bir yıl); icmal yeniden hesaplamaz, Tedarikçi Listesi'ndeki skorla aynıdır. Fiyat sapması = sipariş birim fiyatının, o siparişten önceki son 3 alışın ortalamasına göre farkı.
- **Alış fiyatı** kesin alış faturası satırının KDV hariç birim fiyatıdır (iade faturası hariç). Etki = (son alış − 3. önceki alış) × bu dönem sipariş miktarı.
- **Tasarruf** = geçerli tekliflerin ortalaması − kazanan teklif; "son alışa göre" = sipariş kalemlerinin son alış fiyatıyla tutarı − sipariş tutarı. Tek teklifle verilen siparişler tasarrufa katılmaz, ayrıca sayılır.
- **Bütçe:** gerçekleşen kontrolü yapılmış alış faturası, taahhüt açık (teslimi bitmemiş) sipariştir ve kalandan düşer — talep onayındaki bütçe kontrolüyle aynı hesap. Onaylı talep yalnız bilgi amaçlıdır.

## Çıktı
A4: dönem, şube, talep ve sipariş sayısı, bütçe yılı; aşama başına adet, tutar, bekleyen, ortalama bekleme ve hedef; altta talep tahmini, siparişe dönen, teklif tasarrufu, fatura uyuşmazlığı ve ödemeye onaylanan tutar; imza alanları (Satınalma Sorumlusu, Mali İşler Müdürü).

## Dikkat edilecekler
- Onay ya da ret bu ekrandan verilmez; Onay ekranındadır. Buradan yalnız belgeye gidilir ve onaycıya hatırlatılır.
- Hatırlatma aynı belge için günde birdir; aynı gün ikinci deneme reddedilir. Hatırlatma, alıcının e-posta (yoksa cep) bilgisine göre bildirim kuyruğuna yazılır ve talebin günlüğüne kaydedilir; alıcının iletişim bilgisi yoksa hatırlatma yine kaydedilir ama bildirim gitmez.
- Teklif aşaması atlanan (doğrudan siparişe dönen) talepler huninin 3. satırında sayılmaz.
- Bütçe sekmesi bütçe yılına (dönem sonunun yılı) göredir; bölüm, kategori ve tedarikçi süzgeci bu sekmeye uygulanmaz.

## Örnek sorular
- Hangi talepler 5 günden uzun süredir onay bekliyor, kimde bekliyor?
- Talepten siparişe ortalama kaç gün geçiyor?
- Hangi tedarikçi zamanında teslim etmiyor?
- Teklif alarak bu ay ne kadar tasarruf ettik?
- Hangi kalemlerin alış fiyatı son alışlarda arttı?
- Bütçe kalemlerinin ne kadarı harcandı, ne kadarı bağlandı?
- Kritik stoktan açılan talepler siparişe döndü mü?
