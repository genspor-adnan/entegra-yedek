using System.Text.RegularExpressions;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KADRO AĞACI HARİTASI (`SablonKadro`).
///
/// Kullanıcı: *"Kurum Profili'nde rol seçim gridini de bu ağaç şekline çevir
/// ve buradaki tüm roller olsun"*.
///
/// <para>Haritanın üç sessiz arızası olabilir: yazım hatalı rol kodu (satır
/// hiçbir zaman ağaca girmez), var olmayan bir üst kodu (düğüm sessizce kök
/// olur) ve döngü (A'nın üstü B, B'nin üstü A - ekran o dalı hiç çizemez).
/// Hiçbiri hata vermez, yalnız ekran eksik çizer.</para>
///
/// <para>Harita KAYNAKTAN okunur (<c>StandartRolModulTestleri</c> deseni):
/// sözlük <c>private</c>, metnin kendisi zaten testin konusu.</para>
/// </summary>
public sealed class KadroAgaciTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static string Kaynak()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        return File.ReadAllText(Path.Combine(dizin!.FullName, "src", "Gentegre.Api",
                                             "Uclar", "StandartRolUclari.cs"));
    }

    /// <summary>(rol kodu, bölüm, üst kodu) üçlüleri.</summary>
    private static List<(string Kod, string Bolum, string? Ust)> HaritaOku()
    {
        var metin = Kaynak();
        var blok = Regex.Match(metin,
            @"SablonKadro = new\(StringComparer\.Ordinal\)\s*\{(?<g>.*?)\n    \};",
            RegexOptions.Singleline);
        Assert.True(blok.Success, "SablonKadro haritası kaynakta bulunamadı.");
        return [.. Regex.Matches(blok.Groups["g"].Value,
                @"\[""(?<kod>[a-z_0-9]+)""\]\s*=\s*new\(""(?<bolum>[^""]+)"",\s*(?<ust>null|""[a-z_0-9]+"")")
            .Select(m => (m.Groups["kod"].Value, m.Groups["bolum"].Value,
                          m.Groups["ust"].Value == "null" ? null
                            : m.Groups["ust"].Value.Trim('"')))];
    }

    private static List<string> BolumSirasi()
    {
        var blok = Regex.Match(Kaynak(),
            @"KadroBolumleri =\s*\[(?<g>.*?)\];", RegexOptions.Singleline);
        Assert.True(blok.Success, "KadroBolumleri kaynakta bulunamadı.");
        return [.. Regex.Matches(blok.Groups["g"].Value, @"""(?<b>[^""]+)""")
            .Select(m => m.Groups["b"].Value)];
    }

    [Fact(DisplayName = "Kadro haritasındaki her rol gerçekten var")]
    public async Task Haritadaki_roller_var()
    {
        if (!_olgu.Baglandi(nameof(Haritadaki_roller_var))) return;
        var veri = _olgu.Gerekli();

        var harita = HaritaOku();
        Assert.NotEmpty(harita);

        // Rol ya KURULU olmalı ya da bir ŞABLON olarak tanımlı - ikisi de
        //   değilse haritadaki satır hiçbir zaman ekrana çıkmaz.
        var kurulu = await veri.ListeAsync("select kod from public.rol",
            null, o => o.GetString(0), Iptal);
        var sablonlar = Regex.Matches(Kaynak(), @"new\(""(?<kod>[a-z_0-9]+)"",\s*""")
            .Select(m => m.Groups["kod"].Value).ToHashSet(StringComparer.Ordinal);

        var yok = harita.Select(x => x.Kod)
            .Where(k => !kurulu.Contains(k) && !sablonlar.Contains(k)).ToList();
        Assert.True(yok.Count == 0,
            "Kadro haritasında karşılığı olmayan rol kodu: " + string.Join(", ", yok));
    }

    [Fact(DisplayName = "Üst rol haritada var ve döngü yok")]
    public void Ust_zinciri_saglam()
    {
        var harita = HaritaOku();
        var kodlar = harita.Select(x => x.Kod).ToHashSet(StringComparer.Ordinal);

        var kayipUst = harita.Where(x => x.Ust is not null && !kodlar.Contains(x.Ust!))
            .Select(x => $"{x.Kod} -> {x.Ust}").ToList();
        Assert.True(kayipUst.Count == 0,
            "Üstü haritada olmayan rol (düğüm sessizce kök olur): "
            + string.Join(", ", kayipUst));

        // Döngü: her düğümden yukarı yürü, kendine dönerse kır.
        var ust = harita.ToDictionary(x => x.Kod, x => x.Ust, StringComparer.Ordinal);
        foreach (var kod in kodlar)
        {
            var gorulen = new HashSet<string>(StringComparer.Ordinal) { kod };
            var su = ust[kod];
            while (su is not null)
            {
                Assert.True(gorulen.Add(su), $"Kadro ağacında döngü: {kod} zincirinde {su}");
                su = ust.GetValueOrDefault(su);
            }
        }
    }

    [Fact(DisplayName = "Her bölüm sıra listesinde var")]
    public void Bolumler_sira_listesinde()
    {
        var harita = HaritaOku();
        var sira = BolumSirasi();
        // Listede olmayan bölüm ekranda EN SONA düşer; kasıtlıysa sorun değil
        //   ama sessiz olmasın - sıra listesi bölümlerin tek kaynağıdır.
        var eksik = harita.Select(x => x.Bolum).Distinct()
            .Where(b => !sira.Contains(b)).ToList();
        Assert.True(eksik.Count == 0,
            "KadroBolumleri listesinde olmayan bölüm: " + string.Join(", ", eksik));
    }
}
