namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AVANS LİSTESİ (753).
///
/// LİSTENİN ASIL SORUSU "NE KADARI GERİ GELDİ". Tutar tek başına bir borç
/// tablosu değildir; kesilen, kalan ve GECİKEN taksit olmadan avans
/// ödendikten sonra izlenemez - personel ayrılırken açık kalan avans da
/// burada görünür.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> AvansDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylandı",
        ["3"] = "Reddedildi", ["4"] = "Ödendi", ["5"] = "Kapandı",
        ["8"] = "İptal",
    };

    private static KaynakTanimi PersonelAvansKaynagi() => new(
        Ad: "personelAvans",
        YetkiKodu: "ik.avans",
        Kaynak: "public.v_personel_avans v",
        SubeKolonu: "v.sube_id",
        // AÇIK OLANLAR ÖNCE: kapanmış avans arşivdir.
        VarsayilanSirala: "case when v.durum in (0, 1, 2, 4) then 0 else 1 end," +
                          " v.talep_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("avansNo", "v.avans_no", "metin", "Avans No", Genislik: 120,
                Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 200),
            new("gorevAd", "v.gorev_ad", "metin", "Görev", Genislik: 150,
                Varsayilan: false),
            new("amirAd", "v.amir_ad", "metin", "Âmiri", Genislik: 160,
                Varsayilan: false),
            new("talepTarihi", "v.talep_tarihi", "tarih", "Talep", Hizalama: "orta",
                Genislik: 110),
            new("tutar", "v.tutar", "para", "Tutar", Hizalama: "sag", Genislik: 120),
            new("taksitSayisi", "v.taksit_sayisi", "sayi", "Taksit", Hizalama: "sag",
                Genislik: 80),
            new("ilkDonem", "v.ilk_donem", "metin", "İlk Kesinti", Hizalama: "orta",
                Genislik: 100),
            new("durumAdi",
                "case v.durum when 0 then 'Taslak' when 1 then 'Onayda'" +
                " when 2 then 'Onaylandı' when 3 then 'Reddedildi'" +
                " when 4 then 'Ödendi' when 5 then 'Kapandı'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: AvansDurumKodlari),
            new("bekleyenBasamak", "coalesce(v.bekleyen_basamak, '')", "metin",
                "Bekleyen", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            // KESİLEN / KALAN: avansın izlendiği asıl iki sayı.
            new("kesilenTutar", "v.kesilen_tutar", "para", "Kesilen", Hizalama: "sag",
                Genislik: 110),
            new("kalanTutar", "v.kalan_tutar", "para", "Kalan", Hizalama: "sag",
                Genislik: 110),
            new("bekleyenTaksit", "v.bekleyen_taksit", "sayi", "Bekleyen Taksit",
                Hizalama: "sag", Genislik: 120, Varsayilan: false),
            // GECİKEN TAKSİT: dönemi geçmiş ama kesilmemiş mahsup unutulmuştur;
            //   personel ayrılırsa tahsil edilemez.
            new("gecikenTaksit", "v.geciken_taksit", "sayi", "Geciken Taksit",
                Hizalama: "sag", Genislik: 120),
            new("odemeTarihi", "v.odeme_tarihi", "tarih", "Ödeme", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            new("gerekce", "v.gerekce", "metin", "Gerekçe", Genislik: 240,
                Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
        });
}
