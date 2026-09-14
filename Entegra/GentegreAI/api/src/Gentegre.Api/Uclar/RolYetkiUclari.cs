using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>Rol kartı "Yetki Matrisi" sekmesi (kullanici: rol/yetki yonetim ekrani).</summary>
public static class RolYetkiUclari
{
    public sealed record YetkiSatiriIstegi(int YetkiId, bool Gor, bool Ekle, bool Degistir, bool Sil,
        /// <summary>Sayisal sinir (661) - yalniz `deger_alir` yetkilerde islenir.</summary>
        string Deger = "");
    public sealed record YetkiKaydetIstegi(IReadOnlyList<YetkiSatiriIstegi> Satirlar);
    public sealed record SubeKaydetIstegi(
        IReadOnlyList<KullaniciSubeDeposu.SubeIstegi> Satirlar);
    /// <summary>Kartin EK rolleri (665) - ana rol bu listede DEGILDIR.</summary>
    public sealed record EkRollerIstegi(IReadOnlyList<int>? RolIdleri);

    public static void RolYetkiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart/rol/{rolId:int}/yetkiler").WithTags("Kart").RequireAuthorization();

        grup.MapGet("/", async (
            int rolId, BaglamCozucu cozucu, RolYetkiDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            // Yetki matrisi AKTIF SUBENIN urun moduna gore suzulur (492).
            return Results.Ok(await depo.ListeleAsync(rolId, baglam.SubeId ?? 0, iptal));
        });

        grup.MapPut("/", async (
            int rolId, YetkiKaydetIstegi istek, BaglamCozucu cozucu, RolYetkiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            var satirlar = istek.Satirlar
                .Select(s => new YetkiGuncelleIstegi(s.YetkiId, s.Gor, s.Ekle, s.Degistir, s.Sil, s.Deger))
                .ToList();
            var liste = await depo.KaydetAsync(rolId, satirlar,
                baglam.Yazma, baglam.SubeId ?? 0, iptal);
            return Results.Ok(liste);
        });

        // Rol > Kullanicilar sekmesi (kullanici: "rollerin icine kullanici
        //   ekleyebileyim"). COK ROLLU (665): ekleme kisinin ana rolunu EZMEZ -
        //   yer tutucu roldeyse ana rol olur, degilse EK rol eklenir; cikarma
        //   ek rolu siler, ana rol cikariliyorsa ek rollerden biri ana olur.
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
                ekRolIdleri = d.EkRolIdleri,
            });
        });

        // EK ROLLER (665): kartta cok secimli liste - tek istekte tamami yazilir.
        //   Tek tek ekle/cikar ucu, yarim kalan bir duzenlemede kisiyi istenmeyen
        //   rol kumesiyle birakirdi.
        kartRol.MapPut("/ek", async (int kartId, EkRollerIstegi istek, BaglamCozucu cozucu,
            RolKullaniciDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Degistir);
            await depo.KartEkRollerKaydetAsync(kartId, istek.RolIdleri ?? [], baglam.Yazma, iptal);
            var d = await depo.KartRolOkuAsync(kartId, iptal);
            return Results.Ok(new
            {
                kullaniciVar = d.KullaniciVar, rolId = d.RolId, rolAdi = d.RolAdi,
                roller = d.Roller.Select(r => new { id = r.Id, ad = r.Ad }),
                ekRolIdleri = d.EkRolIdleri,
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
                ekRolIdleri = d.EkRolIdleri,
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
