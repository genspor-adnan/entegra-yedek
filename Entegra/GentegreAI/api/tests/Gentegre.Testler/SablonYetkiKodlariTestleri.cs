using System.Text.RegularExpressions;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ŞABLON ROLLERİN YETKİ KODLARI GERÇEK Mİ, ONAY BASAMAKLARININ SAHİBİ VAR MI.
///
/// <para>İki sessiz arıza vardı:</para>
/// <list type="number">
///   <item>Şablona YANLIŞ YAZILMIŞ bir yetki kodu (ör. <c>satinalma.onay_mali</c> -
///   öyle bir yetki yok) hiçbir hata vermez; rol kurulur, o satır yalnızca
///   eksik kalır.</item>
///   <item><b>Talep onay zinciri</b> (izin, avans, masraf, belge talebi,
///   satınalma, demirbaş onarımı) basamağın yetkisine bakar. O yetki hiçbir
///   şablonda yoksa basamağın tek sahibi sistem yöneticisi olur ve talep orada
///   bekler - kimse hata görmez, iş durur.</item>
/// </list>
///
/// <para>Her iki taraf da KAYNAKTAN okunur (<c>StandartRolModulTestleri</c>
/// deseni): listeler <c>private</c>, metnin kendisi zaten testin konusu.</para>
/// </summary>
public sealed class SablonYetkiKodlariTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static string KaynakOku(string dosya)
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        return File.ReadAllText(Path.Combine(dizin!.FullName, "src", "Gentegre.Api",
                                             "Uclar", dosya));
    }

    /// <summary>Şablonlarda geçen yetki desenleri: T/Y/H/A("...") ve new("...", …).</summary>
    private static List<string> SablonDesenleri()
    {
        var metin = KaynakOku("StandartRolUclari.cs");
        // `new("kod", false)` bir YETKİ kuralı; `new("kod", "Ad", …)` bir ŞABLON
        //   satırı - ikincinin ilk dizesi rol kodudur, yetki değil. Ayrımı
        //   ikinci argümanın dize OLMAMASI veriyor.
        return [.. Regex.Matches(metin,
                @"(?:\b[TYHA]\(|new\((?!\s*""[^""]*""\s*,\s*""))""(?<kod>[a-z_][a-z0-9_.%-]*)""")
            .Select(m => m.Groups["kod"].Value).Distinct()];
    }

    [Fact(DisplayName = "Şablonlardaki yetki kodları katalogda var")]
    public async Task Sablon_yetki_kodlari_gercek()
    {
        if (!_olgu.Baglandi(nameof(Sablon_yetki_kodlari_gercek))) return;
        var veri = _olgu.Gerekli();

        var desenler = SablonDesenleri();
        Assert.NotEmpty(desenler);
        var yetkiler = await veri.ListeAsync("select kod from public.yetki",
            null, o => o.GetString(0), Iptal);

        // Joker desen (`%`) birden çok yetkiyi kapsar; onları LIKE ile arar,
        //   düz kodları birebir. Hiçbir şeye uymayan desen = yazım hatası.
        var eksik = desenler.Where(d => d.Contains('%')
                ? !yetkiler.Any(y => Regex.IsMatch(y, "^" + Regex.Escape(d).Replace("%", ".*") + "$"))
                : !yetkiler.Contains(d))
            .ToList();

        Assert.True(eksik.Count == 0,
            "Katalogda karşılığı olmayan yetki deseni: " + string.Join(", ", eksik));
    }

    [Fact(DisplayName = "Onay basamaklarının yetkisi en az bir şablonda var")]
    public async Task Onay_basamaklarinin_sahibi_var()
    {
        if (!_olgu.Baglandi(nameof(Onay_basamaklarinin_sahibi_var))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Zincirin kullandığı yetki kodları `OnayUclari.AksiyonKodu` içinde
        //   yazılı - onay motorunun tek doğru kaynağı orası.
        var onayMetni = KaynakOku("OnayUclari.cs");
        var govde = Regex.Match(onayMetni,
            @"AksiyonKodu\(string akisKod, short rol\) => akisKod switch\s*\{(?<g>.*?)\n    \};",
            RegexOptions.Singleline);
        Assert.True(govde.Success, "AksiyonKodu haritası kaynakta bulunamadı.");
        // YALNIZ `=>` SAĞINDAKİLER: switch ETİKETLERİ akış kodudur
        //   ("personel.izin"), yetki değil.
        var kodlar = Regex.Matches(govde.Groups["g"].Value, @"=>\s*""(?<k>[a-z_]+\.[a-z_]+)""")
            .Select(m => m.Groups["k"].Value).Distinct().ToList();
        Assert.NotEmpty(kodlar);

        // Kodun gerçekten bir yetki olduğunu da doğrula: switch'te yazım
        //   hatası olsaydı basamak hiç imzalanamazdı.
        var yetkiler = await b.ListeAsync("select kod from public.yetki", null, [],
            o => o.GetString(0), Iptal);
        var tanimsiz = kodlar.Where(k => !yetkiler.Contains(k)).ToList();
        Assert.True(tanimsiz.Count == 0,
            "Onay motorunun istediği yetki katalogda yok: " + string.Join(", ", tanimsiz));

        var desenler = SablonDesenleri();
        var sahipsiz = kodlar.Where(k => !desenler.Any(d => d.Contains('%')
                ? Regex.IsMatch(k, "^" + Regex.Escape(d).Replace("%", ".*") + "$")
                : d == k))
            .ToList();

        Assert.True(sahipsiz.Count == 0,
            "Bu onay basamağının yetkisi hiçbir şablon rolde yok (sahibi yalnız "
            + "sistem yöneticisi olur, talep orada bekler): " + string.Join(", ", sahipsiz));
    }
}
