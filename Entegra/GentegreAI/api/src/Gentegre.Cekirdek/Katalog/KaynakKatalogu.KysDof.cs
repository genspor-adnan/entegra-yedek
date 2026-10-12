namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — DÖF listesi (1050, sade), mockup <c>Ekranlar/Kalite/kalite_dof.html</c>.
/// Çipler Açık / Vadesi geçen / Kapalı; kart generic (KartKatalogu "kys-dof").
/// </summary>
public static partial class KaynakKatalogu
{
    public static readonly IReadOnlyDictionary<string, string> KysDofTurleri =
        new Dictionary<string, string> { ["1"] = "Düzeltici", ["2"] = "Önleyici" };
    public static readonly IReadOnlyDictionary<string, string> KysDofKaynaklari = new Dictionary<string, string>
    {
        ["1"] = "İç denetim", ["2"] = "Olay bildirimi", ["3"] = "Şikâyet / görüş", ["4"] = "Risk", ["5"] = "Dış denetim",
        ["6"] = "YGG / toplantı", ["7"] = "Gösterge", ["8"] = "Tedarikçi", ["9"] = "Diğer",
    };
    public static readonly IReadOnlyDictionary<string, string> KysDofDurumlari = new Dictionary<string, string>
    {
        ["1"] = "Açık", ["3"] = "Faaliyette", ["4"] = "Doğrulamada", ["5"] = "Kapandı", ["9"] = "İptal",
    };

    private static KaynakTanimi KysDof() => new(
        Ad: "kys-dof",
        YetkiKodu: "kys.dof",
        Kaynak: "public.v_kalite_dof d",
        SubeKolonu: "d.sube_id",
        // Açıklar önce, en yakın termin üstte.
        VarsayilanSirala: "d.acik desc, d.termin nulls last, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "d.id",          "sayi",  "Id", Varsayilan: false),
            // Mockup Kalite2/dof_listesi.html (1070): No · Açılış · Tür · Konu · Kaynak ·
            //   Birim · Sorumlu · Termin · Faaliyet (ilerleme) · Durum.
            new("no",          "d.no",          "metin", "No", Genislik: 115),
            new("acilis",      "d.acilis",      "tarih", "Açılış"),
            new("turAdi",      "d.tur_adi",     "metin", "Tür", Genislik: 85),
            new("tanim",       "d.tanim",       "metin", "Konu", Genislik: 280),
            new("kaynakMetin", "d.kaynak_metin","metin", "Kaynak", Genislik: 190),
            new("birimAdi",    "d.birim_adi",   "metin", "Birim", Genislik: 110),
            new("sorumluAdi",  "d.sorumlu_adi", "metin", "Sorumlu", Genislik: 130),
            new("termin",      "d.termin",      "tarih", "Termin"),
            new("tamamlanma",  "d.tamamlanma",  "sayi",  "Faaliyet", Genislik: 110, Bicim: "yuzde"),
            new("durumAdi",    "d.durum_adi",   "metin", "Durum", Genislik: 110, Bicim: "rozet"),
            new("kaynakAdi",   "d.kaynak_adi",  "metin", "Kaynak türü", Genislik: 120, Varsayilan: false),
            new("kaynakNo",    "d.kaynak_no",   "metin", "Kaynak No", Genislik: 110, Varsayilan: false),
            new("dogrulamaTarihi", "d.dogrulama_tarihi", "tarih", "Doğrulama", Varsayilan: false),
            new("tur",         "d.tur",         "sayi",  "Tür Kodu", Varsayilan: false, Kodlar: KysDofTurleri),
            new("kaynakTur",   "d.kaynak_tur",  "sayi",  "Kaynak Türü", Varsayilan: false, Kodlar: KysDofKaynaklari),
            new("kaynakId",    "d.kaynak_id",   "sayi",  "Kaynak Id", Varsayilan: false),
            new("durum",       "d.durum",       "sayi",  "Durum Kodu", Varsayilan: false, Kodlar: KysDofDurumlari),
            new("acik",        "d.acik",        "sayi",  "Açık", Varsayilan: false),
            new("vadesiGecti", "d.vadesi_gecti", "sayi", "Vadesi Geçti", Varsayilan: false),
            new("departmanId", "d.departman_id", "sayi", "Birim Id", Varsayilan: false),
            new("sorumluId",   "d.sorumlu_id",  "sayi",  "Sorumlu Id", Varsayilan: false),
        });
}
