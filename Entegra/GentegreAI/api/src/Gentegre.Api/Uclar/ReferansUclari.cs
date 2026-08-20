using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>Il/Ilce/Ulke gibi statik referans listeleri (auth gerektirir, kart/liste disi).</summary>
public static class ReferansUclari
{
    public static void ReferansUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/referans").WithTags("Referans").RequireAuthorization();

        grup.MapGet("/yerler", async (ReferansDeposu depo, CancellationToken iptal) =>
            Results.Ok(await depo.YerlerAsync(iptal)));
    }
}
