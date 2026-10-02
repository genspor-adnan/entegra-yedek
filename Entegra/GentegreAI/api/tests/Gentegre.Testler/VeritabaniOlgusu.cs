using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// VERİTABANI GEREKTİREN TESTLER İÇİN ORTAK BAĞLAM.
///
/// <para><b>Bağlantı AÇIKÇA verilir</b> (denetim 28.09.2026): dize yalnız
/// <c>GENTEGRE_TEST_DB</c> ortam değişkeninden gelir. Eskiden değişken yoksa
/// paylaşılan geliştirme veritabanına (<c>gentegre_ai</c>) sessizce
/// bağlanılıyordu - testler kendi satırlarını açıp silse de ortak veriye
/// yazıyordu. Artık varsayılan YOK; hedef veritabanının adı ayrıca
/// doğrulanır (adında <c>test</c> geçmeyen veritabanında testler
/// çalışmaz).</para>
///
/// <para><b>Atla / başarısız ol:</b> değişken yoksa DB testleri
/// <see cref="VtFactAttribute"/> ile xUnit'te AÇIKÇA "atlandı" görünür (yeşil
/// değil). <c>GENTEGRE_TEST_ZORUNLU=1</c> (CI bütünleşme aşaması) verildiğinde
/// atlama yoktur: değişken yoksa ya da veritabanına ulaşılamıyorsa test
/// BAŞARISIZ olur.</para>
///
/// <para>Testler KENDİ VERİSİNİ açar ve siler.</para>
/// </summary>
public sealed class VeritabaniOlgusu : IDisposable
{
    public VeriKaynagi? Veri { get; }
    public string? AtlamaSebebi { get; }

    public VeritabaniOlgusu()
    {
        var dizge = TestVeritabani.Dizge;
        if (dizge is null)
        {
            AtlamaSebebi = TestVeritabani.YokSebebi;
            if (TestVeritabani.Zorunlu)
                throw new InvalidOperationException(
                    "GENTEGRE_TEST_ZORUNLU=1 ama GENTEGRE_TEST_DB tanımlı değil - veritabanı testleri atlanamaz.");
            return;
        }

        // Dize AÇIKÇA verilmişse bağlanamamak ya da yanlış hedef bir HATADIR:
        //   "atlandı" deyip yeşil geçmek, bozuk ortamı saklardı.
        var veri = new VeriKaynagi(dizge);
        var ad = veri.TekDegerAsync<string>("select current_database()", null)
                     .GetAwaiter().GetResult() ?? "";
        if (!ad.Contains("test", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException(
                $"GENTEGRE_TEST_DB '{ad}' veritabanını gösteriyor; testler yalnız adında " +
                "'test' geçen, test amaçlı veritabanında çalışır (paylaşılan DB'ye fixture yazılmaz).");
        Veri = veri;
    }

    /// <summary>
    /// Bağlantı yoksa testi durdurur. DB testleri <see cref="VtFactAttribute"/>
    /// ile işaretli olduğu için bu yol yalnız işaretsiz bir DB testinde işler;
    /// zorunlu modda hata, değilse sebep konsola yazılır.
    /// </summary>
    public bool Baglandi(string testAdi)
    {
        if (Veri is not null) return true;
        if (TestVeritabani.Zorunlu)
            throw new InvalidOperationException($"{testAdi}: {AtlamaSebebi}");
        Console.WriteLine($"[ATLANDI] {testAdi}: {AtlamaSebebi}");
        return false;
    }

    public VeriKaynagi Gerekli() => Veri!;

    public void Dispose() => Veri?.DisposeAsync().AsTask().GetAwaiter().GetResult();
}

/// <summary>Test veritabanı ayarları - tek yer.</summary>
public static class TestVeritabani
{
    public static string? Dizge =>
        Environment.GetEnvironmentVariable("GENTEGRE_TEST_DB") is { Length: > 0 } d ? d : null;

    /// <summary>CI bütünleşme aşaması: DB testleri atlanamaz.</summary>
    public static bool Zorunlu =>
        Environment.GetEnvironmentVariable("GENTEGRE_TEST_ZORUNLU") == "1";

    public const string YokSebebi =
        "GENTEGRE_TEST_DB tanımlı değil - veritabanı testleri atlandı " +
        "(zorunlu çalıştırma için GENTEGRE_TEST_ZORUNLU=1).";

    /// <summary>xUnit atlama metni: null = çalıştır.</summary>
    public static string? AtlamaMetni => Dizge is null && !Zorunlu ? YokSebebi : null;
}

/// <summary>
/// VERİTABANI TESTİ. <c>GENTEGRE_TEST_DB</c> yoksa xUnit sonucunda AÇIKÇA
/// "atlandı" görünür (xUnit 2: <c>Skip</c> keşif anında verilir); zorunlu
/// modda asla atlanmaz.
/// </summary>
public sealed class VtFactAttribute : FactAttribute
{
    public VtFactAttribute() { if (TestVeritabani.AtlamaMetni is { } s) Skip = s; }
}

/// <summary><see cref="VtFactAttribute"/>'ün veri güdümlü karşılığı.</summary>
public sealed class VtTheoryAttribute : TheoryAttribute
{
    public VtTheoryAttribute() { if (TestVeritabani.AtlamaMetni is { } s) Skip = s; }
}
