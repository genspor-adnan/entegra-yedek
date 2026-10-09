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

        // Alan/opsiyon yardim metni (public.help, db/103). "?" ikonu bunu ceker.
        //   Yetki ISTEMEZ: yardim metni gizli veri degil, ekranin parcasi.
        yol.MapGet("/api/yardim/{anahtar}", async (
            string anahtar, BaglamCozucu cozucu, AyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            var y = await depo.YardimAsync(anahtar, iptal);
            return y is null ? Results.NotFound() : Results.Ok(y);
        }).WithTags("Ayar").RequireAuthorization();

        grup.MapPut("/{anahtar}", async (
            string anahtar, AyarIstegi istek, BaglamCozucu cozucu, AyarDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // KAYIT KABUL AYARLARI KENDİ KODUYLA (1003): `kayit_kabul.ayar`
            //   yalnız o sayfanın anahtarlarını yazar; genel `ayar` kapısını
            //   ona açmak bütün kurum ayarlarını açmak olurdu.
            //   Kasa Ayarları da aynı desen (1004 aşama 2): `kasa.finans.ayar`.
            var ekranKodu = EkranKodlari.KayitKabulAyarAnahtarlari.Contains(anahtar) ? "kayit_kabul.ayar"
                          : EkranKodlari.AyarAnahtariKodu.GetValueOrDefault(anahtar);
            if (!(ekranKodu is not null && baglam.Yetkiler.Var(ekranKodu, Islem.Degistir)))
                baglam.YetkiIste("ayar", Islem.Degistir);
            else baglam.YazmaIste();
            var liste = await depo.YazAsync(anahtar, istek?.Deger ?? "",
                baglam.Yazma, iptal);
            return Results.Ok(new { ayarlar = liste, izlemeNo = baglam.IzlemeNo });
        });
    }

}
