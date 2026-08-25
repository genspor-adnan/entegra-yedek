using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri;

/// <summary>
/// Dinamik SQL parametreleri.
///
/// SORUN: kolon listesi calisma aninda kuruldugunda (kasa islemi basligi, belge
/// basligi, kart yazma) bir alan NULL gelirse <c>AddWithValue(ad, DBNull.Value)</c>
/// parametreye HIC tip vermez; PostgreSQL de ifadeden tip cikaramayip
/// <c>42P08 could not determine data type of parameter $n</c> ile reddeder.
/// Arayuz bu alanlari hep doldurdugu icin ekranda gorunmuyordu, API'yi dogrudan
/// cagiran (entegrasyon, betik) her seferinde 500 aliyordu.
///
/// COZUM: NULL'lar <c>unknown</c> tipiyle gonderilir - PostgreSQL bunu hedef
/// kolonun tipine gore cozer, tipi burada bilmemiz gerekmez.
/// </summary>
public static class Parametre
{
    public static void Ekle(NpgsqlCommand komut, string ad, object? deger)
    {
        if (deger is null or DBNull)
            komut.Parameters.Add(new NpgsqlParameter(ad, NpgsqlDbType.Unknown)
            {
                Value = DBNull.Value,
            });
        else
            komut.Parameters.AddWithValue(ad, deger);
    }

    /// <summary>Sirali parametre listesi: @p0, @p1, ... (dinamik SQL uretenler).</summary>
    public static void Ekle(NpgsqlCommand komut, IReadOnlyList<object?> degerler)
    {
        for (var i = 0; i < degerler.Count; i++)
            Ekle(komut, "p" + i.ToString(System.Globalization.CultureInfo.InvariantCulture),
                 degerler[i]);
    }
}
