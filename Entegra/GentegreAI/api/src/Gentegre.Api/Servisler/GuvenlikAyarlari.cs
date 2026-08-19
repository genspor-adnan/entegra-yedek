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
}
