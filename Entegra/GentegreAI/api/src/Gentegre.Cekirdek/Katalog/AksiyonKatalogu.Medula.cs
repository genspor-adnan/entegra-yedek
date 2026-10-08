using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Medula (707) ve saglik raporlari, provizyon kuyruklari.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleMedula(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        // ================================================== MEDULA (707) ==
        // Takip listesi: satir BASVURU; hasta kabul / hizmet kaydi ozel sayfalari
        //   satirdan acilir. Ekle/sil yok - basvuru Kayit Kabul'de acilir.
        s["medula-takip-liste"] = new AksiyonTanimi[]
        {
            new("medula.kabul-ac",   "🪪 Hasta Kabul / Provizyon", "medula",
                KaynakKodu: "medula.provizyon", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("medula.hizmet-ac",  "🧾 Hizmet Kaydı", "medula",
                KaynakKodu: "medula.hizmet", Islem: Islem.Gor, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("medula.cikis",      "🚪 Hasta Çıkışı", "medula",
                KaynakKodu: "medula.provizyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2,
                Ipucu: "Takip kapatılır; fatura ancak çıkıştan sonra kesilir"),
            new("medula.fatura-kaydet", "🧮 Fatura Kaydet", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2),
            Yazdir(),
        };
        s["medula-islem-liste"] = new AksiyonTanimi[]
        {
            new("medula.hizmet-ac",  "🧾 Hizmet Kaydı Ekranı", "medula",
                KaynakKodu: "medula.hizmet", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("medula.islem-iptal", "✖ Kaydı İptal Et", "medula",
                KaynakKodu: "medula.hizmet", Islem: Islem.Sil, KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay"),
            new("medula.islem-yerel", "💳 Hastaya Ücretli Bırak", "medula",
                KaynakKodu: "medula.hizmet", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
            Yazdir(),
        };
        s["medula-fatura-liste"] = new AksiyonTanimi[]
        {
            new("medula-fatura.duzenle", "✎ Aç", "medula", Kisayol: "Enter",
                KaynakKodu: "medula.fatura", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
            new("medula.fatura-iptal", "✖ Fatura İptal", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Sil, KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay"),
            new("medula.kesinti-ekle", "➖ Kesinti Yaz", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("medula.donem-ac",   "📅 Fatura & Dönem Ekranı", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Gor, Sira: 40, UrunModu: 2),
            Yazdir(),
        };
        s["medula-donem-liste"] = new AksiyonTanimi[]
        {
            new("medula-donem.duzenle", "✎ Aç", "medula", Kisayol: "Enter",
                KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("medula.donem-ac",   "📅 Fatura & Dönem Ekranı", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Gor, Sira: 20, UrunModu: 2),
            Yazdir(),
        };
        s["medula-kesinti-liste"] =
        [
            .. Crud("medula-kesinti", "medula", "medula.fatura", ekleAdi: "＋ Kesinti", yazdir: false),
            new("medula.itiraz",     "📝 İtiraz Et", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("medula.itiraz-sonuc", "⚖ İtiraz Sonucu", "medula",
                KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2),
            Yazdir(),
        ];
        s["medula-rapor-liste"] =
        [
            .. Crud("medula-rapor", "medula", "medula.recete", ekleAdi: "＋ Rapor", yazdir: false),
            new("medula.rapor-gonder", "📤 Medula'ya Gönder", "medula",
                KaynakKodu: "medula.recete", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "onay"),
            Yazdir(),
        ];
        // e-Recete: recete listesinin Medula gorunumu - imzala, gonder, sil.
        s["medula-recete-liste"] = new AksiyonTanimi[]
        {
            new("recete.duzenle", "✎ Reçeteyi Aç", "medula", Kisayol: "Enter",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("medula.recete-imzala", "✍ İmzala", "medula",
                KaynakKodu: "medula.recete", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2,
                Ipucu: "Taslak → imzalı; alerji kontrolü burada"),
            new("medula.recete-gonder", "📤 Medula'ya Gönder", "medula",
                KaynakKodu: "medula.recete", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "onay"),
            new("medula.recete-sil", "🗑 Medula'dan Sil", "medula", Hedef: "sagtus,palet",
                KaynakKodu: "medula.recete", Islem: Islem.Sil, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "onay",
                Ipucu: "Kabul edilmiş reçete değiştirilemez: sil + yeni"),
            Yazdir(),
        };
        s["medula-kuyruk-liste"] = new AksiyonTanimi[]
        {
            new("medula.kuyruk-gonder", "↻ Bekleyenleri Gönder", "medula",
                KaynakKodu: "medula", Islem: Islem.Degistir, Sira: 10, UrunModu: 2),
            new("medula.kuyruk-tekrar", "🔁 Yeniden Dene", "medula",
                KaynakKodu: "medula", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("medula.kuyruk-iptal", "✖ İptal Et", "medula", Hedef: "sagtus,palet",
                KaynakKodu: "medula", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "onay"),
            new("medula.kuyruk-ac",  "📡 Kuyruk & Ayarlar Ekranı", "medula",
                KaynakKodu: "medula", Islem: Islem.Gor, Sira: 40, UrunModu: 2),
            Yazdir(),
        };
        s["dis-unit-liste"] = Crud("dis-unit", "dis", "dis.unit", ekleAdi: "＋ Ünit", silHedef: null, silIpucu: "Seansı olan ünit silinmez; pasife alın");
        // CALISMA PLANI (711): sablon + istisna listeleri.
        // FTR (719): degerlendirme / program / seans / olcek / unite.
        // Ekle / Düzenle / Sil ARAC CUBUGUNDA (kullanici): silme engelleri sunucuda (KartKatalogu.Ftr SilmeEngelleri).
        // FORM MOTORU (740): şablon CRUD + kopyala/önizle; doldurulan formlar
        //   açılır, hatırlatılır, yeniden gönderilir; kurallar CRUD.
        s["form-sablon-liste"] =
        [
            .. Crud("form-sablon", "form", "form.sablon", ekleAdi: "＋ Şablon", silHedef: null, yazdir: false),
            new("form.sablon-kopyala", "⧉ Kopyala", "form", KaynakKodu: "form.sablon", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("form.sablon-onizle", "👁 Önizle / Test doldur", "form", KaynakKodu: "form.sablon", Islem: Islem.Gor, KayitGerekir: true, Sira: 41, UrunModu: 2),
            new("form.sablon-editor", "✎ Görsel editör", "form", KaynakKodu: "form.sablon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42, UrunModu: 2),
        ];
        s["form-istek-liste"] =
        [
            new("form.istek-ac", "📄 Aç / Doldur", "form", Kisayol: "Enter", KaynakKodu: "form.istek", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("form.istek-hatirlat", "🔔 Hatırlat", "form", KaynakKodu: "form.gonder", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("form.istek-yeniden", "🔁 Yeniden gönder", "form", KaynakKodu: "form.gonder", Islem: Islem.Ekle, KayitGerekir: true, Sira: 21, UrunModu: 2),
            new("form.istek-iptal", "✖ İptal", "form", Hedef: "sagtus,palet", KaynakKodu: "form.gonder", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
            Yazdir(),
        ];
        s["form-kural-liste"] = Crud("form-kural", "form", "form.kural", ekleAdi: "＋ Kural", silHedef: null, yazdir: false);
        // İŞYERİ HEKİMLİĞİ (741): firma/çalışan/ziyaret/olay CRUD + Ek-2 açma,
        //   SMS, çalışan kartı, SGK bildirimi. Muayene listesi formu açar.
        s["isg-firma-liste"] =
        [
            .. Crud("isg-firma", "isg", "isg.firma", ekleAdi: "＋ Firma", silHedef: null, yazdir: false),
            new("isg.firma-kart", "🏭 Firma panosu", "isg", KaynakKodu: "isg.firma", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
        ];
        s["isg-calisan-liste"] =
        [
            .. Crud("isg-calisan", "isg", "isg.calisan", ekleAdi: "＋ Çalışan", silHedef: null, yazdir: false),
            new("isg.calisan-kart", "👷 Çalışan kartı", "isg", KaynakKodu: "isg.calisan", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("isg.muayene-ac", "🩺 Ek-2 muayene aç", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 41, UrunModu: 2),
            new("isg.form-gonder", "📱 Formu gönder (SMS)", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 42, UrunModu: 2),
            new("isg.olay-bildir", "🚨 Olay bildir", "isg", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "isg.olay", Islem: Islem.Ekle, KayitGerekir: true, Sira: 50, UrunModu: 2),
        ];
        s["isg-muayene-liste"] =
        [
            new("isg.muayene-form", "📄 Ek-2 formu", "isg", Kisayol: "Enter", KaynakKodu: "isg.muayene", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("isg.muayene-isle", "✔ Kanaati işle", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("isg-muayene.duzenle", "✎ Düzenle", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("isg.muayene-iptal", "✖ İptal", "isg", Hedef: "sagtus,palet", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            Yazdir(),
        ];
        s["isg-ziyaret-liste"] = Crud("isg-ziyaret", "isg", "isg.ziyaret", ekleAdi: "＋ Ziyaret", silHedef: null);
        s["isg-olay-liste"] =
        [
            .. Crud("isg-olay", "isg", "isg.olay", ekleAdi: "＋ Olay", silHedef: null),
            new("isg.olay-sgk", "🏛 SGK'ya bildirildi", "isg", KaynakKodu: "isg.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("isg.olay-kapat", "✔ Kapat", "isg", Hedef: "sagtus,palet", KaynakKodu: "isg.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
        ];
        // ÇAĞRI MERKEZİ (839): çağrı kayıtları (kart özel sayfa), kampanya (üret / çalıştır /
        //   durdur), kişi sonucu, kalite; ayar listeleri konu / kuyruk / agent düz CRUD.
        s["cagri-liste"] =
        [
            new("cagri.kart", "📞 Çağrı kartı", "cagri", Kisayol: "Enter", KaynakKodu: "cagri.kayit", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("cagri.yeni-kayit", "＋ Elle çağrı kaydı", "cagri", Kisayol: "Ctrl+N", KaynakKodu: "cagri.kayit", Islem: Islem.Ekle, Sira: 11, UrunModu: 2),
            new("cagri.duzenle", "✎ Düzenle", "cagri", KaynakKodu: "cagri.kayit", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("cagri.geri-arama-tamam", "✔ Geri arama yapıldı", "cagri", Hedef: "sagtus,palet", KaynakKodu: "cagri.giden", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("cagri.kisi-ac", "👤 Kişi kartı", "cagri", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "cagri.kayit", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("cagri.sil", "🗑 Sil", "cagri", Kisayol: "Del", KaynakKodu: "cagri.kayit", Islem: Islem.Sil, KayitGerekir: true, Sira: 50, UrunModu: 2),
            Yazdir(),
        ];
        s["cagri-kampanya-liste"] =
        [
            .. Crud("cagri-kampanya", "cagri", "cagri.kampanya", ekleAdi: "＋ Kampanya", silHedef: null, yazdir: false),
            new("cagri.kampanya-kart", "📣 Kampanya panosu", "cagri", KaynakKodu: "cagri.kampanya", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("cagri.kampanya-uret", "🔄 Listeyi üret", "cagri", KaynakKodu: "cagri.kampanya", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
            new("cagri.kampanya-calistir", "▶ Çalıştır (mesaj gönder)", "cagri", KaynakKodu: "cagri.kampanya", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42, UrunModu: 2),
            new("cagri.kampanya-durdur", "⏸ Durdur", "cagri", Hedef: "sagtus,palet", KaynakKodu: "cagri.kampanya", Islem: Islem.Degistir, KayitGerekir: true, Sira: 43, UrunModu: 2),
        ];
        s["cagri-kampanya-kisi-liste"] =
        [
            new("cagri.kisi-ara", "📞 Ara (çağrı aç)", "cagri", Kisayol: "Enter", KaynakKodu: "cagri.giden", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("cagri.kisi-sonuc", "✔ Sonuç yaz", "cagri", KaynakKodu: "cagri.giden", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            Yazdir(),
        ];
        s["cagri-kalite-liste"] =
        [
            .. Crud("cagri-kalite", "cagri", "cagri.kalite", ekleAdi: "＋ Değerlendirme", silHedef: null, yazdir: false),
            new("cagri.kart", "📞 Çağrı kartı", "cagri", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "cagri.kalite", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            Yazdir(),
        ];
        s["cagri-konu-liste"] = Crud("cagri-konu", "cagri", "cagri.ayar", ekleAdi: "＋ Konu", silHedef: null, yazdir: false);
        s["cagri-kuyruk-liste"] = Crud("cagri-kuyruk", "cagri", "cagri.ayar", ekleAdi: "＋ Kuyruk", silHedef: null, yazdir: false);
        s["cagri-agent-liste"] = Crud("cagri-agent", "cagri", "cagri.ayar", ekleAdi: "＋ Agent", silHedef: null, yazdir: false);
        // STERİLİZASYON (868): döngü kartı / izleme; paket izleme / okutma; birim hazırlama adımları; tanım CRUD.
        s["steril-dongu-liste"] =
        [
            new("steril.dongu-kart", "♨️ Döngü kartı", "steril", Kisayol: "Enter", KaynakKodu: "steril.dongu", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("steril.dongu-yeni", "＋ Yeni döngü (pano)", "steril", Kisayol: "Ctrl+N", KaynakKodu: "steril.dongu", Islem: Islem.Ekle, Sira: 11, UrunModu: 2),
            new("steril.dongu-duzenle", "✎ Düzenle (parametre / not)", "steril", KaynakKodu: "steril.dongu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("steril-dongu.sil", "🗑 Sil", "steril", Kisayol: "Del", KaynakKodu: "steril.dongu", Islem: Islem.Sil, KayitGerekir: true, Sira: 30, UrunModu: 2, Ipucu: "Paketi olan döngü silinemez; iptal edin."),
            new("steril.izle-dongu", "🔍 Paketleri izle", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.izleme", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            Yazdir(),
        ];
        s["steril-paket-liste"] =
        [
            new("steril.izle", "🔍 İzlenebilirlik", "steril", Kisayol: "Enter", KaynakKodu: "steril.izleme", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("steril.okut", "📷 Kullanım kaydı (okut)", "steril", KaynakKodu: "steril.kullanim", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("steril.dongu-kart", "♨️ Döngü kartı", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.dongu", Islem: Islem.Gor, KayitGerekir: true, Sira: 30, UrunModu: 2),
            Yazdir(),
        ];
        s["steril-birim-liste"] =
        [
            .. Crud("steril-birim", "steril", "steril.birim", ekleAdi: "＋ Birim (set / döner alet)", silHedef: null, yazdir: false),
            new("steril.birim-kirli", "🧺 Kirli toplandı", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("steril.birim-yikama", "🧼 Yıkamaya al", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
            new("steril.birim-sayim", "🔢 Sayım", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42, UrunModu: 2),
            new("steril.birim-paketle", "📦 Paketle", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 43, UrunModu: 2),
            new("steril.birim-yaglama", "🛢 Yağlandı", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 44, UrunModu: 2),
            new("steril.birim-ariza", "🔧 Arıza / bakım", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.birim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 45, UrunModu: 2),
            new("steril.izle", "🔍 İzlenebilirlik", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.izleme", Islem: Islem.Gor, KayitGerekir: true, Sira: 50, UrunModu: 2),
        ];
        s["steril-set-liste"] = Crud("steril-set", "steril", "steril.birim", ekleAdi: "＋ Set tanımı", silHedef: null, yazdir: false);
        s["steril-cihaz-liste"] = Crud("steril-cihaz", "steril", "steril.ayar", ekleAdi: "＋ Cihaz", silHedef: null, yazdir: false);
        s["steril-program-liste"] = Crud("steril-program", "steril", "steril.ayar", ekleAdi: "＋ Program", silHedef: null, yazdir: false);
        s["steril-bakim-liste"] = Crud("steril-bakim", "steril", "steril.ayar", ekleAdi: "＋ Bakım kaydı", silHedef: null, yazdir: false);
        s["steril-kullanim-liste"] =
        [
            new("steril.izle", "🔍 İzlenebilirlik", "steril", Kisayol: "Enter", KaynakKodu: "steril.izleme", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("steril.hasta-ac", "👤 Hasta kartı", "steril", Hedef: "sagtus,palet", KaynakKodu: "hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 20, UrunModu: 2),
            Yazdir(),
        ];
        s["steril-geri-cagirma-liste"] =
        [
            new("steril.geri-cagirma-ac", "🚨 Geri çağırma panosu", "steril", Kisayol: "Enter", KaynakKodu: "steril.izleme", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("steril.geri-cagirma-kapat", "✔ Kapat", "steril", Hedef: "sagtus,palet", KaynakKodu: "steril.izleme", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
            Yazdir(),
        ];
        s["ftr-degerlendirme-liste"] = Crud("ftr-degerlendirme", "ftr", "ftr.degerlendirme", ekleAdi: "＋ Değerlendirme", silHedef: null,
                                           silIpucu: "Programı olan değerlendirme silinmez");
        s["ftr-program-liste"] =
        [
            .. Crud("ftr-program", "ftr", "ftr.program", ekleAdi: "＋ Program (Kür)", silHedef: null, yazdir: false,
                    silIpucu: "Seansı olan program silinmez; sonlandırılır"),
            new("ftr.program-planla", "🗓 Seansları Planla", "ftr", KaynakKodu: "ftr.program", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("ftr.program-seans-ac", "🏃 Bugünkü Seans", "ftr", KaynakKodu: "ftr.seans", Islem: Islem.Ekle, KayitGerekir: true, Sira: 41, UrunModu: 2),
            new("ftr.program-sonlandir", "✖ Sonlandır", "ftr", Hedef: "sagtus,palet", KaynakKodu: "ftr.program", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2),
        ];
        s["ftr-seans-liste"] =
        [
            .. Crud("ftr-seans", "ftr", "ftr.seans", ekleAdi: "＋ Seans", silHedef: null, yazdir: false,
                    silIpucu: "Yapılmış seans silinmez (uygulama işaretleri kalır)"),
            new("ftr.seans-bitir", "✔ Seansı Bitir", "ftr", KaynakKodu: "ftr.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("ftr.seans-gelmedi", "⛔ Gelmedi", "ftr", Hedef: "sagtus,palet", KaynakKodu: "ftr.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
        ];
        s["ftr-olcek-liste"] = Crud("ftr-olcek", "ftr", "ftr.olcek", ekleAdi: "＋ Ölçek", silHedef: null);
        s["ftr-unite-liste"] = Crud("ftr-unite", "ftr", "ftr.unite", ekleAdi: "＋ Ünite", yazdir: false, silHedef: null,
                                   silIpucu: "Programı olan ünite silinmez; pasife alın");
        s["calisma-sablon-liste"]  = Crud("calisma-sablon", "randevu", "randevu.plan", ekleAdi: "＋ Şablon", yazdir: false);
        s["calisma-istisna-liste"] = Crud("calisma-istisna", "randevu", "randevu.plan", ekleAdi: "＋ İstisna", yazdir: false);
        s["dis-lab-liste"] = Crud("dis-lab", "dis", "dis.unit", ekleAdi: "＋ Laboratuvar", silHedef: null, silIpucu: "İş emri olan laboratuvar silinmez; pasife alın");

        // YATAN HASTA SERVIS LISTESI (695): yatisin YASAM DONGUSU dugmelerle
        //   ilerler - kabul, hastanin yatagina cikisi, nakil, taburcu.
        //   Yatak durumu bu uclarla BIRLIKTE degisir; ayri bir "yatagi dolu
        //   yap" dugmesi olsaydi pano gercegin yarim saat gerisinde kalirdi.
        //
        //   Kabul/nakil/taburcu AYRI AKSIYON YETKILERIDIR (yatan.kabul /
        //   yatan.nakil / yatan.taburcu): kabul masasi yatis acar ama
        //   taburcu etmez, hemsire izlem girer ama yatak degistirmez.
        s["yatan-liste"] = new AksiyonTanimi[]
        {
            new("yatan.kabul",    "＋ Yatış Kabul", "yatan", Kisayol: "Ctrl+N",
                AksiyonYetkisi: "yatan.kabul", Sira: 10, UrunModu: 2),
            new("yatan.duzenle",  "✎ Yatış Kartı", "yatan", Kisayol: "Enter",
                KaynakKodu: "yatan", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            // KABUL ile "hasta yataginda" AYRI adimdir: arada provizyon,
            //   dosya ve transfer var. Yatak ucreti ve hemsire izlemi
            //   hasta geldiginde baslar.
            new("yatan.yatakta",  "🛏 Yatağa Alındı", "yatan",
                AksiyonYetkisi: "yatan.kabul", KayitGerekir: true,
                Sira: 30, UrunModu: 2,
                Ipucu: "Yatış kabul → Yatakta; yatak 'dolu' olur"),
            new("yatan.nakil",    "🔀 Nakil / Yatak Değiştir", "yatan",
                AksiyonYetkisi: "yatan.nakil", KayitGerekir: true,
                Sira: 40, UrunModu: 2),
            new("yatan.taburcu-planla", "📅 Taburcu Planla", "yatan",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "yatan.taburcu", KayitGerekir: true,
                Sira: 50, UrunModu: 2,
                Ipucu: "Panoda 'bugün çıkacak' olarak işaretlenir"),
            new("yatan.taburcu",  "🚪 Taburcu Et", "yatan",
                AksiyonYetkisi: "yatan.taburcu", KayitGerekir: true,
                Sira: 60, UrunModu: 2, Bicim: "onay"),
            // YATIS SILINMEZ, IPTAL EDILIR. Yatisa order, izlem, doz ve
            //   tahakkuk bagli; silinen yatis bunlari da goturur ve "bu
            //   hasta yatmis miydi" sorusu cevapsiz kalir. Yanlis acilan
            //   yatis icin dogru cevap durum 0 (Iptal): kayit kalir,
            //   yatak serbest kalir.
            new("yatan.iptal",    "✖ Yatışı İptal Et", "yatan",
                Hedef: "sagtus,palet", AksiyonYetkisi: "yatan.kabul",
                KayitGerekir: true, Sira: 70, UrunModu: 2, Bicim: "ret",
                Ipucu: "Yanlış açılan yatışı iptal eder (kayıt silinmez)"),
            Yazdir(),
        };

        // YATAK PANOSU (695): satir YATAKTIR, hasta degil. Temizligi biten
        //   yatagi BOS'a dondurmek ayri bir olaydir ve kim yaptigi loglanir -
        //   "yatak hazir" bilgisi kabul masasinin hasta yollama kararidir.
        s["yatak-liste"] = new AksiyonTanimi[]
        {
            new("yatan.yatak-temizlendi", "🧹 Temizlik Bitti", "yatan",
                KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay",
                Ipucu: "Temizlik bekleyen yatağı 'boş' yapar"),
            // YATAK BIR TANIMDIR: kurulumda acilir, kapanir, duzeltilir.
            //   Silme SAG TUSTA: ustunde yatis gecmisi olan yatak
            //   silinemez (yabanci anahtar) - dogru yol pasife almaktir,
            //   ipucu bunu soyluyor.
            new("yatak.yeni",    "＋ Yeni Yatak", "yatan", Kisayol: "Ctrl+N",
                KaynakKodu: "yatan.yatak", Islem: Islem.Ekle, Sira: 20, UrunModu: 2),
            new("yatak.duzenle", "✎ Yatak Kartı", "yatan", Kisayol: "Enter",
                KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30, UrunModu: 2),
            new("yatak.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "yatan.yatak", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 40, UrunModu: 2,
                Ipucu: "Yatış geçmişi olan yatak silinemez; pasife alın"),
            Yazdir(),
        };
    }
}
