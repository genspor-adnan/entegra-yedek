using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Yönetim &gt; Ayarlar &gt; Genel. Firma geneli davranis ayarlari
/// (public.referans, beyaz listeli - bkz. AyarDeposu).
/// </summary>
public static class AyarUclari
{
    public sealed record AyarIstegi(string Deger);

    public static void AyarUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ayar").WithTags("Ayar").RequireAuthorization();

        grup.MapGet("/", async (
            BaglamCozucu cozucu, AyarDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            // OKUMA yetki istemez: bu ayarlar ekranlarin DAVRANISINI belirliyor
            //   (or. belge kartinin tarih kutusu siniri). Yetkisiz kullanici
            //   varsayilanla calissaydi, sunucunun kabul ettigi tarihi girmesine
            //   arayuz izin vermezdi. Yazma yine "ayar" yetkisine bagli.
            var baglam = await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(new { ayarlar = await depo.ListeleAsync(iptal), izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPut("/{anahtar}", async (
            string anahtar, AyarIstegi istek, BaglamCozucu cozucu, AyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);
            var liste = await depo.YazAsync(anahtar, istek?.Deger ?? "",
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, Ip(ctx)), iptal);
            return Results.Ok(new { ayarlar = liste, izlemeNo = baglam.IzlemeNo });
        });
    }

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}
