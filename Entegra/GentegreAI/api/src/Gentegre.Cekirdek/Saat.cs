namespace Gentegre.Cekirdek;

/// <summary>
/// KURULUS SAATI - sunucunun (konteynerin) saat diliminden BAGIMSIZ "simdi".
///
/// SORUN: API konteyneri UTC calisiyor, kullanici Turkiye saatiyle giriyor.
/// `DateTime.Now` konteynerde UTC dondugu icin 12:04'te kesilen bir fatura
/// "3 saat ileri tarihli" sayilip reddediliyordu (kullanici: "saati geri alirsam
/// ekleniyor").
///
/// COZUM: her yerde UTC'den kuruluşun saat dilimine cevrilmis zaman kullanilir.
/// Dilim `Kurulus:SaatDilimi` ayariyla degistirilebilir (varsayilan
/// Europe/Istanbul); tanimsiz bir dilim verilirse sunucu saatine dusulur.
/// </summary>
public static class Saat
{
    private static TimeZoneInfo _dilim = Bul("Europe/Istanbul");

    /// <summary>Uygulama acilisinda ayardan okunur (Program.cs).</summary>
    public static void DilimAyarla(string? ad)
    {
        if (!string.IsNullOrWhiteSpace(ad)) _dilim = Bul(ad);
    }

    public static string DilimAdi => _dilim.Id;

    /// <summary>Kurulus saat diliminde SIMDI (tarih + saat).</summary>
    public static DateTime Simdi => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _dilim);

    /// <summary>Kurulus saat diliminde BUGUN (saat 00:00).</summary>
    public static DateTime Bugun => Simdi.Date;

    private static TimeZoneInfo Bul(string ad)
    {
        try { return TimeZoneInfo.FindSystemTimeZoneById(ad); }
        catch (TimeZoneNotFoundException) { }
        catch (InvalidTimeZoneException) { }
        // Windows'ta ICU adi bulunamazsa eski Windows kimligi denenir.
        try { return TimeZoneInfo.FindSystemTimeZoneById("Turkey Standard Time"); }
        catch (TimeZoneNotFoundException) { return TimeZoneInfo.Local; }
        catch (InvalidTimeZoneException) { return TimeZoneInfo.Local; }
    }
}
