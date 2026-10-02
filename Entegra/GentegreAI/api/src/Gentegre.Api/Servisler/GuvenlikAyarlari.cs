namespace Gentegre.Api.Servisler;

/// <summary>
/// appsettings > Guvenlik. Sureler DB'deki referans tablosundan da okunabilir
/// (guvenlik.jwt_dakika / guvenlik.refresh_gun); buradaki degerler baslangic
/// varsayilanidir ve DB'de kayit varsa o kazanir (bkz. KimlikServisi).
/// </summary>
public sealed class GuvenlikAyarlari
{
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
