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
    public sealed record AyarIstegi(
        int DepartmanId, int? HekimId, string? BaslangicSaat, string? BitisSaat,
        string? OgleBaslangic, string? OgleBitis, int? SlotDk, int? VarsayilanSure,
        string? CalismaGunleri, short? Aktif, string? Aciklama);

    public sealed record BolumIstegi(int DepartmanId, bool BolumMu);

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

        grup.MapPut("/bolum-ayar", async (
            AyarIstegi istek, BaglamCozucu cozucu, RandevuAyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            await depo.YazAsync(new RandevuAyarSatiri(
                null, istek.DepartmanId, istek.HekimId, "",
                istek.BaslangicSaat ?? "", istek.BitisSaat ?? "",
                istek.OgleBaslangic ?? "", istek.OgleBitis ?? "",
                istek.SlotDk, istek.VarsayilanSure, istek.CalismaGunleri ?? "",
                istek.Aktif ?? 1, istek.Aciklama ?? ""), baglam.KullaniciId, iptal);
            return Results.Ok(new { tamam = true });
        });

        // Departmani randevu bolumu yap / bolumlukten cikar - bolum listesi
        //   departman tablosunun bir suzgeci, ayri bir "bolum" tablosu yok.
        grup.MapPut("/bolum", async (
            BolumIstegi istek, BaglamCozucu cozucu, RandevuAyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Degistir);
            await depo.BolumIsaretleAsync(istek.DepartmanId, istek.BolumMu, iptal);
            return Results.Ok(new { tamam = true });
        });
    }
}
