---
id: icmal-doviz-pozisyon
baslik: Döviz Pozisyonu / Kur Farkı İcmali
modul: finans
ekran: doviz-pozisyon
rota: /doviz-pozisyon
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.doviz_pozisyon
erisim: kullanici
ozet: Döviz bazında net pozisyonu (döviz kasa, döviz banka, dövizli cari alacak / borç, portföydeki döviz çek, kredi), dövizli carilerin değerleme farkını, dönemde gerçekleşen kur farkını, kesilmesi gereken kur farkı faturalarını, döviz vade takvimini, kur duyarlılığını ve kullanılan kurları gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Dövizde ne kadar açığız, kur artarsa ne kaybederiz, bu ay kur farkından ne kazandık, kime kur farkı faturası kesmeliyiz?" sorusunu cevaplar. Finans ve yönetimin haftalık ve ay sonu baktığı ekrandır. Bakiyeler Cari Ekstre, hesap ekstresi ve Çek / Senet İcmali ile aynı kümeden gelir; kur farkı Cari İcmali'nin FIFO kapama kuralıyla hesaplanır — ikinci bir kural yoktur.

## Bu ekranda neler yapabilirsiniz
- **Pozisyonu görmek** — "Pozisyon" sekmesi: döviz başına kasa, banka, müşteri alacağı, portföydeki döviz çek (varlık) ile tedarikçi borcu ve döviz kredisi / kredi kartı (yükümlülük); her döviz için net pozisyon ve TL karşılığı.
- **Açık siparişleri dahil etmek** — şeritteki "Açık siparişleri pozisyona dahil et" kutusu açık dövizli satış siparişini gelecek alacak, alış siparişini gelecek borç olarak ekler (varsayılan kapalı: henüz alacak / borç değil).
- **Dövizli carilerin değerleme farkını okumak** — "Cari Bazında" sekmesi: cari ve döviz başına bakiye, ortalama işlem kuru, bugünkü kur, kayıtlı TL, bugünkü TL ve değerleme farkı. Çift tıklayınca cari ekstresi, ada tıklayınca cari kartı açılır.
- **Gerçekleşen kur farkını görmek** — "Kur Farkı" sekmesi: seçili dönemde kapanan dövizli işlemlerden doğan kur farkı geliri / gideri (tahsilat, ödeme, diğer kapamalar), döviz kasa / banka değerlemesi ve açık cari değerlemesi (bu ikisi yalnız bilgi).
- **Kur farkı faturalarını takip etmek** — "Kur Farkı Faturası" sekmesi: satış faturasını kapatan tahsilatta oluşan kur farkı. Lehte farklar "kesilmedi" olarak listelenir. Satırı seçip "🧾 Kur farkı faturası aç" ile carinin yeni satış faturasını açın; faturayı kestikten sonra "✓ Kesildi…" ile o faturanın numarasını girin. Kesmeye gerek yoksa "Gerek yok…" (neden zorunlu). İşaretler loglanır ve "↶ Geri al" ile kaldırılabilir. Yalnız `finans.kur_farki` yetkisi olan kullanıcıda görünür.
- **Vade takvimini görmek** — "Döviz Vade Takvimi" sekmesi: açık dövizli alacak ve borcun vadesi geçmiş, 0–30, 31–60, 61–90, 90+ gün dilimleri ve net TL karşılığı.
- **Kur riskini ölçmek** — "Kur Duyarlılığı" sekmesi: kurlar %5 düşerse, %5 / %10 / %20 artarsa döviz başına ve toplam TL etkisi.
- **Kullanılan kurları görmek** — "Kur Geçmişi" sekmesi: son kur günleri ve önceki ay sonu (değerleme) kuru.

## Ekrana giriş
Finans › İcmaller › Döviz Pozisyonu / Kur Farkı İcmali. Ekranı görmek için `finans.doviz_pozisyon` (Gör) yetkisi gerekir; kur farkı işaretleri için ayrıca `finans.kur_farki` aksiyon yetkisi.

## Süzgeçler
- **Tarih** — pozisyonun ve değerlemenin günü (varsayılan bugün).
- **Kur farkı dönemi** — gerçekleşen kur farkının ayı (varsayılan tarihin ayı).
- **Değerleme kuru** — TCMB döviz alış (varsayılan), efektif alış ya da döviz satış. Varsayılanı Genel Ayarlar › `finans.degerleme_kuru` belirler.
- **Şube** — kasa, banka, çek ve sipariş kalemlerini şubeye göre süzer; cari bakiyeleri kayıt kapsamınıza göre gelir.
- **Döviz** — tablolarda yalnız seçili dövizi gösterir.
- **Portföy çekleri dahil** — alınan döviz çek / senetleri pozisyona katar ya da çıkarır.

## Rakamlar nereden gelir
- **Kasa / banka:** hesap ekstresiyle aynı küme (gerçekleşmiş hareketler), hareketin kendi dövizinde. Kredi ve kredi kartı hesapları yükümlülük satırındadır.
- **Dövizli cari:** hareketi kendi dövizinde tutulan cari (Cari Ekstre'nin döviz sütunu). TL tutulan carinin dövizli faturası TL alacaktır, pozisyona girmez.
- **Portföy çek:** müşteriden alınıp vadesi gelmemiş, portföyde / tahsilde / teminatta duran döviz çek ve senet.
- **Kur farkı:** aynı cari ve döviz içinde borç ve alacak kalemleri vade sırasıyla birbirini kapatır (Cari İcmali FIFO kuralı). Kapanan her parça için kur farkı = döviz tutar × (kapatan kalemin kuru − kapanan kalemin kuru); kalemin kuru = kayıtlı TL / döviz tutar. Kapanış günü iki kalemin geç olanıdır.
- **Değerleme farkı:** açık kalan kalemlerin bugünkü kurdaki TL'si − kayıtlı TL'si. Yalnız bilgidir, muhasebe kaydına geçmez.
- **Kurlar:** Döviz Kurları tanımından; o güne ait kur yoksa önceki son kur kullanılır ve şeritte "Eski kur" rozeti çıkar. Hiç kuru olmayan dövizin TL karşılığı kayıtlı tutardan alınır ("Kuru olmayan döviz" rozeti).

## Çıktı
"🖨 Döviz İcmali" menüsünden A4 önizleme, yazdırma ve PDF: döviz başına varlık, yükümlülük, net ve TL karşılığı; gerçekleşen kur farkı, değerleme farkı ve net döviz pozisyonu.

## Dikkat edilecekler
- Kur farkı faturası **otomatik kesilmez**; ekran yalnız önerir. Kesilen faturayı "Kesildi" ile işaretlemezseniz satır önerilmeye devam eder.
- Aleyhte kur farkı (müşteri lehine) yalnız bilgi olarak gösterilir; gerekiyorsa alacak dekontu / fiyat farkı faturasını ayrıca düzenleyin.
- İhracat faturasının kur farkı faturasında KDV yoktur (satırda "ihracat — KDV yok" rozeti).
- Kur duyarlılığı tek etkenli basit senaryodur: tüm dövizler aynı oranda değişir, türev / vadeli işlemler yok sayılır.

## Örnek sorular
- "Euro'da ne kadar açığız?"
- "Kur %10 artarsa ne kadar zarar ederiz?"
- "Bu ay kur farkından ne kazandık?"
- "Hangi müşterilere kur farkı faturası kesmedik?"
- "Dövizli tedarikçi borçlarımızın vadesi ne zaman?"
