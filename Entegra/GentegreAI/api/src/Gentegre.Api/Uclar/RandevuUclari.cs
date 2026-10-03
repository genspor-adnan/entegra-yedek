using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Randevu Ayarlari > Bolumler sekmesi (251): randevu verilen bolumler, o
/// bolumdeki hekimler ve her ikisinin randevu duzeni. Kart/liste sozlesmesine
/// sigmayan bir MASTER-DETAIL ekran oldugu icin kendi uclari var.
/// </summary>
public static class RandevuUclari
{
    /// <summary>HekimIdleri: penceredeki isaretli doktorlar; bos = sablonu olmayan herkes.</summary>
    public sealed record BolumIstegi(int DepartmanId, bool BolumMu, int[]? HekimIdleri = null);

    public static void RandevuUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/randevu").WithTags("Randevu").RequireAuthorization();

        grup.MapGet("/bolumler", async (
            BaglamCozucu cozucu, RandevuAyarDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            return Results.Ok(await depo.AgacAsync(iptal));
        });

        // Departmani randevu bolumu yap / bolumlukten cikar - bolum listesi
        //   departman tablosunun bir suzgeci, ayri bir "bolum" tablosu yok.
        grup.MapPut("/bolum", async (
            BolumIstegi istek, BaglamCozucu cozucu, RandevuAyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            var eklenen = await depo.BolumIsaretleAsync(istek.DepartmanId, istek.BolumMu,
                baglam.KullaniciId, istek.HekimIdleri, iptal);
            return Results.Ok(new { tamam = true, eklenen });
        });

        // Bolumun doktorlari + aktif sablonu var mi (Calisma Sablonlari > Bolum).
        grup.MapGet("/bolum/{departmanId:int}/doktorlar", async (
            int departmanId, BaglamCozucu cozucu, RandevuAyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var liste = await depo.BolumDoktorlariAsync(departmanId, iptal);
            return Results.Ok(new { doktorlar = liste.Select(d => new { id = d.Id, ad = d.Ad, sablonVar = d.SablonVar }) });
        });
    }
}
