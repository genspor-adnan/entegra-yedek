namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE - İÇ DENETİM (1051, sade) kartı: denetim + bulgular.
/// Numara (DEN-2026-001) kayıt anında kolon varsayılanından. Log 1420-1421.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysDenetim      = 1420;
    private const int LogKysDenetimBulgu = 1421;

    private static readonly Dictionary<string, string> KysDenetimDurum = new() { ["1"] = "Planlı", ["2"] = "Tamamlandı" };
    private static readonly Dictionary<string, string> KysDenetimBulguSinif = new() { ["1"] = "Majör", ["2"] = "Minör", ["3"] = "Gözlem" };

    private static KartTanimi KysDenetimKarti() => new(
        Ad: "kys-denetim",
        YetkiKodu: "kys.denetim",
        Tablo: "public.kalite_denetim",
        LogTabloId: LogKysDenetim,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",             "sayi",  Yazilabilir: false),
            new("no",           "no",             "metin", Yazilabilir: false, Baslik: "Denetim No", Grup: "Denetim"),
            new("departmanId",  "departman_id",   "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Denetlenen birim", Grup: "Denetim"),
            new("planTarih",    "plan_tarih",     "tarih", Zorunlu: true, Baslik: "Plan tarihi", Grup: "Denetim"),
            new("gerceklesen",  "gerceklesen",    "tarih", Baslik: "Gerçekleşen tarih", Grup: "Denetim"),
            new("basDenetciId", "bas_denetci_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Baş denetçi", Grup: "Denetim"),
            new("ekip",         "ekip",           "metin", EnFazlaUzunluk: 300, Baslik: "Denetçi ekibi", Grup: "Denetim"),
            new("durum",        "durum",          "kod",   SabitKodlar: KysDenetimDurum, Baslik: "Durum", Grup: "Denetim"),
            new("kapsam",       "kapsam",         "metin", EnFazlaUzunluk: 2000, Baslik: "Kapsam ve kriterler", Grup: "Denetim"),
            new("sonucNotu",    "sonuc_notu",     "metin", EnFazlaUzunluk: 2000, Baslik: "Sonuç notu", Grup: "Denetim"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("bulgular", "public.kalite_denetim_bulgu", "denetim_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",  Yazilabilir: false),
                new("sinif",    "sinif",    "kod",   Zorunlu: true, SabitKodlar: KysDenetimBulguSinif, Baslik: "Sınıf"),
                new("aciklama", "aciklama", "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Bulgu"),
                new("madde",    "madde",    "metin", EnFazlaUzunluk: 80, Baslik: "ISO / SKS madde"),
            }, Sirala: "sinif, id", Baslik: "Bulgular", LogTabloId: LogKysDenetimBulgu),
        });
}
