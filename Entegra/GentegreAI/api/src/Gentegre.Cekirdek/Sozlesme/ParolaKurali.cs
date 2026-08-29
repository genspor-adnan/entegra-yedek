namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>
/// PAROLA KURALI (kullanıcı: "küçük büyük harf, rakam ve harf-rakam dışında
/// karakter"). Tek yerde: ilk parola belirleme ve parola değiştirme aynı
/// kurala uyar - biri sıkı biri gevşek kalmasın.
/// </summary>
public static class ParolaKurali
{
    public const int VarsayilanEnAz = 8;

    /// <summary>Kural metni - ekranda ipucu olarak gösterilir.</summary>
    public static string Metin(int enAz) =>
        $"En az {enAz} karakter; küçük harf, BÜYÜK harf, rakam ve " +
        "harf/rakam dışı bir karakter (ör. .!?*-_) içermeli.";

    /// <summary>Kurala uymayan parolada anlaşılır bir doğrulama hatası atar.</summary>
    public static void Dogrula(string? parola, int enAz = VarsayilanEnAz,
                               string alan = "yeniParola")
    {
        var p = parola ?? "";
        var eksik = new List<string>();
        if (p.Length < enAz) eksik.Add($"en az {enAz} karakter");
        if (!p.Any(char.IsLower)) eksik.Add("küçük harf");
        if (!p.Any(char.IsUpper)) eksik.Add("büyük harf");
        if (!p.Any(char.IsDigit)) eksik.Add("rakam");
        if (!p.Any(k => !char.IsLetterOrDigit(k))) eksik.Add("harf/rakam dışı bir karakter");
        if (eksik.Count == 0) return;

        throw GentegreHatasi.Dogrulama(
            "Parola kurala uymuyor: " + string.Join(", ", eksik) + " gerekli.",
            new AlanHatasi(alan, Metin(enAz)));
    }
}
