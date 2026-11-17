namespace Gentegre.Api.AraKatman;

/// <summary>
/// KİMLİK UÇLARI HIZ SINIRI - hangi yol sınırlı (Program.cs "kimlik" politikası).
/// YOL NORMALİZE (güvenlik incelemesi 18.11.2026): yönlendirme yolu harf duyarsız eşler ve sondaki '/'yı yutar -
/// "/api/kimlik/Giris" ya da "/giris/" aynı uca gidip harf duyarlı (Ordinal) karşılaştırmadan kaçıyor, sınırsız parola
/// denemesine açılıyordu. Karşılaştırma küçük harfe ve sondaki '/' atılmış yola yapılır.
/// </summary>
public static class KimlikSinirYolu
{
    public static bool Sinirli(string? yolHam)
    {
        var yol = (yolHam ?? "").TrimEnd('/').ToLowerInvariant();
        return yol.EndsWith("/giris", StringComparison.Ordinal)
            || yol.EndsWith("/yenile", StringComparison.Ordinal)
            || yol.Contains("/ilk-parola", StringComparison.Ordinal)
            || yol.Contains("/parola-unuttum", StringComparison.Ordinal)
            || yol.Contains("/giris-kodu", StringComparison.Ordinal);
    }
}
