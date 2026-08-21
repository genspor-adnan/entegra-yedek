using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>Rol kartı "Yetki Matrisi" sekmesi (kullanici: rol/yetki yonetim ekrani).</summary>
public static class RolYetkiUclari
{
    public sealed record YetkiSatiriIstegi(int YetkiId, bool Gor, bool Ekle, bool Degistir, bool Sil);
    public sealed record YetkiKaydetIstegi(IReadOnlyList<YetkiSatiriIstegi> Satirlar);

    public static void RolYetkiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart/rol/{rolId:int}/yetkiler").WithTags("Kart").RequireAuthorization();

        grup.MapGet("/", async (
            int rolId, BaglamCozucu cozucu, RolYetkiDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(rolId, iptal));
        });

        grup.MapPut("/", async (
            int rolId, YetkiKaydetIstegi istek, BaglamCozucu cozucu, RolYetkiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            var satirlar = istek.Satirlar
                .Select(s => new YetkiGuncelleIstegi(s.YetkiId, s.Gor, s.Ekle, s.Degistir, s.Sil))
                .ToList();
            var liste = await depo.KaydetAsync(rolId, satirlar,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });
    }

    private static string Ip(HttpContext ctx) => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}
