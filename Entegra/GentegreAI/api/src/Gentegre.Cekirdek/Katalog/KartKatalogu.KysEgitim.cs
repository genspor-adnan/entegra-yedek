namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1056) — zorunlu eğitim tanım kartı. Log 1460 bloğu.
/// Eğitim kaydının kendisi generic kart değildir (özel kart, KysEgitimUclari):
/// satırlar personel_egitim'e, personel kartı detayının log koduyla (905) yazılır.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysZorunluEgitim = 1460;

    private static KartTanimi KysZorunluEgitimKarti() => new(
        Ad: "kys-zorunlu-egitim",
        YetkiKodu: "kys.egitim",
        Tablo: "public.kalite_zorunlu_egitim",
        LogTabloId: LogKysZorunluEgitim,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("egitimAdi",   "egitim_adi",   "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Eğitim adı", Grup: "Zorunlu eğitim"),
            new("departmanId", "departman_id", "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Birim (boş = tüm personel)", Grup: "Zorunlu eğitim"),
            new("periyotAy",   "periyot_ay",   "sayi",  Baslik: "Yenileme periyodu, ay (boş = bir kez)", Grup: "Zorunlu eğitim"),
            new("aktif",       "aktif",        "kod",   SabitKodlar: KysAktifKodlari, Baslik: "Durum", Grup: "Zorunlu eğitim"),
            new("aciklama",    "aciklama",     "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Zorunlu eğitim"),
        });
}
