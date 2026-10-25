---
id: planli-gider
baslik: Planlı Giderler
modul: finans
ekran: planli-gider
rota: /planli-gider
surec: tanim
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.planli_gider
erisim: kullanici
ozet: Kira, enerji, abonelik, vergi / SGK, sigorta, aidat gibi tekrarlayan giderlerin tanımı; dönemlerin planı ve gerçekleşmesi (ödeme / fatura eşleşmesi), taslak ödeme oluşturma ve Nakit Akış İcmali'ne planlı çıkış olarak yansıması.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu ay kira, elektrik, SGK, KDV için ne kadar ödeyeceğim, hangisi gecikti, hangisi ödendi?" sorusunu cevaplar. Tanım bir kuraldır (kime, ne kadar, hangi takvimle, hangi hesaptan); her dönem (ör. Kasım kirası) takvimden türetilir. Planlı gider kayıt değildir: kasa / banka hareketi ya da fatura kendiliğinden oluşmaz.

## Bu ekranda neler yapabilirsiniz
- **Yeni planlı gider tanımlamak** — "＋ Yeni Planlı Gider"; ad, kategori, ödenecek yer (yalnız tedarikçi listesinden), masraf kalemi, tutar, takvim ve ödeme hesabı.
- **Tutar türünü seçmek** — sabit, son N dönem ortalaması, geçen yıl aynı ay, hesaplanan (KDV İcmali / SGK) ya da her dönem elle.
- **Artış kuralı eklemek** — geçerlilik tarihinden sonraki dönemlere oran (%) ya da yeni tutar (ör. Ocak'ta %30 kira artışı).
- **Bir dönemi atlamak ya da yalnız o dönemin tutarını değiştirmek** — "⏭ Dönemi Atla", "✎ Bu Dönemin Tutarı"; "Geri Al" ikisini de kaldırır.
- **Ödemeyi ya da faturayı dönemle eşleştirmek** — "🔗 Eşleştir" önerileri (kasa / banka ödemesi, alış faturası, işlenmemiş banka hareketi) gösterir; tek aday varsa sistem kendisi eşleştirir.
- **Taslak ödeme oluşturmak** — "💳 Ödeme Oluştur" cari, masraf, tutar, hesap ve açıklaması dolu bir TASLAK kasa / banka ödemesi açar; kesinleştiren sizsiniz.
- **12 aylık takvimi görmek** — Takvim sekmesi kategori ya da ödeme hesabı kırılımıyla aylık toplamları gösterir (sabit / tahmini / hesaplanan).
- **Sözleşmeyi yenilemek** — "⧉ Kopyala" bitişten sonraki gün başlayan yeni bir tanım açar (güncel tutar, ileri tarihli artışlar taşınır).
- **Belge eklemek** — kartın Belgeler sekmesinde kira sözleşmesi, artış bildirimi gibi dosyalar.

## Ekrana giriş
- Sol menü **Finans › Planlı Giderler** (`/planli-gider`).
- Kategoriler: **Finans › Ayarlar › Planlı Gider Kategorileri**.
- `finans.planli_gider` görme yetkisi gerekir (ilk kurulumda Nakit Akış İcmali'nin kaynağını gören rollere verilir). "Ödeme Oluştur" ayrıca kasa işlemi ekleme yetkisi ister.

## Kurallar
- **Ödeme günü:** ayın 29-31'i seçilirse kısa ayda ayın son günü; haftalıkta haftanın günü. Hafta sonuna ya da Resmi Tatiller tanımındaki tam gün tatile denk gelirse kurala göre önceki / sonraki iş günü (varsayılan sonraki).
- **Tutar:** tür kuralı → artış kuralları → o dönem için elle yazılan tutar (elle yazılan her zaman kazanır). Nakit çıkışı = KDV hariç + KDV − stopaj. Ortalama ve geçen yıl, eşleşen gerçek ödemelerden hesaplanır; geçmiş yoksa tanımdaki tutar kullanılır. KDV hesaplanan kalemde KDV İcmali'nin son kesin dönem ödenecek KDV'si, SGK'da son 3 ödemenin ortalaması.
- **Geçmiş korunur:** tarihi geçen ya da eşleşen dönemin planı o günkü hesapla dondurulur; tanım sonradan değişse de "plan − gerçek" bozulmaz.
- **Eşleştirme:** aynı cari ve masraf kalemi, plan tarihinin ± gün toleransı ve tutarın ± % toleransı içinde. Bir ödeme yalnız bir döneme eşleşir. Alış faturası eşleşirse dönem "faturalandı" olur. İşlenmemiş banka hareketiyle eşleşen dönem "beklemede"dir; hareket Banka Hareketleri'nde işlenince eşleşme kesinleşir.
- **Hatırlatma:** plan tarihinden ayarlanan gün kadar önce sorumluya bildirim; gecikirse 5 gün boyunca günde bir. Sözleşme bitişine 90 gün kala yenileme hatırlatması.
- **Bitiş:** bitiş tarihinden sonra tanım kendiliğinden pasif sayılır, Nakit Akış İcmali'nde görünmez.

## Nakit Akış İcmali'ne etkisi
Aktif tanımların eşleşmemiş, atlanmamış dönemleri icmalde "Planlı: {ad}" çıkışı olur. Gecikmiş dönem ilk haftaya taşınır. Kredi kartıyla ödenen gider kartın ekstre son ödeme gününde görünür. Eşleşen dönem akıştan düşer; faturalanan dönem faturanın vadesiyle (açık borç olarak) girer, iki kez sayılmaz.

## Dikkat edilecekler
- Ödenecek yer serbest yazılamaz; listede yoksa önce tedarikçi kartı açın. Yalnız Vergi / SGK kategorisinde boş bırakılabilir.
- Eşleşmiş dönemi olan tanım silinemez; pasife alın.
- Tanım değişikliği yalnız bugünden sonraki dönemleri etkiler.

## Örnek sorular
- Bu ay hangi planlı giderler gecikti?
- Kira artışını Ocak'tan itibaren nasıl tanımlarım?
- Elektrik faturası gelince planlı gider ne olur?
- SGK ödemesi için taslak ödeme nasıl oluşturulur?
- Önümüzdeki 12 ayda planlı giderlerim ne kadar?
- Kartla ödenen internet aboneliği nakit akışta ne zaman görünür?
