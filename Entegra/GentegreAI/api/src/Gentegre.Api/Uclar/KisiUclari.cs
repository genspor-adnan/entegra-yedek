using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>Cari kartı "İlgili Kişiler" (mockup: Genel &gt; İlgili Kişiler tablosu).</summary>
public static class KisiUclari
{
    public sealed record KisiIstegi(string Unvan, string? Telefon, string? Eposta, bool Aktif = true,
        string? Gorev = null, short? Departman = null);

    public static void KisiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart/cari/{tarafId:long}/kisiler").WithTags("Kart").RequireAuthorization();

        grup.MapGet("/", async (
            long tarafId, BaglamCozucu cozucu, KisiDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(tarafId, iptal));
        });

        grup.MapPost("/", async (
            long tarafId, KisiIstegi istek, BaglamCozucu cozucu, KisiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Degistir);
            var liste = await depo.EkleAsync(tarafId, istek.Unvan, istek.Telefon, istek.Eposta,
                istek.Gorev, istek.Departman,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        grup.MapPut("/{kisiId:long}", async (
            long tarafId, long kisiId, KisiIstegi istek, BaglamCozucu cozucu, KisiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Degistir);
            var liste = await depo.GuncelleAsync(tarafId, kisiId, istek.Unvan, istek.Telefon,
                istek.Eposta, istek.Aktif, istek.Gorev, istek.Departman,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        // Var olan bir kisiyi bu cariye bagla (cari kartinda "Kişi Ekle" -> TarafArama).
        grup.MapPost("/{kisiId:long}/bagla", async (
            long tarafId, long kisiId, BaglamCozucu cozucu, KisiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Degistir);
            var liste = await depo.BaglaAsync(tarafId, kisiId,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        // Kisiyi bu cariden KOPAR (bag_id=null) - DB'den SILMEZ. Grid'deki "Sil" ikonu bunu cagirir.
        grup.MapPost("/{kisiId:long}/kopar", async (
            long tarafId, long kisiId, BaglamCozucu cozucu, KisiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Degistir);
            var liste = await depo.KoparAsync(tarafId, kisiId,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(liste);
        });

        grup.MapDelete("/{kisiId:long}", async (
            long tarafId, long kisiId, BaglamCozucu cozucu, KisiDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Sil);
            await depo.SilAsync(tarafId, kisiId, new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.NoContent();
        });
    }

    private static string Ip(HttpContext ctx) => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}
