using System.Collections.Concurrent;
using System.Globalization;
using Gentegre.Cekirdek.Sigorta;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// KOD ÇEVİRİCİ (430) — kanonik değer ↔ sağlayıcı değeri.
///
/// <para>Tablo (<c>sigorta_kod_esleme</c>) KURULUM verisidir: yeni şirket
/// bağlanırken doldurulur, sonra neredeyse hiç değişmez. Bu yüzden bellekte
/// tutulur; her provizyon satırı için ayrı sorgu, tek bir gönderimde onlarca
/// gidiş-geliş demek olurdu.</para>
///
/// <para><b>Eşleme yoksa alan GÖNDERİLMEZ</b> (boş döner). Uydurma bir kod
/// göndermek, şirkette anlamı belirsiz bir provizyon oluştururdu; eksik alan
/// ise şirketin kendi doğrulamasına takılır ve hata mesajı okunur.</para>
/// </summary>
public sealed class SigortaKodDeposu(VeriKaynagi veri) : ISigortaKodCevirici
{
    private readonly VeriKaynagi _veri = veri;

    private sealed record Sozluk(
        IReadOnlyDictionary<string, string> Ileri,   // "alan|yerel" -> saglayici
        IReadOnlyDictionary<string, short> Geri);    // "alan|saglayici" -> yerel

    private static readonly ConcurrentDictionary<short, Sozluk> Onbellek = new();

    /// <summary>Kurulumda / kod eşleme değişince çağrılır.</summary>
    public static void OnbellegiTemizle(short? saglayiciId = null)
    {
        if (saglayiciId is { } id) Onbellek.TryRemove(id, out _);
        else Onbellek.Clear();
    }

    /// <summary>
    /// Sözlüğü yükler. Uçlar bunu istek başında bir kez çağırır; senkron
    /// <see cref="Uzak"/> / <see cref="Yerel"/> çağrıları hazır sözlükten okur
    /// (adapter'ların async olmayan alan çevirisi yapabilmesi için).
    /// </summary>
    public async Task YukleAsync(short saglayiciId, CancellationToken iptal = default)
    {
        if (Onbellek.ContainsKey(saglayiciId)) return;

        var satirlar = await _veri.ListeAsync("""
            select alan, yerel_kod, saglayici_kod
              from public.sigorta_kod_esleme
             where saglayici_id = @p0
            """, [saglayiciId],
            o => (Alan: o.GetString(0), Yerel: o.GetString(1), Uzak: o.GetString(2)), iptal);

        var ileri = new Dictionary<string, string>(StringComparer.Ordinal);
        var geri = new Dictionary<string, short>(StringComparer.OrdinalIgnoreCase);
        foreach (var s in satirlar)
        {
            ileri[$"{s.Alan}|{s.Yerel}"] = s.Uzak;
            if (short.TryParse(s.Yerel, NumberStyles.Integer, CultureInfo.InvariantCulture,
                               out var yerel))
                geri[$"{s.Alan}|{s.Uzak}"] = yerel;
        }
        Onbellek[saglayiciId] = new Sozluk(ileri, geri);
    }

    public string Uzak(short saglayiciId, string alan, short? yerelKod)
    {
        if (yerelKod is null) return "";
        return Onbellek.TryGetValue(saglayiciId, out var s)
            && s.Ileri.TryGetValue($"{alan}|{yerelKod.Value}", out var uzak) ? uzak : "";
    }

    public short? Yerel(short saglayiciId, string alan, string? saglayiciKod)
    {
        if (string.IsNullOrWhiteSpace(saglayiciKod)) return null;
        return Onbellek.TryGetValue(saglayiciId, out var s)
            && s.Geri.TryGetValue($"{alan}|{saglayiciKod.Trim()}", out var yerel)
            ? yerel : null;
    }
}
