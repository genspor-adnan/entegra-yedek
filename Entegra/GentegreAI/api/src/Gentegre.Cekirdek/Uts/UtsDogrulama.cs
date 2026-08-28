using System.Globalization;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Uts;

/// <summary>
/// ÜTS ALAN DOĞRULAMASI - tek yer. Delphi'de her ekran kendi kontrolünü
/// yapıyordu (ya da yapmıyordu); burada bildirim gönderilmeden ÖNCE tüm
/// alanlar sözleşme sınırlarına vurulur ki ÜTS'den anlaşılmaz 400'ler yerine
/// alan bazlı yerli mesajlar dönsün.
///
/// Sözleşme sınırları: UNO ≤23 (rakam), LNO/SNO ≤20, BNO ≤50, GIT YYYY-AA-GG.
/// ADT kuralı (s23 takip tablosu): SNO doluysa ürün TEKİL takiplidir ve ADT
/// GÖNDERİLMEZ; yalnız LNO doluysa LOT takiplidir ve ADT ≥ 1 zorunludur.
/// </summary>
public static class UtsDogrulama
{
    public static string Uno(string? deger)
    {
        var d = (deger ?? "").Trim();
        if (d.Length == 0)
            throw GentegreHatasi.Dogrulama("Ürün numarası (UNO) zorunludur.",
                new AlanHatasi("uno", "Boş olamaz."));
        if (d.Length > 23 || !d.All(char.IsDigit))
            throw GentegreHatasi.Dogrulama("Ürün numarası (UNO) geçersiz.",
                new AlanHatasi("uno", "En çok 23 rakam."));
        return d;
    }

    public static string? LotNo(string? deger) => EnFazla(deger, 20, "lotNo", "Lot numarası");
    public static string? SeriNo(string? deger) => EnFazla(deger, 20, "seriNo", "Seri numarası");

    public static string BelgeNo(string? deger)
    {
        var d = (deger ?? "").Trim();
        if (d.Length is 0 or > 50)
            throw GentegreHatasi.Dogrulama("Belge numarası (BNO) zorunludur.",
                new AlanHatasi("belgeNo", "1-50 karakter."));
        return d;
    }

    public static string KurumNo(string? deger)
    {
        var d = (deger ?? "").Trim();
        if (d.Length is 0 or > 30 || !d.All(char.IsDigit))
            throw GentegreHatasi.Dogrulama("Karşı kurumun ÜTS numarası (KUN) geçersiz.",
                new AlanHatasi("kurumNo", "En çok 30 rakam, boş olamaz."));
        return d;
    }

    /// <summary>GIT / tarih alanları: ÜTS "YYYY-AA-GG" ister.</summary>
    public static string Tarih(DateTime? deger, string alan, string baslik)
    {
        if (deger is null)
            throw GentegreHatasi.Dogrulama($"{baslik} zorunludur.",
                new AlanHatasi(alan, "Boş olamaz."));
        return deger.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    }

    /// <summary>
    /// Takip tipi + ADT kuralı: (adtGonderilecek, adet). SNO dolu → tekil,
    /// ADT gönderilmez (null). Yalnız LNO → lot, ADT ≥ 1 zorunlu. İkisi de
    /// boşsa bildirim yapılamaz.
    /// </summary>
    public static decimal? AdetKurali(string? seriNo, string? lotNo, decimal adet)
    {
        var tekil = !string.IsNullOrWhiteSpace(seriNo);
        var lot = !string.IsNullOrWhiteSpace(lotNo);
        if (!tekil && !lot)
            throw GentegreHatasi.Dogrulama(
                "Seri (SNO) ya da lot (LNO) numarasından en az biri gereklidir.",
                new AlanHatasi("seriNo", "Tekil üründe seri, lot takipli üründe lot girilir."));
        if (tekil) return null;                 // tekil takipte ADT gönderilmez
        if (adet < 1)
            throw GentegreHatasi.Dogrulama("Lot takipli üründe adet (ADT) 1'den küçük olamaz.",
                new AlanHatasi("adet", "En az 1."));
        return adet;
    }

    /// <summary>
    /// GTIN 13/14 varyantları: ÜTS'nin verdiği UNO ile stoktaki barkod hane
    /// sayısı farklı olabilir (Delphi tuzağı) - baştaki '0' atılmış/eklenmiş
    /// ikinci varyantla birlikte aranır.
    /// </summary>
    public static string[] UnoVaryantlari(string uno)
    {
        var d = uno.Trim();
        if (d.Length > 1 && d[0] == '0')
            return new[] { d, d.TrimStart('0') };
        return new[] { d, "0" + d };
    }

    private static string? EnFazla(string? deger, int sinir, string alan, string baslik)
    {
        var d = (deger ?? "").Trim();
        if (d.Length == 0) return null;         // boş → JSON'a hiç yazılmaz
        if (d.Length > sinir)
            throw GentegreHatasi.Dogrulama($"{baslik} en çok {sinir} karakter olabilir.",
                new AlanHatasi(alan, $"En çok {sinir} karakter."));
        return d;
    }
}
