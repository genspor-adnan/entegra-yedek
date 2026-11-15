namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BAŞVURU KARTININ KURUM TİPİNE BAĞLI KURALLARI (kod inceleme 16.11.2026): geliş nedeni varsayılanı, Sıra No ve
/// Refakatçi alanlarının görünürlüğü. Eskiden istemcide kurum tipi kodu listeleriyle yazılıydı (iki dosyada aynı
/// liste); CLAUDE.md kuralı gereği karar SUNUCUDA verilir, istemci `/api/belge/basvuru-kaynaklari` içindeki
/// `kurallar`ı uygular. Yeni bir kurum tipi eklenince yalnız burası değişir.
/// </summary>
/// <param name="GelisNedeniVarsayilan">Yeni başvuruda boş geliş nedenine yazılacak kod (basvuru.gelis_nedeni; 3 = Tetkik / Tahlil), yoksa null.</param>
/// <param name="SiraNoVar">Bekleme sırası numarası sorulur mu (poliklinikli kurumlar).</param>
/// <param name="RefakatciVar">Refakatçi alanı sorulur mu (yalnız hastane).</param>
public sealed record BasvuruKurumKurallari(int? GelisNedeniVarsayilan, bool SiraNoVar, bool RefakatciVar)
{
    /// <summary>Tetkik kurumları: hasta randevu / istemle tetkik için gelir (kullanıcı 16.11.2026).</summary>
    private static readonly HashSet<string> TetkikKurumlari = new(StringComparer.Ordinal) { "lab", "goruntuleme", "goruntuleme_lab" };

    /// <summary>Sıra No'su olmayan kurumlar: tetkik kurumları + muayenehane (kullanıcı 16.11.2026).</summary>
    private static readonly HashSet<string> SiraNosuz = new(StringComparer.Ordinal) { "lab", "goruntuleme", "goruntuleme_lab", "muayenehane" };

    public static BasvuruKurumKurallari Icin(string? kurumTipi)
    {
        var tip = kurumTipi ?? "";
        return new BasvuruKurumKurallari(
            GelisNedeniVarsayilan: TetkikKurumlari.Contains(tip) ? 3 : null,
            SiraNoVar: !SiraNosuz.Contains(tip),
            RefakatciVar: tip == "hastane");
    }
}
