namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURULUM MODU (342/542): 1 Gentegre AI (ERP) · 2 GenoTIP AI (HBYS) ·
/// 3 ikisi birden. Aksiyon, kart alani ve liste kolonu ayni suzgeci
/// kullanir - "bu ekran ogesi hangi kurulumda anlamli" sorusu tek yerde
/// cevaplanir.
/// </summary>
public static class UrunModlari
{
    public const int Erp = 1;
    public const int Hbys = 2;
    public const int Hepsi = 3;

    /// <summary>
    /// Katalog ogesinin bu kurulumda gorunup gorunmeyecegi. Ogenin modu 0 ise
    /// her kurulumda; kurulum "hepsi" ise her oge gorunur.
    /// </summary>
    public static bool Uyar(int ogeModu, int kurulum)
        => ogeModu == 0 || kurulum == Hepsi || ogeModu == kurulum;
}
