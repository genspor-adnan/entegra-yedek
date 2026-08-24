using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Stok kartinin "Stok Durumu" sekmesi (Ekranlar/stok_karti.html): depo bazli
/// miktar/rezerve/kullanilabilir + KPI seridi. Miktarlar SALT OKUNUR; yazilabilen
/// tek sey depo bazli min/max seviyedir (099).
/// </summary>
public static class StokDurumUclari
{
    public sealed record LimitIstegi(int DepoId, decimal? MinStok, decimal? MaxStok);

    public static void StokDurumUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart/stok/{stokId:long}/durum")
                      .WithTags("Kart").RequireAuthorization();

        grup.MapGet("/", async (
            long stokId, BaglamCozucu cozucu, StokDurumDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Gor);
            return Results.Ok(await depo.OkuAsync(stokId, iptal));
        });

        // Hareket dokumu ayri yol: /durum ozet, /hareket satir bazli (tarih araligi).
        //   Varsayilan aralik icinde bulunulan yilin 1 Ocak'i - BUGUN DAHIL
        //   (hesap ekstresiyle ayni kural: bitis gunu 23:59'a kadar sayilir).
        yol.MapGet("/api/kart/stok/{stokId:long}/hareket", async (
            long stokId, DateTime? bas, DateTime? bit, int? depoId,
            BaglamCozucu cozucu, StokDurumDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Gor);

            var baslangic = (bas ?? new DateTime(DateTime.Today.Year, 1, 1)).Date;
            var bitis = (bit ?? DateTime.Today).Date.AddDays(1);   // yarim acik aralik
            return Results.Ok(await depo.HareketAsync(stokId, baslangic, bitis, depoId, iptal));
        }).WithTags("Kart").RequireAuthorization();

        // Cikis belgesinde LOT SECIMI: stokta kalani olan lotlar (114). Cikista
        //   lot GIRILMEZ, mevcut lotlardan SECILIR - yoksa depoda olmayan bir
        //   lottan mal cikmis gorunur ve geri izlenebilirlik kirilir.
        yol.MapGet("/api/kart/stok/{stokId:long}/lot", async (
            long stokId, int? depoId, BaglamCozucu cozucu, StokDurumDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Gor);
            return Results.Ok(new { lotlar = await depo.LotlarAsync(stokId, depoId, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        }).WithTags("Kart").RequireAuthorization();

        // PAKET ICERIGI (124): belge kaleminde paket secilince satirlar buradan
        //   uretilir - istemci kendi basina "paket icerigi nedir" bilemez.
        yol.MapGet("/api/kart/stok/{stokId:long}/paket", async (
            long stokId, BaglamCozucu cozucu, StokDurumDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Gor);
            return Results.Ok(new { icerik = await depo.PaketIcerigiAsync(stokId, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        }).WithTags("Kart").RequireAuthorization();

        grup.MapPut("/limit", async (
            long stokId, LimitIstegi istek, BaglamCozucu cozucu, StokDurumDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Degistir);
            return Results.Ok(await depo.LimitYazAsync(stokId, istek.DepoId,
                istek.MinStok, istek.MaxStok,
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal));
        });
    }

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}
