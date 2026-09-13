using System.Text.RegularExpressions;

namespace Gentegre.Testler;

/// <summary>
/// KATALOĞUN İSTEDİĞİ HER KOD TABLOSU BEYAZ LİSTEDE OLMALI.
///
/// Kart alanları lookup'ı `KodTablosu: "public.v_..."` ile bağlar; okuma
/// tarafı ise bir BEYAZ LİSTE tutar - istek metni asla SQL'e geçmesin diye
/// (§ liste SQL'i whitelist'ten üretilir). İki yer ayrı dosyalarda ve
/// birbirini bilmiyor: kataloğa yeni lookup eklenip beyaz listeye
/// eklenmeyince kart AÇILMIYOR bile.
///
/// GERÇEK VAKA: 615'te uyruk/meslek/klinik lookup'ları hasta ve departman
/// kartlarına bağlandı, beyaz listeye eklenmedi. Hasta kartı "Bilinmeyen kod
/// tablosu: public.v_skrs_ulke_lookup" ile 500 veriyordu - alan bazlı değil,
/// KARTIN TAMAMI açılmıyordu, çünkü hata alan listesini üreten uçta.
///
/// Derleyici yakalamaz (ikisi de sadece metin), testler de yakalamamıştı.
/// Bu test iki listeyi karşılaştırır.
/// </summary>
public sealed class KodTablosuBeyazListeTestleri
{
    private static DirectoryInfo KaynakKok()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        return new DirectoryInfo(Path.Combine(dizin!.FullName, "src"));
    }

    [Fact]
    public void Katalogdaki_lookuplar_beyaz_listede()
    {
        var kok = KaynakKok();

        // Katalogda kullanılan: KodTablosu: "public.v_..."
        var kullanilan = new SortedSet<string>(StringComparer.Ordinal);
        foreach (var dosya in Directory.GetFiles(
                     Path.Combine(kok.FullName, "Gentegre.Cekirdek", "Katalog"),
                     "*.cs", SearchOption.AllDirectories))
            foreach (Match m in Regex.Matches(File.ReadAllText(dosya),
                         @"KodTablosu:\s*""(public\.[A-Za-z0-9_]+)"""))
                kullanilan.Add(m.Groups[1].Value);

        Assert.NotEmpty(kullanilan);   // desen tutmuyorsa test boşuna yeşil olmasın

        var okuma = File.ReadAllText(Path.Combine(
            kok.FullName, "Gentegre.Veri", "Depolar", "KartDeposu.Okuma.cs"));
        // Beyaz listede GORUNUM de TABLO da var ("public.rol", "public.sube");
        //   desen `v_` ile sinirli olsaydi onlari gormez ve yanlis alarm
        //   verirdi.
        var izinli = new SortedSet<string>(
            Regex.Matches(okuma, @"""(public\.[A-Za-z0-9_]+)""")
                 .Select(m => m.Groups[1].Value), StringComparer.Ordinal);

        var eksik = kullanilan.Except(izinli).ToList();
        Assert.True(eksik.Count == 0,
            "Kataloğa bağlı ama beyaz listede olmayan kod tablosu - o kartlar "
            + "hiç açılmaz:\n  " + string.Join("\n  ", eksik));
    }
}
