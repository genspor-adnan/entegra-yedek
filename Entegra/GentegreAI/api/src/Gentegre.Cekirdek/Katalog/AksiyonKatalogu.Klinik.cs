using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Acil (716), yatan hasta, radyoloji, teleradyoloji, dokuman, sigorta, uretim.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKlinik(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // ========================================================= ACİL (716) ==
        // TRİYAJ EKRANI ile TAKİP PANOSU aynı kaynağı okur, AYRI aksiyon
        //   listesi taşır: kabul masasının işi hastayı sıraya sokmak (triyaj,
        //   yatak, hekim), panonunki ise içerideki hastayı ilerletmek (çağrı,
        //   çıkış). Tek liste olsaydı her iki kullanıcı da diğerinin
        //   düğmelerini eleyerek çalışırdı.
        s["acil-triyaj-liste"] = new AksiyonTanimi[]
        {
            new("acil.yeni", "＋ Yeni Başvuru", "acil", Kisayol: "Ctrl+N",
                KaynakKodu: "acil.basvuru", Islem: Islem.Ekle, Sira: 10, UrunModu: 2,
                Ipucu: "Kimliksiz hasta da kabul edilir (geçici ad ile)"),
            new("acil.duzenle", "✎ Hasta Kartı", "acil", Kisayol: "Enter",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            // TRİYAJ TEK DÜĞME: yükseltme serbest, DÜŞÜRME ayrı yetki ve
            //   gerekçe ister - kararı sunucu verir, çünkü düşürme hastayı
            //   sıranın gerisine atar.
            new("acil.triyaj-ver", "🎨 Triyaj Ver / Değiştir", "acil",
                KaynakKodu: "acil.triyaj", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "bir",
                Ipucu: "Düşürmek ayrı yetki ve gerekçe ister"),
            new("acil.yatak-ver", "🛏 Yatak Ver", "acil",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("acil.hekim-gordu", "🩺 Hekim Gördü", "acil",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 50, UrunModu: 2,
                Ipucu: "Kapı-hekim süresinin ikinci ucu; bir kez yazılır"),
            Yazdir(),
        };

        s["acil-takip-liste"] = new AksiyonTanimi[]
        {
            new("acil.duzenle", "✎ Hasta Kartı", "acil", Kisayol: "Enter",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("acil.hekim-gordu", "🩺 Hekim Gördü", "acil",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            // ÇAĞRI PANODAN TEK TIKLA: mavi kodda kart açıp detay satırı
            //   eklemek, ölçtüğümüz sürenin kendisini uzatır.
            new("acil.cagri-ac", "📞 Çağrı Aç", "acil",
                KaynakKodu: "acil.pano", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("acil.cikis-karar", "🚪 Çıkış Kararı", "acil",
                AksiyonYetkisi: "acil.cikis", KayitGerekir: true,
                Sira: 40, UrunModu: 2, Bicim: "onay",
                Ipucu: "Çıkış tanısı zorunlu; yatak temizliğe düşer"),
            new("acil.triyaj-ver", "🎨 Triyaj Değiştir", "acil",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "acil.triyaj", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 50, UrunModu: 2),
            new("acil.yatak-ver", "🛏 Yatak Değiştir", "acil",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 60, UrunModu: 2),
            Yazdir(),
        };

        // ÇAĞRILAR - üç düğme aynı satırın durumunu ilerletir. "Yanıt yok"
        //   KIRMIZI ve ayrı: tekrar sayacını artırır ve bekleme süresini
        //   kapatmaz; yanıtlandı ile karıştırılması ölçümü bozardı.
        s["acil-cagri-liste"] = new AksiyonTanimi[]
        {
            new("acil.cagri-yanit", "✅ Yanıtlandı", "acil",
                KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay",
                Ipucu: "Yanıt saati bir kez yazılır (çağrı-yanıt süresi)"),
            new("acil.cagri-kapat", "⏹ Kapat", "acil",
                KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("acil.cagri-tekrar", "🔁 Yanıt Yok / Tekrar Çağır", "acil",
                KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "ret"),
            Yazdir(),
        };

        s["acil-yatak-liste"] = new AksiyonTanimi[]
        {
            // Çıkışta yatak BOŞ değil TEMİZLİKTE olur; boşa dönmesi ayrı bir
            //   olaydır ve kim yaptığı loglanır - "yatak hazır" bilgisi
            //   triyajın hasta yollama kararıdır.
            new("acil.yatak-temizlendi", "🧹 Temizlik Bitti", "acil",
                KaynakKodu: "acil.yatak", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay"),
            new("acil-yatak.yeni", "＋ Yeni Yatak", "acil", Kisayol: "Ctrl+N",
                KaynakKodu: "acil.yatak", Islem: Islem.Ekle, Sira: 20, UrunModu: 2),
            new("acil-yatak.duzenle", "✎ Düzenle", "acil", Kisayol: "Enter",
                KaynakKodu: "acil.yatak", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("acil-yatak.sil", "🗑 Sil", "acil", Kisayol: "Del",
                KaynakKodu: "acil.yatak", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 40, UrunModu: 2,
                Ipucu: "Başvuru geçmişi olan yatak silinemez; pasife alın"),
            Yazdir(),
        };

        // ODA TANIMLARI (695) - kurulum ekrani. Kural odanin: cinsiyet,
        //   izolasyon, ucret sinifi. Silme sag tusta ve ayni sebeple
        //   kisitli: odaya bagli yatak ve gecmis yatislar var.
        s["oda-liste"] = new AksiyonTanimi[]
        {
            new("oda.yeni",    "＋ Yeni Oda", "yatan", Kisayol: "Ctrl+N",
                KaynakKodu: "yatan.yatak", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
            new("oda.duzenle", "✎ Düzenle", "yatan", Kisayol: "Enter",
                KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("oda.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "yatan.yatak", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 30, UrunModu: 2,
                Ipucu: "Yatağı olan oda silinemez; pasife alın"),
            Yazdir(),
        };

        // ORDER LISTESI (695): talimat kaydi - eklenir, duzeltilir,
        //   DURDURULUR. Silme sag tusta: uygulanmis dozu olan order
        //   silinirse "bu ilac neden verildi" sorusu cevapsiz kalir.
        //   Sozel order imzalama AYRI YETKI (yatan.order.imza): uygulayan
        //   hemsire kendi imzalayamaz.
        s["yatis-order-liste"] = new AksiyonTanimi[]
        {
            new("yatis-order.yeni",    "＋ Yeni Order", "yatan", Kisayol: "Ctrl+N",
                KaynakKodu: "yatan.order", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
            new("yatis-order.duzenle", "✎ Düzenle", "yatan", Kisayol: "Enter",
                KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("yatan.order-imzala",  "✍ Sözel Order İmzala", "yatan",
                AksiyonYetkisi: "yatan.order.imza", KayitGerekir: true,
                Sira: 30, UrunModu: 2, Bicim: "onay"),
            new("yatan.order-durdur",  "⏸ Order Durdur", "yatan",
                KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 40, UrunModu: 2,
                Ipucu: "Gelecekteki bekleyen dozlar düşer, geçmiş kalır"),
            // 968 (mockup order_listesi_v2): kopya order - doz değiştirmede eskisi durur.
            new("yatan.order-doz-degistir", "✎ Doz Değiştir", "yatan",
                KaynakKodu: "yatan.order", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 42, UrunModu: 2,
                Ipucu: "Order durdurulur, aynı bilgilerle yeni order açılır"),
            new("yatan.order-tekrarla", "⟳ Tekrarla", "yatan",
                KaynakKodu: "yatan.order", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 44, UrunModu: 2,
                Ipucu: "Aynı bilgilerle yeni order (başlangıç şimdi)"),
            new("yatis-order.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet",
                Kisayol: "Del", KaynakKodu: "yatan.order", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 50, UrunModu: 2,
                Ipucu: "Uygulanmış dozu olan order silinmez; durdurun"),
            Yazdir(),
        };

        // DOZ KUYRUGU (698): satir PLANLANMIS DOZDUR ve order'dan uretilir.
        //   ELLE EKLEME/SILME YOK - elle eklenen doz planin disinda kalir,
        //   silinen doz "verilmedi mi, hic planlanmadi mi" sorusunu
        //   cevapsiz birakir. Doz yalniz UYGULANIR ya da sebebiyle ATLANIR.
        s["order-uygulama-liste"] = new AksiyonTanimi[]
        {
            new("yatan.doz-uygula", "💉 Uygulandı", "yatan",
                KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay"),
            new("yatan.doz-atla",   "⤫ Atlandı (sebep gir)", "yatan",
                KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "ret"),
            Yazdir(),
        };

        // HEMSIRE IZLEMI (699): olcum ve gozlem HUKUKI KAYITTIR -
        //   duzeltilmez, silinmez; yanlis kayit yeni bir satirla duzeltilir
        //   ve ikisi de durur. Bu yuzden listede duzenle/sil YOK.
        s["yatis-izlem-liste"] = new AksiyonTanimi[]
        {
            new("yatan.izlem-bildir", "🔔 Hekime Bildirildi", "yatan",
                KaynakKodu: "yatan.izlem", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2,
                Ipucu: "Eşiği aşan ölçüm için bildirim kaydı yazar"),
            Yazdir(),
        };

        // HIZMET ICMALI (700): tahakkuk ELLE GIRILMEZ, gun sonu isinden
        //   duser - elle giris acik olsaydi ayni gun hem otomatik hem elle
        //   iki kez faturalanirdi. Yeniden hesaplama, isin atladigi bir
        //   gunu kapatmak icin.
        s["yatis-tahakkuk-liste"] = new AksiyonTanimi[]
        {
            new("yatan.tahakkuk-hesapla", "🔄 Gün Sonunu Yeniden Çalıştır", "yatan",
                KaynakKodu: "yatan", Islem: Islem.Degistir, Sira: 10, UrunModu: 2,
                Ipucu: "Seçili satırın günü için yatak/refakat tahakkukunu üretir"),
            Yazdir(),
        };

        // RADYOLOJI CALISMA LISTESI (283): modulun giris ekrani. Durum
        //   akisi dugmelerle ilerler - "Cekildi" teknisyenin, rapor ve
        //   onay hekimin islemidir, o yuzden AYRI aksiyon yetkileri
        //   (rad.rapor_yaz / rad.rapor_onayla) uzerinden yonetilir.
        s["radyoloji-liste"] = new AksiyonTanimi[]
        {
            // "Yeni İstem" YOK (kullanıcı kuralı): radyoloji istemi YALNIZ
            //   başvurudan açılır - kayıt-kabul (dış hasta → başvuru + istem)
            //   ya da muayeneden hekim isteği. Çalışma listesi bir İŞ
            //   listesidir; buradan boş kart açmak başvurusuz (ücretsiz,
            //   ödeyensiz) istem üretirdi.
            new("radyoloji.duzenle",  "✎ Aç / Düzenle", "radyoloji", Kisayol: "Enter",
                KaynakKodu: "radyoloji", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20),
            // RANDEVU (316): radyolojide randevu CIHAZA verilir; kayit yine
            //   public.randevu'ya gider - ayri modul degil.
            new("radyoloji.randevu",  "📅 Randevu Ver", "radyoloji",
                KaynakKodu: "randevu", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 25),
            new("radyoloji.cekildi",  "✔ Çekildi İşaretle", "radyoloji",
                KaynakKodu: "radyoloji", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30),
            // SARF (320): cekimde kullanilan kontrast/malzeme stoktan duser.
            //   Cekim isaretlenince kendiliginden acilir; buton atlanmis ya
            //   da sonradan duzeltilecek dusum icin.
            new("radyoloji.sarf",     "🧪 Sarf Düş", "radyoloji",
                KaynakKodu: "stok", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 35),
            new("radyoloji.rapor",    "✎ Rapor Yaz", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 40),
            // TESLIM (304): film/CD/basili rapor kime verildi - sonuc
            //   kisisel saglik verisi, "kime verdik" kayda gecer.
            new("radyoloji.teslim",   "📦 Sonuç Teslim Et", "radyoloji",
                AksiyonYetkisi: "rad.teslim", KayitGerekir: true, Sira: 45),
            new("radyoloji.iptal",    "✖ İstemi İptal Et", "radyoloji",
                AksiyonYetkisi: "rad.istem_iptal", KayitGerekir: true, Sira: 50),
        };

        // KRITIK BULGU TAKIBI (318): rapor ekraninda isaretlenen bulgunun
        //   HABER VERILDIGININ takibi. Bildirim ve kapatma ayri islemdir:
        //   kapatma karsi tarafin teyidini ifade eder.
        s["radyoloji-kritik-liste"] = new AksiyonTanimi[]
        {
            new("radyoloji.kritik-bildir", "📞 Bildirimi Kaydet", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 10),
            new("radyoloji.kritik-kapat",  "✔ Kapat (teyit alındı)", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 20),
            new("radyoloji.istem-ac",      "👁 İstemi Aç", "radyoloji",
                KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
            new("radyoloji.rapor",         "📄 Raporu Aç", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 40),
        };

        // KONSULTASYON TAKIBI (318): istenen ikinci gorusler.
        s["radyoloji-konsultasyon-liste"] = new AksiyonTanimi[]
        {
            new("radyoloji.konsultasyon-cevap", "✎ Cevabı Yaz", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 10),
            new("radyoloji.istem-ac",           "👁 İstemi Aç", "radyoloji",
                KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("radyoloji.rapor",              "📄 Raporu Aç", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 30),
        };

        // SONUC TESLIM TAKIBI (318): raporu onayli ama teslim edilmemis
        //   isler. Teslim modali calisma listesindekiyle AYNI.
        s["radyoloji-teslim-liste"] = new AksiyonTanimi[]
        {
            new("radyoloji.teslim",   "📦 Teslim Et", "radyoloji",
                AksiyonYetkisi: "rad.teslim", KayitGerekir: true, Sira: 10),
            new("radyoloji.istem-ac", "👁 İstemi Aç", "radyoloji",
                KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("radyoloji.rapor",    "📄 Raporu Aç", "radyoloji",
                AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 30),
        };

        // TELERADYOLOJI CALISMA LISTESI (799). 797'de `telerad.ata` ve
        //   `telerad.teslim` yetkileri rollere dagitilmisti ama hicbir
        //   aksiyon onlari kullanmiyordu: ekranin arac cubugu hic yoktu
        //   (liste tanimi `aksiyonEkrani` vermeyince GenGrid cubugu
        //   cizmiyor), yani istek ne acilabiliyor ne de akis
        //   ilerletilebiliyordu - kart yalniz cift tikla aciliyordu.
        //
        // DURUM DEGISIKLIGI DUGMELERLE: radyoloji worklist'iyle ayni desen.
        //   Durum alani kartta da secilebilir; dugme ayni gecisi TEK tikla
        //   ve dogru zaman damgasiyla yapar (damgalari tetik yazar).
        s["telerad-istek-liste"] = new AksiyonTanimi[]
        {
            new("telerad.yeni",     "＋ Yeni İstek", "telerad", Kisayol: "Ctrl+N",
                KaynakKodu: "teleradyoloji", Islem: Islem.Ekle, Sira: 10),
            new("telerad.duzenle",  "✎ Düzenle", "telerad", Kisayol: "Enter",
                KaynakKodu: "teleradyoloji", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20),
            // BANA ATA: dagitim yetkisi ayri (`telerad.ata`) - isi kimin
            //   alacagina karar vermek okumaktan farkli bir yetkidir.
            new("telerad.ata",      "👤 Bana Ata", "telerad",
                AksiyonYetkisi: "telerad.ata", KayitGerekir: true, Sira: 30,
                Ipucu: "İsteği üstüne alır (durum: Atandı)"),
            // OTOMATİK DAĞIT (801): sıradaki atanmamış işleri kurallara
            //   göre radyologlara paylaştırır. KAYIT SEÇİMİ İSTEMEZ -
            //   işi tek tek seçtirmek, "gece listeye bakan kimse yok"
            //   sorununu çözmezdi. Kuralı sunucu yorumlar
            //   (`fn_telerad_radyolog_oner`), ekran kural bilmez.
            new("telerad.dagit",    "🤖 Otomatik Dağıt", "telerad",
                AksiyonYetkisi: "telerad.ata", Sira: 32,
                Ipucu: "Sıradaki işleri nöbet çizelgesi ve atama kurallarına göre dağıtır"),
            new("telerad.birak",    "↩ Atamayı Bırak", "telerad",
                Hedef: "sagtus,palet", AksiyonYetkisi: "telerad.ata",
                KayitGerekir: true, Sira: 35, Ipucu: "İstek sıraya geri döner"),
            // OKUMAYA BASLA: `okuma_bas` damgasi buradan dogar - SLA
            //   raporlamasinda "sirada bekleme" ile "okuma suresi" ancak
            //   bu damga varsa ayrilabilir.
            // IS AKISI AYRI YETKIDE (805): kaynak yetkisine bagliyken
            //   portal kullanicisinin (dis kurum) cubugunda da
            //   gorunuyordu - veritabani engelliyordu ama HER ZAMAN HATA
            //   VEREN DUGME gostermek kullaniciya yalan soylemektir.
            new("telerad.oku",      "▶ Okumaya Başla", "telerad",
                AksiyonYetkisi: "telerad.akis",
                KayitGerekir: true, Sira: 40, Bicim: "bir"),
            new("telerad.teslim",   "📦 Teslim Et", "telerad",
                AksiyonYetkisi: "telerad.teslim", KayitGerekir: true, Sira: 50,
                Bicim: "onay", Ipucu: "Onaylı raporu gönderen kuruma teslim eder"),
            // YAZIŞMA (806): gönderen kurum ile radyolog arasındaki
            //   mesajlaşma. Sohbeti sunucu açar ve üyelerini o belirler;
            //   düğme MESAJ yetkisine bağlı - yazışma mesajlaşma
            //   modülünün işidir, teleradyolojinin ikinci bir sohbet
            //   altyapısı yoktur.
            new("telerad.mesaj",    "💬 Yazışma", "telerad",
                KaynakKodu: "mesaj", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 55,
                Ipucu: "Bu isteğin kurum ↔ radyolog yazışmasını açar"),
            new("telerad.iptal",    "✖ İsteği İptal Et", "telerad",
                Hedef: "sagtus,palet", AksiyonYetkisi: "telerad.akis",
                KayitGerekir: true, Sira: 60, Bicim: "ret"),
            new("telerad.sil",      "🗑 Sil", "telerad", Hedef: "sagtus,palet",
                Kisayol: "Del", KaynakKodu: "teleradyoloji", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 70),
            Yazdir(),
        };

        // TESLIM KUYRUGU (814). Kuyrukta yapilabilecek uc sey var:
        //   yeniden dene, iptal et, mesaji gor. "Yeni kayit" YOK - kuyruk
        //   satiri elle acilmaz, teslim akisindan dogar.
        s["telerad-teslim-liste"] = new AksiyonTanimi[]
        {
            new("telerad.teslim_dene", "↻ Yeniden Dene", "telerad",
                AksiyonYetkisi: "telerad.teslim_kuyruk", KayitGerekir: true,
                Sira: 10, Bicim: "bir",
                Ipucu: "Mesaji yeniden uretip gonderir - duzeltme yapildiysa "
                     + "kalici hataya dusmus satir da denenebilir"),
            new("telerad.teslim_iptal", "✖ Kuyruktan Çıkar", "telerad",
                Hedef: "sagtus,palet", AksiyonYetkisi: "telerad.teslim_kuyruk",
                KayitGerekir: true, Sira: 20, Bicim: "ret",
                Ipucu: "Gonderilmeyecek is her gun yeniden denenmesin"),
            new("telerad.teslim_istek", "🔎 İsteğe Git", "telerad",
                KaynakKodu: "teleradyoloji", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 30),
            Yazdir(),
        };

        // GELEN RAPORLAR (817). Eslesmeyen rapor iki sekilde cozulur:
        //   dogru ise ELLE BAGLANIR ya da ham mesaja bakilip karsi tarafa
        //   sorulur. "Yeni kayit" YOK - satir disaridan dogar.
        s["telerad-gelen-liste"] = new AksiyonTanimi[]
        {
            new("telerad.gelen_bagla", "🔗 İsteğe Bağla", "telerad",
                AksiyonYetkisi: "telerad.gelen", KayitGerekir: true, Sira: 10,
                Bicim: "bir",
                Ipucu: "Eslesmeyen raporu dogru isteğe baglar ve raporu yazar"),
            new("telerad.gelen_istek", "🔎 İsteğe Git", "telerad",
                KaynakKodu: "teleradyoloji", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 20),
            Yazdir(),
        };

        // KURUM VE SOZLESME (800): isin SARTLARI. Kart yoktu, bu yuzden
        //   arac cubugu da yoktu - iliski yalniz gocle/betikle
        //   kurulabiliyordu.
        //
        // SILME SAG TUSTA: kurum silinince sozlesmeleri de gider
        //   (`on delete cascade`, 797) - gunluk akisin dugmesi degildir.
        s["telerad-kurum-liste"] =
        [
            .. Crud("telerad-kurum", "telerad", "teleradyoloji.kurum",
                    ekleAdi: "＋ Yeni Kurum",
                    silIpucu: "Kurumla birlikte sözleşmeleri de silinir"),
            // DÖNEM FATURASI (803): kurum seçili olarak fatura ekranını
            //   açar. Teleradyoloji işi tek tek faturalanmaz - dönem sonunda
            //   o kurumun onaylı işleri TEK satış faturasına girer.
            new("telerad.faturala", "🧾 Dönem Faturası", "telerad",
                AksiyonYetkisi: "telerad.faturala", KayitGerekir: true, Sira: 40,
                Ipucu: "Dönemin onaylı işlerini tek satış faturasına toplar"),
        ];
        // NÖBET ÇİZELGESİ ve ATAMA KURALLARI (801): tanım ekranları.
        //   Günlük işin (`telerad.ata`) değil KURULUMUN yetkisiyle -
        //   gece okuyan radyologa kural değiştirme hakkı vermeden atama
        //   hakkı verilebilsin.
        s["telerad-nobet-liste"] =
            Crud("telerad-nobet", "telerad", "teleradyoloji.nobet",
                 ekleAdi: "＋ Yeni Nöbet");
        s["telerad-kural-liste"] =
            Crud("telerad-kural", "telerad", "teleradyoloji.kural",
                 ekleAdi: "＋ Yeni Kural");
        s["telerad-sozlesme-liste"] =
            Crud("telerad-sozlesme", "telerad", "teleradyoloji.sozlesme",
                 ekleAdi: "＋ Yeni Sözleşme");

        // ENTEGRASYON HESAPLARI (336): Ayarlar > Kayit Kabul > Entegrasyon.
        // KATEGORILER (345): iki bolmeli ekran - her iki gridin de kendi
        //   arac cubugu var, aksiyonlar ortak.
        s["kategori-liste"] = new AksiyonTanimi[]
        {
            new("kategori.yeni",    "＋ Yeni", "stok",
                Islem: Islem.Ekle, Sira: 10),
            new("kategori.duzenle", "✎ Düzenle", "stok",
                Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("kategori.sil",     "🗑 Sil", "stok",
                Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
        };

        s["entegrasyon-liste"] = new AksiyonTanimi[]
        {
            new("entegrasyon.yeni",     "＋ Yeni", "entegrasyon",
                Islem: Islem.Ekle, Sira: 10),
            new("entegrasyon.duzenle",  "✎ Düzenle", "entegrasyon",
                Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("entegrasyon.sil",      "🗑 Sil", "entegrasyon",
                Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            // Baglanti sinama: kimlik dogru mu, adres ayakta mi.
            new("entegrasyon.sina",     "🔌 Bağlantıyı Sına", "entegrasyon",
                Islem: Islem.Gor, KayitGerekir: true, Sira: 40),
            // KANAL SINAMASI (820): SMS/e-posta hesabina GERCEK mesaj.
            //   Adres denemesi kanalda hicbir sey soylemiyor - kullanici
            //   adi yanlis olsa da sunucu ayakta gorunur. DEGISTIR yetkisi
            //   ister: disariya mesaj gider, SMS ucretlidir.
            new("entegrasyon.test-bildirim", "✉ Test Mesajı Gönder",
                "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 45),
            // SKRS: kod listelerini servisten cekip yerel listeleri tazeler.
            new("entegrasyon.skrs-senkron", "⟳ SKRS Listelerini Güncelle",
                "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50,
                UrunModu: 2),
            // SKRS klinik kodlarini BOLUM KODUNA yazar (455): e-Nabiz
            //   paketlerindeki klinik alani bolum kodundan okunur.
            new("entegrasyon.skrs-klinik", "🏥 SKRS Klinik Kodlarını Eşle",
                "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 55,
                UrunModu: 2),
        };

        // HAKEDIS SATIRLARI (324): satirlar tahsilattan DOGAR - elle
        //   eklenmez. Buradaki aksiyonlar kaynaga gitmek ve donem
        //   kapatmak icindir.
        s["hakedis-liste"] = new AksiyonTanimi[]
        {
            new("hakedis.donem-kapat", "🔒 Dönemi Kapat", "prim",
                AksiyonYetkisi: "prim.donem_kapat", Sira: 10),
            new("hakedis.kalem",       "↗ Kalemi Aç", "prim",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("hakedis.roller",      "👥 Rolleri Düzenle", "prim",
                KaynakKodu: "prim", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30),
            // ONAY (330): satiri kilitler - sonradan rol/belge turu
            //   degisse bile prim yeniden hesaplanmaz.
            new("hakedis.onayla",      "✔ Onayla", "prim",
                AksiyonYetkisi: "prim.onayla", KayitGerekir: true, Sira: 40),
            new("hakedis.onay-kaldir", "↩ Onayı Kaldır", "prim",
                AksiyonYetkisi: "prim.onayla", KayitGerekir: true, Sira: 50),
        };

        // HAKEDIS BASLIKLARI (324): kapatilmis donemler.
        s["hakedis-donem"] = new AksiyonTanimi[]
        {
            new("hakedis.donem-kapat", "🔒 Dönemi Kapat", "prim",
                AksiyonYetkisi: "prim.donem_kapat", Sira: 10),
            new("hakedis.satirlar",    "📄 Satırları Gör", "prim",
                KaynakKodu: "prim", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
        };

        // RANDEVU (243): liste + takvim gorunumu ayni ekranda.
        s["randevu-liste"] = new AksiyonTanimi[]
        {
            new("randevu.yeni",     "＋ Yeni",   "randevu", Kisayol: "Ctrl+N",
                KaynakKodu: "randevu", Islem: Islem.Ekle, Sira: 10),
            new("randevu.duzenle",  "✎ Düzenle", "randevu", Kisayol: "Enter",
                KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("randevu.geldi",    "✔ Geldi",   "randevu",
                KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
            new("randevu.gelmedi",  "✖ Gelmedi", "randevu",
                KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
            // Randevudan BASVURUYA (265): hasta geldiginde poliklinik
            //   basvurusu acilir, randevunun hizmeti kalem olur.
            new("randevu.basvuru",  "➜ Başvuruya Dönüştür", "belge",
                KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 45),
            new("randevu.iptal",    "⊘ İptal",   "randevu", Hedef: "sagtus,palet",
                KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50),
            new("randevu.sil",      "🗑 Sil",    "randevu", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "randevu", Islem: Islem.Sil, KayitGerekir: true, Sira: 60),
            new("genel.yazdir",     "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // Aday musteriler (122). "Müşteriye Dönüştür" kaydi TASIMAZ, bayragi
        //   degistirir - firsat/gorev/adres gecmisi ayni kayitta kalir.
        s["aday-liste"] = new AksiyonTanimi[]
        {
            new("aday.yeni",      "＋ Yeni",   "cari", Kisayol: "Ctrl+N",
                KaynakKodu: "cari", Islem: Islem.Ekle, Sira: 10),
            new("aday.duzenle",   "✎ Düzenle", "cari", Kisayol: "Enter",
                KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("aday.donustur",  "🤝 Müşteriye Dönüştür", "cari",
                KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
            new("aday.sil",       "🗑 Sil",       "cari", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
            new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // Hesap ekranlari (Kasa / Banka / POS / Kredi Karti / Kredi) - hepsi
        //   ayni 'hesap' kaynagi, tur'e gore ayri liste.
        s["hesap-liste"] = Crud("hesap", "hesap", "hesap", "＋ Ekle", silHedef: null);

        // Cek / Senet portfoyu. Cek uzerindeki ISLEMLER (tahsil/ciro/bozdurma)
        //   kasa turleriyle yapilir - Kasa planinin F5 fazinda baglanacak;
        //   burada simdilik kart islemleri var.
        s["cek-senet-liste"] = Crud("cek-senet", "cek-senet", "cek_senet", "＋ Ekle", silHedef: null);

        // Salt-gorunum ekranlari (ekstre, mizan...): yalniz cikti alma.
        //   "Yazdır" dugmesi acilir menusunde CSV Kaydet de var (GenGrid ekler).
        s["cikti-liste"] = [Yazdir()];

        // DOKUMAN ONAY KUYRUGU (419): satir = ADIM. Karar iki secenek -
        //   onay ya da ret; ret dokumani TASLAGA dondurur, hazirlayan
        //   duzeltip yeni surum acar (reddedilen surumu yeniden onaya
        //   gondermek, neyin degistigini gorunmez kilardi).
        s["dokuman-onay-liste"] =
        [
            new("dokuman.onay", "✔ Onayla", "dokuman-onay",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman.onayla", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("dokuman.ret", "✖ Reddet", "dokuman-onay",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman.onayla", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            Yazdir(),
        ];

        // DOKUMAN LISTESI (419) - mockup dokuman_listesi.html dugmeleri.
        //   YUKLE ve SABLONDAN URET burada YOK: ikisi de dosya secimi ve
        //   kaynak belirlemesi ister, kart galerisinden yurur. Buraya
        //   koymak, listede kaynagi olmayan bir dokuman acmak olurdu.
        // DOKUMAN LISTESI - dugme SIRASI mockuptaki gibi
        //   (Ekranlar/Dokuman/dokuman_listesi.html): Yukle · Duzenle · Sil ·
        //   Indir · Paylas · Bagla · Tasi · Etiket · Onaya Gonder ·
        //   Surum Gecmisi · Depo. "Sablondan Olustur" YOK: sablon
        //   ozelligi henuz kurulmadi, calismayan dugme koymuyoruz.
        s["dokuman-liste"] =
        [
            new("dokuman.yukle", "＋ Yükle", "dokuman",
                Hedef: "araccubugu,palet",
                KaynakKodu: "dokuman", Islem: Islem.Ekle, Sira: 5),
            new("dokuman.duzenle", "✎ Düzenle", "dokuman",
                Hedef: "araccubugu,sagtus,palet", Kisayol: "Enter",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("dokuman.sil", "🗑 Sil", "dokuman",
                Hedef: "araccubugu,sagtus,palet", Kisayol: "Del",
                KaynakKodu: "dokuman", Islem: Islem.Sil, KayitGerekir: true, Sira: 15),
            new("dokuman.ac", "⬇ Aç / İndir", "dokuman",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("dokuman.paylas", "🔗 Paylaş", "dokuman",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 25),
            new("dokuman.bagla", "🔀 Bağla (kaynak)", "dokuman",
                Hedef: "sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 30),
            new("dokuman.tasi", "🗂 Taşı (klasör)", "dokuman",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 35),
            new("dokuman.etiket", "🏷 Etiket", "dokuman",
                Hedef: "sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 40),
            new("dokuman.gizlilik", "🔒 Gizlilik Sınıfı", "dokuman",
                Hedef: "sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 45),
            new("dokuman.onaya-gonder", "✔ Onaya Gönder", "dokuman",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 50),
            // SURUM GECMISI ARAC CUBUGUNDAN KALDIRILDI (kullanici):
            //   surumler dokuman KARTININ kendi sekmesinde duruyor,
            //   listede ayri dugme gerekmiyor. Sag tus ve komut
            //   paletinde kaliyor - hizli erisim isteyen bulsun.
            new("dokuman.surum", "🧾 Sürüm Geçmişi", "dokuman",
                Hedef: "sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Gor, KayitGerekir: true, Sira: 55),
            new("dokuman.depo", "📊 Depo Kullanımı", "dokuman",
                Hedef: "araccubugu,palet",
                KaynakKodu: "dokuman", Islem: Islem.Gor, Sira: 60),
            Yazdir(),
        ];

        // DOKUMAN AYARLARI (431): kategori ve klasor artik EKLENIP
        //   DEGISTIRILEBILIYOR. Kullanilan kayit silinemez - kural
        //   SilmeEngelleri'nde (sunucu), dugme yine gosterilir ki
        //   kullanici sebebini ogrensin.
        s["dokuman-kategori-liste"] = Crud("dokuman-kategori", "dokuman-kategori",
                                          "dokuman", "＋ Yeni", silHedef: null,
                                          yazdir: false);
        s["dokuman-klasor-liste"]   = Crud("dokuman-klasor", "dokuman-klasor",
                                          "dokuman", "＋ Yeni", silHedef: null,
                                          yazdir: false);

        // CIHAZ ARA KATMANI (432). Mesaj listesi salt gorunum: kayit
        //   cihazdan gelir, elle eklenmez. "Yeniden Isle" surucu
        //   duzeltildikten sonra ayni ham metni tekrar cozumler.
        s["cihaz-liste"] =
        [
            .. Crud("cihaz", "cihaz", "cihaz", "＋ Yeni", silHedef: null, yazdir: false),
            new("cihaz.klasor-tara", "📂 Klasörleri Tara", "cihaz",
                Hedef: "araccubugu,palet",
                AksiyonYetkisi: "cihaz.isle", Sira: 40),
        ];

        s["cihaz-mesaj-liste"] =
        [
            new("cihaz.yeniden-isle", "↻ Yeniden İşle", "cihaz-mesaj",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "cihaz.isle", KayitGerekir: true, Sira: 10),
            // COZUMLEME ile SONUCA YAZMA ayri adimlar (433): mesaj
            //   cozumlenmis olabilir ama barkod hic eslesmemistir.
            //   Tek dugmede birlesseydi, eslesmeyen mesaj "islendi"
            //   gorunur ve sonuc kaybolurdu.
            new("lab.mesaj-sonuca-aktar", "🧪 Lab Sonucuna Aktar", "cihaz-mesaj",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.sonuc", KayitGerekir: true, Sira: 15),
            Yazdir(),
        ];

        // SIGORTA v1 (430). Provizyon BASVURU KARTINDAN alinir; buradaki
        //   liste takip ve duzeltme icindir: tazele (searchProvisions),
        //   iptal (cancelProvision), dokuman gonderimi.
        //   Yapilamayacak adim GIZLENMEZ - sunucu sebebini soyler.
        s["sigorta-provizyon-liste"] =
        [
            new("sigorta.tazele", "↻ Durumu Tazele", "sigorta-provizyon",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "sigorta", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
            new("sigorta.dokuman", "📎 Doküman Gönder", "sigorta-provizyon",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "sigorta.provizyon", KayitGerekir: true, Sira: 20),
            new("sigorta.basvuru", "📝 Başvuruya Git", "sigorta-provizyon",
                Hedef: "sagtus,palet",
                KaynakKodu: "sigorta", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
            new("sigorta.iptal", "✖ Provizyonu İptal Et", "sigorta-provizyon",
                Hedef: "sagtus,palet",
                AksiyonYetkisi: "sigorta.iptal", KayitGerekir: true, Sira: 40),
            Yazdir(),
        ];

        s["sigorta-hesap-liste"] =
        [
            .. Crud("sigorta-hesap", "sigorta-hesap", "sigorta", "＋ Yeni",
                    silHedef: null, yazdir: false),
            // BAGLANTI TESTI: jeton akisini ve kimlik bilgilerini dogrular,
            //   hicbir kayit olusturmaz. Kapinin acik olup olmadigi ancak
            //   boyle anlasilir - ilk provizyonda ogrenmek gec olur.
            new("sigorta.hesap-test", "🔌 Bağlantıyı Test Et", "sigorta-hesap",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "sigorta.ayar", KayitGerekir: true, Sira: 40),
        ];

        s["sigorta-kod-esleme-liste"] = Crud("sigorta-kod-esleme", "sigorta-kod-esleme",
                                            "sigorta", "＋ Yeni", silHedef: null,
                                            yazdir: false);

        s["sigorta-istek-log-liste"] = [Yazdir()];

        // URETIM v1 (429). Dugme SIRASI akisin sirasidir: emri ac,
        //   malzemeyi rezerve et, onayla, baslat (sarf), mamul gir, maliyeti
        //   kapat, emri kapat. Yapilamayacak adim GIZLENMEZ - sunucu sebebini
        //   soyler; gizlenen dugme "neden yapamiyorum" sorusunu cevapsiz
        //   birakirdi (ITS ile ayni gerekce).
        s["urun-agaci-liste"] =
        [
            .. Crud("urun-agaci", "urun-agaci", "uretim"),
            new("urun-agaci.maliyet", "🧮 Maliyet Hesapla", "urun-agaci",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
            new("urun-agaci.yeni-surum", "⧉ Yeni Sürüm", "urun-agaci",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Ekle, KayitGerekir: true, Sira: 50),
            new("urun-agaci.nerede", "🔎 Nerede Kullanılıyor", "urun-agaci",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
            new("urun-agaci.emir-ac", "🏭 Üretim Emri Aç", "urun-agaci",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Ekle, KayitGerekir: true, Sira: 70),
        ];

        s["uretim-emri-liste"] =
        [
            .. Crud("uretim-emri", "uretim-emri", "uretim"),
            new("uretim.rezerve", "🔒 Malzeme Rezerve", "uretim-emri",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
            new("uretim.eksik", "⚠ Eksik Malzeme", "uretim-emri",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Gor, KayitGerekir: true, Sira: 45),
            new("uretim.onayla", "✔ Onayla", "uretim-emri",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "uretim.onayla", KayitGerekir: true, Sira: 50),
            new("uretim.baslat", "▶ Üretime Başlat", "uretim-emri",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 55),
            new("uretim.sarf", "📤 Malzeme Sarf Fişi", "uretim-emri",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 60),
            new("uretim.mamul-giris", "📦 Mamul Girişi", "uretim-emri",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 65),
            new("uretim.fire", "🔥 Fire / Ret", "uretim-emri",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 70),
            new("uretim.agactan-yenile", "↻ Ağaçtan Yenile", "uretim-emri",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 75),
            new("uretim.maliyet-kapat", "🧮 Maliyet Kapat", "uretim-emri",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "uretim.maliyet", KayitGerekir: true, Sira: 80),
            new("uretim.kapat", "🔒 Emri Kapat", "uretim-emri",
                Hedef: "sagtus,palet",
                AksiyonYetkisi: "uretim.maliyet", KayitGerekir: true, Sira: 82),
            new("uretim.iptal", "✖ İptal Et", "uretim-emri",
                Hedef: "sagtus,palet",
                KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 85),
        ];

        s["is-merkezi-liste"] = Crud("is-merkezi", "is-merkezi", "uretim",
                                    "＋ Yeni", silHedef: null, yazdir: false);
    }
}
