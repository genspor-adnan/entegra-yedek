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

    /// <summary>
    /// SUBE DILIMLERI (666): "ileri tarihli belge", "kac gun gecti" gibi
    /// kararlar SUBENIN gununde verilmeli - Berlin subesinde saat 23:00'te
    /// kesilen belge, Istanbul gunune gore "yarin" gorunurdu.
    ///
    /// Onbellek: TimeZoneInfo aramasi ucuz degil ve her istekte cagriliyor.
    /// </summary>
    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, TimeZoneInfo>
        _dilimler = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>Ada gore dilim; bos/taninmayan ad KURULUS dilimine duser.</summary>
    public static TimeZoneInfo Dilim(string? ad)
        => string.IsNullOrWhiteSpace(ad) ? _dilim : _dilimler.GetOrAdd(ad, Bul);

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

    /// <summary>VERILEN dilimde simdi (sube saati, 666).</summary>
    public static DateTime SimdiDilim(string? dilim)
        => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, Dilim(dilim));

    /// <summary>VERILEN dilimde bugun (sube gunu, 666).</summary>
    public static DateTime BugunDilim(string? dilim) => SimdiDilim(dilim).Date;

    /// <summary>
    /// VERITABANINA YAZILACAK "simdi" (667): AN, duvar saati degil. Zaman
    /// damgalari timestamptz olduktan sonra saklanan sey bir andir; duvar
    /// saati yazmak, sunucunun saat dilimine gore kayan bir deger birakirdi.
    /// </summary>
    public static DateTime An => DateTime.UtcNow;

    /// <summary>
    /// Saat dilimi BILINMEYEN bir degeri (kullanicinin yazdigi duvar saati)
    /// kurulus dilimine gore UTC ana cevirir. Kind zaten belliyse dokunmaz.
    ///
    /// Yaz saati gecisinde OLMAYAN bir saat girilirse (ornegin 02:30, saatlerin
    /// ileri alindigi gece) .NET hata verir - o durumda deger oldugu gibi UTC
    /// sayilir: kaydi reddetmek, bir saatlik kenar durumu yuzunden calismayi
    /// durdurmak olurdu.
    /// </summary>
    public static DateTime UtcYap(DateTime d, string? dilim = null)
    {
        if (d.Kind != DateTimeKind.Unspecified) return d.ToUniversalTime();
        try { return TimeZoneInfo.ConvertTimeToUtc(d, Dilim(dilim)); }
        catch (ArgumentException) { return DateTime.SpecifyKind(d, DateTimeKind.Utc); }
    }

    /// <summary>UTC bir ani verilen (yoksa kurulus) saat diliminde duvar saatine cevirir.</summary>
    public static DateTime Yerel(DateTime utc, string? dilim = null)
        => TimeZoneInfo.ConvertTimeFromUtc(
               utc.Kind == DateTimeKind.Utc ? utc : DateTime.SpecifyKind(utc, DateTimeKind.Utc),
               Dilim(dilim));

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
