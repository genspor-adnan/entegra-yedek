using ClosedXML.Excel;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Servisler;

/// <summary>
/// EXCEL (.xlsx) OKUMA / YAZMA - jenerik, ekran bilmez.
///
/// Iceri alma ekran basina degil TEK motor uzerinden yurur (fiyat listesi
/// bugun, stok/cari yarin): burasi yalniz "dosya -> baslikli satirlar" ve
/// "baslikli satirlar -> dosya" cevirimidir. Alan dogrulama/cozumleme
/// cagiranin isidir (katalog metasi + DegerCevirici).
///
/// Kurallar:
///  - YALNIZ ILK SAYFA okunur. Musteri dosyalari cok sayfali geliyor (ornek:
///    SONOMED dokumu ISLEMADI + FIYATLAR); hangi sayfanin istendigini
///    kestirmeye calismak sessiz yanlis veri almaktir - sablon tek sayfadir.
///  - 1. satir BASLIKTIR. Esleme baslik ADIYLA yapilir, sutun sirasi ve
///    fazladan sutunlar onemsizdir (kullanici sutun tasisa da calisir).
///  - Baslik normalizasyonu: kirp + TR-buyuk (I/i sorununa girmemek icin
///    buyuk harf), ic bosluklar tekle.
/// </summary>
public static class ExcelOkuma
{
    /// <summary>Satir siniri - bunun ustunde dosya buyuk olasilikla yanlis dosyadir.</summary>
    public const int AzamiSatir = 50_000;

    /// <summary>Dosya boyutu siniri (10 MB).</summary>
    public const long AzamiBoyut = 10 * 1024 * 1024;

    public sealed record Sayfa(
        IReadOnlyList<string> Basliklar,
        // Satir: normalize baslik -> hucre metni. Excel'in satir numarasi
        //   (1-tabanli, baslik dahil) hata raporunda kullanilir.
        IReadOnlyList<(int SatirNo, Dictionary<string, string> Hucreler)> Satirlar);

    /// <summary>Baslik esleme anahtari: kirp + tekli bosluk + TR buyuk harf.</summary>
    public static string BaslikAnahtari(string ham)
        => string.Join(' ', ham.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries))
                 .ToUpper(new System.Globalization.CultureInfo("tr-TR"));

    public static Sayfa Oku(Stream akis)
    {
        XLWorkbook kitap;
        try
        {
            kitap = new XLWorkbook(akis);
        }
        catch (Exception)
        {
            throw GentegreHatasi.Dogrulama(
                "Dosya okunamadı; geçerli bir Excel (.xlsx) dosyası olmalı.",
                new AlanHatasi("dosya", "Geçerli .xlsx değil."));
        }

        using (kitap)
        {
            var sayfa = kitap.Worksheets.FirstOrDefault()
                ?? throw GentegreHatasi.Dogrulama("Dosyada sayfa yok.",
                       new AlanHatasi("dosya", "Boş çalışma kitabı."));

            var kullanilan = sayfa.RangeUsed();
            if (kullanilan is null)
                throw GentegreHatasi.Dogrulama("Sayfa boş.",
                    new AlanHatasi("dosya", "İlk sayfada veri yok."));

            // --- basliklar --------------------------------------------------
            var basliklar = new List<string>();
            var kolonAnahtari = new Dictionary<int, string>();   // sutun no -> normalize baslik
            foreach (var hucre in kullanilan.FirstRow().Cells())
            {
                var metin = HucreMetni(hucre);
                if (metin.Length == 0) continue;                 // bassiz sutun yok sayilir
                basliklar.Add(metin);
                // Ayni baslik iki kez gecerse ILKI kazanir - sonrakini almak
                //   hangi sutunun okundugunu belirsizlestirir.
                var anahtar = BaslikAnahtari(metin);
                if (!kolonAnahtari.ContainsValue(anahtar))
                    kolonAnahtari[hucre.Address.ColumnNumber] = anahtar;
            }
            if (basliklar.Count == 0)
                throw GentegreHatasi.Dogrulama("İlk satırda başlık yok.",
                    new AlanHatasi("dosya", "1. satır sütun başlıklarını taşımalı."));

            // --- satirlar ---------------------------------------------------
            var satirlar = new List<(int, Dictionary<string, string>)>();
            foreach (var satir in kullanilan.Rows().Skip(1))
            {
                var hucreler = new Dictionary<string, string>(StringComparer.Ordinal);
                var doluMu = false;
                foreach (var (kolon, anahtar) in kolonAnahtari)
                {
                    var deger = HucreMetni(satir.Cell(kolon));
                    hucreler[anahtar] = deger;
                    if (deger.Length > 0) doluMu = true;
                }
                if (!doluMu) continue;                           // tamamen bos satir atlanir
                satirlar.Add((satir.RowNumber(), hucreler));

                if (satirlar.Count > AzamiSatir)
                    throw GentegreHatasi.Dogrulama(
                        $"Dosya {AzamiSatir:n0} satırdan büyük; bu büyüklük tek seferde alınamaz.",
                        new AlanHatasi("dosya", "Satır sınırı aşıldı."));
            }

            return new Sayfa(basliklar, satirlar);
        }
    }

    /// <summary>
    /// Hucreyi GUVENLI metne cevirir. `GetFormattedString` binlik ayracli/
    /// bicimli metin dondurebiliyor; sayi ve tarih HAM degerden yazilir ki
    /// cagiranin ayristiricisi (DegerCevirici, invariant nokta) sasirmasin.
    /// </summary>
    private static string HucreMetni(IXLCell hucre)
    {
        if (hucre.IsEmpty()) return "";
        var v = hucre.Value;
        if (v.IsNumber)
            return v.GetNumber().ToString("0.############",
                System.Globalization.CultureInfo.InvariantCulture);
        if (v.IsDateTime)
            return v.GetDateTime().ToString("yyyy-MM-dd");
        if (v.IsBoolean)
            return v.GetBoolean() ? "1" : "0";
        var metin = v.ToString() ?? "";
        // Eski MSSQL dokumlerinde bos hucre "NULL" metniyle geliyor (ornek
        //   dosyada dogrulandi) - bos sayilir.
        return metin.Trim() is "NULL" or "null" ? "" : metin.Trim();
    }

    // ------------------------------------------------------------- yazma ----
    /// <summary>
    /// Baslik + satirlardan .xlsx uretir (sablon ve dolu disa aktarim).
    /// Baslik satiri kalin ve dondurulmus; sutunlar icerige gore genisler.
    /// </summary>
    public static byte[] Yaz(string sayfaAdi, IReadOnlyList<string> basliklar,
                             IEnumerable<IReadOnlyList<object?>> satirlar)
    {
        using var kitap = new XLWorkbook();
        var sayfa = kitap.Worksheets.Add(sayfaAdi);

        for (var k = 0; k < basliklar.Count; k++)
        {
            var hucre = sayfa.Cell(1, k + 1);
            hucre.Value = basliklar[k];
            hucre.Style.Font.Bold = true;
        }
        sayfa.SheetView.FreezeRows(1);

        var s = 2;
        foreach (var satir in satirlar)
        {
            for (var k = 0; k < satir.Count && k < basliklar.Count; k++)
            {
                var deger = satir[k];
                var hucre = sayfa.Cell(s, k + 1);
                switch (deger)
                {
                    case null: break;
                    case decimal d: hucre.Value = d; break;
                    case int i: hucre.Value = i; break;
                    case long l: hucre.Value = l; break;
                    case double db: hucre.Value = db; break;
                    case DateTime t: hucre.Value = t; hucre.Style.DateFormat.Format = "dd.MM.yyyy"; break;
                    default: hucre.Value = deger.ToString(); break;
                }
            }
            s++;
        }

        sayfa.Columns(1, basliklar.Count).AdjustToContents(1, Math.Min(s, 50));

        using var bellek = new MemoryStream();
        kitap.SaveAs(bellek);
        return bellek.ToArray();
    }
}
