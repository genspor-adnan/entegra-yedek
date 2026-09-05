using Gentegre.Api.AraKatman;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KULLANICI TERCIHLERI (397): menu favorileri gibi kullaniciya ait arayuz
/// tercihleri. YETKI ISTEMEZ - kullanici kendi tercihini okur/yazar, baska
/// kullanicininkine erisemez (kullanici id daima jetondan gelir, istekten
/// DEGIL).
/// </summary>
public static class TercihUclari
{
    public sealed record TercihIstegi(string Deger);

    public static void TercihUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/tercih").WithTags("Tercih").RequireAuthorization();

        grup.MapGet("/", async (
            BaglamCozucu cozucu, TercihDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(new { tercihler = await depo.OkuAsync(baglam.KullaniciId, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPut("/{anahtar}", async (
            string anahtar, TercihIstegi istek, BaglamCozucu cozucu, TercihDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var deger = istek?.Deger ?? "";

            // Beyaz liste + uzunluk siniri: tercih tablosu istemcinin serbest
            //   deposu degil. Bilinmeyen anahtar 400 (kaynak/alan dogrulamasinin
            //   ayni kurali), asiri buyuk deger de reddedilir.
            if (!TercihDeposu.Anahtarlar.Contains(anahtar))
                return Results.BadRequest(new { hata = "DOGRULAMA",
                                                mesaj = $"Bilinmeyen tercih: {anahtar}",
                                                izlemeNo = baglam.IzlemeNo });
            if (deger.Length > TercihDeposu.EnFazlaUzunluk)
                return Results.BadRequest(new { hata = "DOGRULAMA",
                                                mesaj = "Tercih değeri çok uzun.",
                                                izlemeNo = baglam.IzlemeNo });

            await depo.YazAsync(baglam.KullaniciId, anahtar, deger, iptal);
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });
    }
}
