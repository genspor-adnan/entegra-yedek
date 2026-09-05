namespace Gentegre.Cekirdek.Zamanlama;

/// <summary>
/// ZAMANLI İŞİN SONRAKİ ÇALIŞMA ZAMANI (405).
///
/// İşçinin içinden çıkarıldı: hesap saf bir kural ve TEST EDİLEBİLİR olmalı -
/// "pazartesi 04:00" gibi bir zamanlamanın yanlış hesaplanması ancak haftalar
/// sonra fark edilirdi.
/// </summary>
public static class ZamanlamaHesabi
{
    /// <summary>Periyot kodları: 1 saatlik · 2 günlük · 3 haftalık · 4 aylık.</summary>
    public static DateTime Sonraki(DateTime simdi, int periyot, int gun, int saat, int dakika)
        => periyot switch
        {
            1 => simdi.AddHours(1),
            2 => Gunluk(simdi, saat, dakika),
            4 => Aylik(simdi, Math.Clamp(gun, 1, 28), saat, dakika),
            _ => Haftalik(simdi, Math.Clamp(gun, 1, 7), saat, dakika),
        };

    /// <summary>Bugünün saati geçtiyse yarın.</summary>
    public static DateTime Gunluk(DateTime simdi, int saat, int dakika)
    {
        var h = simdi.Date.AddHours(saat).AddMinutes(dakika);
        return h > simdi ? h : h.AddDays(1);
    }

    /// <summary>Gün: 1 Pazartesi … 7 Pazar (ISO). Bu haftaki an geçtiyse gelecek hafta.</summary>
    public static DateTime Haftalik(DateTime simdi, int gun, int saat, int dakika)
    {
        var bugun = (int)simdi.DayOfWeek == 0 ? 7 : (int)simdi.DayOfWeek;
        var fark = (gun - bugun + 7) % 7;
        var h = simdi.Date.AddDays(fark).AddHours(saat).AddMinutes(dakika);
        return h > simdi ? h : h.AddDays(7);
    }

    /// <summary>Ayın günü 1-28 (29-31 her ayda yok; iş sessizce atlanmasın).</summary>
    public static DateTime Aylik(DateTime simdi, int gun, int saat, int dakika)
    {
        var h = new DateTime(simdi.Year, simdi.Month, gun, saat, dakika, 0);
        return h > simdi ? h : h.AddMonths(1);
    }
}
