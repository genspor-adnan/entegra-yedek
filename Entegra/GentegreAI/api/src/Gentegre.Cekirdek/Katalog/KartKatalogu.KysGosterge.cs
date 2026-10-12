namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) — gösterge kartı + dönem değerleri detayı.
/// Log tablo kodları 1440-1441.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysGosterge      = 1440;
    private const int LogKysGostergeDeger = 1441;

    private static readonly Dictionary<string, string> KysGostergePeriyot = new() { ["1"] = "Aylık", ["3"] = "3 aylık", ["6"] = "6 aylık", ["12"] = "Yıllık" };
    private static readonly Dictionary<string, string> KysGostergeYon = new() { ["1"] = "≤ hedef (düşük iyi)", ["2"] = "≥ hedef (yüksek iyi)" };
    private static readonly Dictionary<string, string> KysGostergeAktif = new() { ["1"] = "Aktif", ["0"] = "Pasif" };

    private static KartTanimi KysGostergeKarti() => new(
        Ad: "kys-gosterge",
        YetkiKodu: "kys.gosterge",
        Tablo: "public.kalite_gosterge",
        LogTabloId: LogKysGosterge,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["periyotAy"] = (short)1, ["yon"] = (short)1, ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",    Yazilabilir: false),
            new("kod",         "kod",          "metin",   Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Gösterge"),
            new("ad",          "ad",           "metin",   Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Gösterge adı", Grup: "Gösterge"),
            new("formul",      "formul",       "metin",   EnFazlaUzunluk: 400, Baslik: "Formül", Grup: "Gösterge"),
            new("hedef",       "hedef",        "ondalik", Baslik: "Hedef", Grup: "Gösterge"),
            new("yon",         "yon",          "kod",     Zorunlu: true, SabitKodlar: KysGostergeYon, Baslik: "Hedef yönü", Grup: "Gösterge"),
            new("periyotAy",   "periyot_ay",   "kod",     Zorunlu: true, SabitKodlar: KysGostergePeriyot, Baslik: "Periyot", Grup: "Gösterge"),
            new("departmanId", "departman_id", "kod",     KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Gösterge"),
            new("sorumluId",   "sorumlu_id",   "kod",     KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Gösterge"),
            new("aktif",       "aktif",        "kod",     SabitKodlar: KysGostergeAktif, Baslik: "Durum", Grup: "Gösterge"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("degerler", "public.kalite_gosterge_deger", "gosterge_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",    Yazilabilir: false),
                new("donem",    "donem",    "tarih",   Zorunlu: true, Baslik: "Dönem"),
                new("deger",    "deger",    "ondalik", Zorunlu: true, Baslik: "Değer"),
                new("aciklama", "aciklama", "metin",   EnFazlaUzunluk: 400, Baslik: "Not"),
            }, Sirala: "donem desc", SubeKolonu: null, Baslik: "Dönem değerleri", LogTabloId: LogKysGostergeDeger),
        });
}
