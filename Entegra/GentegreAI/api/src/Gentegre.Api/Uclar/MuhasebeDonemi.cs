using System.Globalization;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUHASEBE DÖNEM KAPANIŞI - İrsaliye-Fatura Eşleşme (Bağla) ve KDV İcmali (kapanmış aya düşen alış)
/// aynı kuralı okur (önceden iki kopyaydı).
/// </summary>
internal static class MuhasebeDonemi
{
    /// <summary>
    /// AÇIK DÖNEMİN İLK GÜNÜ. Genel Ayarlar'da `muhasebe.donem_kapanis_tarihi` (yyyy-MM-dd ya da
    /// dd.MM.yyyy; o gün dahil kapalı) varsa ondan sonraki gün; yoksa içinde bulunulan ayın ilk
    /// günü - ay sonu kapanışı: önceki aylar kapanmış sayılır.
    /// </summary>
    internal static async Task<DateTime> AcikDonemBasiAsync(NpgsqlConnection b, NpgsqlTransaction? tx,
        DateTime bugun, CancellationToken iptal)
    {
        var ayar = (await AyarDeposu.MetinAsync(b, tx, "muhasebe.donem_kapanis_tarihi", "", iptal)).Trim();
        if (ayar.Length > 0 && DateTime.TryParseExact(ayar, ["yyyy-MM-dd", "dd.MM.yyyy", "yyyy-MM-ddTHH:mm:ss"],
                CultureInfo.InvariantCulture, DateTimeStyles.None, out var kapanis))
            return kapanis.Date.AddDays(1);
        return new DateTime(bugun.Year, bugun.Month, 1);
    }
}
