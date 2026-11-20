namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RADYOLOJİ RAPORU GÖNDERİM ZAMANI (1389; kullanıcı 20.11.2026: "otomatik gönderim zamanı tümü / kategori / koda göre
/// değişebilmeli.. öncelik koda bakmalı sonra kategori sonra tümü.. kritik bulgu için tek süre yeterli").
///
/// Şubenin kural satırlarından raporun tetkiğine uyan seçilir: önce KOD (tetkik), yoksa tetkiğin KATEGORİSİ (en yakın
/// üst kategori kazanır), o da yoksa TÜMÜ. Hiç satır uymuyorsa otomatik gönderilmez. Kritik bulgulu raporda kurallara
/// bakılmaz - tek süre (dakika); 0 ise otomatik gitmez.
/// </summary>
public static class RaporGonderimKurali
{
    public const short KapsamTumu = 0, KapsamKategori = 1, KapsamKod = 2;
    public const short ZamanHemen = 0, ZamanSaatSonra = 1, ZamanErtesiGun = 2;

    /// <param name="GunDakika">Ertesi gün kuralında günün dakikası (900 = 15:00).</param>
    public sealed record Kural(short Kapsam, int? KategoriId, int? HizmetId, short ZamanTur, int Saat, int GunDakika, string Ad = "");

    /// <summary>
    /// Tetkiğe uyan kural. <paramref name="kategoriZinciri"/>: tetkiğin kategorisi ve üstleri, YAKINDAN UZAĞA.
    /// </summary>
    public static Kural? Sec(IEnumerable<Kural> kurallar, int hizmetId, IReadOnlyList<int> kategoriZinciri)
    {
        var liste = kurallar as IReadOnlyCollection<Kural> ?? kurallar.ToList();
        if (liste.FirstOrDefault(k => k.Kapsam == KapsamKod && k.HizmetId == hizmetId) is { } kod) return kod;
        foreach (var kategori in kategoriZinciri)
            if (liste.FirstOrDefault(k => k.Kapsam == KapsamKategori && k.KategoriId == kategori) is { } kat) return kat;
        return liste.FirstOrDefault(k => k.Kapsam == KapsamTumu);
    }

    /// <summary>
    /// Gönderim anı (UTC). <paramref name="simdi"/> UTC; "ertesi gün saat" şubenin saat diliminde hesaplanır.
    /// </summary>
    public static DateTime Zaman(Kural kural, DateTime simdi, TimeZoneInfo dilim)
    {
        switch (kural.ZamanTur)
        {
            case ZamanHemen: return simdi;
            case ZamanErtesiGun:
                var yerel = TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(simdi, DateTimeKind.Utc), dilim);
                var hedef = yerel.Date.AddDays(1).AddMinutes(Math.Clamp(kural.GunDakika, 0, 1439));
                return TimeZoneInfo.ConvertTimeToUtc(DateTime.SpecifyKind(hedef, DateTimeKind.Unspecified), dilim);
            default: return simdi.AddHours(Math.Max(0, kural.Saat));
        }
    }

    /// <summary>Kuralın listede / kartta görünen açıklaması: "Kategori MR · 3 saat sonra".</summary>
    public static string Aciklama(Kural kural)
    {
        var kapsam = kural.Kapsam switch
        {
            KapsamKod => "Kod " + kural.Ad, KapsamKategori => "Kategori " + kural.Ad, _ => "Tümü",
        };
        var zaman = kural.ZamanTur switch
        {
            ZamanHemen => "hemen",
            ZamanErtesiGun => $"ertesi gün {kural.GunDakika / 60:00}:{kural.GunDakika % 60:00}",
            _ => $"{kural.Saat} saat sonra",
        };
        return $"{kapsam.Trim()} · {zaman}";
    }
}
