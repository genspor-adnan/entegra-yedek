using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ZAMANLI İŞLER (405) — listeyi katalog veriyor; burada yalnız "şimdi
/// çalıştır" var.
///
/// Elle çalıştırma, zamanı beklemeden denemek ve kaçan bir işi telafi etmek
/// için: işçiyle AYNI kilidi kullanır, iş zaten çalışıyorsa ikinci kez
/// başlatmaz.
/// </summary>
public static class ZamanliIsUclari
{
    public static void ZamanliIsUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/zamanli-is").WithTags("Zamanlı İş").RequireAuthorization();

        grup.MapPost("/{kod}/calistir", async (
            string kod, BaglamCozucu cozucu, ZamanliIsIscisi isci,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("zamanli_is", Islem.Degistir);

            var sonuc = await isci.ElleCalistirAsync(kod, iptal);
            return Results.Ok(new { kod, sonuc, izlemeNo = baglam.IzlemeNo });
        });
    }
}
