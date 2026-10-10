using System.Text.Json;
using ClosedXML.Excel;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇIKTI MENÜSÜ "Gönder › Excel" ucu (kullanıcı 10.10.2026, İskonto İcmali'nde
/// test). Tarayıcının kendi başına yapamadığı tek iş: gerçek <c>.xlsx</c>
/// (ClosedXML). Belgeyi ekran zaten çizmiştir - sunucu yeni veri OKUMAZ,
/// yalnız istemcinin gönderdiği tabloyu biçimlendirir; bu yüzden ekran
/// yetkisi değil oturum yeter (veri ekrana gelmişse yetki zaten verilmiştir).
/// </summary>
public static class DisaAktarUclari
{
    /// <summary>Excel tablosu: satırlar sırayla yazılır; sayı hücreleri sayı kalır.</summary>
    public sealed record ExcelIstegi(string? DosyaAdi, string? SayfaAdi, JsonElement[][]? Satirlar, int[]? KalinSatirlar);

    public static void DisaAktarUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/disa-aktar").WithTags("Dışa Aktar").RequireAuthorization();

        grup.MapPost("/excel", async (ExcelIstegi istek, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            var satirlar = istek.Satirlar ?? [];
            if (satirlar.Length == 0) throw GentegreHatasi.IsKurali("Aktarılacak satır yok.");
            if (satirlar.Length > 50_000) throw GentegreHatasi.IsKurali("En çok 50.000 satır aktarılabilir.");

            using var kitap = new XLWorkbook();
            // Excel sayfa adı: en çok 31 karakter, []:*?/\ yasak.
            var ad = new string((istek.SayfaAdi ?? "İcmal").Where(c => !"[]:*?/\\".Contains(c)).ToArray());
            var sayfa = kitap.Worksheets.Add(string.IsNullOrWhiteSpace(ad) ? "İcmal" : ad[..Math.Min(31, ad.Length)]);
            for (var r = 0; r < satirlar.Length; r++)
                for (var c = 0; c < satirlar[r].Length; c++)
                {
                    var hucre = sayfa.Cell(r + 1, c + 1);
                    var d = satirlar[r][c];
                    switch (d.ValueKind)
                    {
                        case JsonValueKind.Number:
                            hucre.Value = d.GetDecimal();
                            hucre.Style.NumberFormat.Format = d.GetDecimal() % 1 == 0 ? "#,##0" : "#,##0.00";
                            break;
                        case JsonValueKind.String: hucre.Value = d.GetString(); break;
                    }
                }
            foreach (var k in istek.KalinSatirlar ?? [])
                if (k >= 0 && k < satirlar.Length) sayfa.Row(k + 1).Style.Font.Bold = true;
            sayfa.Columns().AdjustToContents(8, 60);

            using var akis = new MemoryStream();
            kitap.SaveAs(akis);
            var dosya = DosyaAdi(istek.DosyaAdi, "icmal") + ".xlsx";
            return Results.File(akis.ToArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", dosya);
        });
    }

    /// <summary>Dosya adından Windows'ta yasak karakterleri atar.</summary>
    private static string DosyaAdi(string? ad, string varsayilan)
    {
        var temiz = new string((ad ?? "").Where(c => !"/\\:*?\"<>|".Contains(c)).ToArray()).Trim();
        return temiz.Length == 0 ? varsayilan : temiz;
    }
}
