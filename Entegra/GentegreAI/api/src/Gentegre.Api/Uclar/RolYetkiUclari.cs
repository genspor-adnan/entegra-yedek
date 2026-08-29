using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>Rol kartı "Yetki Matrisi" sekmesi (kullanici: rol/yetki yonetim ekrani).</summary>
public static class RolYetkiUclari
{
    public sealed record YetkiSatiriIstegi(int YetkiId, bool Gor, bool Ekle, bool Degistir, bool Sil);
    public sealed record YetkiKaydetIstegi(IReadOnlyList<YetkiSatiriIstegi> Satirlar);
    public sealed record SubeKaydetIstegi(
        IReadOnlyList<KullaniciSubeDeposu.SubeIstegi> Satirlar);

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

        // Personel/kisi kartindan rol goster-degistir (kullanici). Kart id'si
        //   = kullanici id'si (taraf_kullanici.id -> taraf.id).
        var kartRol = yol.MapGroup("/api/kart/kullanici/{kartId:int}/rol")
                         .WithTags("Kart").RequireAuthorization();

        kartRol.MapGet("/", async (int kartId, BaglamCozucu cozucu,
            RolKullaniciDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            var d = await depo.KartRolOkuAsync(kartId, iptal);
            return Results.Ok(new
            {
                kullaniciVar = d.KullaniciVar, rolId = d.RolId, rolAdi = d.RolAdi,
                roller = d.Roller.Select(r => new { id = r.Id, ad = r.Ad }),
            });
        });

        kartRol.MapPut("/{rolId:int}", async (int kartId, int rolId, BaglamCozucu cozucu,
            RolKullaniciDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            await depo.KartRolDegistirAsync(kartId, rolId, baglam.Yazma, iptal);
            var d = await depo.KartRolOkuAsync(kartId, iptal);
            return Results.Ok(new
            {
                kullaniciVar = d.KullaniciVar, rolId = d.RolId, rolAdi = d.RolAdi,
                roller = d.Roller.Select(r => new { id = r.Id, ad = r.Ad }),
            });
        });

        // KULLANICI > SUBELER (kullanici: "fotonun altina yetkili subeleri
        //   getir, rolden kaldir tekrar"). Rol modul yetkisini, bu liste
        //   calisilabilen subeleri tasir.
        var kartSube = yol.MapGroup("/api/kart/kullanici/{kartId:int}/subeler")
                          .WithTags("Kart").RequireAuthorization();

        kartSube.MapGet("/", async (int kartId, BaglamCozucu cozucu,
            KullaniciSubeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(kartId, iptal));
        });

        kartSube.MapPut("/", async (int kartId, SubeKaydetIstegi istek,
            BaglamCozucu cozucu, KullaniciSubeDeposu depo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            await depo.KaydetAsync(kartId, istek.Satirlar, baglam.Yazma, iptal);
            return Results.Ok(await depo.ListeleAsync(kartId, iptal));
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
