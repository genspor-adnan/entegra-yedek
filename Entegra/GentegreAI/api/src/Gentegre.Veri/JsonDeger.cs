using System.Globalization;
using System.Text.Json;

namespace Gentegre.Veri;

/// <summary>
/// ISTEK GOVDESINDEN TIP DONUSUMU - tek yer.
///
/// Belge ve kasa depolari bu yardimcilarin kendi kopyalarini tasiyordu ve
/// kopyalar AYRISMISTI: belge tarafi <c>JsonOndalik</c>'ta METIN gelen sayiyi
/// ("1234.56") da coz(uy)ordu, kasa tarafi cozmuyor ve sessizce varsayilana
/// dusuyordu - ayni govde iki uca farkli sonuc veriyordu.
///
/// Is kurali YOK: yalnizca "yoksa varsayilan, metinse ayristir" turu donusumler.
/// Cagiran dosyalar <c>using static Gentegre.Veri.JsonDeger;</c> ile alir.
/// </summary>
public static class JsonDeger
{
    public static string JsonMetin(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.String
           ? e.GetString() ?? "" : "";

    public static long JsonSayi(Dictionary<string, JsonElement> d, string ad, long varsayilan)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number
           && e.TryGetInt64(out var l) ? l : varsayilan;

    public static int? JsonSayiNull(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number
           && e.TryGetInt32(out var i) ? i : null;

    /// <summary>
    /// Ondalik deger. METIN de kabul edilir: arayuz sayilari kimi zaman dizge
    /// olarak gonderiyor ("1234.56") ve bunu reddetmek tutari sessizce sifirlardi.
    /// Ayristirma INVARIANT kulturle yapilir - govde her zaman nokta ondalikli.
    /// </summary>
    public static decimal JsonOndalik(Dictionary<string, JsonElement> d, string ad, decimal varsayilan)
    {
        if (!d.TryGetValue(ad, out var e)) return varsayilan;
        return e.ValueKind switch
        {
            JsonValueKind.Number => e.GetDecimal(),
            JsonValueKind.String => decimal.TryParse(e.GetString(), NumberStyles.Number,
                                        CultureInfo.InvariantCulture, out var m) ? m : varsayilan,
            _ => varsayilan
        };
    }

    /// <summary>Dizi ogesini (or. satir.izlemler[i]) alan sozlugune cevirir.</summary>
    public static Dictionary<string, JsonElement> JsonNesne(JsonElement e)
    {
        var sonuc = new Dictionary<string, JsonElement>(StringComparer.OrdinalIgnoreCase);
        if (e.ValueKind == JsonValueKind.Object)
            foreach (var alan in e.EnumerateObject()) sonuc[alan.Name] = alan.Value;
        return sonuc;
    }

    /// <summary>ISO tarih ("2026-08-24" ya da tam damga); bos/gecersiz ise null.</summary>
    public static DateTime? JsonTarih(Dictionary<string, JsonElement> d, string ad)
    {
        if (!d.TryGetValue(ad, out var e) || e.ValueKind != JsonValueKind.String) return null;
        var metin = e.GetString();
        if (string.IsNullOrWhiteSpace(metin)) return null;
        return DateTime.TryParse(metin, CultureInfo.InvariantCulture,
                                 DateTimeStyles.None, out var t) ? t : null;
    }
}
