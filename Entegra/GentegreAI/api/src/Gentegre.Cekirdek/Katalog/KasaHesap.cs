namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kasa islemlerinin para matematigi TEK YERDE. Yuvarlama bicimi
/// <see cref="BelgeHesap.Yuvarla"/> ile aynidir (banker's rounding) - belge ve
/// kasa ayni faturayi farkli kurusa yuvarlarsa cari bakiye asla kapanmaz.
///
/// Bu sinif yalniz HESAPLAR; dogrulama ve bacak uretimi veritabani motorunda
/// (076_fn_kasa.sql) yapilir. Iki yerde kural tutmak, iki farkli dogruluk demek.
/// </summary>
public static class KasaHesap
{
    /// <summary>Doviz tutarinin yerel (TL) karsiligi. Kur yoksa tutarin kendisi.</summary>
    public static decimal YerelTutar(decimal dovizTutar, decimal kur)
        => BelgeHesap.Yuvarla(kur <= 0 ? dovizTutar : dovizTutar * kur, 2);

    /// <summary>Yerel tutarin doviz karsiligi (kur = yerel / doviz).</summary>
    public static decimal DovizTutari(decimal yerelTutar, decimal kur)
        => BelgeHesap.DovizKarsiligi(yerelTutar, kur, 4);

    /// <summary>
    /// Doviz donusumunde efektif kur: verilen ile alinan tutarin orani.
    /// (100 USD verip 4.789,70 TL alindiysa kur 47,897.)
    /// </summary>
    public static decimal CaprazKur(decimal yerelTutar, decimal dovizTutar)
        => dovizTutar == 0 ? 0 : BelgeHesap.Yuvarla(Math.Abs(yerelTutar / dovizTutar), 6);

    /// <summary>K5: gerceklesmis islemin bacaklari kurus kurusuna dengeli olmali.</summary>
    public static bool Dengeli(IEnumerable<(decimal YerelBorc, decimal YerelAlacak)> bacaklar)
    {
        decimal borc = 0, alacak = 0;
        foreach (var (b, a) in bacaklar) { borc += b; alacak += a; }
        return BelgeHesap.Yuvarla(borc, 2) == BelgeHesap.Yuvarla(alacak, 2);
    }

    /// <summary>Yerel para birimi kodu - uygulama genelinde 'TL' (TRY degil).</summary>
    public const string YerelDoviz = "TL";

    public static bool YerelMi(string? dovizCinsi)
        => string.IsNullOrWhiteSpace(dovizCinsi) ||
           string.Equals(dovizCinsi.Trim(), YerelDoviz, StringComparison.OrdinalIgnoreCase);

    /// <summary>
    /// Cek/senet ile tahsilat-odeme turleri: 23 cek ile tahsilat, 24 senet ile
    /// tahsilat, 33 cek ile odeme, 34 senet ile odeme. Bu turlerde islem bir
    /// KIYMETIN el degistirmesidir - `cek_senet` kaydi olmadan bacak uretilemez
    /// (076 motoru 422 verir).
    /// </summary>
    public static bool CekSenetTuru(int tur) => tur is 23 or 24 or 33 or 34;
}
