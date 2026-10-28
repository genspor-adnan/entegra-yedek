namespace Gentegre.Api.Servisler;

/// <summary>
/// appsettings > Guvenlik. Sureler DB'deki referans tablosundan da okunabilir
/// (guvenlik.jwt_dakika / guvenlik.refresh_gun); buradaki degerler baslangic
/// varsayilanidir ve DB'de kayit varsa o kazanir (bkz. KimlikServisi).
/// </summary>
public sealed class GuvenlikAyarlari
{
    /// <summary>Depodaki appsettings.json'da duran geliştirme anahtarının belirgin parçası.</summary>
    public const string GelistirmeAnahtariIzi = "gelistirme-imza-anahtari";

    /// <summary>
    /// ÜRETİM ANAHTAR KAPISI (kod inceleme raporu 28.10.2026 B01): Production'da boş, kısa (&lt; 32 karakter) ya da
    /// depodaki geliştirme anahtarı ile API AÇILMAZ - anahtarı bilen biri herhangi bir aktif kullanıcının kimliğiyle
    /// token üretebilirdi. Kurulum anahtarı sunucuda üretilir (yayin/sunucu-guncelle.sh, appsettings.Gizli.json).
    /// </summary>
    public static void UretimAnahtariniDogrula(string? anahtar, bool uretim)
    {
        if (!uretim) return;
        if (string.IsNullOrWhiteSpace(anahtar) || anahtar.Length < 32
            || anahtar.Contains(GelistirmeAnahtariIzi, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException(
                "Üretim ortamında JWT imza anahtarı geçersiz (boş, kısa ya da geliştirme anahtarı). "
                + "Kurulum anahtarı appsettings.Gizli.json'da olmalı (yayin/sunucu-guncelle.sh üretir).");
    }

    public string ImzaAnahtari { get; set; } = "";
    public string Yayinci { get; set; } = "gentegre-ai";
    public string Hedef { get; set; } = "gentegre-ai-istemci";
    public int JwtDakika { get; set; } = 30;
    public int RefreshGun { get; set; } = 30;
    /// <summary>
    /// GUVENILEN PROXY'LER (denetim 28.09.2026 #5): X-Forwarded-For yalniz bu
    /// adreslerden gelirse okunur. Bos = yalniz loopback (nginx ayni makinede,
    /// 127.0.0.1'e proxy_pass). Istemcinin kendi yazdigi basliga guvenilmez.
    /// </summary>
    public string[] GuvenilenProxyler { get; set; } = [];
}
