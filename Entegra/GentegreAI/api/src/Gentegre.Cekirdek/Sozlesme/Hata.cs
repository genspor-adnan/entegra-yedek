namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>API sozlesmesi §1.2 - tum hatalar ayni govdeyi doner.</summary>
public static class HataKodu
{
    public const string Dogrulama  = "DOGRULAMA";   // 400 - alanlar[] dolu
    public const string Yetkisiz   = "YETKISIZ";    // 401 - kimlik yok / suresi dolmus
    public const string Yasak      = "YASAK";       // 403 - yetki yok
    public const string Bulunamadi = "BULUNAMADI";  // 404 - kayit yok ya da kapsam disi
    public const string Cakisma    = "CAKISMA";     // 409 - esszamanlilik
    public const string IsKurali   = "IS_KURALI";   // 422 - "Bu cariye ait fatura var, silinemez."
    public const string Sunucu     = "SUNUCU";      // 500 - beklenmeyen

    public static int HttpDurumu(string kod) => kod switch
    {
        Dogrulama  => 400,
        Yetkisiz   => 401,
        Yasak      => 403,
        Bulunamadi => 404,
        Cakisma    => 409,
        IsKurali   => 422,
        _          => 500
    };
}

public sealed record AlanHatasi(string Alan, string Mesaj);

public sealed class HataGovdesi
{
    public string Kod { get; set; } = HataKodu.Sunucu;
    public string Mesaj { get; set; } = "";
    public string IzlemeNo { get; set; } = "";
    public IReadOnlyList<AlanHatasi>? Alanlar { get; set; }
    public IReadOnlyList<string>? CakisanAlanlar { get; set; }
    public object? GuncelDeger { get; set; }
    /// <summary>§3.3 silme engeli: { tablo, adet }.</summary>
    public object? Engel { get; set; }
}

public sealed class HataYaniti
{
    public HataGovdesi Hata { get; set; } = new();
}

/// <summary>
/// Is katmaninin firlattigi hata. Ara katman bunu HataYaniti'na cevirir;
/// beklenmeyen istisnalar SUNUCU koduyla sarilir (ayrinti kullaniciya gitmez).
/// </summary>
public class GentegreHatasi : Exception
{
    public string Kod { get; }
    public IReadOnlyList<AlanHatasi>? Alanlar { get; }
    public IReadOnlyList<string>? CakisanAlanlar { get; }
    public object? GuncelDeger { get; }
    public object? Engel { get; }

    public GentegreHatasi(string kod, string mesaj,
                          IReadOnlyList<AlanHatasi>? alanlar = null,
                          IReadOnlyList<string>? cakisanAlanlar = null,
                          object? guncelDeger = null,
                          object? engel = null) : base(mesaj)
    {
        Kod = kod;
        Alanlar = alanlar;
        CakisanAlanlar = cakisanAlanlar;
        GuncelDeger = guncelDeger;
        Engel = engel;
    }

    public static GentegreHatasi Dogrulama(string mesaj, params AlanHatasi[] alanlar)
        => new(HataKodu.Dogrulama, mesaj, alanlar);

    public static GentegreHatasi Yetkisiz(string mesaj = "Oturum gecersiz ya da suresi dolmus.")
        => new(HataKodu.Yetkisiz, mesaj);

    public static GentegreHatasi Yasak(string mesaj = "Bu islem icin yetkiniz yok.")
        => new(HataKodu.Yasak, mesaj);

    public static GentegreHatasi Bulunamadi(string mesaj = "Kayit bulunamadi.")
        => new(HataKodu.Bulunamadi, mesaj);

    public static GentegreHatasi IsKurali(string mesaj, object? engel = null)
        => new(HataKodu.IsKurali, mesaj, engel: engel);

    /// <summary>§1.3 - satiri baskasi degistirdi. Guncel hali ile birlikte doner.</summary>
    public static GentegreHatasi Cakisma(object? guncelDeger, IReadOnlyList<string>? cakisanAlanlar = null)
        => new(HataKodu.Cakisma, "Bu kaydi baska bir kullanici degistirdi.",
               cakisanAlanlar: cakisanAlanlar, guncelDeger: guncelDeger);
}
