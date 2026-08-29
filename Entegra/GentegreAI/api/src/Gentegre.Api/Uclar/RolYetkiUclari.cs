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
                baglam.Yazma, iptal);
            return Results.Ok(liste);
        });

        // Rol > Kullanicilar sekmesi (kullanici: "rollerin icine kullanici
        //   ekleyebileyim"). Bir kullanici TEK role bagli - ekleme = rolunu
        //   bu role cevirme, cikarma = varsayilan sistem roluna geri tasima.
        var kul = yol.MapGroup("/api/kart/rol/{rolId:int}/kullanicilar")
                     .WithTags("Kart").RequireAuthorization();

        kul.MapGet("/", async (int rolId, BaglamCozucu cozucu, RolKullaniciDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(rolId, iptal));
        });

        kul.MapGet("/adaylar", async (int rolId, string? arama, BaglamCozucu cozucu,
            RolKullaniciDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            return Results.Ok(await depo.AdaylarAsync(rolId, arama, iptal));
        });

        kul.MapPost("/{kullaniciId:int}", async (int rolId, int kullaniciId,
            BaglamCozucu cozucu, RolKullaniciDeposu depo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            await depo.AtaAsync(rolId, kullaniciId, baglam.Yazma, iptal);
            return Results.Ok(await depo.ListeleAsync(rolId, iptal));
        });

        kul.MapDelete("/{kullaniciId:int}", async (int rolId, int kullaniciId,
            BaglamCozucu cozucu, RolKullaniciDeposu depo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            var mesaj = await depo.CikarAsync(rolId, kullaniciId, baglam.Yazma, iptal);
            return Results.Ok(new { mesaj, kullanicilar = await depo.ListeleAsync(rolId, iptal) });
        });
    }

    private static string Ip(HttpContext ctx) => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}
