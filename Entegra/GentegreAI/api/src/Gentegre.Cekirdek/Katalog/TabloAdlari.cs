namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TABLO ADI -> KULLANICIYA GÖRÜNEN AD.
///
/// Silme engeli mesajının sonuna "hangi kayıttan kaç tane engelliyor"
/// bilgisi ekleniyor (§3.3). Orada ham tablo adı görünüyordu:
/// "(hakedis_satir: 2 kayıt)". Kullanıcı tablo adı bilmez - burada tek
/// yerden Türkçe karşılığa çevrilir.
///
/// Sözlükte olmayan tablo için ham ad döner: mesaj yine anlaşılır kalır
/// ("belge: 3 kayıt"), yalnız daha az cilalı olur. Yeni bir engel eklenince
/// buraya bir satır yazmak yeterli.
/// </summary>
public static class TabloAdlari
{
    private static readonly Dictionary<string, string> Adlar =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["belge"]              = "belge",
            ["belge_satir"]        = "belge satırı",
            ["cek_senet"]          = "çek / senet",
            ["fiyat_listesi"]      = "fiyat listesi",
            ["hakedis"]            = "hakediş",
            ["hakedis_satir"]      = "hakediş satırı",
            ["hesap"]              = "kasa / banka hesabı",
            ["kasa_islem"]         = "kasa işlemi",
            ["mali_hareket"]       = "kasa/banka hareketi",
            ["muhasebe_fis_satir"] = "muhasebe fişi satırı",
            ["randevu"]            = "randevu",
            ["radyoloji_istem"]    = "radyoloji istemi",
            ["rol_sube"]           = "rol-şube ataması",
            ["stok_durum"]         = "depo stok bakiyesi",
            ["stok_izleme"]        = "stok hareketi",
            ["taraf_kullanici"]    = "kullanıcı bağı",
            ["uts_bildirim"]       = "ÜTS bildirimi",
        };

    /// <summary>Şema ön eki olsun olmasın çalışır ("public.belge_satir").</summary>
    public static string Coz(string tablo)
    {
        var ad = tablo.Replace("public.", "", StringComparison.OrdinalIgnoreCase);
        return Adlar.TryGetValue(ad, out var karsilik) ? karsilik : ad;
    }
}
