---
id: icmal-musteri-risk-icmali
baslik: Müşteri Risk / Limit İcmali
modul: finans
ekran: musteri-risk-icmali
rota: /musteri-risk-icmali
surec: icmal
roller: muhasebe, finans, satis, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.musteri_risk_icmali
erisim: kullanici
ozet: Müşteri bazında toplam riski (açık bakiye + portföydeki müşteri çeki + faturasız irsaliye + açık sipariş), risk limiti ve teminatla karşılaştırmasını, limit aşımını, vade özetini, çek riskini, ödeme davranışı skorunu, yoğunlaşmayı ve sevk blokesi önerisini gösterir; yetkili kullanıcı limit, teminat ve sevk blokesini buradan değiştirir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Kime ne kadar açığız, kim limitini aştı, kime mal göndermeye devam etmeliyiz?" sorusunu cevaplar. Satış müdürü, muhasebe ve yönetimin sevk kararından önce baktığı ekrandır. Her risk bileşeni kendi icmalinin kuralıyla hesaplanır (Cari İcmali, Çek / Senet İcmali, İrsaliye-Fatura Eşleşme, Açık Satır Listesi) — ikinci bir kural yoktur. Satış belgesi kaydındaki limit kontrolü de aynı hesabı kullanır.

## Bu ekranda neler yapabilirsiniz
- **Müşteri bazında toplam riski görmek** — "Risk Listesi" sekmesi: açık bakiye, vadesi geçen, portföy çek, faturasız irsaliye, açık sipariş, toplam risk, limit, kullanım çubuğu ve A–D skoru. Satıra tıklayınca müşteri seçilir ve bileşenlerin ayrıntısı (evrak / belge adetleri, teminat, bloke bilgisi) açılır; çift tıklayınca cari ekstresi, ada tıklayınca cari kartı açılır.
- **Riske giren bileşenleri seçmek** — şeritteki "Açık siparişler riske dahil" ve "Portföydeki müşteri çekleri dahil" kutularıyla bileşeni açıp kapatın; "Limiti tanımsızları gizle" yalnız limiti tanımlı müşterileri bırakır. Şube, temsilci ve risk grubuna göre süzün.
- **Limit aşımını izlemek** — "Limit Aşımı" sekmesi: limitini aşan ve limitinin %80'ine yaklaşan müşteriler; aşım tutarı, kullanım, teminat, son limit değişikliği (tarih · kişi) ve durum (aşım · teminat içinde / vadesi geçen var / yaklaşıyor).
- **Limiti güncellemek** — müşteriyi seçip "✎ Limit güncelle…": limit (boş = tanımsız), limit dövizi, risk grubu ve zorunlu neden. Değişiklik alan bazında loglanır. Yalnız `cari.risk_limit` yetkisi olan kullanıcıda görünür.
- **Sevk blokesi koymak / kaldırmak** — "⛔ Sevk blokesi koy…" / "kaldır…": neden zorunlu, kim / ne zaman ile loglanır. Bloke Önerisi sekmesinden de aynı pencere açılır.
- **Teminatları yönetmek** — "🛡 Teminatlar…": teminat mektubu, ipotek, çek / senet, nakit, diğer; tutar, döviz, başlangıç ve bitiş. Yetkili kullanıcı ekler, düzeltir, siler (hepsi loglu). Bugün geçerli teminat, limit aşımının teminatla karşılanıp karşılanmadığını belirler.
- **Vade özetini görmek** — "Vade / Yaşlandırma" sekmesi: vadesi gelmemiş, 1–30, 31–60, 61–90, 90+ gün dilimleri, ortalama gecikme ve en eski vade (Cari İcmali ile aynı FIFO kuralı).
- **Çek riskini okumak** — "Çek Riski" sekmesi: müşteri (ciranta), keşideci, evrak adedi, tutar, vade aralığı, banka; geçmişte karşılıksız evrakı olan keşideci, üçüncü şahıs çeki ve 7 gün içinde vadesi gelen tutar uyarılarıyla.
- **Ödeme davranışını karşılaştırmak** — "Ödeme Davranışı" sekmesi (son 12 ay): ortalama vade, ortalama ödeme süresi, ortalama gecikme, eğilim (↗ iyileşiyor / ↘ kötüleşiyor), zamanında ödeme yüzdesi, karşılıksız evrak ve skor.
- **Yoğunlaşmayı görmek** — "Yoğunlaşma" sekmesi: riskin ilk 10 müşteride toplanması (pay, kümülatif; tek müşteride %15 üstü sarı) ve risk grubu toplamları (satıra tıklayınca liste o gruba süzülür).
- **Bloke önerisini değerlendirmek** — "Bloke Önerisi" sekmesi: blokele (peşin / teminat), uyarıyla sat, blokede kalsın, kaldırılabilir — nedenleriyle. İcmal blokeyi kendisi koymaz.
- **Çıktı almak** — "🖨 Risk İcmali ▾" menüsü ya da "🖨 Önizleme (A4)" sekmesi: müşteri, toplam risk, limit, kullanım, vadesi geçen ve risk toplamları; hazırlayan ve genel müdür imza alanları.
- **İlgili ekranlara geçmek** — "👤 Cari kartı", "📄 Ekstre", "⏳ Alacak Yaşlandırma", "📊 Cari İcmali", "📃 Çek / Senet İcmali".

## Ekrana giriş
- Sol menü **Finans › İcmaller › Müşteri Risk / Limit İcmali** (`/musteri-risk-icmali`).
- `finans.musteri_risk_icmali` görme yetkisi gerekir (Cari İcmali'ni gören rol bu icmali de görür).
- Limit / teminat / sevk blokesi değişikliği `cari.risk_limit` aksiyon yetkisi ister (Cari İcmali'nde değiştirme yetkisi olan rol); salt okuma şubesinde değişiklik yapılamaz.
- Cari kayıt kapsamı olan kullanıcı yalnız kendi carilerini görür.

## Süzgeçler
- **Şube** (çek, irsaliye ve sipariş bileşenine uygulanır; cari bakiye şubeler arası ortaktır), **Temsilci**, **Risk grubu**.
- **Açık siparişler riske dahil** (varsayılan açık), **Portföydeki müşteri çekleri dahil** (varsayılan açık), **Limiti tanımsızları gizle**.
- Tarih bugündür; risk bugünün parasıdır.

## Özet ve sekmeler
- Kutular: Toplam Risk, Açık Bakiye, Vadesi Geçen, Portföydeki Çek, Faturasız İrsaliye + Açık Sipariş, Limit Aşan, Limitin %80'i Üstü, İlk 10 Müşteri Payı.
- **Risk Listesi**, **Limit Aşımı**, **Vade / Yaşlandırma**, **Çek Riski**, **Ödeme Davranışı**, **Yoğunlaşma**, **Bloke Önerisi**, **Önizleme (A4)**.

## Rakamlar nereden gelir
- **Açık bakiye**: cari hareketleri (Cari İcmali / Cari Ekstre ile aynı küme, bakiyeye dahil satırlar). Dövizli hareket kendi dövizindeki bakiye × bugünkü kur.
- **Portföy çek**: müşteriden alınmış, portföyde / bankada tahsilde / teminatta, vadesi gelmemiş, ciro edilmemiş çek ve senet (Çek / Senet İcmali kuralı); dövizli evrak bugünkü kurla.
- **Faturasız irsaliye**: kesin satış irsaliyesi ve giden konsinye, iade hariç; hiç faturalanmamışsa belge matrahı, kısmen faturalanmışsa kalan miktarın tutarı (İrsaliye-Fatura Eşleşme kuralı). KDV hariç.
- **Açık sipariş**: Açık Satır Listesi'ndeki açık satış siparişi satırları, "kalanı kapat" ile kapatılan satır hariç; tutar sipariş matrahının satıra düşen payı × kalan miktar (Sipariş İcmali gibi). KDV hariç.
- **Limit**: cari kartındaki risk limiti, kendi dövizinde; TL karşılığı bugünkü kurla. Limit boşsa **tanımsız**dır, limitsiz değil. Kullanım = toplam risk / limit.
- **Skor (A–D)**: son 12 ayın satış faturalarından, sabit ağırlıkla — zamanında ödeme % 40, ortalama gecikme 30, karşılıksız evrak (12 ay) 20, limit kullanımı 10. A 85+, B 70+, C 50+, altı D. Ödeme süresi FIFO ile: fatura → onu kapatan tahsilat. Skor yalnız bilgidir.
- **Bloke önerisi**: limit aşımı teminatla karşılanmıyor ve 90+ gün vadesi geçen / karşılıksız geçmişi / 6 aydır tahsilat yoksa ya da kullanım %150'yi aşıyorsa "blokele"; aşım varsa ya da 90+ gecikme varsa "uyarıyla sat"; blokeli müşteride durum sürüyorsa "blokede kalsın", düzelmişse "kaldırılabilir".

## Satış belgesinde limit kontrolü
- Satış siparişi, satış irsaliyesi ve satış faturası kesin kaydedilirken (taslak hariç, iade hariç; tahsilatta yok) müşterinin sevk blokesi ve risk limiti kontrol edilir. Risk, kaydedilen belge dahil hesaplanır.
- Genel Ayarlar › `satis.limit_davranis`: **uyar** (varsayılan) — belge kaydedilir, ekranda uyarı görünür; **engelle** — belge kaydedilmez, yalnız `satis.limit_asim` yetkisi olan kullanıcı uyarıyla kaydedebilir.
- Limiti tanımsız ve blokesiz müşteride kontrol yapılmaz.

## Çıktı
A4: tarih, para birimi (TL karşılığı, bugünkü kur), risk tanımı ve müşteri sayısı; müşteri, toplam risk, limit, kullanım, vadesi geçen (ilk 30 müşteri); açık bakiye, portföy çek, faturasız irsaliye + açık sipariş ve toplam risk; hazırlayan ve genel müdür imza alanları.

## Dikkat edilecekler
- Cari kartında risk limiti, limit dövizi, risk grubu, sevk blokesi ve teminat özeti **salt okunurdur**; değişiklik bu ekrandan yapılır.
- İrsaliye ve sipariş bileşenleri KDV hariçtir (kaynak icmallerle aynı rakam); faturaya dönüşünce cari bakiyeye KDV dahil girer.
- Kur tablosunda bugünkü kuru olmayan dövizli kalem işlem kuruyla sayılır; dövizli limitin kuru yoksa limit karşılaştırılamaz (rozet "kur yok").
- Hatırlatma gönderimi bu ekranda yok: müşteriye ileti şablonu henüz tanımlı değil.

## Örnek sorular
- Hangi müşteriler risk limitini aştı?
- Toplam riskimiz ne kadar, ne kadarı portföydeki çekte?
- Limiti tanımsız kaç aktif müşterimiz var?
- Hangi müşteriye sevk blokesi koymalıyım?
- Müşterinin limitini nasıl güncellerim?
- Riskin ne kadarı ilk 10 müşteride toplanmış?
- Ödemesi en çok geciken müşteriler kimler?
