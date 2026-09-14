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
                    // Zorunlu parola degisimi (674): /ben de tasir.
                    ParolaDegismeli = kullanici.ParolaDegismeli,
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
                // SINIRLI aksiyonlarin degeri (661): iskonto tavani gibi. Kod
                //   listede olsa da sinir 0 ise istemci islemi acmaz.
                AksiyonDegerleri = baglam.Yetkiler.Tumu
                                   .Where(y => y.Tur == 1 && y.Gor && y.Deger.Length > 0)
                                   .Select(y => new { y.Kod, D = baglam.Yetkiler.AksiyonDegeri(y.Kod) })
                                   .Where(x => x.D != 0m)
                                   .ToDictionary(x => x.Kod, x => x.D),
                Kaynaklar = baglam.Yetkiler.Tumu.Where(y => y.Tur == 0)
                                   .Select(y => new KaynakYetkisi(y.Kod, y.Gor, y.Ekle, y.Degistir, y.Sil))
                                   .OrderBy(k => k.Kod).ToList()
            });
        }).RequireAuthorization();

        // MARKA (anonim, 502): giris ekrani hangi urunun kapisi oldugunu
        //   OTURUM ACILMADAN bilmeli - "Gentegre" yazan sabit baslik, HBYS
        //   kurulumunda (GenoTIP AI) yanlis urun adi gosteriyordu. Mod
        //   kurulusun profilinden gelir (fn_urun_modu, 489); veritabanina
        //   ulasilamazsa istemci kendi yolundan (BASE_URL) tahmin eder.
        grup.MapGet("/marka", [AllowAnonymous] async (
            VeriKaynagi veri, CancellationToken iptal) =>
        {
            var mod = await veri.TekDegerAsync<int>(
                "select public.fn_urun_modu(0)::int", [], iptal);
            return Results.Ok(new { urunModu = mod });
        });

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

        // PERSONEL HESAPLARI (674): hesabi olmayana hesap acar, parolasiz
        //   hesaba varsayilan parolayi (kart id) yazar. Listeye elle girilmis
        //   ya da gocle gelmis personel bu ucla girise acilir - kart ekranindan
        //   tek tek gecmek 93 kisilik listede gercekci degil.
        //   `sifirla=true` DOLU parolalari da kart id'sine ceker (admin haric).
        grup.MapPost("/personel-hesap", async (
            int? tarafId, bool? sifirla, KimlikServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("personel", Gentegre.Cekirdek.Yetki.Islem.Degistir);
            var (acilan, parola) = await servis.PersonelHesaplariHazirlaAsync(
                tarafId, sifirla == true, iptal);
            return Results.Ok(new { acilan, parolaAtanan = parola });
        }).RequireAuthorization();

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

        // ------------------------------------- KULLANICI AYARLARI (669) ----
        // Hepsi KISININ KENDI hesabi uzerinde calisir; kullanici kimligi
        //   baglamdan gelir, istekten DEGIL - "kullaniciId" parametresi alan
        //   bir uc, baskasinin hesabini okumanin kapisi olurdu. Bu yuzden
        //   yetki de istemezler: kendi e-postasini gormek icin `kullanici`
        //   yetkisi aramak, herkesin yonetici olmasini gerektirirdi.

        grup.MapGet("/hesabim", async (
            KullaniciDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var h = await depo.HesapBilgisiAsync(baglam.KullaniciId, iptal);
            if (h is null) return Results.NotFound();
            return Results.Ok(new
            {
                unvan = h.Unvan, gorev = h.Gorev,
                eposta = h.Eposta, cepTel = h.CepTel,
                parolaTarihi = h.ParolaTarihi, sonGiris = h.SonGiris,
                sonGirisIp = h.SonGirisIp, hataliGiris = h.HataliGiris,
                totpAktif = h.TotpAktif,
                anaRol = h.AnaRol,
                // Ek roller (665): tek metin degil LISTE gider - istemci
                //   rozet cizecek, virgul ayirmakla ugrasmasin.
                ekRoller = h.EkRoller.Length == 0
                    ? Array.Empty<string>()
                    : h.EkRoller.Split(", ", StringSplitOptions.RemoveEmptyEntries),
            });
        }).RequireAuthorization();

        grup.MapPut("/iletisim", async (
            IletisimIstegi istek, KullaniciDeposu depo, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var eposta = (istek?.Eposta ?? "").Trim();
            var cep = (istek?.CepTel ?? "").Trim();
            if (eposta.Length > 120 || cep.Length > 30)
                throw GentegreHatasi.Dogrulama("E-posta ya da telefon çok uzun.");
            if (eposta.Length > 0 && (!eposta.Contains('@') || eposta.Contains(' ')))
                throw GentegreHatasi.Dogrulama("E-posta adresi geçersiz.");
            await depo.IletisimGuncelleAsync(baglam.KullaniciId, eposta, cep, iptal);
            return Results.NoContent();
        }).RequireAuthorization();

        grup.MapGet("/oturumlar", async (
            OturumDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var liste = await depo.AcikListeAsync(baglam.KullaniciId, iptal);
            var ip = Ip(ctx);
            var istemci = Istemci(ctx);
            return Results.Ok(liste.Select(o => new
            {
                id = o.Id, ip = o.Ip, istemci = o.Istemci,
                olusma = o.OlusmaTarihi, sonKullanim = o.SonKullanim,
                bitis = o.BitisTarihi, sube = o.SubeAdi,
                // "Bu cihaz" isareti IP + tarayici esinden cikarilir: access
                //   token oturum kimligi TASIMAZ (JWT'ye oturum id gomulmedi),
                //   bu yuzden kesin degil - etiket de "bu tarayıcı" der.
                buCihaz = o.Ip == ip && o.Istemci == istemci,
            }));
        }).RequireAuthorization();

        grup.MapPost("/oturumlar/{oturumId:long}/kapat", async (
            long oturumId, OturumDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Sahiplik kontrolu SQL'in icinde: baskasinin oturum kimligini
            //   yazan istek 0 satir kapatir ve 404 alir.
            var kapanan = await depo.KendiOturumunuKapatAsync(baglam.KullaniciId, oturumId, iptal);
            if (kapanan == 0) return Results.NotFound();
            return Results.Ok(new { kapanan });
        }).RequireAuthorization();

        grup.MapGet("/giris-gecmisi", async (
            KullaniciDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var liste = await depo.GirisGecmisiAsync(baglam.KullaniciId, 10, iptal);
            return Results.Ok(liste.Select(g => new
            {
                tarih = g.Tarih, basarili = g.Basarili, sebep = g.Sebep,
                ip = g.Ip, istemci = g.Istemci,
            }));
        }).RequireAuthorization();
    }

    // Giris/yenileme baglam COZULMEDEN once calisir (henuz kimlik yok) -
    //   IP'yi merkezi cozucuden dogrudan alir.
    private static string Ip(HttpContext ctx) => BaglamCozucu.IpCoz(ctx);

    private static string Istemci(HttpContext ctx)
        => ctx.Request.Headers.UserAgent.ToString();
}
