using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authorization;

namespace Gentegre.Api.Uclar;

public static class KimlikUclari
{
    public static void KimlikUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kimlik").WithTags("Kimlik");

        grup.MapPost("/giris", [AllowAnonymous] async (
            GirisIstegi istek, KimlikServisi servis, HttpContext ctx, CancellationToken iptal)
            => Results.Ok(await servis.GirisAsync(istek, Ip(ctx), Istemci(ctx), iptal)));

        grup.MapPost("/yenile", [AllowAnonymous] async (
            YenileIstegi istek, KimlikServisi servis, HttpContext ctx, CancellationToken iptal)
            => Results.Ok(await servis.YenileAsync(istek.RefreshToken, Ip(ctx), Istemci(ctx), iptal)));

        grup.MapPost("/cikis", [AllowAnonymous] async (
            YenileIstegi istek, KimlikServisi servis, CancellationToken iptal) =>
        {
            await servis.CikisAsync(istek.RefreshToken, iptal);
            return Results.NoContent();
        });

        // Cok subeli kullanici calisma subesini degistirir: yeni access token,
        //   refresh ayni kalir. Yetkisiz sube -> 403.
        grup.MapPost("/sube", async (
            SubeSecIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var refresh = ctx.Request.Headers["X-Refresh-Token"].ToString();
            return Results.Ok(await servis.SubeSecAsync(baglam.KullaniciId, istek.SubeId, refresh, iptal));
        }).RequireAuthorization();

        // Kullanicinin giris / islem yapabilecegi subeler (rolunun subeleri - rol_sube, 234).
        grup.MapGet("/subeler", async (
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(new
            {
                aktifSubeId = baglam.SubeId,
                yazma = baglam.SubeYazma,
                subeler = baglam.Subeler
            });
        }).RequireAuthorization();

        grup.MapGet("/ben", async (
            BaglamCozucu cozucu, KullaniciDeposu kullanicilar, VeriKaynagi veri,
            KurumProfilDeposu kurum, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kullanici = await kullanicilar.IdIleBulAsync(baglam.KullaniciId, iptal)
                            ?? throw GentegreHatasi.Yetkisiz();
            var subeler = await kullanicilar.SubeleriAsync(baglam.KullaniciId, iptal);

            // Urun modu (215/489) - giris yanitindaki ile ayni kaynak: AKTIF
            //   SUBENIN profili. /ben acilista cagrildigi icin buradan da
            //   gelmezse istemci hep ERP sanirdi.
            var urunModu = await kurum.UrunModuAsync(baglam.SubeId ?? 0, iptal);

            return Results.Ok(new BenYaniti
            {
                Kullanici = new KullaniciOzeti
                {
                    Id = kullanici.TarafId,
                    Kod = kullanici.Kod,
                    Ad = kullanici.Ad,
                    RolId = kullanici.RolId,
                    RolAdi = kullanici.RolAdi,
                    Dil = kullanici.Dil,
                    YetkiSurumu = baglam.Yetkiler.YetkiSurumu,
                    SubeId = baglam.SubeId,
                    SubeYazma = baglam.SubeYazma,
                    Subeler = subeler,
                    UrunModu = urunModu,
                    // Acik moduller (359): menu ve rotalar bunlara gore suzulur.
                    Moduller = await kurum.AcikModullerAsync(baglam.SubeId ?? 0, iptal),
                    // Basvuruda sorulan hekim rolu (361/364) - aktif subeye gore.
                    HekimRolu = await kurum.HekimRoluAsync(baglam.SubeId ?? 0, iptal)
                },
                // Yetkisiz aksiyon HIC donmez (API §7).
                Aksiyonlar = baglam.Yetkiler.Tumu.Where(y => y.Tur == 1 && y.Gor)
                                   .Select(y => y.Kod).OrderBy(k => k).ToList(),
                Kaynaklar = baglam.Yetkiler.Tumu.Where(y => y.Tur == 0)
                                   .Select(y => new KaynakYetkisi(y.Kod, y.Gor, y.Ekle, y.Degistir, y.Sil))
                                   .OrderBy(k => k.Kod).ToList()
            });
        }).RequireAuthorization();

        // ILK PAROLA (anonim): otomatik acilan hesap sahibinin kendi parolasini
        //   belirlemesi. Kimlik kaniti TCKN son 4 (bkz. KimlikServisi).
        grup.MapPost("/ilk-parola", async (
            IlkParolaIstegi istek, KimlikServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            await servis.IlkParolaAsync(istek, Ip(ctx),
                ctx.Request.Headers.UserAgent.ToString(), iptal);
            return Results.Ok(new { mesaj = "Parolanız tanımlandı, giriş yapabilirsiniz." });
        }).AllowAnonymous();

        grup.MapPost("/parola", async (
            ParolaDegistirIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await servis.ParolaDegistirAsync(baglam.KullaniciId, istek, iptal);
            return Results.NoContent();
        }).RequireAuthorization();

        grup.MapPost("/dil", async (
            DilDegistirIstegi istek, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await servis.DilDegistirAsync(baglam.KullaniciId, istek, iptal);
            return Results.NoContent();
        }).RequireAuthorization();
    }

    // Giris/yenileme baglam COZULMEDEN once calisir (henuz kimlik yok) -
    //   IP'yi merkezi cozucuden dogrudan alir.
    private static string Ip(HttpContext ctx) => BaglamCozucu.IpCoz(ctx);

    private static string Istemci(HttpContext ctx)
        => ctx.Request.Headers.UserAgent.ToString();
}
