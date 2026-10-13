namespace Gentegre.Aktarim.Ajan;

/// <summary>
/// Kök tabloya bağlı alt tablo. Sunucu (fn_aktar_*) pakette olmayan alt satırı SİLER:
/// kök hangi sebeple gönderilirse gönderilsin bütün alt satırlarıyla gider.
/// </summary>
/// <param name="UstSorgu">Alt satır kimliklerinden ({0}) kök kimliklerini veren SELECT.</param>
/// <param name="AltFiltre">Kök kimliklerine ({0}) bağlı alt satırların WHERE'i.</param>
public sealed record AltTablo(string Tablo, string UstSorgu, string AltFiltre)
{
    public static AltTablo Basit(string tablo, string ustKolon) => new(tablo,
        $"SELECT [{ustKolon}] FROM dbo.[{tablo}] WHERE [ID] IN ({{0}})",
        $"[{ustKolon}] IN ({{0}})");
}

/// <param name="Sira">Sunucu adım sırası (fn_aktarim_adimlari) - gönderim de bu sırayla.</param>
/// <param name="Kok">Kök tablo; birincil anahtarı Delphi'den okunur.</param>
/// <param name="Tarih">Hareket tablosu: tam yüklemede bu kolon &gt;= hareket_baslangic.</param>
/// <param name="TamSira">Tam yüklemede kök sırası (bağlı kişi üst cariden sonra gelsin).</param>
/// <param name="Sayfa">Paket başına kök sayısı.</param>
public sealed record Grup(int Sira, string Kok, AltTablo[] Altlar, string? Tarih = null, string? TamSira = null, int Sayfa = 500)
{
    public IEnumerable<string> Tablolar => Altlar.Select(a => a.Tablo).Prepend(Kok);
}

public static class Toplamlar
{
    public static readonly Grup[] Gruplar =
    [
        new(1, "DEPOLAR", []),
        new(2, "DOVIZ", [], Sayfa: 5000),
        new(3, "SRMMERKEZI", []),
        new(4, "REHBER",
        [
            AltTablo.Basit("REHBERILETISIM", "REHBERID"),
            // REHBERBILGI: YERI 2 -> YER_ID cari, YERI 1 -> YER_ID cari adresi.
            new("REHBERBILGI",
                "SELECT CASE WHEN b.[YERI] = 2 THEN b.[YER_ID] ELSE i.[REHBERID] END FROM dbo.[REHBERBILGI] b " +
                "LEFT JOIN dbo.[REHBERILETISIM] i ON b.[YERI] = 1 AND i.[ID] = b.[YER_ID] " +
                "WHERE b.[YERI] IN (1, 2) AND b.[ID] IN ({0})",
                "([YERI] = 2 AND [YER_ID] IN ({0})) OR ([YERI] = 1 AND [YER_ID] IN " +
                "(SELECT i.[ID] FROM dbo.[REHBERILETISIM] i WHERE i.[REHBERID] IN ({0})))"),
        ], TamSira: "CASE WHEN ISNULL([BAGID], 0) > 0 THEN 1 ELSE 0 END, [ID]"),
        new(5, "PROJELER", []),
        new(6, "MASRAFGELIR", [AltTablo.Basit("FIYATLAR", "HIZMETID")]),
        new(7, "STOKLAR",
        [
            AltTablo.Basit("STOKBARKOD", "STOKID"),
            AltTablo.Basit("STOKFIYAT", "STOKID"),
            AltTablo.Basit("STOKSERILOT", "STOKID"),
        ]),
        new(8, "KASALAR", []),
        new(8, "BANKAHESAPLAR", []),
        new(8, "POS", []),            // banka hesabından sonra
        new(8, "KREDIKARTI", []),
        new(8, "KREDILER", []),
        new(9, "LOKASYON", []),
        // Bütün reçeteler tek pakette: yarı mamul satırı başka reçeteye bağlanır.
        new(10, "URETIMRECETE",
        [
            AltTablo.Basit("URETIMRECETEDETAY", "URETIMRECETEID"),
            AltTablo.Basit("URETIMRECETEOPR", "URETIMRECETEID"),
        ], Sayfa: 5000),
        new(11, "STOKDURUM", [], Sayfa: 5000),
        new(12, "FATBASLIK",
        [
            AltTablo.Basit("FATURA", "FATBASID"),
            AltTablo.Basit("STOKIZLEME", "BASLIKID"),
        ], Tarih: "FATURATARIH", Sayfa: 200),
        new(13, "KASA", [], Tarih: "ISLEMTARIHI", Sayfa: 2000),
    ];
}
