---
id: icmal-teklif-icmali
baslik: Teklif / Fırsat Dönüşüm İcmali
modul: satis
ekran: teklif-icmali
rota: /teklif-icmali
surec: icmal
roller: satis, yonetim
dil: tr
surum: 1
urun_modu: 1
yetki: satis.teklif_icmali
erisim: kullanici
ozet: Verilen satış tekliflerinin ne kadarının siparişe döndüğünü fırsat → teklif → sipariş → fatura hunisinde, temsilci, müşteri ve kategori bazında gösterir; kayıp nedenlerini ve rakipleri, süresi dolmak üzere olan ve hareketsiz teklifleri listeler. Süresi dolan teklif gece kendiliğinden "kaybedildi · süre doldu" olur; yetkili kullanıcı açık teklifi nedeniyle kaybedildi işaretler.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Verdiğimiz tekliflerin ne kadarı satışa dönüyor, nerede kaybediyoruz, hangi teklif takip bekliyor?" sorusunu cevaplar. Satış müdürü ve temsilcilerin haftalık satış toplantısında baktığı ekrandır.

## Bu ekranda neler yapabilirsiniz
- **Huniyi görmek** — "Huni" sekmesi: fırsat açıldı, teklif verildi, sunuldu / müzakere, siparişe döndü, faturalandı; her aşamanın adedi, tutarı, önceki aşamadan geçiş oranı ve ortalama bekleme süresi.
- **Teklifleri durumlarıyla listelemek** — "Teklifler" sekmesi: teklif no (revize numarası rozetle), tarih, müşteri, temsilci, tutar, iskonto, geçerlilik, durum (bekliyor / kabul · sipariş bekliyor / kısmen döndü / siparişe döndü / kaybedildi · neden / süresi doldu / iptal) ve dönen tutar. Satıra tıklayınca seçilir, çift tıklayınca teklif kartı açılır.
- **Kaybedildi işaretlemek** — teklifi seçip "✖ Kaybedildi işaretle": kayıp nedeni (zorunlu), rakip ve rakip fiyatı (isteğe bağlı), açıklama. Yalnız `satis.teklif_kayip` yetkisi olan kullanıcıda açılır; satırları siparişe dönmüş teklif kaybedilemez.
- **Temsilcileri karşılaştırmak** — "Temsilci" sekmesi: teklif, tutar, dönen, dönüşüm, kayıp, ortalama iskonto, ortalama dönüş süresi, bekleyen. Yüksek iskonto ile düşük dönüşüm aynı satırda kırmızı. Çift tık: temsilciyle süz.
- **Müşterileri okumak** — "Müşteri" sekmesi: çok teklif alıp az sipariş veren müşteriler "düşük dönüşüm" rozetiyle üstte; son teklif ve son sipariş tarihi.
- **Ürün / kategori kırılımı** — teklif satırlarından kategori bazında teklif tutarı, dönen, dönüşüm ve ortalama iskonto.
- **Kayıp nedenlerini çözümlemek** — "Kayıp Nedeni" sekmesi: neden, adet, tutar, pay, girilen rakipler ve rakip fiyatına göre ortalama fark.
- **Takip etmek** — "Takip Bekleyen" sekmesi: geçerliliği 7 gün içinde bitecek ya da 7 gündür hareket görmemiş açık teklifler; "yarın kayba düşer", "3 gün kaldı", "12 gündür hareketsiz".
- **Çıktı almak** — "🖨 Dönüşüm İcmali ▾" menüsü ya da "🖨 Önizleme (A4)": temsilci bazında teklif / tutar / dönen / dönüşüm ve toplamlar.

## Ekrana giriş
- Sol menü **Satış › İcmaller › Teklif / Fırsat Dönüşüm İcmali** (`/teklif-icmali`).
- `satis.teklif_icmali` görme yetkisi gerekir (satış teklifi listesini gören rol bu icmali de görür).
- Kaybedildi işaretlemek `satis.teklif_kayip` aksiyon yetkisi ister; salt okuma şubesinde yapılamaz.
- Cari kayıt kapsamı olan kullanıcı yalnız kendi carilerinin tekliflerini görür.

## Süzgeçler
- **Dönem** (teklif tarihi; varsayılan bu yıl), **Şube**, **Temsilci** (teklifteki satıcı; "(temsilcisiz)" seçilebilir).
- **Tutar / Adet**: dönüşüm oranının tutara mı teklif adedine mi göre gösterileceği.

## Rakamlar nereden gelir
- **Tutar**: teklifin dip toplamı (KDV hariç, TL); dövizli teklif teklif tarihindeki belge kuruyla.
- **Dönüşüm**: teklif satırından türeyen sipariş, irsaliye ya da fatura satırı (belge dönüşüm izi). Satırın dönen oranı türeyen miktar / teklif miktarı; teklifin dönen tutarı dip toplamın satır payıyla ağırlıklı dönen kısmı. Bütün satırlar döndüyse "siparişe döndü", bir kısmı döndüyse "kısmen döndü".
- **Faturalandı**: teklif satırının zincirinde (sipariş → irsaliye → fatura) kesin satış faturası.
- **İptal** teklif dönüşüm hesabına girmez.
- **İskonto**: teklif satırlarında adet × birim fiyat ile satır tutarı arasındaki fark.
- **Fırsat**: dönemde açılan satış fırsatları (tahmini tutar, dövizliyse fırsat kuruyla); ağırlıklı tutar = tahmini tutar × olasılık.

## Süresi dolan teklif
- Geçerlilik = teklif tarihi + teklif kartındaki **Geçerlilik Süresi (gün)**. Süre girilmemiş teklif hiç dolmaz.
- Geçerliliği biten, hiçbir satırı siparişe / irsaliyeye / faturaya dönmemiş açık (hazırlanıyor / sunuldu) teklif o gece kendiliğinden **kaybedildi · süre doldu** olur (kullanıcı "sistem", loglu). Kabul edilmiş ya da kısmen dönmüş teklif kayba düşmez.
- Genel Ayarlar › `teklif.otomatik_kayip` = 0 ise bu iş kapalıdır (boş ya da 1 = açık).

## Dikkat edilecekler
- Geçerlilik süresini uzatmak için teklif kartında Geçerlilik Süresi'ni değiştirin; zaten kaybedilmiş teklifin durumu kartta değiştirilir.
- Kayıp nedenleri Ayarlar › Kod Listeleri › `teklif.kayip_nedeni`; "Süre doldu" sistemin kullandığı nedendir, elle seçilmez.
- Temsilci teklifteki satıcıdır; cari kartındaki temsilci kullanılmaz.

## Örnek sorular
- Bu yıl verdiğimiz tekliflerin yüzde kaçı siparişe döndü?
- Hangi temsilcinin dönüşüm oranı en düşük?
- Teklifleri en çok hangi nedenle kaybediyoruz?
- Süresi bu hafta dolacak teklifler hangileri?
- Hangi müşteri çok teklif alıp az sipariş veriyor?
- Bir teklifi nasıl kaybedildi işaretlerim?
