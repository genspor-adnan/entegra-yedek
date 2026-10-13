using System.Text.RegularExpressions;

namespace Gentegre.Testler;

/// <summary>
/// KARTIN BELGE KAYNAĞI DOKÜMAN DEPOSUNUN BEYAZ LİSTESİNDE OLMALI.
///
/// Kartın "Belgeler" sekmesi kart adını <c>DokumanUclari.FizikselKaynak</c> ile
/// tablo kaynağına çevirir ("personelIzin" → "izin"); <c>DokumanDeposu</c> ise
/// yalnız beyaz listedeki kaynağa okur / yazar. İki liste ayrı dosyalarda ve
/// birbirini bilmiyor.
///
/// GERÇEK VAKA (dokuman/17): arıza, duyuru, izin, avans, belge talebi,
/// radyoloji cihazı (04.10.2026) ve demirbaş (10.10.2026) belgeleri
/// FizikselKaynak'a eklendi, beyaz listeye eklenmedi. Bu ekranların Belgeler
/// sekmeleri "Bilinmeyen kaynak" ile 500 veriyordu; 12.10.2026'ya dek fark
/// edilmedi. Bu test iki listeyi karşılaştırır.
/// </summary>
public sealed class DokumanKaynakBeyazListeTestleri
{
    private static string Kaynak(params string[] yol)
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        return File.ReadAllText(Path.Combine([dizin!.FullName, "src", .. yol]));
    }

    [Fact]
    public void FizikselKaynak_hedefleri_depo_beyaz_listesinde()
    {
        var uclar = Kaynak("Gentegre.Api", "Uclar", "DokumanUclari.cs");
        // FizikselKaynak gövdesi: "private static string FizikselKaynak(...) => kartAdi switch { ... };"
        var bas = uclar.IndexOf("string FizikselKaynak(", StringComparison.Ordinal);
        Assert.True(bas >= 0, "DokumanUclari.FizikselKaynak bulunamadı - test güncellenmeli.");
        var son = uclar.IndexOf("};", bas, StringComparison.Ordinal);
        var govde = uclar[bas..son];
        // Kol: "... => \"izin\"," - sağdaki metin tablo kaynağıdır (`_ => kartAdi` metin değil, atlanır).
        var hedefler = new SortedSet<string>(
            Regex.Matches(govde, @"=>\s*""([a-z0-9-]+)""").Select(m => m.Groups[1].Value), StringComparer.Ordinal);
        // "a" or "b" => kartAdi kolu: soldaki adlar aynen tablo kaynağı olur.
        foreach (Match m in Regex.Matches(govde, @"((?:""[a-z0-9-]+""\s*(?:or\s*)?)+)=>\s*kartAdi"))
            foreach (Match a in Regex.Matches(m.Groups[1].Value, @"""([a-z0-9-]+)"""))
                hedefler.Add(a.Groups[1].Value);
        Assert.NotEmpty(hedefler);   // desen tutmuyorsa test boşuna yeşil olmasın

        var depo = Kaynak("Gentegre.Veri", "Depolar", "DokumanDeposu.cs");
        var lb = depo.IndexOf("KaynakBeyazListe =", StringComparison.Ordinal);
        Assert.True(lb >= 0, "DokumanDeposu.KaynakBeyazListe bulunamadı - test güncellenmeli.");
        var liste = depo[lb..depo.IndexOf("};", lb, StringComparison.Ordinal)];
        // Yorum satırlarındaki tırnaklı adlar sayılmasın: yalnız "{ ... }" gövdesi.
        var izinli = new SortedSet<string>(
            Regex.Matches(liste[liste.IndexOf('{')..], @"""([a-z0-9-]+)""").Select(m => m.Groups[1].Value),
            StringComparer.Ordinal);

        var eksik = hedefler.Except(izinli).ToList();
        Assert.True(eksik.Count == 0,
            "Kartın belge kaynağı DokumanDeposu beyaz listesinde yok - o kartın Belgeler sekmesi 500 verir:\n  "
            + string.Join("\n  ", eksik));
    }
}
